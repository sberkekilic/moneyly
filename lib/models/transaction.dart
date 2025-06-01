import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Transaction {
  int transactionId;
  DateTime date;
  double amount;
  int? installment;
  String currency;
  String subcategory;
  String category;
  String title;
  String description;
  bool isSurplus;
  bool isFromInvoice;
  DateTime? initialInstallmentDate;
  bool isProvisioned;

  Transaction({
    required this.transactionId,
    required this.date,
    required this.amount,
    this.installment,
    required this.isFromInvoice,
    required this.currency,
    required this.subcategory,
    required this.category,
    required this.description,
    required this.title,
    required this.isSurplus,
    required this.initialInstallmentDate,
    required this.isProvisioned,
  });

  // Convert Transaction to JSON
  Map<String, dynamic> toJson() => {
    'transactionId': transactionId,
    'date': date.toIso8601String(),
    'amount': amount,
    'installment': installment,
    'currency': currency,
    'subcategory': subcategory,
    'category': category,
    'title': title,
    'description': description,
    'isSurplus': isSurplus,
    'isFromInvoice': isFromInvoice,
    'initialInstallmentDate': initialInstallmentDate?.toIso8601String(),
    'isProvisioned':isProvisioned
  };

  // Create Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    transactionId: json['transactionId'],
    date: DateTime.parse(json['date']),
    amount: json['amount'],
    installment: json['installment'],
    currency: json['currency'],
    subcategory: json['subcategory'],
    category: json['category'],
    title: json['title'],
    description: json['description'],
    isSurplus: json['isSurplus'],
    isFromInvoice: json['isFromInvoice'],
    initialInstallmentDate: json['initialInstallmentDate'] != null
        ? DateTime.tryParse(json['initialInstallmentDate'])
        : null,
      isProvisioned: json['isProvisioned']
  );
  String toDisplayString() {
    return 'ID: $transactionId\nDate: $date\nAmount: $amount\nInstallment: ${installment  ?? 'N/A'}\nCurrency: $currency\nSubcategory: $subcategory\nCategory: $category\nTitle: $title\ndescription: $description\nisSurplus: $isSurplus\nInstallmentDate: ${initialInstallmentDate  ?? 'N/A'}';
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

  Transaction copyWith({
    int? transactionId,
    DateTime? date,
    double? amount,
    int? installment,
    String? currency,
    String? subcategory,
    String? category,
    String? title,
    String? description,
    bool? isSurplus,
    bool? isFromInvoice,
    DateTime? initialInstallmentDate,
    bool? isProvisioned
  }) {
    return Transaction(
      transactionId: transactionId ?? this.transactionId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      installment: installment ?? this.installment,
      isFromInvoice: isFromInvoice ?? this.isFromInvoice,
      currency: currency ?? this.currency,
      subcategory: subcategory ?? this.subcategory,
      category: category ?? this.category,
      description: description ?? this.description,
      title: title ?? this.title,
      isSurplus: isSurplus ?? this.isSurplus,
      initialInstallmentDate: initialInstallmentDate ?? this.initialInstallmentDate,
        isProvisioned: isProvisioned ?? this.isProvisioned
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Transaction &&
              runtimeType == other.runtimeType &&
              transactionId == other.transactionId;

  @override
  int get hashCode => transactionId.hashCode;
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
    final index = transactions.indexWhere((t) => t.transactionId == updatedTransaction.transactionId);
    if (index != -1) {
      transactions[index] = updatedTransaction;
      await saveTransactions(transactions);
    }
  }

  // Delete a transaction
  static Future<void> deleteTransaction(int id) async {
    final transactions = await loadTransactions();
    transactions.removeWhere((t) => t.transactionId == id);
    await saveTransactions(transactions);
  }

  // Function to validate and adjust the day
  static DateTime _validateDay(int day, DateTime referenceDate) {
    final lastDayOfMonth = DateTime(referenceDate.year, referenceDate.month + 1, 0).day;
    if (day > lastDayOfMonth) day = lastDayOfMonth;

    DateTime validatedDate = DateTime(referenceDate.year, referenceDate.month, day);

    if (validatedDate.weekday == DateTime.saturday) {
      validatedDate = validatedDate.add(Duration(days: 2));
    } else if (validatedDate.weekday == DateTime.sunday) {
      validatedDate = validatedDate.add(Duration(days: 1));
    }

    return validatedDate;
  }

  // Create a list of Transactions from incomeMap
  static Future<List<Transaction>> _createTransactions() async {
    Map<String, List<Map<String, dynamic>>> incomeMap = {};
    final prefs = await SharedPreferences.getInstance();
    final ab2 = prefs.getString('incomeMap') ?? "0";
    String? startDateString = prefs.getString('startDate');
    String? endDateString = prefs.getString('endDate');

    if (ab2.isNotEmpty) {
      final decodedData = json.decode(ab2);
      if (decodedData is Map<String, dynamic>) {
        incomeMap = {};
        decodedData.forEach((key, value) {
          if (value is List<dynamic>) {
            incomeMap[key] = List<Map<String, dynamic>>.from(value.map((e) => Map<String, dynamic>.from(e)));
          }
        });
      }
      print('Final incomeMap: ${jsonEncode(incomeMap)}');
    }

    if (startDateString == null || endDateString == null) {
      print('Start date or end date is missing!');
      return [];
    }

    DateTime startDate = DateTime.parse(startDateString);
    DateTime endDate = DateTime.parse(endDateString);
    List<Transaction> transactions = [];

    for (DateTime currentDate = startDate;
    currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate);
    currentDate = DateTime(currentDate.year, currentDate.month + 1, 1)) {

      incomeMap.forEach((key, incomeList) {
        if (incomeList == null || incomeList.isEmpty) return;

        for (var income in incomeList) {
          int day = income['day'] ?? 1;
          DateTime transactionDate = _validateDay(day, currentDate);

          if (transactionDate.isAfter(endDate)) continue;

          double amount = NumberFormat.decimalPattern('tr_TR').parse(income['amount'].toString()) as double;

          transactions.add(Transaction(
            transactionId: DateTime.now().millisecondsSinceEpoch,
            date: transactionDate,
            amount: amount,
            installment: null,
            currency: 'TRY',
            subcategory: 'Maaş',
            category: 'Gelir',
            title: 'Maaş',
            description: 'Income',
            isSurplus: true,
            isFromInvoice: false,
            initialInstallmentDate: null,
              isProvisioned: false
          ));
        }
      });
    }

    return transactions;
  }

  // Public method to generate transactions and save them
  static Future<void> generateAndSaveTransactions() async {
    List<Transaction> transactions = await _createTransactions();
    await saveTransactions(transactions);
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  TransactionCard({
    Key? key,
    required this.transaction
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
                      style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    // Month and Year (center)
                    Text(
                      DateFormat('MMM yyyy').format(transaction.date),
                      style: GoogleFonts.montserrat(fontSize: 8.sp),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                // Center section: Currency
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        transaction.description,
                        style: GoogleFonts.montserrat(fontSize: 8.sp, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                // Right section: Amount and Installment
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Amount (top)
                    Text(
                      NumberFormat("#,##0.00", "tr_TR").format(transaction.amount) + " " + transaction.currency,
                      style: GoogleFonts.montserrat(fontSize: 10.sp, color: amountColor),
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