import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SelectedOption {
  None,
  Is,
  Burs,
  Emekli,
}

class IncomeSelections with ChangeNotifier {
  SelectedOption _selectedOption = SelectedOption.None;

  SelectedOption get selectedOption => _selectedOption;

  String incomeValue = '';

  void setIncomeValue(String value) async {
    incomeValue = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('income_value', value);

    notifyListeners();
  }


  void setSelectedOption(SelectedOption option) {
    _selectedOption = option;
    notifyListeners();
  }
}
