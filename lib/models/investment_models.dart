import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Investment {
  int id;
  String category;
  String currency;
  String name;
  DateTime? deadline;
  String amount;

  Investment({
    required this.name,
    this.deadline,
    required this.id,
    required this.category,
    required this.amount,
    required this.currency,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'currency': currency,
      'name': name,
      'deadline': deadline?.toIso8601String(),
      'amount': amount,
    };
  }

  factory Investment.fromMap(Map<String, dynamic> map) {
    return Investment(
      id: map['id'] ?? 0,
      category: map['category'] ?? '',
      currency: map['currency'] ?? '',
      name: map['name'] ?? '',
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      amount: map['amount'] ?? '',
    );
  }
}

class InvestmentModel {
  final int id;
  final double aim;
  final double amount;

  InvestmentModel({required this.id, required this.aim, required this.amount});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'aim': aim,
      'amount': amount,
    };
  }

  factory InvestmentModel.fromMap(Map<String, dynamic> map) {
    return InvestmentModel(
      id: map['id'],
      aim: map['aim'],
      amount: map['amount'],
    );
  }
}

class InvestmentService {
  static const String _key = 'investments';
  static const String _modelKey = 'exchangeDollarList';

  Future<void> saveInvestment(Investment investment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> investments = prefs.getStringList(_key) ?? [];
    investments.add(jsonEncode(investment.toMap()));
    await prefs.setStringList(_key, investments);
  }

  Future<void> saveInvestmentModel(InvestmentModel investment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> investments = prefs.getStringList(_modelKey) ?? [];
    investments.add(jsonEncode(investment.toMap()));
    await prefs.setStringList(_modelKey, investments);
  }

  Future<List<Investment>> getInvestments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> investments = prefs.getStringList(_key) ?? [];
    return investments.map((e) => Investment.fromMap(jsonDecode(e))).toList();
  }

  Future<List<InvestmentModel>> getInvestmentModels() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> investments = prefs.getStringList(_modelKey) ?? [];
    return investments.map((e) => InvestmentModel.fromMap(jsonDecode(e))).toList();
  }

  Future<void> clearInvestments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}