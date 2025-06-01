import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Account {
  int accountId;
  String name;
  String type;
  double? balance;
  List<dynamic> transactions;
  List<dynamic> debts;
  String currency;
  bool isDebit;

  // Kredi kartı bilgileri
  double? creditLimit;
  double? availableCredit;
  double? remainingDebt;
  double? minPayment;
  double? remainingMinPayment;
  double? previousDebt;
  double? totalDebt;
  double? currentDebt;
  int cutoffDate;

  // Dönem bilgileri
  DateTime? previousCutoffDate;
  DateTime? nextCutoffDate;
  DateTime? previousDueDate;
  DateTime? nextDueDate;

  Account({
    required this.accountId,
    required this.name,
    required this.type,
    this.balance,
    this.transactions = const [],
    this.debts = const [],
    required this.currency,
    required this.isDebit,
    this.creditLimit,
    this.availableCredit,
    this.remainingDebt,
    this.minPayment,
    this.remainingMinPayment,
    this.previousDebt,
    this.totalDebt,
    this.currentDebt,
    required this.cutoffDate,
    this.previousCutoffDate,
    this.nextCutoffDate,
    this.previousDueDate,
    this.nextDueDate,
  });

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    String? formatDate(DateTime? date) =>
        date != null ? dateFormat.format(date) : null;

    return {
      'accountId': accountId,
      'name': name,
      'type': type,
      'balance': balance,
      'transactions': transactions,
      'debts': debts,
      'currency': currency,
      'isDebit': isDebit,
      'creditLimit': creditLimit,
      'availableCredit': availableCredit,
      'remainingDebt': remainingDebt,
      'minPayment': minPayment,
      'remainingMinPayment': remainingMinPayment,
      'previousDebt': previousDebt,
      'totalDebt': totalDebt,
      'currentDebt': currentDebt,
      'cutoffDate': cutoffDate,
      'previousCutoffDate': formatDate(previousCutoffDate),
      'nextCutoffDate': formatDate(nextCutoffDate),
      'previousDueDate': formatDate(previousDueDate),
      'nextDueDate': formatDate(nextDueDate),
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    DateTime? parseDate(String? date) =>
        date != null ? dateFormat.parse(date) : null;

    return Account(
      accountId: json['accountId'],
      name: json['name'],
      type: json['type'],
      balance: (json['balance'] ?? 0.0).toDouble(),
      transactions: json['transactions'] ?? [],
      debts: json['debts'] ?? [],
      currency: json['currency'] ?? '',
      isDebit: json['isDebit'] ?? true,
      creditLimit: (json['creditLimit'] ?? 0.0).toDouble(),
      availableCredit: (json['availableCredit'] ?? 0.0).toDouble(),
      remainingDebt: (json['remainingDebt'] ?? 0.0).toDouble(),
      minPayment: (json['minPayment'] ?? 0.0).toDouble(),
      remainingMinPayment: (json['remainingMinPayment'] ?? 0.0).toDouble(),
      previousDebt: (json['previousDebt'] ?? 0.0).toDouble(),
      totalDebt: (json['totalDebt'] ?? 0.0).toDouble(),
      currentDebt: (json['currentDebt'] ?? 0.0).toDouble(),
      cutoffDate: json['cutoffDate'] ?? 1,
      previousCutoffDate: parseDate(json['previousCutoffDate']),
      nextCutoffDate: parseDate(json['nextCutoffDate']),
      previousDueDate: parseDate(json['previousDueDate']),
      nextDueDate: parseDate(json['nextDueDate']),
    );
  }

  // Kredi kartı asgari ödeme hesaplama
  double calculateMinPayment() {
    print("calculateMinPayment ÇALIŞIYOR... ${totalDebt.toString()}");
    if (creditLimit == null || totalDebt == null) return 0.0;
    if (creditLimit! < 25000) {
      return totalDebt! * 0.20; // %20
    } else if (creditLimit! > 50000) {
      return totalDebt! * 0.40; // %40
    } else {
      return totalDebt! * 0.30; // %30 (orta seviye)
    }
  }

  // Hesap kesim günü haftasonuna denk gelirse bir sonraki iş gününe kaydır
  DateTime getActualCutoffDate(DateTime baseDate) {
    DateTime tentativeDate = DateTime(baseDate.year, baseDate.month, cutoffDate);
    while (tentativeDate.weekday == DateTime.saturday || tentativeDate.weekday == DateTime.sunday) {
      tentativeDate = tentativeDate.add(const Duration(days: 1));
    }
    return tentativeDate;
  }

  void updateCreditDates({DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    final thisMonthCutoff = getActualCutoffDate(DateTime(now.year, now.month, 1));

    if (now.isBefore(thisMonthCutoff)) {
      // Hâlâ önceki dönemdeyiz
      final previousMonth = DateTime(now.year, now.month - 1, 1);
      final previousCutoff = getActualCutoffDate(previousMonth);
      final nextCutoff = thisMonthCutoff;

      previousCutoffDate = previousCutoff;
      nextCutoffDate = nextCutoff;

      previousDueDate = previousCutoff.add(const Duration(days: 10));
      nextDueDate = nextCutoff.add(const Duration(days: 10));
    } else {
      // Yeni döneme girdik
      final previousCutoff = thisMonthCutoff;
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      final nextCutoff = getActualCutoffDate(nextMonth);

      previousCutoffDate = previousCutoff;
      nextCutoffDate = nextCutoff;

      previousDueDate = previousCutoff.add(const Duration(days: 10));
      nextDueDate = nextCutoff.add(const Duration(days: 10));
    }
  }

  // Önceki dönemin başlangıç ve bitiş tarihini hesapla
  Map<String, DateTime> getPreviousPeriod(DateTime today) {
    DateTime currentCutoff = getActualCutoffDate(today);

    // Eğer bugün kesim tarihinden önceyse, bir önceki aya geç
    if (today.isBefore(currentCutoff)) {
      DateTime lastMonth = DateTime(today.year, today.month == 1 ? 12 : today.month - 1, 1);
      DateTime lastCutoff = getActualCutoffDate(lastMonth);
      DateTime prevCutoff = getActualCutoffDate(DateTime(lastCutoff.year, lastCutoff.month - 1, 1));
      return {
        'start': prevCutoff,
        'end': lastCutoff.subtract(const Duration(days: 1)),
      };
    } else {
      // Bu ayın dönemi
      DateTime prevCutoff = getActualCutoffDate(DateTime(today.year, today.month - 1, 1));
      return {
        'start': prevCutoff,
        'end': currentCutoff.subtract(const Duration(days: 1)),
      };
    }
  }

  // Bu döneme ait işlemleri getir (kredi kartı için)
  List<Map<String, dynamic>> getCurrentPeriodTransactions() {
    DateTime today = DateTime.now();
    DateTime start = getPreviousPeriod(today)['end']!.add(const Duration(days: 1));
    DateTime end = getActualCutoffDate(today);

    return transactions
        .where((tx) {
      final date = DateTime.tryParse(tx['date']) ?? DateTime.now();
      return !tx['isSurplus'] && date.isAfter(start.subtract(const Duration(days: 1))) && date.isBefore(end.add(const Duration(days: 1)));
    })
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  // Önceki dönemden kalan borcu hesapla
  double getDebtCarriedFromPreviousPeriod() {
    DateTime today = DateTime.now();
    final previousPeriod = getPreviousPeriod(today);
    final start = previousPeriod['start']!;
    final end = previousPeriod['end']!;

    final previousTransactions = transactions.where((tx) {
      // Use dot notation to access the 'date' and 'isSurplus' properties
      final date = tx.date;
      return !tx.isSurplus && date.isAfter(start.subtract(const Duration(days: 1))) && date.isBefore(end.add(const Duration(days: 1)));
    });

    double total = 0.0;
    for (var tx in previousTransactions) {
      total += tx.amount;
    }
    return total;
  }
}

class AccountCard extends StatelessWidget {
  final Account account;

  const AccountCard({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCreditCard = !account.isDebit;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: GoogleFonts.montserrat(
                            fontSize: 12.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        account.type,
                        style: GoogleFonts.montserrat(
                            fontSize: 8.sp, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat("#,##0.00", "tr_TR").format(account.balance),
                      style: GoogleFonts.montserrat(fontSize: 10.sp),
                    ),
                    if (isCreditCard) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'Limit: ${NumberFormat("#,##0.00", "tr_TR").format(account.creditLimit ?? 0)}',
                        style: GoogleFonts.montserrat(fontSize: 8.sp),
                      ),
                      Text(
                        'Borç: ${NumberFormat("#,##0.00", "tr_TR").format(account.previousDebt ?? 0)}',
                        style: GoogleFonts.montserrat(fontSize: 8.sp),
                      ),
                      Text(
                        'Min. Ödeme: ${NumberFormat("#,##0.00", "tr_TR").format(account.minPayment ?? 0)}',
                        style: GoogleFonts.montserrat(fontSize: 8.sp),
                      ),
                    ],
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