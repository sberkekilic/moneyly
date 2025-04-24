// ignore_for_file: unused_import, avoid_unnecessary_containers

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/models/transaction.dart';
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
  List<Map<String, dynamic>> bankAccounts = [];
  Map<String, dynamic>? selectedAccount;
  bool isLoading = true; // Flag to indicate loading state

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

  Map<String, List<Map<String, dynamic>>> userCategories = {};
  final TextEditingController subcategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Function to get the correct number of days for a given month in the current year
  int _daysInMonth(int month) {
    int year = DateTime.now().year;
    return DateTime(year, month + 1, 0).day;
  }

// Function to update the days list based on the selected month
  void _updateDaysListForSelectedMonth() {
    daysList = List.generate(_daysInMonth(_selectedBillingMonth!), (index) => index + 1);

    // Ensure selected day is within the updated range
    if (_selectedBillingDay != null && (_selectedBillingDay! > daysList.length)) {
      setState(() {
        _selectedBillingDay = daysList.last;
      });
    } else if (_selectedDueDay != null && (_selectedDueDay! > daysList.length)) {
      setState(() {
        _selectedDueDay = daysList.last;
      });
    }
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
    final String? data = prefs.getString("userCategories");
    String? accountDataListJson = prefs.getString('accountDataList');
    String? accountData = prefs.getString('selectedAccount');
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
      if (data != null) {
        setState(() {
          userCategories = Map<String, List<Map<String, dynamic>>>.from(
            (jsonDecode(data) as Map).map((key, value) =>
                MapEntry(key as String, List<Map<String, dynamic>>.from(value))),
          );
        });
      }
      // Handle account data list
      if (accountDataListJson != null) {
        try {
          List<Map<String, dynamic>> decodedData = List<Map<String, dynamic>>.from(jsonDecode(accountDataListJson));
          print('Tüm Hesaplar: $decodedData');
          bankAccounts = decodedData.toSet().toList();

          if (accountData != null) {
            final Map<String, dynamic> accountFromPrefs = Map<String, dynamic>.from(jsonDecode(accountData));
            print('Saved account data: $accountFromPrefs');

            // Only proceed if we have both bankId and accountId
            if (accountFromPrefs['bankId'] != null && accountFromPrefs['accountId'] != null) {
              // Find the bank first
              final bank = bankAccounts.firstWhere(
                    (bank) => bank['bankId'] == accountFromPrefs['bankId'],
                orElse: () => {},
              );

              if (bank.isNotEmpty) {
                // Then find the specific account within that bank
                final accounts = bank['accounts'] as List?;
                if (accounts != null) {
                  final account = accounts.firstWhere(
                        (acc) => acc['accountId'] == accountFromPrefs['accountId'],
                    orElse: () => {},
                  );

                  if (account.isNotEmpty) {
                    // Combine bank info with account info
                    selectedAccount = {
                      ...account,
                      'bankId': bank['bankId'],
                      'bankName': bank['bankName'],
                      // Include any other bank fields you need
                    };
                  }
                }
              }
            }
          }

          setState(() => isLoading = false);
        } catch (e) {
          print('Error decoding account data: $e');
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }

      print('Seçili hesap: $accountData');
      print('Selected account1: $selectedAccount');

      if (accountData != null && selectedAccount == null) {
        final savedData = jsonDecode(accountData);

        // Check if accountId exists and is not null
        if (savedData['accountId'] != null) {
          final account = _findAccountById(savedData['accountId']);
          if (account != null) {
            setState(() {
              selectedAccount = account;
            });
          }
        } else {
          print('Warning: savedData contains null accountId: $savedData');
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

  double calculateTotalPrice() {
    double total = 0.0;

    userCategories.forEach((category, entries) {
      for (var entry in entries) {
        final price = double.tryParse(entry['amount'].toString());
        if (price != null) {
          total += price;
        }
      }
    });

    return total;
  }

  double calculateCategoryTotal(String category) {
    double total = 0.0;

    if (userCategories.containsKey(category)) {
      for (var entry in userCategories[category]!) {
        final price = double.tryParse(entry['amount'].toString());
        if (price != null) total += price;
      }
    }

    return total;
  }



  @override
  Widget build(BuildContext context) {
    outcomeValue = calculateTotalPrice();
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

    Future<void> _saveSelectedAccount(Map<String, dynamic> account) async {
      // First get the actual account ID - might be nested in an 'accounts' array
      final dynamic accountId = account['accountId'] ??
          (account['accounts'] as List?)?.firstOrNull?['accountId'];

      // Get bank ID - might be at top level
      final dynamic bankId = account['bankId'];

      if (accountId == null || bankId == null) {
        print('Cannot save account - missing IDs. Full account data: $account');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedAccount', jsonEncode({
        'accountId': accountId,
        'bankId': bankId,
      }));
      print('Successfully saved account: $accountId from bank: $bankId');
    }

    Future<void> _saveToPrefs() async {
      final prefs = await SharedPreferences.getInstance();
      try {
        final jsonString = jsonEncode(bankAccounts);
        await prefs.setString('accountDataList', jsonString);
        print('[DEBUG] Saved accountDataList: $jsonString');
      } catch (e) {
        print('[ERROR] Failed to save accountDataList: $e');
      }
    }

    Future<void> _saveCategoriesToPrefs() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userCategories', jsonEncode(userCategories));
    }

    void _addSubcategory(String category, String subcategory) async {
      // Create a new subcategory entry
      Map<String, dynamic> entry = {
        "subcategory": subcategory,
      };

      // Add the new subcategory to the category
      if (userCategories.containsKey(category)) {
        userCategories[category]!.add(entry);
      } else {
        userCategories[category] = [entry];
      }

      setState(() {});
      await _saveToPrefs();
    }


    void _addEntry(String category, String subcategory, String title, double amount) async {
      print('[DEBUG] Starting _addEntry');
      print('[DEBUG] Selected Account: ${selectedAccount?['accountId']}');
      print('[DEBUG] BankAccounts before: ${jsonEncode(bankAccounts)}');
      // First ensure we have a selected account
      if (selectedAccount == null) {
        print('No account selected');
        return;
      }
      // Create transaction entry
      final transaction = Transaction(
          transactionId: DateTime.now().millisecondsSinceEpoch,
          date: DateTime.now(),
          amount: amount,
          isFromInvoice: false,
          currency: 'TRY',
          subcategory: subcategory,
          category: category,
          description: 'deneme description',
          title: title,
          isSurplus: false,
          initialInstallmentDate: null
      );

      // Update the selected account's transactions
      setState(() {
        print('[DEBUG] Starting account update');
        // Find the account in bankAccounts
        for (var bank in bankAccounts) {
          print('[DEBUG] Checking bank: ${bank['bankId']}');
          if (bank['bankId'] == selectedAccount!['bankId']) {
            print('[DEBUG] Found matching bank');
            final accounts = bank['accounts'] as List?;
            if (accounts != null) {
              for (var account in accounts) {
                print('[DEBUG] Checking account: ${account['accountId']}');
                if (account['accountId'] == selectedAccount!['accountId']) {
                  print('[DEBUG] Found matching account');
                  // Initialize transactions list if null
                  account['transactions'] ??= [];
                  print('[DEBUG] Transactions before add: ${account['transactions'].length}');
                  // Add new transaction
                  account['transactions'].add(transaction);
                  print('[DEBUG] Transactions after add: ${account['transactions'].length}');
                  // Update the balance
                  account['balance'] = (account['balance'] ?? 0.0) + amount;
                  print('[DEBUG] New balance: ${account['balance']}');

                  // Update the selectedAccount reference
                  selectedAccount = {
                    ...account,
                    'bankId': bank['bankId'],
                    'bankName': bank['bankName'],
                    'currency': bank['currency'],
                    'isDebit': bank['isDebit'],
                    'creditLimit': bank['creditLimit'],
                    'cutoffDate': bank['cutoffDate'],
                  };
                  print('[DEBUG] Updated selectedAccount');
                  break;
                }
              }
            }
          }
        }
      });

      print('[DEBUG] BankAccounts after: ${jsonEncode(bankAccounts)}');

      // Save to SharedPreferences
      await _saveToPrefs();
      await _saveSelectedAccount(selectedAccount!);

      // Also save to userCategories if needed
      if (userCategories.containsKey(category)) {
        userCategories[category]!.add({
          "subcategory": subcategory,
          "title": title,
          "amount": amount,
        });
      } else {
        userCategories[category] = [{
          "subcategory": subcategory,
          "title": title,
          "amount": amount,
        }];
      }

      // Save categories separately if needed
      await _saveCategoriesToPrefs();
    }

    void _editEntry(String category, int index, Map<String, dynamic> updatedEntry) {
      setState(() {
        userCategories[category]![index] = updatedEntry;
      });
      _saveToPrefs();
    }

    void _deleteEntry(String category, int index) {
      setState(() {
        userCategories[category]!.removeAt(index);
        // Eğer kategori tamamen boş kaldıysa istersen onu da sil
        if (userCategories[category]!.isEmpty) {
          userCategories.remove(category);
        }
      });
      _saveToPrefs();
    }

    void _showAddDialog(BuildContext context) {
      final TextEditingController categoryController = TextEditingController();
      final TextEditingController subcategoryController = TextEditingController();
      final TextEditingController titleController = TextEditingController();
      final TextEditingController priceController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Yeni Gider Ekle"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: "Kategori"),
                ),
                TextField(
                  controller: subcategoryController,
                  decoration: const InputDecoration(labelText: "Alt Kategori"),
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Başlık"),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Fiyat"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _addEntry(
                    categoryController.text.trim(),
                    subcategoryController.text.trim(),
                    titleController.text,
                    double.tryParse(priceController.text) ?? 0.0, // Make sure price is parsed to double
                  );
                  Navigator.of(context).pop();
                },
                child: const Text("Ekle"),
              ),
            ],
          );
        },
      );
    }

    void _showEditDialog(BuildContext context, String category, String subcategory, int index) {
      final data = userCategories[category]!.firstWhere((entry) => entry["subcategory"] == subcategory);
      final TextEditingController titleController = TextEditingController(text: data["title"]);
      final TextEditingController priceController = TextEditingController(text: data["amount"] != null ? data["amount"].toString() : "");

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Gideri Düzenle"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Başlık"),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Fiyat"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _deleteEntry(category, index);
                  Navigator.of(context).pop();
                },
                child: const Text("Sil", style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  _editEntry(category, index, {
                    "title": titleController.text,
                    "amount": priceController.text,
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("Kaydet"),
              ),
            ],
          );
        },
      );
    }

    void _showAddSubcategoryDialog(String category) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Alt Kategori Ekle"),
            content: TextField(
              controller: subcategoryController,
              decoration: InputDecoration(labelText: "Alt kategori ismi"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (subcategoryController.text.trim().isNotEmpty) {
                    _addSubcategory(category, subcategoryController.text.trim());
                    Navigator.pop(context); // Close the dialog
                  }
                },
                child: Text("Ekle"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("İptal"),
              ),
            ],
          );
        },
      );
    }

    void _showAddExpenseDialog(BuildContext context, String category, int index) {
      final TextEditingController titleController = TextEditingController();
      final TextEditingController amountController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Gider Ekle"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Başlık"),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: "Fiyat"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("İptal"),
              ),
              TextButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  final amount = double.tryParse(amountController.text.trim());
                  if (title.isNotEmpty && amount != null) {
                    setState(() {
                      userCategories[category]![index]["title"] = title;
                      userCategories[category]![index]["amount"] = amount;
                    });
                  }
                  setState(() {});
                  await _saveToPrefs();
                  Navigator.of(context).pop();
                },
                child: const Text("Kaydet"),
              ),
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
              Text(
                userCategories.entries.map((entry) {
                  final category = entry.key;
                  final items = entry.value.map((item) {
                    return item.entries.map((e) => '${e.key}: ${e.value}').join(', ');
                  }).join(' | ');
                  return '$category - $items';
                }).join(' | '),
                style: GoogleFonts.montserrat(fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 10,
              ),
              SizedBox(height: 20.h),
              bankAccounts.isEmpty
                  ? const Text("Banka hesabı bulunamadı.")
                  : Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: DropdownButtonFormField<int>(
                  value: selectedAccount?['accountId'],
                  decoration: InputDecoration(
                    labelText: "Choose an account",
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: bankAccounts.expand<DropdownMenuItem<int>>((bank) {
                    return (bank['accounts'] as List?)?.map((account) {
                      return DropdownMenuItem<int>(
                        value: account['accountId'],
                        child: Text("${bank['bankName']} - ${account['name']}"),
                      );
                    }) ?? [];
                  }).toList(),
                  onChanged: (selectedAccountId) {
                    if (selectedAccountId != null) {
                      final account = _findAccountById(selectedAccountId);
                      if (account != null) {
                        setState(() {
                          selectedAccount = account;
                        });
                        _saveSelectedAccount(account);
                      }
                    }
                  },
                ),
              ),
              userCategories.isEmpty
                  ? Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.redAccent.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    "Lütfen önce kategori ekleyin.",
                    style: GoogleFonts.montserrat(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              )
                  : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFF0EAD6),
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
                        "${calculateTotalPrice().toStringAsFixed(2)} ₺",
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: userCategories.entries.map((entry) {
                          final category = entry.key;
                          final categoryTotal = calculateCategoryTotal(category);
                          final total = calculateTotalPrice();
                          final percentage = total > 0 ? (categoryTotal / total) : 0.0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      category,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      "%${(percentage * 100).toStringAsFixed(2)}",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearPercentIndicator(
                                  padding: EdgeInsets.zero,
                                  lineHeight: 10,
                                  percent: percentage.clamp(0.0, 1.0),
                                  progressColor: Colors.orangeAccent,
                                  backgroundColor: Colors.orangeAccent.withOpacity(0.3),
                                  barRadius: const Radius.circular(8),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: userCategories.entries.map((entry) {
                  final category = entry.key;
                  final subcategories = entry.value;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Title
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0, bottom: 6),
                          child: Text(
                            category,
                            style: GoogleFonts.montserrat(
                              color: const Color(0xFF333333),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Divider(thickness: 1.2, color: Color(0xffd0d0d0)),
                        ...subcategories.map((subcategoryData) {
                          final subcategory = subcategoryData["subcategory"] ?? "";
                          final title = subcategoryData["title"] ?? "";
                          final amount = subcategoryData["amount"];
                          final hasContent = title.isNotEmpty || amount != null;

                          return Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                childrenPadding: const EdgeInsets.fromLTRB(16, 4, 12, 8),
                                backgroundColor: Colors.white,
                                collapsedBackgroundColor: const Color(0xFFF2F2F2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                title: Text(
                                  subcategory,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                children: [
                                  if (hasContent)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 3,
                                            child: Text(
                                              title,
                                              style: GoogleFonts.montserrat(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF444444),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 2,
                                            child: Text(
                                              amount?.toString() ?? "",
                                              style: GoogleFonts.montserrat(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF00796B),
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          IconButton(
                                            splashRadius: 20,
                                            icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                                            onPressed: () {
                                              _showEditDialog(
                                                context,
                                                category,
                                                subcategory,
                                                subcategories.indexOf(subcategoryData),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () {
                                        _showAddExpenseDialog(context, category, subcategories.indexOf(subcategoryData));
                                      },
                                      icon: const Icon(Icons.add, size: 18, color: Color(0xFF00695C)),
                                      label: const Text("Gider ekle", style: TextStyle(color: Color(0xFF00695C))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () {
                              _showAddSubcategoryDialog(category);
                            },
                            icon: const Icon(Icons.add, size: 18, color: Color(0xFF004D40)),
                            label: const Text("Alt kategori ekle", style: TextStyle(color: Color(0xFF004D40))),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Map<String, dynamic>? _findAccountById(int? accountId) {
    if (accountId == null) {
      print('Warning: _findAccountById called with null accountId');
      return null;
    }

    for (var bank in bankAccounts) {
      for (var account in bank['accounts'] ?? []) {
        if (account['accountId'] == accountId) {
          // Return a flattened structure with account + bank info
          return {
            ...account, // Spread all account fields
            'bankId': bank['bankId'],
            'bankName': bank['bankName'],
            'currency': bank['currency'],
            'isDebit': bank['isDebit'] ?? true,
            'creditLimit': bank['creditLimit'] ?? false,
            'cutoffDate': bank['cutoffDate'] ?? false,
            // Don't include nested accounts array since we're selecting one account
          };
        }
      }
    }
    return null;
  }
}