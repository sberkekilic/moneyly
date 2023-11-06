// ignore_for_file: unused_import, avoid_unnecessary_containers

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/pages/selection.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../deneme.dart';
import 'faturalar.dart';

class OutcomePage extends StatefulWidget {
  const OutcomePage({Key? key}) : super(key: key);

  @override
  State<OutcomePage> createState() => _OutcomePageState();
}

class _OutcomePageState extends State<OutcomePage> {
  final List<Invoice> invoices = [];
  int biggestIndex = 0;
  final TextEditingController textController = TextEditingController();
  final TextEditingController platformPriceController = TextEditingController();

  bool isSubsAddActive = false;
  bool hasSubsCategorySelected = false;
  bool isBillsAddActive = false;
  bool hasBillsCategorySelected = false;
  bool isOthersAddActive = false;
  bool hasOthersCategorySelected = false;
  // Initial Selected Value
  String dropdownvaluesubs = 'Film, Dizi ve TV';
  String dropdownvaluebills = 'Ev Faturaları';
  String dropdownvalueothers = 'Kira';

  // List of items in our dropdown menu
  var subsItems = [
    'Film, Dizi ve TV',
    'Oyun',
    'Müzik',
  ];

  var billsItems = [
    'Ev Faturaları',
    'İnternet',
    'Telefon'
  ];

  var othersItems = [
    'Kira',
    'Mutfak',
    'Yeme İçme',
    'Eğlence',
    'Diğer'
  ];


  List<String> tvTitleList = [];
  List<String> gameTitleList = [];
  List<String> musicTitleList = [];
  List<String> tvPriceList = [];
  List<String> gamePriceList = [];
  List<String> musicPriceList = [];

  List<String> homeBillsTitleList = [];
  List<String> internetTitleList = [];
  List<String> phoneTitleList = [];
  List<String> homeBillsPriceList = [];
  List<String> internetPriceList = [];
  List<String> phonePriceList = [];

  List<String> rentTitleList = [];
  List<String> kitchenTitleList = [];
  List<String> cateringTitleList = [];
  List<String> entertainmentTitleList = [];
  List<String> otherTitleList = [];
  List<String> rentPriceList = [];
  List<String> kitchenPriceList = [];
  List<String> cateringPriceList = [];
  List<String> entertainmentPriceList = [];
  List<String> otherPriceList = [];

  double incomeValue = 0.0;
  double outcomeValue = 0.0;
  int subsPercent = 0;
  int billsPercent = 0;
  int othersPercent = 0;
  double savingsValue = 0.0;
  double wishesValue = 0.0;
  double needsValue = 0.0;
  double sumOfSubs = 0.0;
  double sumOfBills = 0.0;
  double sumOfOthers = 0.0;
  double sumOfTV = 0.0;
  double sumOfGame = 0.0;
  double sumOfMusic = 0.0;
  double sumOfHome = 0.0;
  double sumOfInternet = 0.0;
  double sumOfPhone = 0.0;
  double sumOfRent = 0.0;
  double sumOfKitchen = 0.0;
  double sumOfCatering = 0.0;
  double sumOfEnt = 0.0;
  double sumOfOther = 0.0;
  String selectedTitle = '';
  String convertSum = "";
  String convertSum2 = "";
  String convertSum3 = "";

  int? _selectedBillingDay;
  int? _selectedDueDay;
  List<int> daysList = List.generate(31, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _load();
  }

