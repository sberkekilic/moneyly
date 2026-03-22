import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/models/transaction_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/account_service.dart';
import 'account.dart';

class Transaction {
  int transactionId;
  DateTime date;
  double amount;
  int? installment; // Toplam taksit sayısı
  String currency;
  String subcategory;
  String category;
  String title;
  String description;
  bool isSurplus;
  bool isFromInvoice;
  DateTime? initialInstallmentDate; // İlk taksit tarihi
  bool isProvisioned;

  TransactionType? transactionType;

  // YENİ ALANLAR EKLENDİ
  int? currentInstallment; // Kaçıncı taksit olduğu
  double? totalAmount; // Toplam işlem tutarı (taksitli ise)
  bool? isInstallmentCompleted; // Tüm taksitler ödendi mi?

  // Taksitli işlem mi? - DÜZELTİLDİ: nullable kontrolü eklendi
  bool get isInstallment => installment != null && installment! > 1;

  // Ana işlem ID'si (taksitli işlemler için)
  int? parentTransactionId;

  // Taksit numarası - DÜZELTİLDİ: property ismini değiştirdim
  int? _installmentIndex;

  bool? isInstallmentPaid; // Bu taksit ödendi mi?
  double? paidAmount; // Ödenmiş miktar

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
    this.currentInstallment,
    this.totalAmount,
    this.isInstallmentCompleted = false,
    this.transactionType,
    this.parentTransactionId,
    int? installmentIndex, // Parametre adını değiştirdim
    this.isInstallmentPaid = false,
    this.paidAmount = 0.0,
  }) : _installmentIndex = installmentIndex; // Atama düzeltildi

  // Taksitli işlem için tam tutarı hesapla
  double get totalTransactionAmount {
    if (installment != null && installment! > 1 && totalAmount != null) {
      return totalAmount!;
    }
    return amount;
  }

  // Taksit başına düşen tutarı hesapla
  double get installmentAmount {
    if (installment != null && installment! > 0) {
      if (totalAmount != null) {
        return totalAmount! / installment!;
      }
      return amount; // Eğer totalAmount yoksa, amount zaten taksit tutarıdır
    }
    return amount;
  }

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
    'isProvisioned': isProvisioned,
    'currentInstallment': currentInstallment,
    'totalAmount': totalAmount,
    'isInstallmentCompleted': isInstallmentCompleted,
    'transactionType': transactionType?.index,
    'parentTransactionId': parentTransactionId,
    'installmentIndex': _installmentIndex, // JSON'a farklı isimle kaydet
    'isInstallmentPaid': isInstallmentPaid,
    'paidAmount': paidAmount,
  };

  // Create Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    transactionId: json['transactionId'],
    date: DateTime.parse(json['date']),
    amount: json['amount'] is int ? (json['amount'] as int).toDouble() : json['amount'],
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
    isProvisioned: json['isProvisioned'] ?? false,
    currentInstallment: json['currentInstallment'],
    totalAmount: json['totalAmount'] is int
        ? (json['totalAmount'] as int).toDouble()
        : json['totalAmount'],
    isInstallmentCompleted: json['isInstallmentCompleted'] ?? false,
    transactionType: json['transactionType'] != null
        ? TransactionType.values[json['transactionType']]
        : null,
    parentTransactionId: json['parentTransactionId'],
    installmentIndex: json['installmentIndex'], // JSON'dan farklı isimle al
    isInstallmentPaid: json['isInstallmentPaid'] ?? false,
    paidAmount: json['paidAmount'] ?? 0.0,
  );

  // Taksitli işlemin ödenmemiş kısmını hesapla - DÜZELTİLDİ: nullable kontrolü
  double get unpaidAmount {
    if (installment == null || installment! <= 1 || totalAmount == null) {
      return amount; // Taksitli değilse tamamı
    }

    // Ödenmiş taksit sayısını bul - DÜZELTİLDİ: nullable kontrolü
    final paidInstallments = (isInstallmentPaid ?? false) ? 1 : 0;
    final perInstallment = totalAmount! / installment!;

    return totalAmount! - (paidInstallments * perInstallment);
  }

  // Bu transaction kaçıncı taksit? - DÜZELTİLDİ: fonksiyon adını değiştirdim
  int get installmentPosition {
    if (!isInstallment || initialInstallmentDate == null) return 1;

    final monthsDiff = (date.year - initialInstallmentDate!.year) * 12 +
        (date.month - initialInstallmentDate!.month);
    return monthsDiff + 1;
  }

  // Getter for installment index
  int? get installmentIndex => _installmentIndex;

  // Setter for installment index
  set installmentIndex(int? value) {
    _installmentIndex = value;
  }

  String toDisplayString() {
    return 'ID: $transactionId\nDate: $date\nAmount: $amount\nInstallment: ${installment ?? 'N/A'}\nCurrency: $currency\nSubcategory: $subcategory\nCategory: $category\nTitle: $title\ndescription: $description\nisSurplus: $isSurplus\nInstallmentDate: ${initialInstallmentDate ?? 'N/A'}\nCurrent Installment: $currentInstallment\nTotal Amount: $totalAmount';
  }

  // Method to get the current installment period
  String getCurrentInstallmentPeriod() {
    if (installment == null || installment! <= 0) {
      return ''; // No installments
    }

    if (currentInstallment != null) {
      return '$currentInstallment/$installment';
    }

    return '1/$installment'; // Default to first installment
  }

  // Method to calculate which installment this is
  int calculateCurrentInstallment() {
    if (installment == null || initialInstallmentDate == null) {
      return 1;
    }

    final now = DateTime.now();
    final start = initialInstallmentDate!;

    // İki tarih arasındaki ay farkını hesapla
    int monthsDiff = (now.year - start.year) * 12 + (now.month - start.month);

    // Tarih karşılaştırması: eğer bugün ilk taksit tarihinden önceyse 0 dön
    if (now.isBefore(start)) {
      return 0;
    }

    // Ay farkına 1 ekle (ilk taksit 1 olacak)
    return monthsDiff + 1;
  }

  // Taksitlerden kaçının ödendiğini kontrol et
  int getPaidInstallmentsCount(DateTime cutoffDate) {
    if (installment == null || initialInstallmentDate == null) {
      return 0;
    }

    int paidCount = 0;
    final start = initialInstallmentDate!;

    for (int i = 0; i < installment!; i++) {
      DateTime installmentDate = DateTime(
        start.year,
        start.month + i,
        start.day,
      );

      // Eğer taksit tarihi kesim tarihinden önceyse, ödenmiş say
      if (installmentDate.isBefore(cutoffDate)) {
        paidCount++;
      }
    }

    return paidCount;
  }

  // Toplam borca ne kadarının yansıdığını hesapla
  double getAmountIncludedInTotalDebt(DateTime cutoffDate) {
    if (installment == null || installment! <= 1 || totalAmount == null) {
      return amount; // Taksitli değilse tamamı
    }

    int paidInstallments = getPaidInstallmentsCount(cutoffDate);
    double installmentAmount = totalAmount! / installment!;

    // Ödenmiş taksitler kadarını toplam borçtan düş
    return totalAmount! - (paidInstallments * installmentAmount);
  }

  // Mevcut dönemde ödenmesi gereken taksit var mı?
  bool hasInstallmentDueThisPeriod(DateTime previousCutoff, DateTime nextCutoff) {
    if (installment == null || initialInstallmentDate == null) {
      return false;
    }

    final start = initialInstallmentDate!;

    for (int i = 0; i < installment!; i++) {
      DateTime installmentDate = DateTime(
        start.year,
        start.month + i,
        start.day,
      );

      // Taksit tarihi bu dönem içindeyse true dön
      if (installmentDate.isAfter(previousCutoff) &&
          installmentDate.isBefore(nextCutoff)) {
        return true;
      }
    }

    return false;
  }

  // CopyWith metodu
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
    bool? isProvisioned,
    TransactionType? transactionType,
    int? currentInstallment,
    double? totalAmount,
    bool? isInstallmentCompleted,
    int? parentTransactionId,
    int? installmentIndex,
    bool? isInstallmentPaid,
    double? paidAmount,
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
      isProvisioned: isProvisioned ?? this.isProvisioned,
      currentInstallment: currentInstallment ?? this.currentInstallment,
      totalAmount: totalAmount ?? this.totalAmount,
      isInstallmentCompleted: isInstallmentCompleted ?? this.isInstallmentCompleted,
      transactionType: transactionType ?? this.transactionType,
      parentTransactionId: parentTransactionId ?? this.parentTransactionId,
      installmentIndex: installmentIndex ?? _installmentIndex,
      isInstallmentPaid: isInstallmentPaid ?? this.isInstallmentPaid,
      paidAmount: paidAmount ?? this.paidAmount,
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
  static const _accountDataListKey = 'accountDataList';
  static const _selectedAccountKey = 'selectedAccount';

  // Save list of transactions
  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_key, jsonData);
  }

  // Load transactions from all sources
  static Future<List<Transaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();

    // First, try to get from transactions key
    final transactionsJson = prefs.getString(_key);
    if (transactionsJson != null && transactionsJson.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(transactionsJson);
        final transactions = jsonList.map((json) => Transaction.fromJson(json)).toList();
        print('✅ Loaded ${transactions.length} transactions from $_key');

        // If we have transactions, return them
        if (transactions.isNotEmpty) {
          return transactions;
        }
      } catch (e) {
        print('❌ Error parsing transactions from $_key: $e');
      }
    } else {
      print('ℹ️ No transactions found in $_key key');
    }

    // If no transactions in separate key, extract from accounts
    print('🔄 Extracting transactions from accounts...');
    final allTransactions = await AccountService.extractAllTransactions();

    // Save them to the transactions key for future use
    if (allTransactions.isNotEmpty) {
      print('💾 Saving ${allTransactions.length} transactions to $_key...');
      await saveTransactions(allTransactions);
      print('✅ Saved transactions to $_key');
    } else {
      print('⚠️ No transactions extracted from accounts');
    }

    return allTransactions;
  }

  static Future<List<Transaction>> _extractAllTransactionsFromAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Transaction> allTransactions = [];

    // 1. Extract from accountDataList
    final accountDataListJson = prefs.getString(_accountDataListKey);
    if (accountDataListJson != null && accountDataListJson.isNotEmpty) {
      try {
        final accountDataList = jsonDecode(accountDataListJson) as List<dynamic>;

        for (final bankData in accountDataList) {
          final accounts = (bankData['accounts'] as List<dynamic>? ?? []);

          for (final accountJson in accounts) {
            final account = Account.fromJson(accountJson);

            // Add all transactions from this account
            for (final transaction in account.transactions) {
              if (transaction is Transaction) {
                allTransactions.add(transaction);
              }
            }
          }
        }
      } catch (e) {
        print('Error extracting transactions from accountDataList: $e');
      }
    }

    // 2. Extract from selectedAccount
    final selectedAccountJson = prefs.getString(_selectedAccountKey);
    if (selectedAccountJson != null && selectedAccountJson.isNotEmpty) {
      try {
        final selectedAccount = Account.fromJson(jsonDecode(selectedAccountJson));

        // Add all transactions from selected account (avoid duplicates)
        for (final transaction in selectedAccount.transactions) {
          if (transaction is Transaction) {
            final exists = allTransactions.any((t) => t.transactionId == transaction.transactionId);
            if (!exists) {
              allTransactions.add(transaction);
            }
          }
        }
      } catch (e) {
        print('Error extracting transactions from selectedAccount: $e');
      }
    }

    print('Extracted ${allTransactions.length} transactions from accounts');
    return allTransactions;
  }

  // Add a new transaction
  static Future<void> addTransaction(Transaction transaction) async {
    final transactions = await loadTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
    print('✅ Added new transaction (ID: ${transaction.transactionId})');
  }

  // Update an existing transaction
  static Future<void> updateTransaction(Transaction updatedTransaction) async {
    final transactions = await loadTransactions();
    final index = transactions.indexWhere((t) => t.transactionId == updatedTransaction.transactionId);

    if (index != -1) {
      // Update in the separate transactions list
      transactions[index] = updatedTransaction;
      await saveTransactions(transactions);

      // Also update in all accounts
      await AccountService.updateTransactionInAccounts(updatedTransaction);

      print('✅ Updated transaction (ID: ${updatedTransaction.transactionId})');
    } else {
      print('❌ Transaction not found (ID: ${updatedTransaction.transactionId})');
    }
  }

  static Future<void> _updateTransactionInAccounts(Transaction updatedTransaction) async {
    final prefs = await SharedPreferences.getInstance();
    final accountDataListJson = prefs.getString(_accountDataListKey);

    if (accountDataListJson == null) return;

    try {
      final accountDataList = jsonDecode(accountDataListJson) as List<dynamic>;
      bool updated = false;

      for (int bankIndex = 0; bankIndex < accountDataList.length; bankIndex++) {
        final bankData = accountDataList[bankIndex] as Map<String, dynamic>;
        final accounts = (bankData['accounts'] as List<dynamic>? ?? []);

        for (int accountIndex = 0; accountIndex < accounts.length; accountIndex++) {
          final accountJson = accounts[accountIndex] as Map<String, dynamic>;
          final transactions = (accountJson['transactions'] as List<dynamic>? ?? []);

          for (int txIndex = 0; txIndex < transactions.length; txIndex++) {
            final txJson = transactions[txIndex] as Map<String, dynamic>;
            if (txJson['transactionId'] == updatedTransaction.transactionId) {
              // Update this transaction
              transactions[txIndex] = updatedTransaction.toJson();
              accountJson['transactions'] = transactions;
              accounts[accountIndex] = accountJson;
              bankData['accounts'] = accounts;
              accountDataList[bankIndex] = bankData;
              updated = true;
              break;
            }
          }
          if (updated) break;
        }
        if (updated) break;
      }

      if (updated) {
        await prefs.setString(_accountDataListKey, jsonEncode(accountDataList));
      }
    } catch (e) {
      print('Error updating transaction in accountDataList: $e');
    }
  }

  static Future<void> _updateTransactionInSelectedAccount(Transaction updatedTransaction) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedAccountJson = prefs.getString(_selectedAccountKey);

    if (selectedAccountJson == null) return;

    try {
      final selectedAccount = jsonDecode(selectedAccountJson) as Map<String, dynamic>;
      final transactions = (selectedAccount['transactions'] as List<dynamic>? ?? []);

      for (int i = 0; i < transactions.length; i++) {
        final txJson = transactions[i] as Map<String, dynamic>;
        if (txJson['transactionId'] == updatedTransaction.transactionId) {
          transactions[i] = updatedTransaction.toJson();
          selectedAccount['transactions'] = transactions;
          await prefs.setString(_selectedAccountKey, jsonEncode(selectedAccount));
          break;
        }
      }
    } catch (e) {
      print('Error updating transaction in selectedAccount: $e');
    }
  }


  // Delete a transaction
  static Future<void> deleteTransaction(int transactionId) async {
    final transactions = await loadTransactions();

    // Delete from the separate transactions list
    final initialCount = transactions.length;
    transactions.removeWhere((t) => t.transactionId == transactionId);

    if (transactions.length < initialCount) {
      await saveTransactions(transactions);

      // Also delete from all accounts
      await AccountService.deleteTransactionFromAccounts(transactionId);

      print('✅ Deleted transaction (ID: $transactionId)');
    } else {
      print('❌ Transaction not found for deletion (ID: $transactionId)');
    }
  }

  static Future<void> _deleteTransactionFromAccounts(int transactionId) async {
    final prefs = await SharedPreferences.getInstance();
    final accountDataListJson = prefs.getString(_accountDataListKey);

    if (accountDataListJson == null) return;

    try {
      final accountDataList = jsonDecode(accountDataListJson) as List<dynamic>;
      bool deleted = false;

      for (int bankIndex = 0; bankIndex < accountDataList.length; bankIndex++) {
        final bankData = accountDataList[bankIndex] as Map<String, dynamic>;
        final accounts = (bankData['accounts'] as List<dynamic>? ?? []);

        for (int accountIndex = 0; accountIndex < accounts.length; accountIndex++) {
          final accountJson = accounts[accountIndex] as Map<String, dynamic>;
          final transactions = (accountJson['transactions'] as List<dynamic>? ?? []);

          final updatedTransactions = transactions.where((tx) {
            final txJson = tx as Map<String, dynamic>;
            return txJson['transactionId'] != transactionId;
          }).toList();

          if (updatedTransactions.length != transactions.length) {
            accountJson['transactions'] = updatedTransactions;
            accounts[accountIndex] = accountJson;
            bankData['accounts'] = accounts;
            accountDataList[bankIndex] = bankData;
            deleted = true;
            break;
          }
        }
        if (deleted) break;
      }

      if (deleted) {
        await prefs.setString(_accountDataListKey, jsonEncode(accountDataList));
      }
    } catch (e) {
      print('Error deleting transaction from accountDataList: $e');
    }
  }

  static Future<void> _deleteTransactionFromSelectedAccount(int transactionId) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedAccountJson = prefs.getString(_selectedAccountKey);

    if (selectedAccountJson == null) return;

    try {
      final selectedAccount = jsonDecode(selectedAccountJson) as Map<String, dynamic>;
      final transactions = (selectedAccount['transactions'] as List<dynamic>? ?? []);

      final updatedTransactions = transactions.where((tx) {
        final txJson = tx as Map<String, dynamic>;
        return txJson['transactionId'] != transactionId;
      }).toList();

      if (updatedTransactions.length != transactions.length) {
        selectedAccount['transactions'] = updatedTransactions;
        await prefs.setString(_selectedAccountKey, jsonEncode(selectedAccount));
      }
    } catch (e) {
      print('Error deleting transaction from selectedAccount: $e');
    }
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