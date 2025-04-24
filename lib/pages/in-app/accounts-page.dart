import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/account.dart';
import '../../models/transaction.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  List<Map<String, dynamic>> bankAccounts = [];
  Map<String, List<Map<String, dynamic>>> incomeMap = {};

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    String? accountDataListJson = prefs.getString('accountDataList');
    String? incomeMapJson = prefs.getString('incomeMap');

    if (accountDataListJson != null) {
      List<Map<String, dynamic>> updatedAccounts =
      List<Map<String, dynamic>>.from(jsonDecode(accountDataListJson));

      setState(() {
        bankAccounts = updatedAccounts; // Refresh UI instantly
      });
    }

    if (incomeMapJson != null) {
      final decoded = json.decode(incomeMapJson) as Map<String, dynamic>;

      incomeMap = decoded.map<String, List<Map<String, dynamic>>>(
            (key, value) => MapEntry(
          key,
          List<Map<String, dynamic>>.from(value),
        ),
      );
    }

  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accountDataList', jsonEncode(bankAccounts));
  }

  void _showBankDialog({int? editIndex}) {
    bool isEditing = editIndex != null;
    Map<String, dynamic>? existingData = isEditing ? bankAccounts[editIndex] : null;

    TextEditingController bankNameController = TextEditingController(text: existingData?['bankName'] ?? "");
    TextEditingController creditLimitController = TextEditingController(text: existingData?['creditLimit']?.toString() ?? "");
    String selectedCurrency = existingData?['currency'] ?? "USD";
    bool isDebit = existingData?['isDebit'] ?? false;
    int selectedCutoffDate = existingData?['cutoffDate'] ?? 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? "Edit Bank Account" : "Add Bank Account"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: bankNameController,
                    decoration: InputDecoration(labelText: "Bank Name"),
                  ),
                  DropdownButton<String>(
                    value: selectedCurrency,
                    items: ["USD", "EUR", "TRY"]
                        .map((String currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCurrency = value!;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isDebit ? "Debit Account" : "Credit Account"),
                      Switch(
                        value: isDebit,
                        onChanged: (value) {
                          setState(() {
                            isDebit = value;
                          });
                        },
                      ),
                    ],
                  ),
                  if (!isDebit) ...[
                    TextField(
                      controller: creditLimitController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Credit Limit"),
                    ),
                    DropdownButton<int>(
                      value: selectedCutoffDate,
                      items: List.generate(28, (index) => index + 1)
                          .map((day) => DropdownMenuItem(
                        value: day,
                        child: Text("Cutoff Date: $day"),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCutoffDate = value!;
                        });
                      },
                    ),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    String bankName = bankNameController.text.trim();
                    double creditLimit = isDebit ? 0.0 : (double.tryParse(creditLimitController.text) ?? 0.0);

                    if (bankName.isNotEmpty) {
                      final bankData = {
                        'bankId': isEditing ? existingData!['bankId'] : bankAccounts.length + 1,
                        'bankName': bankName,
                        'currency': selectedCurrency,
                        'isDebit': isDebit,
                        'creditLimit': creditLimit,
                        'cutoffDate': selectedCutoffDate,
                        'accounts': [],
                      };

                      if (isEditing) {
                        bankAccounts[editIndex!] = bankData; // Update existing
                      } else {
                        bankAccounts.add(bankData); // Add new
                      }

                      _saveAccounts();
                      _loadAccounts(); // Ensure full page refresh after updating
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(isEditing ? "Update" : "Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteAccount(int index) {
    setState(() {
      bankAccounts.removeAt(index);
      _saveAccounts();
    });
  }

  Future<void> _addAccountToBank(int bankId, Account account) async {
    try {
      setState(() {
        final accountIndex = bankAccounts.indexWhere((acc) => acc['bankId'] == bankId);
        if (accountIndex != -1) {
          bankAccounts[accountIndex]['accounts'] ??= [];
          bankAccounts[accountIndex]['accounts'].add(account.toJson());
        }
      });
      await _saveAccounts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add transaction: $e")),
      );
    }
  }

  void _showEditTransactionDialog(int accountId, Transaction transaction) {
    print("accountID == ${accountId}, transaction title == ${transaction.title}");
    final account = bankAccounts.firstWhere((acc) => acc['bankId'] == accountId);

    TextEditingController amountController = TextEditingController(
        text: transaction.amount.abs().toString());
    TextEditingController titleController = TextEditingController(
        text: transaction.title);
    TextEditingController descriptionController = TextEditingController(
        text: transaction.description);
    DateTime selectedDate = transaction.date;
    bool isSurplus = transaction.isSurplus;
    String selectedCategory = transaction.category;
    String selectedSubcategory = transaction.subcategory;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Transaction"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: "Amount"),
                    ),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: "Title"),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: "Description"),
                    ),
                    ListTile(
                      title: Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() => selectedDate = picked);
                        }
                      },
                    ),
                    DropdownButton<String>(
                      value: selectedCategory,
                      items: ['Income', 'Expense', 'Transfer']
                          .map((String category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                          isSurplus = value == 'Income';
                        });
                      },
                    ),
                    DropdownButton<String>(
                      value: selectedSubcategory,
                      items: _getSubcategories(selectedCategory)
                          .map((String subcat) => DropdownMenuItem(
                        value: subcat,
                        child: Text(subcat),
                      ))
                          .toList(),
                      onChanged: (value) => setState(() => selectedSubcategory = value!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null && titleController.text.isNotEmpty) {
                      final updatedTransaction = transaction.copyWith(
                        date: selectedDate,
                        amount: isSurplus ? amount : -amount,
                        currency: account['currency'],
                        subcategory: selectedSubcategory,
                        category: selectedCategory,
                        title: titleController.text,
                        description: descriptionController.text,
                        isSurplus: isSurplus,
                      );

                      await _updateTransactionInAccount(accountId, transaction, updatedTransaction);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateTransactionInAccount(int accountId, Transaction oldTransaction, Transaction newTransaction) async {
    setState(() {
      final accountIndex = bankAccounts.indexWhere((acc) => acc['id'] == accountId);
      if (accountIndex != -1) {
        final transactions = List<dynamic>.from(bankAccounts[accountIndex]['transactions']);
        final transactionIndex = transactions.indexWhere(
                (t) => Transaction.fromJson(t).transactionId == oldTransaction.transactionId
        );

        if (transactionIndex != -1) {
          transactions[transactionIndex] = newTransaction.toJson();
          bankAccounts[accountIndex]['transactions'] = transactions;
        }
      }
    });
    await _saveAccounts();
  }

  void _showAccountDialog(int bankId) {
    final account = bankAccounts.firstWhere((acc) => acc['bankId'] == bankId);
    final accountCurrency = account['currency'];

    TextEditingController nameController = TextEditingController();
    TextEditingController typeController = TextEditingController();
    TextEditingController balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Transaction to ${account['bankName']}"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: "Name"),
                    ),
                    TextField(
                      controller: typeController,
                      decoration: InputDecoration(labelText: "Type"),
                    ),
                    TextField(
                      controller: balanceController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: "Balance"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    final name = nameController.text;
                    final type = typeController.text;
                    final balance = double.tryParse(balanceController.text);

                    if (name.isNotEmpty && type.isNotEmpty){
                      final account = Account(
                          accountId: DateTime.now().millisecondsSinceEpoch,
                          name: name,
                          type: type,
                          balance: balance ?? 0.0
                      );

                      await _addAccountToBank(bankId, account);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<String> _getSubcategories(String category) {
    switch (category) {
      case 'Income':
        return ['Salary', 'Bonus', 'Investment', 'İş', 'Burs', 'Emekli'];
      case 'Expense':
        return ['Food', 'Transport', 'Housing', 'Entertainment', 'Other'];
      case 'Transfer':
        return ['Between Accounts', 'To Savings', 'From Savings'];
      default:
        return ['Other'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bank Accounts"),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: bankAccounts.isEmpty
          ? Center(child: Text("No bank accounts added yet."))
          : ListView.builder(
        itemCount: bankAccounts.length,
        itemBuilder: (context, bankIndex) {
          final bank = bankAccounts[bankIndex];
          return Card(
            margin: EdgeInsets.all(8.0),
            elevation: 3,
            color: Colors.blueGrey[50], // Light background for banks
            child: ExpansionTile(
              key: ValueKey(bank['bankId']),
              tilePadding: EdgeInsets.symmetric(horizontal: 16),
              leading: Icon(Icons.account_balance, color: Colors.blueGrey[800]),
              title: Text(
                bank['bankName'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "${bank['currency']} • ${bank['isDebit'] ? 'Debit' : 'Credit'}",
                      style: TextStyle(color: Colors.blueGrey[700]),),
                      if (!bank['isDebit'])
                  Text(
                    "Limit: ${bank['creditLimit']} • Cutoff: ${bank['cutoffDate']}",
                    style: TextStyle(color: Colors.blueGrey[600]),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue[800]),
                    onPressed: () => _showBankDialog(editIndex: bankIndex),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red[800]),
                    onPressed: () => _deleteAccount(bankIndex),
                  ),
                ],
              ),
              children: [
                // Add Account button
                Container(
                  color: Colors.blueGrey[100],
                  child: ListTile(
                    leading: Icon(Icons.add, color: Colors.blue[800]),
                    title: Text(
                      "Add Account",
                      style: TextStyle(color: Colors.blue[800]),
                    ),
                    onTap: () => _showAccountDialog(bank['bankId']),
                  ),
                ),

                // Accounts list
                if (bank['accounts'] != null && bank['accounts'].isNotEmpty)
                  ...bank['accounts'].map((accountData) {
                    final account = Account.fromJson(accountData);
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      color: Colors.teal[50], // Light background for accounts
                      child: ExpansionTile(
                        key: ValueKey(account.accountId),
                        tilePadding: EdgeInsets.symmetric(horizontal: 16),
                        leading: Icon(Icons.credit_card, color: Colors.teal[800]),
                        title: Text(
                          account.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.teal[900],
                          ),
                        ),
                        subtitle: Text(
                          "${account.type} • ${account.balance.toStringAsFixed(2)} ${bank['currency']}",
                          style: TextStyle(color: Colors.teal[700]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, size: 20, color: Colors.teal[800]),
                              onPressed: () {}, // Add edit account functionality
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, size: 20, color: Colors.red[700]),
                              onPressed: () {}, // Add delete account functionality
                            ),
                          ],
                        ),
                        children: [
                          // Transactions list
                          if (accountData['transactions'] != null && accountData['transactions'].isNotEmpty)
                            ...accountData['transactions'].map((transactionData) {
                              final transaction = Transaction.fromJson(transactionData);
                              return Card(
                                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                color: Colors.grey[100], // Light background for transactions
                                child: ListTile(
                                  leading: Icon(
                                    transaction.isSurplus ? Icons.arrow_upward : Icons.arrow_downward,
                                    color: transaction.isSurplus ? Colors.green[800] : Colors.red[800],
                                  ),
                                  title: Text(
                                    transaction.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${DateFormat('yyyy-MM-dd').format(transaction.date)} • ${transaction.category}",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  trailing: Text(
                                    "${transaction.isSurplus ? '+' : '-'}${transaction.amount.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: transaction.isSurplus ? Colors.green[800] : Colors.red[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onTap: () => _showEditTransactionDialog(account.accountId, transaction),
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey[800],
        onPressed: () => _showBankDialog(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}