  String labelForOption(SelectedOption option) {
    switch (option) {
      case SelectedOption.Is:
        return 'İş';
      case SelectedOption.Burs:
        return 'Burs';
      case SelectedOption.Emekli:
        return 'Emekli';
      default:
        return '';
    }
  }

  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ab1 = prefs.getInt('selected_option') ?? SelectedOption.None.index;
    final ab2 = prefs.getString('income_value') ?? '0';
    final ab3 = prefs.getDouble('sumOfTV2') ?? 0.0;
    final ab4 = prefs.getDouble('sumOfGame2') ?? 0.0;
    final ab5 = prefs.getDouble('sumOfMusic2') ?? 0.0;
    final ab6 = prefs.getDouble('sumOfHome2') ?? 0.0;
    final ab7 = prefs.getDouble('sumOfInternet2') ?? 0.0;
    final ab8 = prefs.getDouble('sumOfPhone2') ?? 0.0;
    final ab9 = prefs.getDouble('sumOfRent2') ?? 0.0;
    final ab10 = prefs.getDouble('sumOfKitchen2') ?? 0.0;
    final ab11 = prefs.getDouble('sumOfCatering2') ?? 0.0;
    final ab12 = prefs.getDouble('sumOfEnt2') ?? 0.0;
    final ab13 = prefs.getDouble('sumOfOther2') ?? 0.0;
    final ab14 = prefs.getDouble('sumOfSubs2') ?? 0.0;
    final ab15 = prefs.getDouble('sumOfBills2') ?? 0.0;
    final ab16 = prefs.getDouble('sumOfOthers2') ?? 0.0;
    final ab17 = prefs.getStringList('tvTitleList2') ?? [];
    final ab18 = prefs.getStringList('gameTitleList2') ?? [];
    final ab19 = prefs.getStringList('musicTitleList2') ?? [];
    final ab20 = prefs.getStringList('homeBillsTitleList2') ?? [];
    final ab21 = prefs.getStringList('internetTitleList2') ?? [];
    final ab22 = prefs.getStringList('phoneTitleList2') ?? [];
    final ab23 = prefs.getStringList('rentTitleList2') ?? [];
    final ab24 = prefs.getStringList('kitchenTitleList2') ?? [];
    final ab25 = prefs.getStringList('cateringTitleList2') ?? [];
    final ab26 = prefs.getStringList('entertainmentTitleList2') ?? [];
    final ab27 = prefs.getStringList('otherTitleList2') ?? [];
    final ab28 = prefs.getStringList('tvPriceList2') ?? [];
    final ab29 = prefs.getStringList('gamePriceList2') ?? [];
    final ab30 = prefs.getStringList('musicPriceList2') ?? [];
    final ab31 = prefs.getStringList('homeBillsPriceList2') ?? [];
    final ab32 = prefs.getStringList('internetPriceList2') ?? [];
    final ab33 = prefs.getStringList('phonePriceList2') ?? [];
    final ab34 = prefs.getStringList('rentPriceList2') ?? [];
    final ab35 = prefs.getStringList('kitchenPriceList2') ?? [];
    final ab36 = prefs.getStringList('cateringPriceList2') ?? [];
    final ab37 = prefs.getStringList('entertainmentPriceList2') ?? [];
    final ab38 = prefs.getStringList('otherPriceList2') ?? [];
    final ab39 = prefs.getStringList('invoices') ?? [];
    setState(() {
      selectedTitle = labelForOption(SelectedOption.values[ab1]);
      incomeValue = NumberFormat.decimalPattern('tr_TR').parse(ab2) as double;
      sumOfTV = ab3;
      sumOfGame = ab4;
      sumOfMusic = ab5;
      sumOfHome = ab6;
      sumOfInternet = ab7;
      sumOfPhone = ab8;
      sumOfRent = ab9;
      sumOfKitchen = ab10;
      sumOfCatering = ab11;
      sumOfEnt = ab12;
      sumOfOther = ab13;
      sumOfSubs = ab14;
      sumOfBills = ab15;
      sumOfOthers = ab16;
      tvTitleList = ab17;
      gameTitleList = ab18;
      musicTitleList = ab19;
      homeBillsTitleList = ab20;
      internetTitleList = ab21;
      phoneTitleList = ab22;
      rentTitleList = ab23;
      kitchenTitleList = ab24;
      cateringTitleList = ab25;
      entertainmentTitleList = ab26;
      otherTitleList = ab27;
      tvPriceList = ab28;
      gamePriceList = ab29;
      musicPriceList = ab30;
      homeBillsPriceList = ab31;
      internetPriceList = ab32;
      phonePriceList = ab33;
      rentPriceList = ab34;
      kitchenPriceList = ab35;
      cateringPriceList = ab36;
      entertainmentPriceList = ab37;
      otherPriceList = ab38;
      for (final invoiceString in ab39) {
        final Map<String, dynamic> invoiceJson = jsonDecode(invoiceString);
        final Invoice invoice = Invoice.fromJson(invoiceJson);
        invoices.add(invoice);
        print("INVOICE LENGTH E08 : ${invoices.length}");
      }
    });
    convertSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfTV);
    convertSum2 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfGame);
    convertSum3 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfMusic);
  }

  Future<void> setSumAll(double value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('sumOfSubs2', value);
  }

  Future<void> saveInvoices() async {
    print("INVOICE LENGTH E06 : ${invoices.length}");
    final invoicesCopy = invoices.toList();
    final prefs = await SharedPreferences.getInstance();
    final invoiceList = invoicesCopy.map((invoice) => invoice.toJson()).toList();
    await prefs.setStringList('invoices', invoiceList.map((invoice) => jsonEncode(invoice)).toList());
    print("INVOICE LENGTH E07 : ${invoices.length}");
  }

  void removeInvoice(int id) {
    setState(() {
      int index = invoices.indexWhere((invoice) => invoice.id == id);
      if (index != -1) {
        setState(() {
          invoices.removeAt(index);
        });
      } else {
        // Entry with the target ID not found
      }
    });
    saveInvoices();
  }

  DateTime faturaDonemi = DateTime.now();
  DateTime sonOdeme = DateTime.now();

  void formatDate(int day) {
    final currentDate = DateTime.now();
    int year = currentDate.year;
    int month = currentDate.month;

    // Handle the case where the day is greater than the current day
    if (day > currentDate.day) {
      // Set the period month to the current month
      month = currentDate.month;
    } else {
      // Increase the month by one if needed
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }

    // Handle the case where the day is 29th February and it's not a leap year
    if (day == 29 && month == 2 && !isLeapYear(year)) {
      day = 28;
    }

    faturaDonemi = DateTime(year, month, day);
  }

  void formatDate2(int day, Invoice invoice) {
    final currentDate = DateTime.now();
    int year = currentDate.year;
    int month = currentDate.month;

    // Handle the case where the day is greater than the current day
    if (day > currentDate.day && invoice != null && invoice.dueDate != null) {
      // Set the period month to the current month
      month = currentDate.month;
    } else {
      // Increase the month by one if needed
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }

    // Handle the case where the day is 29th February and it's not a leap year
    if (day == 29 && month == 2 && !isLeapYear(year)) {
      day = 28;
    }

    sonOdeme = DateTime(year, month, day);
  }

  bool isLeapYear(int year) {
    if (year % 4 != 0) return false;
    if (year % 100 != 0) return true;
    return year % 400 == 0;
  }

  String getDaysRemainingMessage(Invoice invoice, int periodDate) {
    print("INVOICE PERIOD DATE INSIDE DIFF : ${invoice.periodDate}");
    formatDate(periodDate);
    formatDate2(invoice.dueDate ?? invoice.periodDate, invoice);
    final currentDate = DateTime.now();
    final dueDateKnown = invoice.dueDate != null;

    if (currentDate.isBefore(faturaDonemi)) {
      invoice.difference = faturaDonemi.difference(currentDate).inDays.toString();
      print("invoice.difference1:${invoice.difference}");
      return invoice.difference;
    } else if (dueDateKnown) {
      if (currentDate.isBefore(sonOdeme)) {
        invoice.difference = sonOdeme.difference(currentDate).inDays.toString();
        print("invoice.difference2:${invoice.difference}");
        return invoice.difference;
      } else {
        print("invoice.difference3:${invoice.difference}");
        return invoice.difference;
      }
    } else {
      print("invoice.difference4:${invoice.difference}");
      return invoice.difference;
    }
  }

  void editInvoice(int id, int periodDate, int? dueDate) {
    print("INVOICE LENGTH E02 : ${invoices.length}");
    int index = invoices.indexWhere((invoice) => invoice.id == id);
    if (index != -1) {
      setState(() {
        final invoice = invoices[index];
        print("INVOICE LENGTH E03 : ${invoices.length}");
        print("INVOICE PERIOD DATE BEFORE EDIT : ${invoice.periodDate}");
        final difference = getDaysRemainingMessage(invoice, periodDate);
        final updatedInvoice = Invoice(
          id: invoice.id,
          price: invoice.price,
          subCategory: invoice.subCategory,
          category: invoice.category,
          name: invoice.name,
          periodDate: periodDate,
          dueDate: dueDate,
          difference: difference
        );
        print("INVOICE LENGTH E04 : ${invoices.length}");
        invoices[index] = updatedInvoice;
        saveInvoices();
        print("INVOICE PERIOD DATE AFTER EDIT : ${invoice.periodDate}");
        print("INVOICE LENGTH E05 : ${invoices.length}");
      });
    }
  }

  double calculateSubcategorySum(List<Invoice> invoices, String subcategory) {
    double sum = 0.0;

    for (var invoice in invoices) {
      if (invoice.subCategory == subcategory) {
        double price = double.parse(invoice.price);
        sum += price;
      }
    }

    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final formDataProvider2 = Provider.of<FormDataProvider2>(context, listen: false);
    double tvSum = calculateSubcategorySum(invoices, 'TV');
    double hbSum = calculateSubcategorySum(invoices, 'Ev Faturaları');
    sumOfSubs = tvSum + sumOfGame + sumOfMusic;
    sumOfBills = hbSum + sumOfInternet + sumOfPhone;
    sumOfOthers = sumOfRent + sumOfKitchen + sumOfCatering + sumOfEnt + sumOfOther;
    outcomeValue = sumOfSubs+sumOfBills+sumOfOthers;
    subsPercent = (outcomeValue != 0) ? ((sumOfSubs / outcomeValue) * 100).round() : 0;
    billsPercent = (outcomeValue != 0) ? ((sumOfBills / outcomeValue) * 100).round() : 0;
    othersPercent = (outcomeValue != 0) ? ((sumOfOthers / outcomeValue) * 100).round() : 0;
    List<double> percentages = [
      subsPercent.isNaN ? 0.0 : (subsPercent.toDouble()/100),
      billsPercent.isNaN ? 0.0 : (billsPercent.toDouble()/100),
      othersPercent.isNaN ? 0.0 : (othersPercent.toDouble()/100),
    ];
    print("İLK percentages:$percentages");
    Map<String, double> variableMap = {
      'subsPercent': subsPercent.toDouble(),
      'billsPercent': billsPercent.toDouble(),
      'othersPercent': othersPercent.toDouble(),
    };
    percentages.sort();

    List<String> variableNames = variableMap.keys.toList()
      ..sort((a, b) => (variableMap[a] ?? 0.0).compareTo(variableMap[b] ?? 0.0));

    String smallestVariable = variableNames[0];
    String mediumVariable = variableNames[1];
    String largestVariable = variableNames[2];


    percentages.sort((a, b) => b.compareTo(a),);
    percentages[0] = 1.0;
    print("son percentages:$percentages, smallestVariable:$smallestVariable, mediumVariable:$mediumVariable, largestVariable:$largestVariable");

    String formattedIncomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(incomeValue);
    String formattedOutcomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(outcomeValue);
    String formattedsavingsValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(savingsValue);
    String formattedwishesValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(wishesValue);
    String formattedneedsValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(needsValue);
    String formattedSumOfSubs = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfSubs);
    String formattedSumOfBills = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfBills);
    String formattedSumOfOthers = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfOthers);

    Color smallestColor = Color(0xFFFFD700);
    Color mediumColor = Color(0xFFFFA500);
    Color biggestColor = Color(0xFFFF8C00);

    List<int> getIdsWithSubcategory(List<Invoice> invoices, String subCategory) {
      return invoices
          .where((invoice) => invoice.subCategory == subCategory)
          .map((invoice) => invoice.id)
          .toList();
    }


    List<int> idsWithTVTargetCategory = getIdsWithSubcategory(invoices, "TV");
    List<int> idsWithHBTargetCategory = getIdsWithSubcategory(invoices, "Ev Faturaları");


    int totalSubsElement = idsWithTVTargetCategory.length + gameTitleList.length + musicTitleList.length;
    int totalBillsElement = idsWithHBTargetCategory.length + internetTitleList.length + phoneTitleList.length;
    int totalOthersElement = rentTitleList.length + kitchenTitleList.length + cateringTitleList.length + entertainmentTitleList.length + otherTitleList.length;

    void _showEditDialog(BuildContext context, int index, int page, int orderIndex, int id) {
      String caterogyName = "";
      if(page == 1){
        switch (orderIndex) {
          case 1:
            caterogyName = "TV";
            break;
          case 2:
            caterogyName = "Gaming";
            break;
          case 3:
            caterogyName = "Music";
            break;
        }
      } else if (page == 2){
        switch (orderIndex) {
          case 1:
            caterogyName = "Home Bills";
            break;
          case 2:
            caterogyName = "Internet";
            break;
          case 3:
            caterogyName = "Phone";
            break;
        }
      } else if (page == 3){
        switch (orderIndex) {
          case 1:
            caterogyName = "Rent";
            break;
          case 2:
            caterogyName = "Kitchen";
            break;
          case 3:
            caterogyName = "Catering";
            break;
          case 4:
            caterogyName = "Entertainment";
            break;
          case 5:
            caterogyName = "Other";
            break;
        }
      }

      TextEditingController selectedEditController = TextEditingController();
      TextEditingController selectedPriceController = TextEditingController();
      Invoice invoice = invoices.firstWhere((invoice) => invoice.id == id);
      _selectedBillingDay = invoice.periodDate;
      _selectedDueDay = invoice.dueDate;


      if(page == 1){
        switch (orderIndex) {
          case 1:
            TextEditingController editController =
            TextEditingController(text: invoice.name);
            TextEditingController priceController =
            TextEditingController(text: invoice.price);
            selectedEditController = editController;
            selectedPriceController = priceController;
            break;
          case 2:
            TextEditingController NDeditController =
            TextEditingController(text: gameTitleList[index]);
            TextEditingController NDpriceController =
            TextEditingController(text: gamePriceList[index]);
            selectedEditController = NDeditController;
            selectedPriceController = NDpriceController;
            break;
          case 3:
            TextEditingController RDeditController =
            TextEditingController(text: musicTitleList[index]);
            TextEditingController RDpriceController =
            TextEditingController(text: musicPriceList[index]);
            selectedEditController = RDeditController;
            selectedPriceController = RDpriceController;
            break;
        }
      } else if (page == 2){
        switch (orderIndex) {
          case 1:
            TextEditingController editController =
            TextEditingController(text: homeBillsTitleList[index]);
            TextEditingController priceController =
            TextEditingController(text: homeBillsPriceList[index]);
            selectedEditController = editController;
            selectedPriceController = priceController;
            break;
          case 2:
            TextEditingController NDeditController =
            TextEditingController(text: internetTitleList[index]);
            TextEditingController NDpriceController =
            TextEditingController(text: internetPriceList[index]);
            selectedEditController = NDeditController;
            selectedPriceController = NDpriceController;
            break;
          case 3:
            TextEditingController RDeditController =
            TextEditingController(text: phoneTitleList[index]);
            TextEditingController RDpriceController =
            TextEditingController(text: phonePriceList[index]);
            selectedEditController = RDeditController;
            selectedPriceController = RDpriceController;
            break;
        }
      } else if (page == 3){
        switch (orderIndex) {
          case 1:
            TextEditingController editController =
            TextEditingController(text: rentTitleList[index]);
            TextEditingController priceController =
            TextEditingController(text: rentPriceList[index]);
            selectedEditController = editController;
            selectedPriceController = priceController;
            break;
          case 2:
            TextEditingController NDeditController =
            TextEditingController(text: kitchenTitleList[index]);
            TextEditingController NDpriceController =
            TextEditingController(text: kitchenPriceList[index]);
            selectedEditController = NDeditController;
            selectedPriceController = NDpriceController;
            break;
          case 3:
            TextEditingController RDeditController =
            TextEditingController(text: cateringTitleList[index]);
            TextEditingController RDpriceController =
            TextEditingController(text: cateringPriceList[index]);
            selectedEditController = RDeditController;
            selectedPriceController = RDpriceController;
            break;
          case 4:
            TextEditingController THeditController =
            TextEditingController(text: entertainmentTitleList[index]);
            TextEditingController THpriceController =
            TextEditingController(text: entertainmentPriceList[index]);
            selectedEditController = THeditController;
            selectedPriceController = THpriceController;
            break;
          case 5:
            TextEditingController otherEditController =
            TextEditingController(text: otherTitleList[index]);
            TextEditingController otherPriceController =
            TextEditingController(text: otherPriceList[index]);
            selectedEditController = otherEditController;
            selectedPriceController = otherPriceController;
            break;
        }
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
            ),
            title: Text('Edit $caterogyName',style: const TextStyle(fontSize: 20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(child: Text("Item", style: TextStyle(fontSize: 18),), alignment: Alignment.centerLeft,),
                const SizedBox(height: 10),
                TextFormField(
                  controller: selectedEditController,
                  decoration: InputDecoration(
                    isDense: true,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(width: 3, color: Colors.black)
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(width: 3, color: Colors.black), // Use the same border style for enabled state
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  ),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                const Align(child: Text("Price",style: TextStyle(fontSize: 18)), alignment: Alignment.centerLeft),
                const SizedBox(height: 10),
                TextFormField(
                  controller: selectedPriceController,
                  decoration: InputDecoration(
                    isDense: true,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(width: 3, color: Colors.black)
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(width: 3, color: Colors.black), // Use the same border style for enabled state
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  ),
                  style: const TextStyle(fontSize: 20),
                  keyboardType: TextInputType.number,
                ),
                const Align(child: Text("Bill Period",style: TextStyle(fontSize: 18)), alignment: Alignment.centerLeft),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _selectedBillingDay,
                  onChanged: (value) {
                    setState(() {
                      _selectedBillingDay = value;
                    });
                  },
                  items: daysList.map((day) {
                    return DropdownMenuItem<int>(
                      value: day,
                      child: Text(day.toString()),
                    );
                  }).toList(),
                ),
                const Align(child: Text("Due Date",style: TextStyle(fontSize: 18)), alignment: Alignment.centerLeft),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _selectedDueDay,
                  onChanged: (value) {
                    setState(() {
                      _selectedDueDay = value;
                    });
                  },
                  items: daysList.map((day) {
                    return DropdownMenuItem<int>(
                      value: day,
                      child: Text(day.toString()),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.cancel)
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      if(page == 1){
                        switch (orderIndex){
                          case 1:
                            print("INVOICE LENGTH E01 : ${invoices.length}");
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            String name = selectedEditController.text;
                            invoice.name = name;
                            invoice.price = price;
                            editInvoice(id, _selectedBillingDay ?? 0, _selectedDueDay ?? null);
                            break;
                          case 2:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            gameTitleList[index] = selectedEditController.text;
                            gamePriceList[index] = price;
                            formDataProvider2.setGameTitleValue(selectedEditController.text, gameTitleList);
                            formDataProvider2.setGamePriceValue(price, gamePriceList);
                            formDataProvider2.calculateSumOfGame(gamePriceList);
                            break;
                          case 3:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            musicTitleList[index] = selectedEditController.text;
                            musicPriceList[index] = price;
                            formDataProvider2.setMusicTitleValue(selectedEditController.text, musicTitleList);
                            formDataProvider2.setMusicPriceValue(price, musicPriceList);
                            formDataProvider2.calculateSumOfMusic(musicPriceList);
                            break;
                        }
                      } else if (page == 2){
                        switch (orderIndex){
                          case 1:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            homeBillsTitleList[index] = selectedEditController.text;
                            homeBillsPriceList[index] = price;
                            formDataProvider2.setHomeTitleValue(selectedEditController.text, homeBillsTitleList);
                            formDataProvider2.setHomePriceValue(price, homeBillsPriceList);
                            formDataProvider2.calculateSumOfHome(homeBillsPriceList);
                            break;
                          case 2:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            internetTitleList[index] = selectedEditController.text;
                            internetPriceList[index] = price;
                            formDataProvider2.setInternetTitleValue(selectedEditController.text, internetTitleList);
                            formDataProvider2.setInternetPriceValue(price, internetPriceList);
                            formDataProvider2.calculateSumOfInternet(internetPriceList);
                            break;
                          case 3:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            phoneTitleList[index] = selectedEditController.text;
                            phonePriceList[index] = price;
                            formDataProvider2.setPhoneTitleValue(selectedEditController.text, phoneTitleList);
                            formDataProvider2.setPhonePriceValue(price, phonePriceList);
                            formDataProvider2.calculateSumOfPhone(phonePriceList);
                            break;
                        }
                      } else if (page == 3){
                        switch (orderIndex){
                          case 1:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            rentTitleList[index] = selectedEditController.text;
                            rentPriceList[index] = price;
                            formDataProvider2.setRentTitleValue(selectedEditController.text, rentTitleList);
                            formDataProvider2.setRentPriceValue(price, rentPriceList);
                            formDataProvider2.calculateSumOfRent(rentPriceList);
                            break;
                          case 2:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            kitchenTitleList[index] = selectedEditController.text;
                            kitchenPriceList[index] = price;
                            formDataProvider2.setKitchenTitleValue(selectedEditController.text, kitchenTitleList);
                            formDataProvider2.setKitchenPriceValue(price, kitchenPriceList);
                            formDataProvider2.calculateSumOfKitchen(kitchenPriceList);
                            break;
                          case 3:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            cateringTitleList[index] = selectedEditController.text;
                            cateringPriceList[index] = price;
                            formDataProvider2.setCateringTitleValue(selectedEditController.text, cateringTitleList);
                            formDataProvider2.setCateringPriceValue(price, cateringPriceList);
                            formDataProvider2.calculateSumOfCatering(cateringPriceList);
                            break;
                          case 4:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            entertainmentTitleList[index] = selectedEditController.text;
                            entertainmentPriceList[index] = price;
                            formDataProvider2.setEntertainmentTitleValue(selectedEditController.text, entertainmentTitleList);
                            formDataProvider2.setEntertainmentPriceValue(price, entertainmentPriceList);
                            formDataProvider2.calculateSumOfEnt(entertainmentPriceList);
                            break;
                          case 5:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            otherTitleList[index] = selectedEditController.text;
                            otherPriceList[index] = price;
                            formDataProvider2.setOtherTitleValue(selectedEditController.text, otherTitleList);
                            formDataProvider2.setOtherPriceValue(price, otherPriceList);
                            formDataProvider2.calculateSumOfOther(otherPriceList);
                            break;
                        }
                      }
                    });
                    saveInvoices();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.save)
              ),
              IconButton(
                    onPressed: () {
                      setState(() {
                        if(page == 1 && totalSubsElement != 1){
                          switch (orderIndex){
                            case 1:
                              formDataProvider2.removeTVTitleValue(tvTitleList);
                              formDataProvider2.removeTVPriceValue(tvPriceList);
                              removeInvoice(id);
                              break;
                            case 2:
                              gameTitleList.removeAt(index);
                              gamePriceList.removeAt(index);
                              formDataProvider2.removeGameTitleValue(gameTitleList);
                              formDataProvider2.removeGamePriceValue(gamePriceList);
                              formDataProvider2.calculateSumOfGame(gamePriceList);
                              break;
                            case 3:
                              musicTitleList.removeAt(index);
                              musicPriceList.removeAt(index);
                              formDataProvider2.removeMusicTitleValue(musicTitleList);
                              formDataProvider2.removeMusicPriceValue(musicPriceList);
                              formDataProvider2.calculateSumOfMusic(musicPriceList);
                              break;
                          }
                        } else if (page == 2 && totalBillsElement != 1){
                          switch (orderIndex){
                            case 1:
                              homeBillsTitleList.removeAt(index);
                              homeBillsPriceList.removeAt(index);
                              formDataProvider2.removeHomeTitleValue(homeBillsTitleList);
                              formDataProvider2.removeHomePriceValue(homeBillsPriceList);
                              formDataProvider2.calculateSumOfHome(homeBillsPriceList);
                              break;
                            case 2:
                              internetTitleList.removeAt(index);
                              internetPriceList.removeAt(index);
                              formDataProvider2.removeInternetTitleValue(internetTitleList);
                              formDataProvider2.removeInternetPriceValue(internetPriceList);
                              formDataProvider2.calculateSumOfInternet(internetPriceList);
                              break;
                            case 3:
                              phoneTitleList.removeAt(index);
                              phonePriceList.removeAt(index);
                              formDataProvider2.removePhoneTitleValue(phoneTitleList);
                              formDataProvider2.removePhonePriceValue(phoneTitleList);
                              formDataProvider2.calculateSumOfPhone(phonePriceList);
                              break;
                          }
                        } else if (page == 3 && totalOthersElement != 1){
                          switch (orderIndex){
                            case 1:
                              rentTitleList.removeAt(index);
                              rentPriceList.removeAt(index);
                              formDataProvider2.removeRentTitleValue(rentTitleList);
                              formDataProvider2.removeRentPriceValue(rentPriceList);
                              formDataProvider2.calculateSumOfRent(rentPriceList);
                              break;
                            case 2:
                              kitchenTitleList.removeAt(index);
                              kitchenPriceList.removeAt(index);
                              formDataProvider2.removeKitchenTitleValue(kitchenTitleList);
                              formDataProvider2.removeKitchenPriceValue(kitchenPriceList);
                              formDataProvider2.calculateSumOfKitchen(kitchenPriceList);
                              break;
                            case 3:
                              cateringTitleList.removeAt(index);
                              cateringPriceList.removeAt(index);
                              formDataProvider2.removeCateringTitleValue(cateringTitleList);
                              formDataProvider2.removeCateringPriceValue(cateringPriceList);
                              formDataProvider2.calculateSumOfCatering(cateringPriceList);
                              break;
                            case 4:
                              entertainmentTitleList.removeAt(index);
                              entertainmentPriceList.removeAt(index);
                              formDataProvider2.removeEntertainmentTitleValue(entertainmentTitleList);
                              formDataProvider2.removeEntertainmentPriceValue(entertainmentPriceList);
                              formDataProvider2.calculateSumOfEnt(entertainmentPriceList);
                              break;
                            case 5:
                              otherTitleList.removeAt(index);
                              otherPriceList.removeAt(index);
                              formDataProvider2.removeOtherTitleValue(otherTitleList);
                              formDataProvider2.removeOtherPriceValue(otherPriceList);
                              formDataProvider2.calculateSumOfOther(otherPriceList);
                              break;
                          }
                        } else {
                          // Show a Snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Delete operation not allowed."),
                            ),
                          );
                        }
                        Navigator.of(context).pop();
                      });
                    },
                    icon: const Icon(Icons.delete_forever)
                )
            ],
          );
        },
      );
    }
    for (Invoice invoice in invoices) {
      print('Before ID: ${invoice.id}, Subcategory: ${invoice.subCategory}');
    }


    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff0f0f1),
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        leadingWidth: 30,
        title: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushNamed(context, '/');
                  },
                  icon: const Icon(Icons.settings, color: Colors.black), // Replace with the desired left icon
                ),
                IconButton(
                  onPressed: () {

                  },
                  icon: const Icon(Icons.person, color: Colors.black), // Replace with the desired right icon
                ),
              ],
            ),
            Text(
              "Eylül 2023",
              style: GoogleFonts.montserrat(color: Colors.black, fontSize: 28, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20,0,20,20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Giderler Detayı", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tüm Giderler", style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(formattedOutcomeValue, style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        LinearPercentIndicator(
                          padding: EdgeInsets.zero,
                          percent: percentages[0],
                          backgroundColor: Colors.transparent,
                          progressColor: const Color(0xFFFF8C00),
                          lineHeight: 10,
                          barRadius: const Radius.circular(10),
                        ),
                        LinearPercentIndicator(
                          padding: EdgeInsets.zero,
                          percent: percentages[1]+percentages[2],
                          progressColor: const Color(0xFFFFA500),
                          backgroundColor: Colors.transparent,
                          lineHeight: 10,
                          barRadius: const Radius.circular(10),
                        ),
                        LinearPercentIndicator(
                          padding: EdgeInsets.zero,
                          percent: percentages[2],
                          progressColor: const Color(0xFFFFD700),
                          backgroundColor: Colors.transparent,
                          lineHeight: 10,
                          barRadius: const Radius.circular(10),
                        )
                      ],
                    ),
                    Text("$percentages", style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                    if (largestVariable == "subsPercent" && mediumVariable == "billsPercent")
                      Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircularPercentIndicator(
                              radius: 30,
                              lineWidth: 7.0,
                              percent: sumOfOthers/outcomeValue,
                              center: Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                              progressColor: smallestColor,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Diğer Giderler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                Text("$formattedSumOfOthers / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                              ],
                            )
                          ],
                        ),
                        const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                        Container(
                          child: Row(
                            children: [
                              CircularPercentIndicator(
                                radius: 30,
                                lineWidth: 7.0,
                                percent: sumOfBills/outcomeValue,
                                center: Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                progressColor: mediumColor,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Faturalar", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                  Text("$formattedSumOfBills / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                ],
                              )
                            ],
                          ),
                        ),
                        const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                        Container(
                          child: Row(
                            children: [
                              CircularPercentIndicator(
                                radius: 30,
                                lineWidth: 7.0,
                                percent: sumOfSubs/outcomeValue,
                                center: Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                progressColor: biggestColor,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Abonelikler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                  Text("$formattedSumOfSubs / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (largestVariable == "subsPercent" && mediumVariable == "othersPercent")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfBills/outcomeValue,
                                  center: Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: smallestColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Faturalar", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfBills / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                          const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfOthers/outcomeValue,
                                  center: Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: mediumColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Diğer Giderler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfOthers / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                          const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfSubs/outcomeValue,
                                  center: Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: biggestColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Abonelikler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfSubs / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (largestVariable == "billsPercent" && mediumVariable == "subsPercent")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfOthers/outcomeValue,
                                  center: Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: smallestColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Diğer Giderler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfOthers / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                          const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfSubs/outcomeValue,
                                  center: Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: mediumColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Abonelikler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfSubs / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                          const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfBills/outcomeValue,
                                  center: Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: biggestColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Faturalar", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfBills / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (largestVariable == "billsPercent" && mediumVariable == "othersPercent")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfSubs/outcomeValue,
                                  center: Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: smallestColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Abonelikler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfSubs / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                          const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfOthers/outcomeValue,
                                  center: Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: mediumColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Diğer Giderler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfOthers / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                          const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfBills/outcomeValue,
                                  center: Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: biggestColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Faturalar", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfBills / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (largestVariable == "othersPercent" && mediumVariable == "subsPercent")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfBills/outcomeValue,
                                  center: Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: smallestColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Faturalar", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfBills / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                          const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfSubs/outcomeValue,
                                  center: Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: mediumColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Abonelikler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfSubs / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                          const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfOthers/outcomeValue,
                                  center: Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: biggestColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Diğer Giderler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfOthers / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (largestVariable == "othersPercent" && mediumVariable == "billsPercent")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfSubs/outcomeValue,
                                  center: Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: smallestColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Abonelikler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfSubs / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                          const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfBills/outcomeValue,
                                  center: Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: mediumColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Faturalar", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfBills / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                          const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfOthers/outcomeValue,
                                  center: Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: biggestColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Diğer Giderler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfOthers / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (largestVariable == mediumVariable && mediumVariable == smallestVariable)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfSubs/outcomeValue,
                                  center: Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: smallestColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Abonelikler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfSubs / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                          const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfBills/outcomeValue,
                                  center: Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: mediumColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Faturalar", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfBills / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                          const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfOthers/outcomeValue,
                                  center: Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: biggestColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Diğer Giderler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                    Text("$formattedSumOfOthers / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text("Abonelikler", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Period Dates: ${invoices.map((invoice) => invoice.periodDate.toString()).join(', ')}'),
              Text('Liste: $idsWithTVTargetCategory'),
              Text(
                invoices
                    .map((invoice) =>
                '\nID: ${invoice.id}'
                '\nName: ${invoice.name}'
                '\nSubcategory: ${invoice.subCategory}'
                '\nDifference: ${invoice.difference}'
                '\nPeriod: ${invoice.periodDate}\n')
                    .join(' | '),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$formattedSumOfSubs / $formattedOutcomeValue", style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold)),
                    SizedBox(
                      child: LinearPercentIndicator(
                        padding: const EdgeInsets.only(right: 10),
                        backgroundColor: const Color(0xffc6c6c7),
                        animation: true,
                        lineHeight: 10,
                        animationDuration: 1000,
                        percent: sumOfSubs/outcomeValue,
                        trailing: Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                        barRadius: const Radius.circular(10),
                        progressColor: Colors.lightBlue,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        if(invoices.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("TV", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: idsWithTVTargetCategory.length,
                              itemBuilder: (context, index) {
                                int id = idsWithTVTargetCategory[index];
                                Invoice invoice = invoices.firstWhere((invoice) => invoice.id == id);
                                if (index < idsWithTVTargetCategory.length) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              invoice.name,
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              textAlign: TextAlign.right,
                                              invoice.price,
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              _showEditDialog(context, index, 1, 1, id); // Show the edit dialog
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        if(gameTitleList.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Gaming", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: gameTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                              itemBuilder: (context, index) {
                                if (index < gameTitleList.length) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              gameTitleList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              textAlign: TextAlign.right,
                                              gamePriceList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              _showEditDialog(context, index, 1, 2, 0); // Show the edit dialog
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        if(musicTitleList.isNotEmpty)
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Music", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: musicTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                              itemBuilder: (context, index) {
                                if (index < musicTitleList.length) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              musicTitleList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              textAlign: TextAlign.right,
                                              musicPriceList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              _showEditDialog(context, index, 1, 3, 0); // Show the edit dialog
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        if(!isSubsAddActive)
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Abonelik Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isSubsAddActive = true;
                                  });
                                },
                                icon: const Icon(Icons.add_circle),
                              ),
                            ],
                          ),
                        ),
                        if(isSubsAddActive)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child:DropdownButton(
                                  value: dropdownvaluesubs,
                                  icon:const Icon(Icons.keyboard_arrow_down),
                                  items: subsItems.map((String items) {
                                    return DropdownMenuItem(
                                      value: items,
                                      child: Text(items),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      dropdownvaluesubs = newValue!;
                                    });
                                  },
                                )
                              ),
                              Wrap(
                                children: [
                                  if(!hasSubsCategorySelected)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isSubsAddActive = true;
                                        hasSubsCategorySelected = true;
                                      });
                                    },
                                    icon: const Icon(Icons.arrow_downward, size: 26),
                                  ),
                                  if(!hasSubsCategorySelected)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isSubsAddActive = false;
                                        hasSubsCategorySelected = false;
                                      });
                                    },
                                    icon: const Icon(Icons.cancel, size: 26),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        if(hasSubsCategorySelected)
                        Container(
                          padding: const EdgeInsets.only(top:10, bottom:10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: textController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'ABA',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: platformPriceController,
                                  keyboardType: TextInputType.number, // Show numeric keyboard
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'GAG',
                                  ),
                                ),
                              ),
                              Wrap(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final prefs = await SharedPreferences.getInstance();
                                      final text = textController.text.trim();
                                      final priceText = platformPriceController.text.trim();
                                      if (text.isNotEmpty && priceText.isNotEmpty && dropdownvaluesubs == "Film, Dizi ve TV") {
                                        double dprice = double.tryParse(priceText) ?? 0.0;
                                        String price = dprice.toStringAsFixed(2);
                                        setState(() {
                                          tvTitleList.add(text);
                                          tvPriceList.add(price);
                                          prefs.setStringList('tvTitleList2', tvTitleList);
                                          prefs.setStringList('tvPriceList2', tvPriceList);
                                          textController.clear();
                                          platformPriceController.clear();
                                          isSubsAddActive = false;
                                          hasSubsCategorySelected = false;
                                          _load();
                                        });
                                      } else if (text.isNotEmpty && priceText.isNotEmpty && dropdownvaluesubs == "Oyun") {
                                        double dprice = double.tryParse(priceText) ?? 0.0;
                                        String price = dprice.toStringAsFixed(2);
                                        setState(() {
                                          gameTitleList.add(text);
                                          gamePriceList.add(price);
                                          prefs.setStringList('gameTitleList2', gameTitleList);
                                          prefs.setStringList('gamePriceList2', gamePriceList);
                                          formDataProvider2.calculateSumOfGame(gamePriceList);
                                          textController.clear();
                                          platformPriceController.clear();
                                          //isTextFormFieldVisible = false;
                                          isSubsAddActive = false;
                                          hasSubsCategorySelected = false;
                                          _load();
                                        });
                                      } else if (text.isNotEmpty && priceText.isNotEmpty && dropdownvaluesubs == "Müzik") {
                                        double dprice = double.tryParse(priceText) ?? 0.0;
                                        String price = dprice.toStringAsFixed(2);
                                        setState(() {
                                          musicTitleList.add(text);
                                          musicPriceList.add(price);
                                          prefs.setStringList('musicTitleList2', musicTitleList);
                                          prefs.setStringList('musicPriceList2', musicPriceList);
                                          formDataProvider2.calculateSumOfMusic(musicPriceList);
                                          textController.clear();
                                          platformPriceController.clear();
                                          isSubsAddActive = false;
                                          hasSubsCategorySelected = false;
                                          _load();
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.check_circle, size: 26),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        //isTextFormFieldVisible = false;
                                        isSubsAddActive = false;
                                        hasSubsCategorySelected = false;
                                        textController.clear();
                                        platformPriceController.clear();
                                      });
                                    },
                                    icon: const Icon(Icons.cancel, size: 26),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text("Faturalar", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$formattedSumOfBills / $formattedOutcomeValue", style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold)),
                    SizedBox(
                      child: LinearPercentIndicator(
                        padding: const EdgeInsets.only(right: 10),
                        backgroundColor: const Color(0xffc6c6c7),
                        animation: true,
                        lineHeight: 10,
                        animationDuration: 1000,
                        percent: sumOfBills/outcomeValue,
                        trailing: Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                        barRadius: const Radius.circular(10),
                        progressColor: Colors.lightBlue,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        if(invoices.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Home Bills", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: idsWithHBTargetCategory.length,
                              itemBuilder: (context, index) {
                                int id = idsWithHBTargetCategory[index];
                                Invoice invoice = invoices.firstWhere((invoice) => invoice.id == id);
                                if (index < idsWithHBTargetCategory.length) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              invoice.name,
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              textAlign: TextAlign.right,
                                              invoice.price,
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              _showEditDialog(context, index, 2, 1, id); // Show the edit dialog
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        if(internetTitleList.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Internet", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: internetTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                              itemBuilder: (context, index) {
                                if (index < internetTitleList.length) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              internetTitleList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              textAlign: TextAlign.right,
                                              internetPriceList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              _showEditDialog(context, index, 2, 2, 0); // Show the edit dialog
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        if(phoneTitleList.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Phone", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: phoneTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                              itemBuilder: (context, index) {
                                if (index < phoneTitleList.length) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              phoneTitleList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              textAlign: TextAlign.right,
                                              phonePriceList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              _showEditDialog(context, index, 2, 3, 0); // Show the edit dialog
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        if(!isBillsAddActive)
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Fatura Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isBillsAddActive = true;
                                  });
                                },
                                icon: const Icon(Icons.add_circle),
                              ),
                            ],
                          ),
                        ),
                        if(isBillsAddActive)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  child:DropdownButton(
                                    value: dropdownvaluebills,
                                    icon:const Icon(Icons.keyboard_arrow_down),
                                    items: billsItems.map((String items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Text(items),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        dropdownvaluebills = newValue!;
                                      });
                                    },
                                  )
                              ),
                              Wrap(
                                children: [
                                  if(!hasBillsCategorySelected)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isBillsAddActive = true;
                                        hasBillsCategorySelected = true;
                                      });
                                    },
                                    icon: const Icon(Icons.arrow_downward, size: 26),
                                  ),
                                  if(!hasBillsCategorySelected)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isBillsAddActive = false;
                                        hasBillsCategorySelected = false;
                                      });
                                    },
                                    icon: const Icon(Icons.cancel, size: 26),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        if(hasBillsCategorySelected)
                          Container(
                            padding: const EdgeInsets.only(top:10, bottom:10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: textController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'ABA',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: platformPriceController,
                                    keyboardType: TextInputType.number, // Show numeric keyboard
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'GAG',
                                    ),
                                  ),
                                ),
                                Wrap(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        final text = textController.text.trim();
                                        final priceText = platformPriceController.text.trim();
                                        if (text.isNotEmpty && priceText.isNotEmpty && dropdownvaluebills == "Ev Faturaları") {
                                          double dprice = double.tryParse(priceText) ?? 0.0;
                                          String price = dprice.toStringAsFixed(2);
                                          setState(() {
                                            homeBillsTitleList.add(text);
                                            homeBillsPriceList.add(price);
                                            prefs.setStringList('homeBillsTitleList2', homeBillsTitleList);
                                            prefs.setStringList('homeBillsPriceList2', homeBillsPriceList);
                                            formDataProvider2.calculateSumOfHome(homeBillsPriceList);
                                            textController.clear();
                                            platformPriceController.clear();
                                            //isTextFormFieldVisible = false;
                                            isBillsAddActive = false;
                                            hasBillsCategorySelected = false;
                                            _load();
                                          });
                                        } else if (text.isNotEmpty && priceText.isNotEmpty && dropdownvaluebills == "İnternet") {
                                          double dprice = double.tryParse(priceText) ?? 0.0;
                                          String price = dprice.toStringAsFixed(2);
                                          setState(() {
                                            internetTitleList.add(text);
                                            internetPriceList.add(price);
                                            prefs.setStringList('internetTitleList2', internetTitleList);
                                            prefs.setStringList('internetPriceList2', internetPriceList);
                                            formDataProvider2.calculateSumOfInternet(internetPriceList);
                                            textController.clear();
                                            platformPriceController.clear();
                                            //isTextFormFieldVisible = false;
                                            isBillsAddActive = false;
                                            hasBillsCategorySelected = false;
                                            _load();
                                          });
                                        } else if (text.isNotEmpty && priceText.isNotEmpty && dropdownvaluebills == "Telefon") {
                                          double dprice = double.tryParse(priceText) ?? 0.0;
                                          String price = dprice.toStringAsFixed(2);
                                          setState(() {
                                            phoneTitleList.add(text);
                                            phonePriceList.add(price);
                                            prefs.setStringList('phoneTitleList2', phoneTitleList);
                                            prefs.setStringList('phonePriceList2', phonePriceList);
                                            formDataProvider2.calculateSumOfPhone(phonePriceList);
                                            textController.clear();
                                            platformPriceController.clear();
                                            //isTextFormFieldVisible = false;
                                            isBillsAddActive = false;
                                            hasBillsCategorySelected = false;
                                            _load();
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.check_circle, size: 26),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          //isTextFormFieldVisible = false;
                                          isBillsAddActive = false;
                                          hasBillsCategorySelected = false;
                                          textController.clear();
                                          platformPriceController.clear();
                                        });
                                      },
                                      icon: const Icon(Icons.cancel, size: 26),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text("Diğer Giderler", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$formattedSumOfOthers / $formattedOutcomeValue", style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold)),
                    SizedBox(
                      child: LinearPercentIndicator(
                        padding: const EdgeInsets.only(right: 10),
                        backgroundColor: const Color(0xffc6c6c7),
                        animation: true,
                        lineHeight: 10,
                        animationDuration: 1000,
                        percent: sumOfOthers/outcomeValue,
                        trailing: Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                        barRadius: const Radius.circular(10),
                        progressColor: Colors.lightBlue,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        if(rentTitleList.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Rent", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: rentTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                              itemBuilder: (context, index) {
                                if (index < rentTitleList.length) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              rentTitleList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              textAlign: TextAlign.right,
                                              rentPriceList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              _showEditDialog(context, index, 3, 1, 0); // Show the edit dialog
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        if(kitchenTitleList.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Kitchen", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: kitchenTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                              itemBuilder: (context, index) {
                                if (index < kitchenTitleList.length) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              kitchenTitleList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              textAlign: TextAlign.right,
                                              kitchenPriceList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              _showEditDialog(context, index, 3, 2, 0); // Show the edit dialog
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        if(cateringTitleList.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Catering", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: cateringTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                              itemBuilder: (context, index) {
                                if (index < cateringTitleList.length) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              cateringTitleList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              textAlign: TextAlign.right,
                                              cateringPriceList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              _showEditDialog(context, index, 3, 3, 0); // Show the edit dialog
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        if(entertainmentTitleList.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Entertainment", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: entertainmentTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                              itemBuilder: (context, index) {
                                if (index < entertainmentTitleList.length) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              entertainmentTitleList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              textAlign: TextAlign.right,
                                              entertainmentPriceList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              _showEditDialog(context, index, 3, 4, 0); // Show the edit dialog
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        if(otherTitleList.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Others", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: otherTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                              itemBuilder: (context, index) {
                                if (index < otherTitleList.length) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              otherTitleList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Flexible(
                                            flex: 2,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              textAlign: TextAlign.right,
                                              otherPriceList[index],
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              _showEditDialog(context, index, 3, 5, 0); // Show the edit dialog
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        if(!isOthersAddActive)
                          SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Diğer Gider Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isOthersAddActive = true;
                                    });
                                  },
                                  icon: const Icon(Icons.add_circle),
                                ),
                              ],
                            ),
                          ),
                        if(isOthersAddActive)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  child:DropdownButton(
                                    value: dropdownvalueothers,
                                    icon:const Icon(Icons.keyboard_arrow_down),
                                    items: othersItems.map((String items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Text(items),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        dropdownvalueothers= newValue!;
                                      });
                                    },
                                  )
                              ),
                              Wrap(
                                children: [
                                  if(!hasOthersCategorySelected)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isOthersAddActive = true;
                                        hasOthersCategorySelected = true;
                                      });
                                    },
                                    icon: const Icon(Icons.arrow_downward, size: 26),
                                  ),
                                  if(!hasOthersCategorySelected)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isOthersAddActive = false;
                                        hasOthersCategorySelected = false;
                                      });
                                    },
                                    icon: const Icon(Icons.cancel, size: 26),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        if(hasOthersCategorySelected)
                          Container(
                            padding: const EdgeInsets.only(top:10, bottom:10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: textController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'ABA',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: platformPriceController,
                                    keyboardType: TextInputType.number, // Show numeric keyboard
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'GAG',
                                    ),
                                  ),
                                ),
                                Wrap(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        final text = textController.text.trim();
                                        final priceText = platformPriceController.text.trim();
                                        if (text.isNotEmpty && priceText.isNotEmpty && dropdownvalueothers == "Kira") {
                                          double dprice = double.tryParse(priceText) ?? 0.0;
                                          String price = dprice.toStringAsFixed(2);
                                          setState(() {
                                            rentTitleList.add(text);
                                            rentPriceList.add(price);
                                            prefs.setStringList('rentTitleList2', rentTitleList);
                                            prefs.setStringList('rentPriceList2', rentPriceList);
                                            formDataProvider2.calculateSumOfRent(rentPriceList);
                                            textController.clear();
                                            platformPriceController.clear();
                                            //isTextFormFieldVisible = false;
                                            isOthersAddActive = false;
                                            hasOthersCategorySelected = false;
                                            _load();
                                          });
                                        } else if (text.isNotEmpty && priceText.isNotEmpty && dropdownvalueothers == "Mutfak") {
                                          double dprice = double.tryParse(priceText) ?? 0.0;
                                          String price = dprice.toStringAsFixed(2);
                                          setState(() {
                                            kitchenTitleList.add(text);
                                            kitchenPriceList.add(price);
                                            prefs.setStringList('kitchenTitleList2', kitchenTitleList);
                                            prefs.setStringList('kitchenPriceList2', kitchenPriceList);
                                            formDataProvider2.calculateSumOfKitchen(kitchenPriceList);
                                            textController.clear();
                                            platformPriceController.clear();
                                            //isTextFormFieldVisible = false;
                                            isOthersAddActive = false;
                                            hasOthersCategorySelected = false;
                                            _load();
                                          });
                                        } else if (text.isNotEmpty && priceText.isNotEmpty && dropdownvalueothers == "Yeme İçme") {
                                          double dprice = double.tryParse(priceText) ?? 0.0;
                                          String price = dprice.toStringAsFixed(2);
                                          setState(() {
                                            cateringTitleList.add(text);
                                            cateringPriceList.add(price);
                                            prefs.setStringList('cateringTitleList2', cateringTitleList);
                                            prefs.setStringList('cateringPriceList2', cateringPriceList);
                                            formDataProvider2.calculateSumOfCatering(cateringPriceList);
                                            textController.clear();
                                            platformPriceController.clear();
                                            //isTextFormFieldVisible = false;
                                            isOthersAddActive = false;
                                            hasOthersCategorySelected = false;
                                            _load();
                                          });
                                        } else if (text.isNotEmpty && priceText.isNotEmpty && dropdownvalueothers == "Eğlence") {
                                          double dprice = double.tryParse(priceText) ?? 0.0;
                                          String price = dprice.toStringAsFixed(2);
                                          setState(() {
                                            entertainmentTitleList.add(text);
                                            entertainmentPriceList.add(price);
                                            prefs.setStringList('entertainmentTitleList2', entertainmentTitleList);
                                            prefs.setStringList('entertainmentPriceList2', entertainmentPriceList);
                                            formDataProvider2.calculateSumOfEnt(entertainmentPriceList);
                                            textController.clear();
                                            platformPriceController.clear();
                                            //isTextFormFieldVisible = false;
                                            isOthersAddActive = false;
                                            hasOthersCategorySelected = false;
                                            _load();
                                          });
                                        } else if (text.isNotEmpty && priceText.isNotEmpty && dropdownvalueothers == "Diğer") {
                                          double dprice = double.tryParse(priceText) ?? 0.0;
                                          String price = dprice.toStringAsFixed(2);
                                          setState(() {
                                            otherTitleList.add(text);
                                            otherPriceList.add(price);
                                            prefs.setStringList('otherTitleList2', otherTitleList);
                                            prefs.setStringList('otherPriceList2', otherPriceList);
                                            formDataProvider2.calculateSumOfOther(otherPriceList);
                                            textController.clear();
                                            platformPriceController.clear();
                                            //isTextFormFieldVisible = false;
                                            isOthersAddActive = false;
                                            hasOthersCategorySelected = false;
                                            _load();
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.check_circle, size: 26),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          //isTextFormFieldVisible = false;
                                          isOthersAddActive = false;
                                          hasOthersCategorySelected = false;
                                          textController.clear();
                                          platformPriceController.clear();
                                        });
                                      },
                                      icon: const Icon(Icons.cancel, size: 26),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 90,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), // Adjust as needed
              topRight: Radius.circular(10), // Adjust as needed
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), // Adjust as needed
              topRight: Radius.circular(10), // Adjust as needed
            ),
            child: BottomNavigationBar(
              currentIndex: 2,
              onTap: (int index) {
                switch (index) {
                  case 0:
                    Navigator.pushNamed(context, 'ana-sayfa');
                    break;
                  case 1:
                    Navigator.pushNamed(context, 'income-page');
                    break;
                  case 2:
                    Navigator.pushNamed(context, 'outcome-page');
                    break;
                  case 3:
                    Navigator.pushNamed(context, 'investment-page');
                    break;
                  case 4:
                    Navigator.pushNamed(context, 'wishes-page');
                    break;
                }
              },
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: GoogleFonts.montserrat(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.montserrat(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w600),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 30),
                  label: 'Ana Sayfa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.attach_money, size: 30),
                  label: 'Gelir',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(left: 5,right: 5),
                    child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100, // Background color
                          borderRadius: BorderRadius.circular(20), // Rounded corners
                        ),
                        child: Icon(Icons.money_off_sharp, size: 30)
                    ),
                  ),
                  label: 'Gider',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.trending_up, size: 30),
                  label: 'Yatırım',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 5,bottom: 5),
                    child: Icon(FontAwesome.bank, size: 20),
                  ),
                  label: 'İstekler',
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}