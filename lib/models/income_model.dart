import 'package:intl/intl.dart';

class Income {
  final int incomeId;
  final int accountId;
  final String accountName;
  final String source; // İş, Burs, Emekli, etc.
  final double amount;
  final DateTime date;
  final String currency;
  final String description;

  Income({
    required this.incomeId,
    required this.accountId,
    required this.accountName,
    required this.source,
    required this.amount,
    required this.date,
    required this.currency,
    this.description = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'incomeId': incomeId,
      'accountId': accountId,
      'accountName': accountName,
      'source': source,
      'amount': amount,
      'date': date.toIso8601String(),
      'currency': currency,
      'description': description,
    };
  }

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      incomeId: json['incomeId'],
      accountId: json['accountId'],
      accountName: json['accountName'],
      source: json['source'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      currency: json['currency'],
      description: json['description'] ?? '',
    );
  }

  String toDisplayString() {
    final format = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);
    return 'ID: $incomeId\nAccount: $accountName\nSource: $source\nAmount: ${format.format(amount)}\nDate: ${DateFormat('dd/MM/yyyy').format(date)}\nCurrency: $currency';
  }

  Income copyWith({
    int? incomeId,
    int? accountId,
    String? accountName,
    String? source,
    double? amount,
    DateTime? date,
    String? currency,
    String? description,
  }) {
    return Income(
      incomeId: incomeId ?? this.incomeId,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      source: source ?? this.source,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      currency: currency ?? this.currency,
      description: description ?? this.description,
    );
  }
}