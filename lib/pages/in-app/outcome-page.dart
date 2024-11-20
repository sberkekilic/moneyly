// ignore_for_file: unused_import, avoid_unnecessary_containers

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../blocs/income-selections.dart';
import '../add-expense/faturalar.dart';

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
  int? _selectedBillingMonth;
  int? _selectedDueDay;
  String faturaDonemi = "";
  String? sonOdeme;

  List<int> daysList = List.generate(31, (index) => index + 1);
  List<int> monthsList = List.generate(12, (index) => index + 1);
  List<String> monthNames = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

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
        try {
          final Map<String, dynamic> invoiceJson = jsonDecode(invoiceString);
          print("Decoded JSON: $invoiceJson");  // Check the decoded data
          final Invoice invoice = Invoice.fromJson(invoiceJson);
          invoices.add(invoice);
          print("OUTCOME-PAGE 3| invoices:${invoices}");
        } catch (e) {
          print("Error: $e");
        }
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

  bool isLeapYear(int year) {
    if (year % 4 != 0) return false;
    if (year % 100 != 0) return true;
    return year % 400 == 0;
  }

  String getDaysRemainingMessage(Invoice invoice) {
    final currentDate = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    final dueDateKnown = invoice.dueDate != null;

    if (currentDate.isBefore(DateTime.parse(faturaDonemi))) {
      invoice.difference = (DateTime.parse(faturaDonemi).difference(currentDate).inDays + 1).toString();
      return invoice.difference;
    } else if (formattedDate == faturaDonemi) {
      invoice.difference = "0";
      return invoice.difference;
    } else if (dueDateKnown) {
      if (sonOdeme != null && currentDate.isAfter(DateTime.parse(faturaDonemi))) {
        invoice.difference = (DateTime.parse(sonOdeme!).difference(currentDate).inDays + 1).toString();
        return invoice.difference;
      } else {
        return "error1";
      }
    } else {
      return "error2";
    }
  }

  void onSave(Invoice invoice) {
    getDaysRemainingMessage(invoice);
    setState(() {
      invoices.add(invoice);
    });
    saveInvoices();
  }

  void editInvoice(int id, String periodDate, String? dueDate) {
    int index = invoices.indexWhere((invoice) => invoice.id == id);
    if (index != -1) {
      setState(() {
        final invoice = invoices[index];
        String diff = getDaysRemainingMessage(invoice);
        final updatedInvoice = Invoice(
            id: invoice.id,
            price: invoice.price,
            subCategory: invoice.subCategory,
            category: invoice.category,
            name: invoice.name,
            periodDate: periodDate,
            dueDate: dueDate,
            difference: diff
        );
        invoices[index] = updatedInvoice;
        saveInvoices();
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
    double tvSum = calculateSubcategorySum(invoices, 'TV');
    double hbSum = calculateSubcategorySum(invoices, 'Ev Faturaları');
    double rentSum = calculateSubcategorySum(invoices, 'Kira');
    sumOfSubs = tvSum + sumOfGame + sumOfMusic;
    sumOfBills = hbSum + sumOfInternet + sumOfPhone;
    sumOfOthers = rentSum + sumOfKitchen + sumOfCatering + sumOfEnt + sumOfOther;
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
    print("variableNames:$variableNames");

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
    Color smallestSoftColor = Color(0xFFFFE680);
    Color mediumSoftColor = Color(0xFFFFD3A3);
    Color biggestSoftColor = Color(0xFFFFAB8A);


    List<int> getIdsWithSubcategory(List<Invoice> invoices, String subCategory) {
      return invoices
          .where((invoice) => invoice.subCategory == subCategory)
          .map((invoice) => invoice.id)
          .toList();
    }


    List<int> idsWithTVTargetCategory = getIdsWithSubcategory(invoices, "TV");
    List<int> idsWithHBTargetCategory = getIdsWithSubcategory(invoices, "Ev Faturaları");
    List<int> idsWithRentTargetCategory = getIdsWithSubcategory(invoices, "Kira");

    int totalSubsElement = idsWithTVTargetCategory.length + gameTitleList.length + musicTitleList.length;
    int totalBillsElement = idsWithHBTargetCategory.length + internetTitleList.length + phoneTitleList.length;
    int totalOthersElement = idsWithRentTargetCategory.length + kitchenTitleList.length + cateringTitleList.length + entertainmentTitleList.length + otherTitleList.length;

    String formatPeriodDate(int day, int month) {
      final currentDate = DateTime.now();
      int year = currentDate.year;

      if (month > 12) {
        month = 1;
        year++;
      }

      // Handle the case where the day is 29th February and it's not a leap year
      if (day == 29 && month == 2 && !isLeapYear(year)) {
        day = 28;
      }

      return faturaDonemi = '${year.toString()}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    }
    String formatDueDate(int? day, String periodDay) {
      final currentDate = DateTime.now();
      int year = currentDate.year;

      // Parse the periodDay string to DateTime
      DateTime parsedPeriodDay = DateTime.parse(periodDay);
      int month = parsedPeriodDay.month;

      if (month > 12) {
        month = 1;
        year++;
      }

      // Handle the case where day is not null and is 29th February, and it's not a leap year
      if (day != null && day == 29 && month == 2 && !isLeapYear(year)) {
        day = 28;
      }

      // Use a default value of null if day is null
      int? calculatedDay = day;

      DateTime calculatedDate = DateTime(year, month, calculatedDay ?? 1);

      // Check if calculatedDate is before the parsedPeriodDay and increase the month if needed
      if (calculatedDate.isBefore(parsedPeriodDay)) {
        month++;
        if (month > 12) {
          month = 1;
          year++;
        }
        calculatedDate = DateTime(year, month, calculatedDay ?? 1);
      }

      // Return the formatted date as a string
      return sonOdeme = '${calculatedDate.year}-${calculatedDate.month.toString().padLeft(2, '0')}-${calculatedDate.day.toString().padLeft(2, '0')}';
    }

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
      _selectedBillingMonth = invoice.getPeriodMonth();
      _selectedBillingDay = invoice.getPeriodDay();
      _selectedDueDay = invoice.getDueDay();
      invoice.periodDate = formatPeriodDate(_selectedBillingDay ?? 0, _selectedBillingMonth ?? 0);
      if (_selectedDueDay != null) {
        invoice.dueDate = formatDueDate(_selectedDueDay, invoice.periodDate);
      }

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
            TextEditingController(text: invoice.name);
            TextEditingController priceController =
            TextEditingController(text: invoice.price);
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
            TextEditingController(text: invoice.name);
            TextEditingController priceController =
            TextEditingController(text: invoice.price);
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
                borderRadius: BorderRadius.circular(20)
            ),
            title: Text('Edit $caterogyName',style: const TextStyle(fontSize: 20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(alignment: Alignment.centerLeft,child: Text("Item", style: GoogleFonts.montserrat(fontSize: 18),),),
                const SizedBox(height: 10),
                TextFormField(
                  controller: selectedEditController,
                  decoration: InputDecoration(
                    isDense: true,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(width: 3, color: Colors.black)
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(width: 3, color: Colors.black), // Use the same border style for enabled state
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  ),
                  style: GoogleFonts.montserrat(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerLeft, child: Text("Price",style: GoogleFonts.montserrat(fontSize: 18))),
                const SizedBox(height: 10),
                TextFormField(
                  controller: selectedPriceController,
                  decoration: InputDecoration(
                    isDense: true,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(width: 3, color: Colors.black)
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(width: 3, color: Colors.black), // Use the same border style for enabled state
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  ),
                  style: GoogleFonts.montserrat(fontSize: 20),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerLeft, child: Text("Period Date",style: GoogleFonts.montserrat(fontSize: 18))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
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
                    ),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedBillingMonth,
                        onChanged: (value) {
                          setState(() {
                            _selectedBillingMonth = value;
                          });
                        },
                        items: monthsList.map((month) {
                          return DropdownMenuItem<int>(
                            value: month,
                            child: Text(month.toString()),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerLeft, child: Text("Due Date",style: GoogleFonts.montserrat(fontSize: 18))),
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
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            String name = selectedEditController.text;
                            invoice.name = name;
                            invoice.price = price;
                            if (_selectedDueDay != null) {
                              editInvoice(
                                id,
                                formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!),
                                formatDueDate(_selectedDueDay, formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!)),
                              );
                            } else {
                              editInvoice(
                                id,
                                formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!),
                                null, // or provide any default value you want for dueDate when _selectedDueDay is null
                              );
                            }
                            break;
                          case 2:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            gameTitleList[index] = selectedEditController.text;
                            gamePriceList[index] = price;
                            break;
                          case 3:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            musicTitleList[index] = selectedEditController.text;
                            musicPriceList[index] = price;
                            break;
                        }
                      } else if (page == 2){
                        switch (orderIndex){
                          case 1:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            String name = selectedEditController.text;
                            invoice.name = name;
                            invoice.price = price;
                            if (_selectedDueDay != null) {
                              editInvoice(
                                id,
                                formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!),
                                formatDueDate(_selectedDueDay, formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!)),
                              );
                            } else {
                              editInvoice(
                                id,
                                formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!),
                                null, // or provide any default value you want for dueDate when _selectedDueDay is null
                              );
                            }
                            break;
                          case 2:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            internetTitleList[index] = selectedEditController.text;
                            internetPriceList[index] = price;
                            break;
                          case 3:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            phoneTitleList[index] = selectedEditController.text;
                            phonePriceList[index] = price;
                            break;
                        }
                      } else if (page == 3){
                        switch (orderIndex){
                          case 1:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            String name = selectedEditController.text;
                            invoice.name = name;
                            invoice.price = price;
                            if (_selectedDueDay != null) {
                              editInvoice(
                                id,
                                formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!),
                                formatDueDate(_selectedDueDay, formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!)),
                              );
                            } else {
                              editInvoice(
                                id,
                                formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!),
                                null, // or provide any default value you want for dueDate when _selectedDueDay is null
                              );
                            }
                            break;
                          case 2:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            kitchenTitleList[index] = selectedEditController.text;
                            kitchenPriceList[index] = price;
                            break;
                          case 3:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            cateringTitleList[index] = selectedEditController.text;
                            cateringPriceList[index] = price;
                            break;
                          case 4:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            entertainmentTitleList[index] = selectedEditController.text;
                            entertainmentPriceList[index] = price;
                            break;
                          case 5:
                            final priceText = selectedPriceController.text.trim();
                            double dprice = double.tryParse(priceText) ?? 0.0;
                            String price = dprice.toStringAsFixed(2);
                            otherTitleList[index] = selectedEditController.text;
                            otherPriceList[index] = price;
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
                            removeInvoice(id);
                            break;
                          case 2:
                            gameTitleList.removeAt(index);
                            gamePriceList.removeAt(index);
                            break;
                          case 3:
                            musicTitleList.removeAt(index);
                            musicPriceList.removeAt(index);
                            break;
                        }
                      } else if (page == 2 && totalBillsElement != 1){
                        switch (orderIndex){
                          case 1:
                            removeInvoice(id);
                            break;
                          case 2:
                            internetTitleList.removeAt(index);
                            internetPriceList.removeAt(index);
                            break;
                          case 3:
                            phoneTitleList.removeAt(index);
                            phonePriceList.removeAt(index);
                            break;
                        }
                      } else if (page == 3 && totalOthersElement != 1){
                        switch (orderIndex){
                          case 1:
                            removeInvoice(id);
                            break;
                          case 2:
                            kitchenTitleList.removeAt(index);
                            kitchenPriceList.removeAt(index);
                            break;
                          case 3:
                            cateringTitleList.removeAt(index);
                            cateringPriceList.removeAt(index);
                            break;
                          case 4:
                            entertainmentTitleList.removeAt(index);
                            entertainmentPriceList.removeAt(index);
                            break;
                          case 5:
                            otherTitleList.removeAt(index);
                            otherPriceList.removeAt(index);
                            break;
                        }
                      } else {
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

    String currentDate = DateFormat('dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Giderler Detayı",
                style: TextStyle(
                  fontFamily: 'Keep Calm',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850] // Dark mode color
                      : Colors.white, // Light mode color
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.5) // Dark mode shadow color
                          : Colors.grey.withOpacity(0.5), // Light mode shadow color
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xFFF0EAD6)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tüm Giderler",
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              formattedOutcomeValue,
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,  // Stretch column to take full width
                              children: [
                                Stack(
                                  children: [
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      percent: percentages[0],
                                      backgroundColor: Colors.transparent,
                                      progressColor: const Color(0xFFFF8C00),
                                      lineHeight: 10.h,
                                      barRadius: const Radius.circular(10),
                                    ),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      percent: percentages[1] + percentages[2],
                                      progressColor: const Color(0xFFFFA500),
                                      backgroundColor: Colors.transparent,
                                      lineHeight: 10.h,
                                      barRadius: const Radius.circular(10),
                                    ),
                                    LinearPercentIndicator(
                                      padding: EdgeInsets.zero,
                                      percent: percentages[2],
                                      progressColor: const Color(0xFFFFD700),
                                      backgroundColor: Colors.transparent,
                                      lineHeight: 10.h,
                                      barRadius: const Radius.circular(10),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.h),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: (percentages[2] * 100).toInt(),
                                      child: Text(
                                        "%${(percentages[2] * 100).toStringAsFixed(0)}",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.grey[850] // Dark mode color
                                              : Colors.black, // Light mode color
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: (percentages[1] * 100).toInt(),
                                      child: Text(
                                        "%${(percentages[1] * 100).toStringAsFixed(0)}",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.grey[850] // Dark mode color
                                              : Colors.black, // Light mode color
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: ((percentages[2] * 100)+(percentages[1] * 100)).toInt(),
                                      child: Text(
                                        "%${((percentages[2] * 100)+(percentages[1] * 100)).toStringAsFixed(0)}",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.grey[850] // Dark mode color
                                              : Colors.black, // Light mode color
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                            //Text("$percentages", style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold)), DEBUG FOR PERCENTAGES
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (largestVariable == "subsPercent" && mediumVariable == "billsPercent")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                            decoration: BoxDecoration(
                              color: smallestSoftColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  animation: true,
                                  circularStrokeCap: CircularStrokeCap.round,
                                  radius: 23.sp,
                                  lineWidth: 6.w,
                                  percent: sumOfSubs/outcomeValue,
                                  center: Text(
                                    "%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}",
                                    style: GoogleFonts.montserrat(
                                      color: Colors.black,
                                      fontSize: (sumOfSubs/outcomeValue)*100 == 100
                                          ? 8.sp
                                          : 11.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  progressColor: smallestColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Abonelikler",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.black,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "$formattedSumOfSubs / $formattedOutcomeValue",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.black,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: mediumSoftColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 23.sp,
                                  lineWidth: 6.w,
                                  percent: sumOfBills/outcomeValue,
                                  center: Text(
                                      "%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}",
                                      style: GoogleFonts.montserrat(
                                          color: Colors.black,
                                          fontSize: (sumOfSubs/outcomeValue)*100 == 100
                                              ? 8.sp
                                              : 11.sp,
                                          fontWeight: FontWeight.w600
                                      )
                                  ),
                                  progressColor: mediumColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Faturalar",
                                        style: GoogleFonts.montserrat(
                                            color: Colors.black,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600
                                        )
                                    ),
                                    Text(
                                        "$formattedSumOfBills / $formattedOutcomeValue",
                                        style: GoogleFonts.montserrat(
                                            color: Colors.black,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500
                                        )
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: biggestSoftColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 23.sp,
                                  lineWidth: 6.w,
                                  percent: sumOfOthers/outcomeValue,
                                  center: Text(
                                      "%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}",
                                      style: GoogleFonts.montserrat(
                                          color: Colors.black,
                                          fontSize: (sumOfSubs/outcomeValue)*100 == 100
                                              ? 8.sp
                                              : 11.sp,
                                          fontWeight: FontWeight.w600
                                      )
                                  ),
                                  progressColor: biggestColor,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Diğer Giderler",
                                        style: GoogleFonts.montserrat(
                                            color: Colors.black,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600
                                        )
                                    ),
                                    Text(
                                        "$formattedSumOfOthers / $formattedOutcomeValue",
                                        style: GoogleFonts.montserrat(
                                            color: Colors.black,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500
                                        )
                                    )
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
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: 0,
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
              //Text('Period Dates: ${invoices.map((invoice) => invoice.periodDate.toString()).join(', ')}'),
              //Text(invoices.map((invoice) => '\nID: ${invoice.id}''\nName: ${invoice.name}''\nCategory: ${invoice.category}''\nSubcategory: ${invoice.subCategory}''\nDifference: ${invoice.difference}''\nPeriod: ${invoice.periodDate}\n').join(' | '),),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850] // Dark mode color
                      : Colors.white, // Light mode color
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.5) // Dark mode shadow color
                          : Colors.grey.withOpacity(0.5), // Light mode shadow color
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: variableNames[0] == "subsPercent"
                          ? smallestSoftColor
                            : variableNames[1] == "subsPercent"
                          ? mediumSoftColor
                            :biggestSoftColor
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    formattedSumOfSubs,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 19.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    )
                                ),
                                Text(
                                    formattedOutcomeValue,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    )
                                ),
                              ],
                            ),
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
                                progressColor: variableNames[0] == "subsPercent"
                                    ? smallestColor
                                    : variableNames[1] == "subsPercent"
                                    ? mediumColor
                                    :biggestColor
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ListView(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        if(invoices.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(200, 255, 243, 152),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:10, top:10),
                                  child: Text("TV", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(height: 20),
                                ListView(
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  children: idsWithTVTargetCategory.map((id) {
                                    Invoice invoice = invoices.firstWhere((invoice) => invoice.id == id);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(255, 255, 226, 3),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  flex:2,
                                                  child: ListTile(
                                                    dense: true,
                                                    title: Text("Name", style: TextStyle(color: Colors.black)),
                                                    subtitle: Text(
                                                        invoice.name,
                                                      style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex:2,
                                                  child: ListTile(
                                                    dense: true,
                                                    title: Text("Amount", style: TextStyle(color: Colors.black)),
                                                    subtitle: Text(
                                                        invoice.price,
                                                      style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Flexible(
                                                  flex:2,
                                                  child: ListTile(
                                                    dense: true,
                                                    title: Text("Period Date", style: TextStyle(color: Colors.black)),
                                                    subtitle: Text(
                                                        invoice.periodDate,
                                                      style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex:2,
                                                  child: ListTile(
                                                    dense: true,
                                                    title: Text("Due Date", style: TextStyle(color: Colors.black)),
                                                    subtitle: Text(
                                                        invoice.dueDate ?? "N/A",
                                                      style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(200, 255, 200, 0),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              padding: EdgeInsets.only(left: 20,right: 20),
                                              child: SizedBox(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("Düzenle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                                    IconButton(
                                                      splashRadius: 0.0001,
                                                      padding: EdgeInsets.zero,
                                                      constraints: BoxConstraints(minWidth: 23, maxWidth: 23),
                                                      icon: Icon(Icons.edit, size: 21, color: Colors.black),
                                                      onPressed: () {
                                                        print("TV: ${context}, $id");
                                                        _showEditDialog(context, idsWithTVTargetCategory.indexOf(id), 1, 1, id);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )

                              ],
                            ),
                          ),
                        if(gameTitleList.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Gaming", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                              const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                              ListView.builder(
                                padding: EdgeInsets.zero,
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
                                padding: EdgeInsets.zero,
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
                        SizedBox(height: 10),
                        if(!isSubsAddActive)
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(200, 255, 200, 0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.only(left: 20,right: 20),
                            child: SizedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Abonelik Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.black)),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isSubsAddActive = true;
                                      });
                                    },
                                    icon: const Icon(Icons.add_circle, color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if(isSubsAddActive)
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    PullDownButton(
                                      itemBuilder: (context) => subsItems
                                          .map(
                                              (item) => PullDownMenuItem(
                                              onTap: () {
                                              setState(() {
                                              dropdownvaluesubs = item;
                                              });
                                              },
                                              title: item.toString()
                                              )
                                      ).toList(),
                                      buttonBuilder: (context, showMenu) => ElevatedButton.icon(
                                        onPressed: showMenu,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        icon: const Icon(Icons.keyboard_arrow_down),
                                        label: Text(dropdownvaluesubs),
                                      ),
                                    ),
                                    Wrap(
                                      children: [
                                        if (!hasSubsCategorySelected)
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                hasSubsCategorySelected = true;
                                              });
                                            },
                                            icon: const Icon(Icons.arrow_downward, size: 26),
                                          ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
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
                                if (hasSubsCategorySelected)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Text("Item")
                                              ),
                                              SizedBox(width: 20.w),
                                              Expanded(
                                                  child: Text("Price")
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: textController,
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    isDense: true,
                                                    fillColor: Colors.white,
                                                    contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                      borderSide: BorderSide(color: Colors.amber, width: 3),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                      borderSide: BorderSide(color: Colors.black, width: 3),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                    ),
                                                    hintText: 'ABA',
                                                    hintStyle: TextStyle(color: Colors.black)
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 20.w),
                                            Expanded(
                                              child: TextFormField(
                                                controller: platformPriceController,
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                    filled: true,
                                                    isDense: true,
                                                    fillColor: Colors.white,
                                                    contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                      borderSide: BorderSide(color: Colors.amber, width: 3),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                      borderSide: BorderSide(color: Colors.black, width: 3),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                    ),
                                                    hintText: 'GAG',
                                                    hintStyle: TextStyle(color: Colors.black)
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Text("Başlangıç Günü")
                                              ),
                                              SizedBox(width: 20.w),
                                              Expanded(
                                                  child: Text("Başlangıç Ayı")
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: PullDownButton(
                                                  itemBuilder: (context) => daysList
                                                      .map(
                                                        (day) => PullDownMenuItem(
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedBillingDay = day;
                                                          });
                                                        },
                                                        title: day.toString()
                                                    ),
                                                  ).toList(),
                                                  buttonBuilder: (context, showMenu) => ElevatedButton(
                                                    onPressed: showMenu,
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                            _selectedBillingDay == null
                                                                ? "Gün"
                                                                : _selectedBillingDay.toString(),
                                                            style: TextStyle(
                                                                color: Colors.black
                                                            )
                                                        ),
                                                        Icon(
                                                            Icons.arrow_drop_down,
                                                            color: Colors.black
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                            ),
                                            SizedBox(width: 20.w),
                                            Expanded(
                                                child: PullDownButton(
                                                  itemBuilder: (context) => monthsList
                                                      .map(
                                                        (month) => PullDownMenuItem(
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedBillingMonth = month;
                                                          });
                                                        },
                                                        title: monthNames[month - 1]
                                                    ),
                                                  ).toList(),
                                                  buttonBuilder: (context, showMenu) => ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                    ),
                                                    onPressed: showMenu,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                            _selectedBillingMonth == null
                                                                ? "Ay"
                                                                : monthNames[_selectedBillingMonth! - 1],
                                                            style: TextStyle(
                                                                color: Colors.black
                                                            )
                                                        ),
                                                        Icon(Icons.arrow_drop_down, color: Colors.black)
                                                      ],
                                                    ),
                                                  ),
                                                )
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                              child: Text("Son Ödeme Günü")
                                          ),
                                        ),
                                        Row(
                                            children: [
                                              Expanded(
                                                  child: PullDownButton(
                                                    itemBuilder: (context) => daysList
                                                        .map(
                                                          (day) => PullDownMenuItem(
                                                          onTap: () {
                                                            setState(() {
                                                              _selectedDueDay = day;
                                                            });
                                                          },
                                                          title: day.toString()
                                                      ),
                                                    ).toList(),
                                                    buttonBuilder: (context, showMenu) => ElevatedButton(
                                                      onPressed: showMenu,
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(20),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                              _selectedDueDay == null
                                                                  ? "Gün"
                                                                  : _selectedDueDay.toString(),
                                                              style: TextStyle(
                                                                  color: Colors.black
                                                              )
                                                          ),
                                                          Icon(Icons.arrow_drop_down, color: Colors.black)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              ),
                                              SizedBox(width: 20.w),
                                              Expanded(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    final prefs = await SharedPreferences.getInstance();
                                                    setState(() {
                                                      int maxId = 0; // Initialize with the lowest possible value
                                                      for (var invoice in invoices) {
                                                        if (invoice.id > maxId) {
                                                          maxId = invoice.id;
                                                        }
                                                      }
                                                      int newId = maxId + 1;
                                                      final text = textController.text.trim();
                                                      final priceText = platformPriceController.text.trim();
                                                      double dprice = double.tryParse(priceText) ?? 0.0;
                                                      String price = dprice.toStringAsFixed(2);
                                                      if (text.isNotEmpty && priceText.isNotEmpty && dropdownvaluesubs == "Film, Dizi ve TV") {
                                                        final invoice = Invoice(
                                                            id: newId,
                                                            price: price,
                                                            subCategory: 'TV',
                                                            category: 'Abonelikler',
                                                            name: text,
                                                            periodDate: formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!),
                                                            dueDate: _selectedDueDay != null
                                                                ? formatDueDate(_selectedDueDay!, formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!))
                                                                : null,
                                                            difference: "tv2"
                                                        );
                                                        onSave(invoice);
                                                        if (text.isNotEmpty && priceText.isNotEmpty) {
                                                          setState(() {
                                                            textController.clear();
                                                            platformPriceController.clear();
                                                            isSubsAddActive = false;
                                                            hasSubsCategorySelected = false;
                                                          });
                                                        }
                                                      } else if (text.isNotEmpty && priceText.isNotEmpty && dropdownvaluesubs == "Oyun") {
                                                        setState(() {
                                                          gameTitleList.add(text);
                                                          gamePriceList.add(price);
                                                          prefs.setStringList('gameTitleList2', gameTitleList);
                                                          prefs.setStringList('gamePriceList2', gamePriceList);
                                                          textController.clear();
                                                          platformPriceController.clear();
                                                          isSubsAddActive = false;
                                                          hasSubsCategorySelected = false;
                                                          _load();
                                                        });
                                                      } else if (text.isNotEmpty && priceText.isNotEmpty && dropdownvaluesubs == "Müzik") {
                                                        setState(() {
                                                          musicTitleList.add(text);
                                                          musicPriceList.add(price);
                                                          prefs.setStringList('musicTitleList2', musicTitleList);
                                                          prefs.setStringList('musicPriceList2', musicPriceList);
                                                          textController.clear();
                                                          platformPriceController.clear();
                                                          isSubsAddActive = false;
                                                          hasSubsCategorySelected = false;
                                                          _load();
                                                        });
                                                      }
                                                    });
                                                  },
                                                  child: Icon(Icons.check_circle, size: 26, color: Colors.black),
                                                ),
                                              )
                                            ],
                                        )
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text("Faturalar", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850] // Dark mode color
                      : Colors.white, // Light mode color
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.5) // Dark mode shadow color
                          : Colors.grey.withOpacity(0.5), // Light mode shadow color
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                          color: variableNames[0] == "billsPercent"
                              ? smallestSoftColor
                              : variableNames[1] == "billsPercent"
                              ? mediumSoftColor
                              :biggestSoftColor
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    formattedSumOfBills,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 19.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    )
                                ),
                                Text(
                                    formattedOutcomeValue,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    )
                                ),
                              ],
                            ),
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
                                progressColor: variableNames[0] == "billsPercent"
                                    ? smallestColor
                                    : variableNames[1] == "billsPercent"
                                    ? mediumColor
                                    :biggestColor
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        if(invoices.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 255, 204, 148),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:10, top:10),
                                  child: Text("Home Bills", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(height: 20),
                                ListView(
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  children: idsWithHBTargetCategory.map((id) {
                                    Invoice invoice = invoices.firstWhere((invoice) => invoice.id == id);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(200, 255, 199, 138),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  flex:2,
                                                  child: ListTile(
                                                    dense: true,
                                                    title: Text("Name", style: TextStyle(color: Colors.black)),
                                                    subtitle: Text(
                                                      invoice.name,
                                                      style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex:2,
                                                  child: ListTile(
                                                    dense: true,
                                                    title: Text("Amount", style: TextStyle(color: Colors.black)),
                                                    subtitle: Text(
                                                      invoice.price,
                                                      style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Flexible(
                                                  flex:2,
                                                  child: ListTile(
                                                    dense: true,
                                                    title: Text("Period Date", style: TextStyle(color: Colors.black)),
                                                    subtitle: Text(
                                                      invoice.periodDate,
                                                      style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex:2,
                                                  child: ListTile(
                                                    dense: true,
                                                    title: Text("Due Date", style: TextStyle(color: Colors.black)),
                                                    subtitle: Text(
                                                      invoice.dueDate ?? "N/A",
                                                      style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(200, 255, 176, 89),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              padding: EdgeInsets.only(left: 20,right: 20),
                                              child: SizedBox(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("Düzenle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                                    IconButton(
                                                      splashRadius: 0.0001,
                                                      padding: EdgeInsets.zero,
                                                      constraints: BoxConstraints(minWidth: 23, maxWidth: 23),
                                                      icon: Icon(Icons.edit, size: 21, color: Colors.black),
                                                      onPressed: () {
                                                        _showEditDialog(context, idsWithHBTargetCategory.indexOf(id), 1, 1, id);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        if(internetTitleList.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Internet", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                              const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                              ListView.builder(
                                padding: EdgeInsets.zero,
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
                                padding: EdgeInsets.zero,
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
                        SizedBox(height: 10),
                        if(!isBillsAddActive)
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(200, 255, 176, 89),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.only(left: 20,right: 20),
                            child: SizedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Fatura Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isBillsAddActive = true;
                                      });
                                    },
                                    icon: const Icon(Icons.add_circle, color: Colors.black),
                                  ),
                                ],
                              ),
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
                            child: Column(
                              children: [
                                Row(
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
                                          onPressed: () async{
                                            final prefs = await SharedPreferences.getInstance();
                                            setState((){
                                              int maxId = 0; // Initialize with the lowest possible value
                                              for (var invoice in invoices) {
                                                if (invoice.id > maxId) {
                                                  maxId = invoice.id;
                                                }
                                              }
                                              int newId = maxId + 1;
                                              final text = textController.text.trim();
                                              final priceText = platformPriceController.text.trim();
                                              double dprice = double.tryParse(priceText) ?? 0.0;
                                              String price = dprice.toStringAsFixed(2);

                                              if (text.isNotEmpty && priceText.isNotEmpty && dropdownvaluebills == "Ev Faturaları") {
                                                final invoice = Invoice(
                                                    id: newId,
                                                    price: price,
                                                    subCategory: 'Ev Faturaları',
                                                    category: "Faturalar",
                                                    name: text,
                                                    periodDate: formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!),
                                                    dueDate: _selectedDueDay != null
                                                        ? formatDueDate(_selectedDueDay!, formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!))
                                                        : null,
                                                    difference: "fa2"
                                                );
                                                onSave(invoice);
                                                if (text.isNotEmpty && priceText.isNotEmpty) {
                                                  textController.clear();
                                                  platformPriceController.clear();
                                                  //isTextFormFieldVisible = false;
                                                  isBillsAddActive = false;
                                                  hasBillsCategorySelected = false;
                                                }
                                              } else if (text.isNotEmpty && priceText.isNotEmpty && dropdownvaluebills == "İnternet") {
                                                setState(() {
                                                  internetTitleList.add(text);
                                                  internetPriceList.add(price);
                                                  prefs.setStringList('internetTitleList2', internetTitleList);
                                                  prefs.setStringList('internetPriceList2', internetPriceList);
                                                  textController.clear();
                                                  platformPriceController.clear();
                                                  //isTextFormFieldVisible = false;
                                                  isBillsAddActive = false;
                                                  hasBillsCategorySelected = false;
                                                  _load();
                                                });
                                              } else if (text.isNotEmpty && priceText.isNotEmpty && dropdownvaluebills == "Telefon") {
                                                setState(() {
                                                  phoneTitleList.add(text);
                                                  phonePriceList.add(price);
                                                  prefs.setStringList('phoneTitleList2', phoneTitleList);
                                                  prefs.setStringList('phonePriceList2', phonePriceList);
                                                  textController.clear();
                                                  platformPriceController.clear();
                                                  //isTextFormFieldVisible = false;
                                                  isBillsAddActive = false;
                                                  hasBillsCategorySelected = false;
                                                  _load();
                                                });
                                              }
                                            });
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<int>(
                                        value: null,
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
                                    ),
                                    Expanded(
                                      child: DropdownButtonFormField<int>(
                                        value: null,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedBillingMonth = value;
                                          });
                                        },
                                        items: monthsList.map((month) {
                                          return DropdownMenuItem<int>(
                                            value: month,
                                            child: Text(month.toString()),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<int>(
                                  value: null,
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
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850] // Dark mode color
                      : Colors.white, // Light mode color
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.5) // Dark mode shadow color
                          : Colors.grey.withOpacity(0.5), // Light mode shadow color
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                          color: variableNames[0] == "othersPercent"
                              ? smallestSoftColor
                              : variableNames[1] == "othersPercent"
                              ? mediumSoftColor
                              :biggestSoftColor
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    formattedSumOfOthers,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 19.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    )
                                ),
                                Text(
                                    formattedOutcomeValue,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    )
                                ),
                              ],
                            ),
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
                                progressColor: variableNames[0] == "othersPercent"
                                    ? smallestColor
                                    : variableNames[1] == "othersPercent"
                                    ? mediumColor
                                    :biggestColor
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        if(invoices.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 255, 171, 138),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:10, top:10),
                                  child: Text("Rent", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(height: 20),
                                ListView(
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  children: idsWithRentTargetCategory.map((id) {
                                    Invoice invoice = invoices.firstWhere((invoice) => invoice.id == id);
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(255, 255, 127, 77),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  flex:2,
                                                  child: ListTile(
                                                    dense: true,
                                                    title: Text("Name", style: TextStyle(color: Colors.black)),
                                                    subtitle: Text(
                                                      invoice.name,
                                                      style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex:2,
                                                  child: ListTile(
                                                    dense: true,
                                                    title: Text("Amount", style: TextStyle(color: Colors.black)),
                                                    subtitle: Text(
                                                      invoice.price,
                                                      style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Flexible(
                                                  flex:2,
                                                  child: ListTile(
                                                    dense: true,
                                                    title: Text("Period Date", style: TextStyle(color: Colors.black)),
                                                    subtitle: Text(
                                                      invoice.periodDate,
                                                      style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex:2,
                                                  child: ListTile(
                                                    dense: true,
                                                    title: Text("Due Date", style: TextStyle(color: Colors.black)),
                                                    subtitle: Text(
                                                      invoice.dueDate ?? "N/A",
                                                      style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(200, 247, 69, 0),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              padding: EdgeInsets.only(left: 20,right: 20),
                                              child: SizedBox(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("Düzenle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                                    IconButton(
                                                      splashRadius: 0.0001,
                                                      padding: EdgeInsets.zero,
                                                      constraints: BoxConstraints(minWidth: 23, maxWidth: 23),
                                                      icon: Icon(Icons.edit, size: 21, color: Colors.black),
                                                      onPressed: () {
                                                        _showEditDialog(context, idsWithRentTargetCategory.indexOf(id), 1, 1, id);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList()
                                ),
                              ],
                            ),
                          ),
                        if(kitchenTitleList.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Kitchen", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                              const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                              ListView.builder(
                                padding: EdgeInsets.zero,
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
                                padding: EdgeInsets.zero,
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
                                padding: EdgeInsets.zero,
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
                                padding: EdgeInsets.zero,
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
                        SizedBox(height: 10),
                        if(!isOthersAddActive)
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(200, 247, 69, 0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.only(left: 20,right: 20),
                            child: SizedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Diğer Gider Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isOthersAddActive = true;
                                      });
                                    },
                                    icon: const Icon(Icons.add_circle, color: Colors.black),
                                  ),
                                ],
                              ),
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
    );
  }
}