import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/add-expense/faturalar.dart';

class InvoiceService {
  static final InvoiceService _instance = InvoiceService._internal();
  factory InvoiceService() => _instance;
  InvoiceService._internal();

  // MARK: - Date Utilities
  bool isLeapYear(int year) {
    if (year % 4 != 0) return false;
    if (year % 100 != 0) return true;
    return year % 400 == 0;
  }

  String formatPeriodDate(int day, int month, int year) {
    if (month > 12) {
      month = 1;
      year++;
    }

    if (day == 29 && month == 2 && !isLeapYear(year)) {
      day = 28;
    }

    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  String formatDueDate(int? day, String periodDay) {
    DateTime parsedPeriodDay = DateTime.parse(periodDay);
    int month = parsedPeriodDay.month;
    int year = parsedPeriodDay.year;

    if (month > 12) {
      month = 1;
      year++;
    }

    if (day != null && day == 29 && month == 2 && !isLeapYear(year)) {
      day = 28;
    }

    int? calculatedDay = day;
    DateTime calculatedDate = DateTime(year, month, calculatedDay ?? 1);

    if (calculatedDate.isBefore(parsedPeriodDay)) {
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
      calculatedDate = DateTime(year, month, calculatedDay ?? 1);
    }

    return '${calculatedDate.year}-${calculatedDate.month.toString().padLeft(2, '0')}-${calculatedDate.day.toString().padLeft(2, '0')}';
  }

  String calculateDaysRemaining(Invoice invoice) {
    final currentDate = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    final dueDateKnown = invoice.dueDate != null;

    if (currentDate.isBefore(DateTime.parse(invoice.periodDate))) {
      return (DateTime.parse(invoice.periodDate).difference(currentDate).inDays + 1).toString();
    } else if (formattedDate == invoice.periodDate) {
      return "0";
    } else if (dueDateKnown) {
      if (invoice.dueDate != null && currentDate.isAfter(DateTime.parse(invoice.periodDate))) {
        return (DateTime.parse(invoice.dueDate!).difference(currentDate).inDays + 1).toString();
      } else {
        return "error1";
      }
    } else {
      return "error2";
    }
  }

  String? calculateNewDiff(String? dueDate, String periodDate) {
    final currentDate = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    final dueDateKnown = dueDate != null;

    if (currentDate.isBefore(DateTime.parse(periodDate))) {
      return (DateTime.parse(periodDate).difference(currentDate).inDays + 1).toString();
    } else if (formattedDate == periodDate) {
      return "0";
    } else if (dueDateKnown) {
      if (currentDate.isAfter(DateTime.parse(periodDate))) {
        return (DateTime.parse(dueDate).difference(currentDate).inDays + 1).toString();
      } else {
        return "error1";
      }
    } else {
      return "error2";
    }
  }

  DateTime incrementMonth(DateTime date) {
    int nextMonth = date.month + 1;
    int nextYear = date.year;

    if (nextMonth > 12) {
      nextMonth = 1;
      nextYear++;
    }

    int lastDayOfNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
    int adjustedDay = date.day > lastDayOfNextMonth ? lastDayOfNextMonth : date.day;

    return DateTime(nextYear, nextMonth, adjustedDay);
  }

  // MARK: - Invoice Operations
  Future<void> saveInvoices(List<Invoice> invoices) async {
    final prefs = await SharedPreferences.getInstance();
    final invoiceList = invoices.map((invoice) => invoice.toJson()).toList();
    await prefs.setStringList('invoices',
        invoiceList.map((invoice) => jsonEncode(invoice)).toList());
  }

  Future<List<Invoice>> loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final savedInvoicesJson = prefs.getStringList('invoices');

    if (savedInvoicesJson == null) return [];

    List<Invoice> invoices = savedInvoicesJson
        .map((json) => Invoice.fromJson(jsonDecode(json)))
        .toList();

    for (var invoice in invoices) {
      if (invoice.dueDate != null) {
        invoice.updateDifference(invoice, invoice.periodDate, invoice.dueDate);
      } else {
        invoice.updateDifference(invoice, invoice.periodDate, null);
      }
    }

    invoices.sort((a, b) => int.parse(a.difference).compareTo(int.parse(b.difference)));
    return invoices;
  }

  void editInvoice(List<Invoice> invoices, int id, String periodDate, String? dueDate) {
    int index = invoices.indexWhere((invoice) => invoice.id == id);
    if (index != -1) {
      final invoice = invoices[index];
      invoice.periodDate = periodDate;
      String diff = calculateDaysRemaining(invoice);

      final updatedInvoice = Invoice(
          id: invoice.id,
          price: invoice.price,
          subCategory: invoice.subCategory,
          category: invoice.category,
          name: invoice.name,
          periodDate: invoice.periodDate,
          dueDate: dueDate,
          difference: diff
      );
      invoices[index] = updatedInvoice;
    }
  }

  void payInvoice(List<Invoice> invoices, Invoice invoice, int id) {
    int index = invoices.indexWhere((invoice) => invoice.id == id);

    DateTime originalPeriodDate = DateTime.parse(invoice.periodDate);
    DateTime newPeriodDate = incrementMonth(originalPeriodDate);
    String stringPeriodDate = DateFormat('yyyy-MM-dd').format(newPeriodDate);

    String? stringDueDate;
    if (invoice.dueDate != null) {
      DateTime originalDueDate = DateTime.parse(invoice.dueDate!);
      DateTime newDueDate = incrementMonth(originalDueDate);
      stringDueDate = DateFormat('yyyy-MM-dd').format(newDueDate);
    }

    String? diff = calculateNewDiff(stringDueDate, stringPeriodDate);

    final updatedInvoice = Invoice(
        id: invoice.id,
        price: invoice.price,
        subCategory: invoice.subCategory,
        category: invoice.category,
        name: invoice.name,
        periodDate: stringPeriodDate,
        dueDate: stringDueDate,
        difference: diff!
    );

    invoices[index] = updatedInvoice;
  }

  List<int> getIdsWithSubcategory(List<Invoice> invoices, String subCategory) {
    return invoices
        .where((invoice) => invoice.subCategory == subCategory)
        .map((invoice) => invoice.id)
        .toList();
  }

  double calculateSubcategorySum(List<Invoice> invoices, String subcategory) {
    double sum = 0.0;
    for (var invoice in invoices) {
      if (invoice.subCategory == subcategory) {
        sum += double.parse(invoice.price);
      }
    }
    return sum;
  }

  double calculateCategorySum(List<Invoice> invoices, String category) {
    double sum = 0.0;
    for (var invoice in invoices) {
      if (invoice.category == category) {
        sum += double.parse(invoice.price);
      }
    }
    return sum;
  }
}