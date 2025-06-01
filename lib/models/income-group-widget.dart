import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncomeByAccountWidget extends StatelessWidget {
  final List<Map<String, dynamic>> bankAccounts;

  const IncomeByAccountWidget({super.key, required this.bankAccounts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: bankAccounts.length,
      itemBuilder: (context, bankIndex) {
        final bank = bankAccounts[bankIndex];
        final bankName = bank['bankName'] ?? 'Unnamed Bank';
        final accounts = bank['accounts'] as List<dynamic>? ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Text(
                bankName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ...accounts.map((account) {
              final accountName = account['name'] ?? 'Unnamed Account';
              final currency = account['currency'] ?? '';
              final transactions = (account['transactions'] as List<dynamic>? ?? [])
                  .where((t) => t['isSurplus'] == true)
                  .toList();

              if (transactions.isEmpty) return const SizedBox(); // Skip if no incomes

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$accountName ($currency)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ...transactions.map((tx) => _buildTransactionItem(tx, account['accountId'].toString(), context)).toList(),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // Show the dialog to edit a transaction
  void _showEditDialog(BuildContext context, String accountId, Map<String, dynamic> transaction) {
    final TextEditingController amountController =
    TextEditingController(text: transaction['amount'].toString());

    DateTime selectedDate = DateTime.parse(transaction['date']);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Geliri Güncelle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Tutar'),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      selectedDate = picked;
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tarih',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newAmount = double.tryParse(amountController.text) ?? transaction['amount'];
                  final newTx = Map<String, dynamic>.from(transaction);
                  newTx['amount'] = newAmount;
                  newTx['date'] = selectedDate.toIso8601String();
                  _updateTransaction(accountId, transaction, newTx);
                  Navigator.pop(context);
                },
                child: const Text('Kaydet'),
              ),
            ],
          );
        },
        );
      },
    );
  }

// Güncelleme ve silme işlemleri sırasında _saveAccounts() çağrılmadan önce veriyi loglayarak kontrol edelim.

  void _updateTransaction(String accountId, Map<String, dynamic> oldTx, Map<String, dynamic> newTx) async {
    for (var bank in bankAccounts) {
      final account = (bank['accounts'] as List).firstWhere(
            (acc) => acc['accountId'].toString() == accountId,
        orElse: () => null,
      );

      if (account != null) {
        final txList = account['transactions'] as List;
        final oldIndex = txList.indexWhere((t) => t['transactionId'] == oldTx['transactionId']);

        if (oldIndex != -1) {
          // Balance düzelt
          account['balance'] -= oldTx['amount'];
          account['balance'] += newTx['amount'];
          txList[oldIndex] = newTx;

          // Debugging: Güncelleme yapıldı mı kontrolü
          print('Transaction updated: ${jsonEncode(bankAccounts)}');

          await _saveAccounts();
          print('Accounts saved to SharedPreferences.');
        }
        break;
      }
    }
  }

  void _deleteTransaction(String accountId, Map<String, dynamic> tx) async {
    for (var bank in bankAccounts) {
      final account = (bank['accounts'] as List).firstWhere(
            (acc) => acc['accountId'].toString() == accountId,
        orElse: () => null,
      );

      if (account != null) {
        final txList = account['transactions'] as List;
        txList.removeWhere((t) => t['transactionId'] == tx['transactionId']);
        account['balance'] -= tx['amount'];

        // Debugging: Silme yapıldı mı kontrolü
        print('Transaction deleted: ${jsonEncode(bankAccounts)}');

        await _saveAccounts();
        print('Accounts saved to SharedPreferences.');
        break;
      }
    }
  }

// _saveAccounts fonksiyonu, SharedPreferences'a kaydetme işlemini yapıyor.
  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accountDataList', jsonEncode(bankAccounts));

    // Debugging: Kaydedilen veriyi kontrol et
    print('Saved to SharedPreferences: ${prefs.getString('accountDataList')}');
  }


  // Build each transaction item
  Widget _buildTransactionItem(Map<String, dynamic> transaction, String accountId, BuildContext context) {
    final amount = transaction['amount'] ?? 0.0;
    final currency = transaction['currency'] ?? '';
    final category = transaction['category'] ?? '';
    final subcategory = transaction['subcategory'] ?? '';
    final date = DateTime.tryParse(transaction['date'] ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(transaction['date']);
    final formattedDate = DateFormat('dd MMM yyyy').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$category / $subcategory',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${amount.toStringAsFixed(2)} $currency',
                style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                    onPressed: () {
                      _showEditDialog(context, accountId, transaction);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () {
                      _deleteTransaction(accountId, transaction);
                    },
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
