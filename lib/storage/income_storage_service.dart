import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/income_model.dart';

class IncomeStorageService {
  static const String _incomesKey = 'personal_incomes';
  static const String _incomeSummaryKey = 'income_summary';

  // Save all incomes
  static Future<void> saveIncomes(List<Income> incomes) async {
    final prefs = await SharedPreferences.getInstance();
    final incomesJson = incomes.map((income) => income.toJson()).toList();
    await prefs.setString(_incomesKey, json.encode(incomesJson));
  }

  // Load all incomes
  static Future<List<Income>> loadIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final incomesJson = prefs.getString(_incomesKey);

    if (incomesJson == null) return [];

    try {
      final List<dynamic> decoded = json.decode(incomesJson);
      return decoded.map((json) => Income.fromJson(json)).toList();
    } catch (e) {
      print('Error loading incomes: $e');
      return [];
    }
  }

  // Add new income
  static Future<void> addIncome(Income income) async {
    final incomes = await loadIncomes();
    incomes.add(income);
    await saveIncomes(incomes);
    await _updateIncomeSummary(incomes);
  }

  // Delete income
  static Future<void> deleteIncome(int incomeId) async {
    final incomes = await loadIncomes();
    incomes.removeWhere((income) => income.incomeId == incomeId);
    await saveIncomes(incomes);
    await _updateIncomeSummary(incomes);
  }

  // Get incomes by account ID
  static Future<List<Income>> getIncomesByAccountId(int accountId) async {
    final incomes = await loadIncomes();
    return incomes.where((income) => income.accountId == accountId).toList();
  }

  // Get incomes by source
  static Future<List<Income>> getIncomesBySource(String source) async {
    final incomes = await loadIncomes();
    return incomes.where((income) => income.source == source).toList();
  }

  // Get total income by account - FIXED VERSION
  static Future<double> getTotalIncomeByAccount(int accountId) async {
    final accountIncomes = await getIncomesByAccountId(accountId);
    double total = 0.0;
    for (final income in accountIncomes) {
      total += income.amount;
    }
    return total;
  }

  // Get total income by source - FIXED VERSION
  static Future<double> getTotalIncomeBySource(String source) async {
    final sourceIncomes = await getIncomesBySource(source);
    double total = 0.0;
    for (final income in sourceIncomes) {
      total += income.amount;
    }
    return total;
  }

  // Get all-time total income - FIXED VERSION
  static Future<double> getTotalIncome() async {
    final incomes = await loadIncomes();
    double total = 0.0;
    for (final income in incomes) {
      total += income.amount;
    }
    return total;
  }

  // Update income summary for quick access
  static Future<void> _updateIncomeSummary(List<Income> incomes) async {
    final prefs = await SharedPreferences.getInstance();

    // Calculate totals by source using simple loops
    double workIncome = 0.0;
    double scholarshipIncome = 0.0;
    double pensionIncome = 0.0;

    for (final income in incomes) {
      switch (income.source) {
        case 'İş':
          workIncome += income.amount;
          break;
        case 'Burs':
          scholarshipIncome += income.amount;
          break;
        case 'Emekli':
          pensionIncome += income.amount;
          break;
      }
    }

    final totalIncome = workIncome + scholarshipIncome + pensionIncome;

    final summary = {
      'work': workIncome,
      'scholarship': scholarshipIncome,
      'pension': pensionIncome,
      'total': totalIncome,
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_incomeSummaryKey, json.encode(summary));
  }

  // Get income summary
  static Future<Map<String, dynamic>> getIncomeSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final summaryJson = prefs.getString(_incomeSummaryKey);

    if (summaryJson == null) {
      return {
        'work': 0.0,
        'scholarship': 0.0,
        'pension': 0.0,
        'total': 0.0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }

    try {
      return Map<String, dynamic>.from(json.decode(summaryJson));
    } catch (e) {
      print('Error loading income summary: $e');
      return {
        'work': 0.0,
        'scholarship': 0.0,
        'pension': 0.0,
        'total': 0.0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }

  // Get monthly income breakdown - FIXED VERSION
  static Future<Map<String, double>> getMonthlyIncomeBreakdown() async {
    final incomes = await loadIncomes();
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);

    double workIncome = 0.0;
    double scholarshipIncome = 0.0;
    double pensionIncome = 0.0;
    double totalIncome = 0.0;

    for (final income in incomes) {
      if (income.date.isAfter(currentMonth.subtract(Duration(days: 1))) &&
          income.date.isBefore(nextMonth)) {

        totalIncome += income.amount;

        switch (income.source) {
          case 'İş':
            workIncome += income.amount;
            break;
          case 'Burs':
            scholarshipIncome += income.amount;
            break;
          case 'Emekli':
            pensionIncome += income.amount;
            break;
        }
      }
    }

    return {
      'work': workIncome,
      'scholarship': scholarshipIncome,
      'pension': pensionIncome,
      'total': totalIncome,
    };
  }

  // Get income by date range
  static Future<List<Income>> getIncomesByDateRange(DateTime start, DateTime end) async {
    final incomes = await loadIncomes();
    return incomes.where((income) =>
    income.date.isAfter(start.subtract(Duration(days: 1))) &&
        income.date.isBefore(end.add(Duration(days: 1)))
    ).toList();
  }

  // Get total income by date range
  static Future<double> getTotalIncomeByDateRange(DateTime start, DateTime end) async {
    final rangeIncomes = await getIncomesByDateRange(start, end);
    double total = 0.0;
    for (final income in rangeIncomes) {
      total += income.amount;
    }
    return total;
  }

  // Get income statistics by account
  static Future<Map<String, dynamic>> getAccountIncomeStatistics(int accountId) async {
    final accountIncomes = await getIncomesByAccountId(accountId);

    if (accountIncomes.isEmpty) {
      return {
        'total': 0.0,
        'count': 0,
        'average': 0.0,
        'sources': {},
      };
    }

    double total = 0.0;
    final sources = <String, double>{};

    for (final income in accountIncomes) {
      total += income.amount;
      sources[income.source] = (sources[income.source] ?? 0.0) + income.amount;
    }

    final average = total / accountIncomes.length;

    return {
      'total': total,
      'count': accountIncomes.length,
      'average': average,
      'sources': sources,
    };
  }

  // Get all accounts that have received income
  static Future<Set<int>> getAccountsWithIncome() async {
    final incomes = await loadIncomes();
    final accountIds = <int>{};
    for (final income in incomes) {
      accountIds.add(income.accountId);
    }
    return accountIds;
  }

  // Get income distribution by account
  static Future<Map<int, double>> getIncomeDistributionByAccount() async {
    final incomes = await loadIncomes();
    final distribution = <int, double>{};

    for (final income in incomes) {
      distribution[income.accountId] = (distribution[income.accountId] ?? 0.0) + income.amount;
    }

    return distribution;
  }
}