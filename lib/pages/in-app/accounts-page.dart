import 'dart:convert';
import 'dart:ui';

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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? "Edit Bank" : "Add Bank"),
        content: TextField(
          controller: bankNameController,
          decoration: InputDecoration(labelText: "Bank Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              String bankName = bankNameController.text.trim();
              if (bankName.isNotEmpty) {
                final bankData = {
                  'bankId': isEditing ? existingData!['bankId'] : DateTime.now().millisecondsSinceEpoch,
                  'bankName': bankName,
                  'accounts': existingData?['accounts'] ?? [],
                };
                if (isEditing) {
                  bankAccounts[editIndex!] = bankData;
                } else {
                  bankAccounts.add(bankData);
                }
                _saveAccounts();
                _loadAccounts();
                Navigator.of(context).pop();
              }
            },
            child: Text(isEditing ? "Update" : "Add"),
          ),
        ],
      ),
    );
  }

  void _deleteBank(int bankIndex) {
    setState(() {
      bankAccounts.removeAt(bankIndex);
      _saveAccounts(); // Veriyi kaydetmek için gerekli
    });
  }

  void _deleteAccount(int bankId, int accountIndex) {
    final bank = bankAccounts.firstWhere((b) => b['bankId'] == bankId);
    setState(() {
      bank['accounts'].removeAt(accountIndex);
      _saveAccounts(); // Veriyi kaydetmek için gerekli
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

  void _showEditAccountDialog(int bankId, int accountIndex) {
    final bank = bankAccounts.firstWhere((b) => b['bankId'] == bankId);
    final account = bank['accounts'][accountIndex];

    TextEditingController nameController = TextEditingController(text: account['name'] ?? '');
    TextEditingController typeController = TextEditingController(text: account['type'] ?? '');
    TextEditingController balanceController = TextEditingController(text: (account['balance'] ?? 0.0).toString());
    TextEditingController creditLimitController = TextEditingController(text: (account['creditLimit'] ?? 0.0).toString());
    TextEditingController availableCreditController = TextEditingController(text: (account['availableCredit'] ?? 0.0).toString());
    TextEditingController remainingDebtController = TextEditingController(text: (account['remainingDebt'] ?? 0.0).toString());
    TextEditingController minPaymentController = TextEditingController(text: (account['minPayment'] ?? 0.0).toString());
    TextEditingController remainingMinPaymentController = TextEditingController(text: (account['remainingMinPayment'] ?? 0.0).toString());
    TextEditingController previousDebtController = TextEditingController(text: (account['previousDebt'] ?? 0.0).toString());
    TextEditingController totalDebtController = TextEditingController(text: (account['totalDebt'] ?? 0.0).toString());
    TextEditingController currentDebtController = TextEditingController(text: (account['currentDebt'] ?? 0.0).toString());

    String selectedCurrency = account['currency'] ?? 'TRY';
    bool isDebit = account['isDebit'] ?? true;
    int selectedCutoffDate = account['cutoffDate'] ?? 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Edit Account - ${bank['bankName']}"),
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
                  DropdownButton<String>(
                    value: selectedCurrency,
                    items: ["TRY", "USD", "EUR"].map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedCurrency = value!),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isDebit ? "Debit Account" : "Credit Account"),
                      Switch(
                        value: isDebit,
                        onChanged: (value) => setState(() => isDebit = value),
                      ),
                    ],
                  ),
                  if (!isDebit) ...[
                    TextField(
                      controller: creditLimitController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: "Credit Limit"),
                    ),
                    TextField(
                      controller: availableCreditController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: "Available Credit"),
                    ),
                    TextField(
                      controller: remainingDebtController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: "Remaining Debt"),
                    ),
                    TextField(
                      controller: minPaymentController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: "Min Payment"),
                    ),
                    TextField(
                      controller: remainingMinPaymentController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: "Remaining Min Payment"),
                    ),
                    TextField(
                      controller: previousDebtController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: "Previous Debt"),
                    ),
                    TextField(
                      controller: totalDebtController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: "Total Debt"),
                    ),
                    TextField(
                      controller: currentDebtController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: "Current Debt"),
                    ),
                    DropdownButton<int>(
                      value: selectedCutoffDate,
                      items: List.generate(28, (i) => i + 1).map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text("Cutoff Date: $day"),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedCutoffDate = value!),
                    ),
                  ],
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
                  final updatedAccount = {
                    'accountId': account['accountId'],
                    'name': nameController.text,
                    'type': typeController.text,
                    'balance': double.tryParse(balanceController.text) ?? 0.0,
                    'transactions': account['transactions'],
                    'debts': account['debts'],
                    'currency': selectedCurrency,
                    'isDebit': isDebit,
                    'creditLimit': isDebit ? null : double.tryParse(creditLimitController.text),
                    'availableCredit': isDebit ? null : double.tryParse(availableCreditController.text),
                    'remainingDebt': isDebit ? null : double.tryParse(remainingDebtController.text),
                    'minPayment': isDebit ? null : double.tryParse(minPaymentController.text),
                    'remainingMinPayment': isDebit ? null : double.tryParse(remainingMinPaymentController.text),
                    'previousDebt': isDebit ? null : double.tryParse(previousDebtController.text),
                    'totalDebt': isDebit ? null : double.tryParse(totalDebtController.text),
                    'currentDebt': isDebit ? null : double.tryParse(currentDebtController.text),
                    'cutoffDate': isDebit ? 1 : selectedCutoffDate,
                    'previousCutoffDate': account['previousCutoffDate'],
                    'nextCutoffDate': account['nextCutoffDate'],
                    'previousDueDate': account['previousDueDate'],
                    'nextDueDate': account['nextDueDate'],
                  };

                  bank['accounts'][accountIndex] = updatedAccount;
                  _saveAccounts();
                  _loadAccounts();
                  Navigator.of(context).pop();
                },
                child: Text("Update"),
              ),
            ],
          );
        });
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
    final bank = bankAccounts.firstWhere((b) => b['bankId'] == bankId);
    TextEditingController nameController = TextEditingController();
    TextEditingController typeController = TextEditingController();
    TextEditingController balanceController = TextEditingController();
    TextEditingController previousDebtController = TextEditingController();
    TextEditingController totalDebtController = TextEditingController();
    TextEditingController creditLimitController = TextEditingController();

    String selectedCurrency = "USD";
    bool isDebit = false;
    int selectedCutoffDate = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Account to ${bank['bankName']}"),
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
                    if (!isDebit) ...[
                      // previousDebt yerine balance
                      TextField(
                        controller: creditLimitController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Credit Limit"),
                      ),
                      TextField(
                        controller: previousDebtController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Previous Debt"),
                      ),
                      TextField(
                        controller: totalDebtController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Total Debt"),
                      ),
                    ] else ...[
                      TextField(
                        controller: balanceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Balance"),
                      ),
                    ],
                    DropdownButton<String>(
                      value: selectedCurrency,
                      items: ["USD", "EUR", "TRY"].map((currency) => DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      )).toList(),
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
                          onChanged: (value) => setState(() => isDebit = value),
                        ),
                      ],
                    ),
                    if (!isDebit) ...[
                      DropdownButton<int>(
                        value: selectedCutoffDate,
                        items: List.generate(28, (index) => index + 1).map((day) => DropdownMenuItem(
                          value: day,
                          child: Text("Cutoff Date: $day"),
                        )).toList(),
                        onChanged: (value) => setState(() => selectedCutoffDate = value!),
                      ),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Cancel")),
                TextButton(
                  onPressed: () async {
                    final name = nameController.text;
                    final type = typeController.text;
                    final balance = double.tryParse(balanceController.text) ?? 0.0;
                    final creditLimit = isDebit ? 0.0 : (double.tryParse(creditLimitController.text) ?? 0.0);
                    final previousDebt = isDebit ? 0.0 : (double.tryParse(previousDebtController.text) ?? 0.0);
                    final totalDebt = isDebit ? 0.0 : (double.tryParse(totalDebtController.text) ?? 0.0);

                    if (name.isNotEmpty && type.isNotEmpty) {
                      final newAccount = Account(
                        accountId: DateTime.now().millisecondsSinceEpoch,
                        name: name,
                        type: type,
                        balance: balance,
                        currency: selectedCurrency,
                        isDebit: isDebit,
                        creditLimit: creditLimit,
                        availableCredit: isDebit ? null : creditLimit - totalDebt,
                        remainingDebt: isDebit ? null : previousDebt,
                        currentDebt: isDebit ? null : totalDebt - previousDebt,
                        minPayment: 0.0,
                        remainingMinPayment: 0.0,
                        previousDebt: previousDebt,
                        totalDebt: totalDebt,
                        cutoffDate: selectedCutoffDate,
                        previousCutoffDate: null,
                        nextCutoffDate: null,
                        previousDueDate: null,
                        nextDueDate: null,
                      );

                      if (!isDebit) {
                        newAccount.updateCreditDates();

                        newAccount.minPayment = newAccount.calculateMinPayment();
                        newAccount.remainingMinPayment = newAccount.minPayment;
                      }

                      bank['accounts'].add(newAccount.toJson());
                      _saveAccounts();
                      _loadAccounts();
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
      body: bankAccounts.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No bank accounts yet",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the + button to add your first account",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: bankAccounts.length,
        itemBuilder: (context, bankIndex) {
          final bank = bankAccounts[bankIndex];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GlassmorphismContainer(
              borderRadius: 20,
              blur: 12,
              borderColor: Colors.white.withOpacity(0.2),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: ValueKey(bank['bankId']),
                  tilePadding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance,
                      color: Colors.blue[700],
                      size: 24,
                    ),
                  ),
                  title: Text(
                    bank['bankName'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  subtitle: Text(
                    "${bank['accounts']?.length ?? 0} accounts",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, size: 20, color: Colors.blueGrey[600]),
                        onPressed: () => _showBankDialog(editIndex: bankIndex),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, size: 20, color: Colors.red[400]),
                        onPressed: () => _deleteBank(bankIndex),
                      ),
                    ],
                  ),
                  children: [
                    // Add Account button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: GlassmorphismContainer(
                        borderRadius: 12,
                        blur: 10,
                        borderColor: Colors.white.withOpacity(0.2),
                        child: ListTile(
                          leading: Icon(Icons.add_circle_outline, color: Colors.blue[600]),
                          title: Text(
                            "Add Account",
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => _showAccountDialog(bank['bankId']),
                        ),
                      ),
                    ),

                    // Accounts list
                    if (bank['accounts'] != null && bank['accounts'].isNotEmpty)
                      ...bank['accounts'].map((accountData) {
                        final account = Account.fromJson(accountData);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: GlassmorphismContainer(
                            borderRadius: 16,
                            blur: 10,
                            borderColor: Colors.white.withOpacity(0.2),
                            child: ExpansionTile(
                              key: ValueKey(account.accountId),
                              tilePadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.teal[50],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.credit_card,
                                  color: Colors.teal[700],
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                account.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                "${account.type} • ${account.balance!.toStringAsFixed(2)} ${account.currency}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, size: 18, color: Colors.blueGrey[500]),
                                    onPressed: () => _showEditAccountDialog(
                                      bank['bankId'],
                                      bank['accounts'].indexOf(accountData),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, size: 18, color: Colors.red[400]),
                                    onPressed: () => _deleteAccount(
                                      bank['bankId'],
                                      bank['accounts'].indexOf(accountData),
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                // Transactions header
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Recent Transactions",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "See All",
                                        style: TextStyle(
                                          color: Colors.blue[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Transactions list
                                if (accountData['transactions'] != null && accountData['transactions'].isNotEmpty)
                                  ...accountData['transactions'].map((transactionData) {
                                    final transaction = Transaction.fromJson(transactionData);
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: GlassmorphismContainer(
                                        borderRadius: 10,
                                        blur: 8,
                                        borderColor: Colors.white.withOpacity(0.2),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                          leading: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: transaction.isSurplus ? Colors.green[50] : Colors.red[50],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              transaction.isSurplus ? Icons.arrow_upward : Icons.arrow_downward,
                                              color: transaction.isSurplus ? Colors.green[600] : Colors.red[600],
                                              size: 18,
                                            ),
                                          ),
                                          title: Text(
                                            transaction.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "${DateFormat('MMM dd').format(transaction.date)} • ${transaction.category}",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 11,
                                            ),
                                          ),
                                          trailing: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "${transaction.isSurplus ? '+' : '-'}${transaction.amount.toStringAsFixed(2)}",
                                                style: TextStyle(
                                                  color: transaction.isSurplus ? Colors.green[700] : Colors.red[700],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                transaction.currency,
                                                style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () => _showEditTransactionDialog(account.accountId, transaction),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBankDialog(),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color borderColor;

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 12,
    this.borderColor = Colors.white24,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}