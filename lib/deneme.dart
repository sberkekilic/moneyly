import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormData2 {
  bool hasTVSelected = false;
  bool hasGameSelected = false;
  bool hasMusicSelected = false;
  bool hasHomeSelected = false;
  bool hasInternetSelected = false;
  bool hasPhoneSelected = false;
  bool hasRentSelected = false;
  bool hasKitchenSelected = false;
  bool hasCateringSelected = false;
  bool hasEntertainmentSelected = false;
  bool hasOtherSelected = false;

  List<String> tvTitleList = [];
  List<String> gameTitleList = [];
  List<String> musicTitleList = [];
  List<String> homeBillsTitleList = [];
  List<String> internetTitleList = [];
  List<String> phoneTitleList = [];
  List<String> rentTitleList = [];
  List<String> kitchenTitleList = [];
  List<String> cateringTitleList = [];
  List<String> entertainmentTitleList = [];
  List<String> otherTitleList = [];

  List<String> tvPriceList = [];
  List<String> gamePriceList = [];
  List<String> musicPriceList = [];
  List<String> homeBillsPriceList = [];
  List<String> internetPriceList = [];
  List<String> phonePriceList = [];
  List<String> rentPriceList = [];
  List<String> kitchenPriceList = [];
  List<String> cateringPriceList = [];
  List<String> entertainmentPriceList = [];
  List<String> otherPriceList = [];

  double sumOfTV = 0.0;
  double sumOfGame = 0.0;
  double sumOfMusic = 0.0;
  double sumOfHomeBills = 0.0;
  double sumOfInternet = 0.0;
  double sumOfPhone = 0.0;
  double sumOfRent = 0.0;
  double sumOfKitchen = 0.0;
  double sumOfCatering = 0.0;
  double sumOfEnt = 0.0;
  double sumOfOther = 0.0;
}

class FormDataProvider2 with ChangeNotifier{
  FormData2 _formData2 = FormData2();

  void setTVTitleValue(String value, List<String> list) async {
    _formData2.tvTitleList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tvTitleList2', list);
    notifyListeners();
  }

  void setTVPriceValue(String value, List<String> list) async {
    _formData2.tvPriceList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tvPriceList2', list);
    notifyListeners();
  }

  void setGameTitleValue(String value, List<String> list) async {
    _formData2.gameTitleList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('gameTitleList2', list);
    notifyListeners();
  }

  void setGamePriceValue(String value, List<String> list) async {
    _formData2.gamePriceList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('gamePriceList2', list);
    notifyListeners();
  }

  void setMusicTitleValue(String value, List<String> list) async {
    _formData2.musicTitleList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('musicTitleList2', list);
    notifyListeners();
  }

  void setMusicPriceValue(String value, List<String> list) async {
    _formData2.musicPriceList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('musicPriceList2', list);
    notifyListeners();
  }

  void setHomeTitleValue(String value, List<String> list) async {
    _formData2.homeBillsTitleList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('homeBillsTitleList2', list);
    notifyListeners();
  }

  void setHomePriceValue(String value, List<String> list) async {
    _formData2.homeBillsPriceList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('homeBillsPriceList2', list);
    notifyListeners();
  }

  void setInternetTitleValue(String value, List<String> list) async {
    _formData2.internetTitleList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('internetTitleList2', list);
    notifyListeners();
  }

  void setInternetPriceValue(String value, List<String> list) async {
    _formData2.internetPriceList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('internetPriceList2', list);
    notifyListeners();
  }

  void setPhoneTitleValue(String value, List<String> list) async {
    _formData2.phoneTitleList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('phoneTitleList2', list);
    notifyListeners();
  }

  void setPhonePriceValue(String value, List<String> list) async {
    _formData2.phonePriceList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('phonePriceList2', list);
    notifyListeners();
  }

  void setRentTitleValue(String value, List<String> list) async {
    _formData2.rentTitleList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('rentTitleList2', list);
    notifyListeners();
  }

  void setRentPriceValue(String value, List<String> list) async {
    _formData2.rentPriceList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('rentPriceList2', list);
    notifyListeners();
  }

  void setKitchenTitleValue(String value, List<String> list) async {
    _formData2.kitchenTitleList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('kitchenTitleList2', list);
    notifyListeners();
  }

  void setKitchenPriceValue(String value, List<String> list) async {
    _formData2.kitchenPriceList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('kitchenPriceList2', list);
    notifyListeners();
  }

  void setCateringTitleValue(String value, List<String> list) async {
    _formData2.cateringTitleList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cateringTitleList2', list);
    notifyListeners();
  }

  void setCateringPriceValue(String value, List<String> list) async {
    _formData2.cateringPriceList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cateringPriceList2', list);
    notifyListeners();
  }

  void setEntertainmentTitleValue(String value, List<String> list) async {
    _formData2.entertainmentTitleList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('entertainmentTitleList2', list);
    notifyListeners();
  }

  void setEntertainmentPriceValue(String value, List<String> list) async {
    _formData2.entertainmentPriceList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('entertainmentPriceList2', list);
    notifyListeners();
  }

  void setOtherTitleValue(String value, List<String> list) async {
    _formData2.otherTitleList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('otherTitleList2', list);
    notifyListeners();
  }

  void setOtherPriceValue(String value, List<String> list) async {
    _formData2.otherPriceList.add(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('otherPriceList', list);
    notifyListeners();
  }

  void removeTVTitleValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tvTitleList2', list);
    notifyListeners();
  }

