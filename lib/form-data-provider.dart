import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormData {
  String textValue;

  FormData(this.textValue);
}

class FormDataProvider with ChangeNotifier {
  FormData _formData = FormData('');

  List<String> tvTitleList = [];
  List<String> tvPriceList = [];
  String sumOfTV = "";

  List<String> gamingTitleList = [];
  List<String> gamingPriceList = [];
  String sumOfGaming = "";

  List<String> musicTitleList = [];
  List<String> musicPriceList = [];
  String sumOfMusic = "";

  List<String> homeBillsTitleList = [];
  List<String> homeBillsPriceList = [];
  String sumOfHomeBills = "";

  List<String> internetTitleList = [];
  List<String> internetPriceList = [];
  String sumOfInternet = "";

  List<String> phoneTitleList = [];
  List<String> phonePriceList = [];
  String sumOfPhone = "";

  List<String> rentTitleList = [];
  List<String> rentPriceList = [];
  String sumOfRent = "";

  List<String> kitchenTitleList = [];
  List<String> kitchenPriceList = [];
  String sumOfKitchen = "";

  List<String> cateringTitleList = [];
  List<String> cateringPriceList = [];
  String sumOfCatering = "";

  List<String> entertainmentTitleList = [];
  List<String> entertainmentPriceList = [];
  String sumOfEntertainment = "";

  List<String> otherTitleList = [];
  List<String> otherPriceList = [];
  String sumOfOther = "";

  FormData get formData => _formData;

  Future<void> loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    final textValue = prefs.getString('textValue') ?? '';
    _formData = FormData(textValue);
    tvTitleList = prefs.getStringList('itemList') ?? [];
    tvPriceList = prefs.getStringList('pricesList') ?? [];
    homeBillsTitleList = prefs.getStringList('itemListHomeBills') ?? [];
    homeBillsPriceList = prefs.getStringList('pricesListHomeBills') ?? [];
    notifyListeners();
  }

  Future<void> updateTextValue(String value, int pageIndex, int orderIndex) async {
    notifyListeners();
    _formData = FormData(value);
    if (pageIndex == 1) {
    } else if (pageIndex == 2) {
      if (orderIndex == 1)
      tvTitleList.add(value);
      if (orderIndex == 2)
      gamingTitleList.add(value);
      if (orderIndex == 3)
      musicTitleList.add(value);
    } else if (pageIndex == 3) {
      if (orderIndex == 1)
      homeBillsTitleList.add(value);
      if (orderIndex == 2)
      internetTitleList.add(value);
      if (orderIndex == 3)
      phoneTitleList.add(value);
    } else if (pageIndex == 4) {
      if (orderIndex == 1)
      rentTitleList.add(value);
      if (orderIndex == 2)
      kitchenTitleList.add(value);
      if (orderIndex == 3)
      cateringTitleList.add(value);
      if (orderIndex == 4)
      entertainmentTitleList.add(value);
      if (orderIndex == 5)
        otherTitleList.add(value);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('textValue', value);
    await prefs.setStringList('itemList', tvTitleList);
    await prefs.setStringList('pricesList', tvPriceList);// Update the itemList in SharedPreferences
    notifyListeners();
  }

  Future<void> updateNumberValue(String value, int pageIndex, int orderIndex) async {
    notifyListeners();
    _formData = FormData(value);
    if (pageIndex == 1) {
    } else if (pageIndex == 2) {
      if (orderIndex == 1)
      tvPriceList.add(value);
      if (orderIndex == 2)
      gamingPriceList.add(value);
      if (orderIndex == 3)
      musicPriceList.add(value);
    } else if (pageIndex == 3) {
      if (orderIndex == 1)
      homeBillsPriceList.add(value);
      if (orderIndex == 2)
      internetPriceList.add(value);
      if (orderIndex == 3)
      phonePriceList.add(value);
    } else if (pageIndex == 4) {
      if (orderIndex == 1)
      rentPriceList.add(value);
      if (orderIndex == 2)
      kitchenPriceList.add(value);
      if (orderIndex == 3)
      cateringPriceList.add(value);
      if (orderIndex == 4)
      entertainmentPriceList.add(value);
      if (orderIndex == 5)
        otherPriceList.add(value);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('textValue', value);
    await prefs.setStringList('pricesList', tvPriceList);// Update the itemList in SharedPreferences
    notifyListeners();
  }
}