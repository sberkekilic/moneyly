import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormData {
  String textValue;

  FormData(this.textValue);
}

class FormDataProvider with ChangeNotifier {
  FormData _formData = FormData('');
  List<String> itemList = [];
  List<String> pricesList = [];
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller4 = TextEditingController();

  FormData get formData => _formData;

  Future<void> loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    final textValue = prefs.getString('textValue') ?? '';
    _formData = FormData(textValue);
    controller1.text = textValue;
    controller2.text = textValue;
    controller3.text = textValue;
    controller4.text = textValue;
    itemList = prefs.getStringList('itemList') ?? [];
    pricesList = prefs.getStringList('itemList') ?? [];
    notifyListeners();
  }

  Future<void> updateTextValue(String value, int pageIndex) async {
    notifyListeners();
    _formData = FormData(value);
    itemList.add(value); // Add value to the itemList
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('textValue', value);
    await prefs.setStringList('itemList', itemList);
    await prefs.setStringList('pricesList', pricesList);// Update the itemList in SharedPreferences
    if (pageIndex == 1) {
      controller1.text = value;
    } else if (pageIndex == 2) {
      controller2.text = value;
    } else if (pageIndex == 3) {
      controller3.text = value;
    } else if (pageIndex == 4) {
      controller4.text = value;
    }
    notifyListeners();
  }

  Future<void> updateNumberValue(String value, int pageIndex) async {
    notifyListeners();
    _formData = FormData(value);
    pricesList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('textValue', value);
    await prefs.setStringList('pricesList', pricesList);// Update the itemList in SharedPreferences
    if (pageIndex == 1) {
      controller1.text = value;
    } else if (pageIndex == 2) {
      controller2.text = value;
    } else if (pageIndex == 3) {
      controller3.text = value;
    } else if (pageIndex == 4) {
      controller4.text = value;
    }
    notifyListeners();
  }
}