  void removeTVPriceValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tvPriceList2', list);
    notifyListeners();
  }

  void removeGameTitleValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('gameTitleList2', list);
    notifyListeners();
  }

  void removeGamePriceValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('gamePriceList2', list);
    notifyListeners();
  }

  void removeMusicTitleValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('musicTitleList2', list);
    notifyListeners();
  }

  void removeMusicPriceValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('musicPriceList2', list);
    notifyListeners();
  }

  void removeHomeTitleValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('homeBillsTitleList2', list);
    notifyListeners();
  }

  void removeHomePriceValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('homeBillsPriceList2', list);
    notifyListeners();
  }

  void removeInternetTitleValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('internetTitleList2', list);
    notifyListeners();
  }

  void removeInternetPriceValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('internetPriceList2', list);
    notifyListeners();
  }

  void removePhoneTitleValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('phoneTitleList2', list);
    notifyListeners();
  }

  void removePhonePriceValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('phonePriceList2', list);
    notifyListeners();
  }

  void removeRentTitleValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('rentTitleList2', list);
    notifyListeners();
  }

  void removeRentPriceValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('rentPriceList2', list);
    notifyListeners();
  }

  void removeKitchenTitleValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('kitchenTitleList2', list);
    notifyListeners();
  }

  void removeKitchenPriceValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('kitchenPriceList2', list);
    notifyListeners();
  }

  void removeCateringTitleValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cateringTitleList2', list);
    notifyListeners();
  }

  void removeCateringPriceValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cateringPriceList2', list);
    notifyListeners();
  }

  void removeEntertainmentTitleValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('entertainmentTitleList2', list);
    notifyListeners();
  }

  void removeEntertainmentPriceValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('entertainmentPriceList2', list);
    notifyListeners();
  }

  void removeOtherTitleValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('otherTitleList2', list);
    notifyListeners();
  }

  void removeOtherPriceValue(List<String> list) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('otherPriceList2', list);
    notifyListeners();
  }

  void calculateSumOfTV(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    double sum = 0.0;
    for (String price in list) {
      sum += double.tryParse(price) ?? 0.0; // Handle potential parsing errors
    }
    await prefs.setDouble('sumOfTV2', sum);// Update the sumOfTV property
    notifyListeners();
  }

  void calculateSumOfGame(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    double sum = 0.0;
    for (String price in list) {
      sum += double.tryParse(price) ?? 0.0; // Handle potential parsing errors
    }
    await prefs.setDouble('sumOfGame2', sum);// Update the sumOfTV property
    notifyListeners();
  }

  void calculateSumOfMusic(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    double sum = 0.0;
    for (String price in list) {
      sum += double.tryParse(price) ?? 0.0; // Handle potential parsing errors
    }
    await prefs.setDouble('sumOfMusic2', sum);// Update the sumOfTV property
    notifyListeners();
  }

  void calculateSumOfHome(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    double sum = 0.0;
    for (String price in list) {
      sum += double.tryParse(price) ?? 0.0; // Handle potential parsing errors
    }
    await prefs.setDouble('sumOfHome2', sum);// Update the sumOfTV property
    notifyListeners();
  }

  void calculateSumOfInternet(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    double sum = 0.0;
    for (String price in list) {
      sum += double.tryParse(price) ?? 0.0; // Handle potential parsing errors
    }
    await prefs.setDouble('sumOfInternet2', sum);// Update the sumOfTV property
    notifyListeners();
  }

  void calculateSumOfPhone(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    double sum = 0.0;
    for (String price in list) {
      sum += double.tryParse(price) ?? 0.0; // Handle potential parsing errors
    }
    await prefs.setDouble('sumOfPhone2', sum);// Update the sumOfTV property
    notifyListeners();
  }

  void calculateSumOfRent(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    double sum = 0.0;
    for (String price in list) {
      sum += double.tryParse(price) ?? 0.0; // Handle potential parsing errors
    }
    await prefs.setDouble('sumOfRent2', sum);// Update the sumOfTV property
    notifyListeners();
  }

  void calculateSumOfKitchen(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    double sum = 0.0;
    for (String price in list) {
      sum += double.tryParse(price) ?? 0.0; // Handle potential parsing errors
    }
    await prefs.setDouble('sumOfKitchen2', sum);// Update the sumOfTV property
    notifyListeners();
  }

  void calculateSumOfCatering(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    double sum = 0.0;
    for (String price in list) {
      sum += double.tryParse(price) ?? 0.0; // Handle potential parsing errors
    }
    await prefs.setDouble('sumOfCatering2', sum);// Update the sumOfTV property
    notifyListeners();
  }

  void calculateSumOfEnt(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    double sum = 0.0;
    for (String price in list) {
      sum += double.tryParse(price) ?? 0.0; // Handle potential parsing errors
    }
    await prefs.setDouble('sumOfEnt2', sum);// Update the sumOfTV property
    notifyListeners();
  }

  void calculateSumOfOther(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    double sum = 0.0;
    for (String price in list) {
      sum += double.tryParse(price) ?? 0.0; // Handle potential parsing errors
    }
    await prefs.setDouble('sumOfOther2', sum);// Update the sumOfTV property
    notifyListeners();
  }
}