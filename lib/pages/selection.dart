import 'package:flutter/material.dart';
import 'gelir-ekle.dart';

class IncomeSelections with ChangeNotifier {
  String incomeValue = '';
  SelectedOption selectedOption = SelectedOption.None;

  void setIncomeValue(String value) {
    incomeValue = value;
    notifyListeners();
  }

  void setSelectedOption(SelectedOption option) {
    selectedOption = option;
    notifyListeners();
  }

// Add any other selections you want to store
}
