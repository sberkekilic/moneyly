import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Transaction {
  int id;
  DateTime date;
  double amount;
  int? installment;
  String currency;
  String description;
  bool isSurplus;
  bool isFromInvoice;
  DateTime? initialInstallmentDate;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    this.installment,
    required this.isFromInvoice,
    required this.currency,
    required this.description,
    required this.isSurplus,
    required this.initialInstallmentDate,
  });

  // Convert Transaction to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'amount': amount,
    'installment': installment,
    'currency': currency,
    'description': description,
    'isSurplus': isSurplus,
    'isFromInvoice': isFromInvoice,
    'initialInstallmentDate': initialInstallmentDate?.toIso8601String(),
  };

  // Create Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    date: DateTime.parse(json['date']),
    amount: json['amount'],
    installment: json['installment'],
    currency: json['currency'],
    description: json['description'],
    isSurplus: json['isSurplus'],
    isFromInvoice: json['isFromInvoice'],
    initialInstallmentDate: json['initialInstallmentDate'] != null
        ? DateTime.tryParse(json['initialInstallmentDate'])
        : null,
  );
  String toDisplayString() {
    return 'ID: $id\nDate: $date\nAmount: $amount\nInstallment: ${installment  ?? 'N/A'}\nCurrency: $currency\ndescription: $description\nisSurplus: $isSurplus\nInstallmentDate: ${initialInstallmentDate  ?? 'N/A'}';
  }
  // Method to get the current installment period
  String getCurrentInstallmentPeriod() {
    if (installment == null || installment! <= 0) {
      return ''; // No installments
    }

    double installmentAmount = amount / installment!;
    int currentInstallment = _getCurrentInstallment();

    return '$currentInstallment/$installment - ${NumberFormat.currency(name: currency).format(installmentAmount)}';
  }

  // Method to get the current installment number
  int _getCurrentInstallment() {
    int monthsDiff = DateTime.now().difference(initialInstallmentDate!).inDays ~/ 30;
    return monthsDiff + 1;
  }
}

class TransactionService {

  static const _key = 'transactions';

  // Save list of transactions
  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_key, jsonData);
  }

  // Load list of transactions
  static Future<List<Transaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString(_key);
    if (jsonData == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonData);
    return jsonList.map((json) => Transaction.fromJson(json)).toList();
  }

  // Add a new transaction
  static Future<void> addTransaction(Transaction transaction) async {
    final transactions = await loadTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
  }

  // Update an existing transaction
  static Future<void> updateTransaction(Transaction updatedTransaction) async {
    final transactions = await loadTransactions();
    final index = transactions.indexWhere((t) => t.id == updatedTransaction.id);
    if (index != -1) {
      transactions[index] = updatedTransaction;
      await saveTransactions(transactions);
    }
  }

  // Delete a transaction
  static Future<void> deleteTransaction(int id) async {
    final transactions = await loadTransactions();
    transactions.removeWhere((t) => t.id == id);
    await saveTransactions(transactions);
  }
}




class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  TransactionCard({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color amountColor = transaction.isSurplus ? Colors.green : Colors.red;
    Color backgroundColor = transaction.isFromInvoice
        ? Colors.blue.withOpacity(0.3) // Light blue for Invoice transactions
        : Colors.white; // Default white for other transactions
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left section: Date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Day (top)
                    Text(
                      DateFormat('d').format(transaction.date),
                      style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                    // Month and Year (center)
                    Text(
                      DateFormat('MMM yyyy').format(transaction.date),
                      style: GoogleFonts.montserrat(fontSize: 10.sp),
                    ),
                    // Time (bottom)
                    Text(
                      DateFormat('HH:mm:ss').format(transaction.date),
                      style: GoogleFonts.montserrat(fontSize: 8.sp),
                    ),
                  ],
                ),
                SizedBox(width: 16),
                // Center section: Currency
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.currency,
                        style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        transaction.description,
                        style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                // Right section: Amount and Installment
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Amount (top)
                    Text(
                      NumberFormat.currency(name: transaction.currency).format(transaction.amount),
                      style: GoogleFonts.montserrat(fontSize: 12.sp, color: amountColor),
                    ),
                    Text(
                      transaction.getCurrentInstallmentPeriod(),
                      style: GoogleFonts.montserrat(fontSize: 10.sp),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}