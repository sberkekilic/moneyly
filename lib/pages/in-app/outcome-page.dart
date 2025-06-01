// ignore_for_file: unused_import, avoid_unnecessary_containers

import 'dart:convert';
import 'dart:math' as math;

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
import '../../models/account.dart';
import '../../models/category.dart';
import '../add-expense/faturalar.dart';

class OutcomePage extends StatefulWidget {
  const OutcomePage({Key? key}) : super(key: key);

  @override
  State<OutcomePage> createState() => _OutcomePageState();
}

class _OutcomePageState extends State<OutcomePage> {
  List<Map<String, dynamic>> bankAccounts = [];
  Map<String, dynamic>? selectedAccount;
  DateTime? _selectedDate;
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

  List<CategoryData> userCategories = [];
  List<Transaction> transactions = [];

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
    final data = await CategoryStorage.load();
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
          userCategories = data;
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

    final rawList = selectedAccount?['transactions'];
    if (rawList != null) {
      transactions = List<Map<String, dynamic>>.from(rawList)
          .map((json) => Transaction.fromJson(json))
          .toList();
    }

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

  void _addOrUpdateTransaction([Transaction? existing]) {
    bool isProvisioned = existing?.isProvisioned ?? false;
    final formKey = GlobalKey<FormState>();
    String? selectedCategory = existing?.category;
    String? selectedSubcategory = existing?.subcategory;
    final titleController = TextEditingController(text: existing?.title ?? '');
    final amountController = TextEditingController(text: existing?.amount.toString() ?? '');
    final TextEditingController installmentController = TextEditingController();
    DateTime? _installmentStartDate;
    DateTime? _selectedDate = existing?.date;

    Future<void> _selectDate(BuildContext context, void Function(void Function()) setDialogState) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2050),
      );
      if (picked != null) {
        setDialogState(() => _selectedDate = picked);
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? "Add Transaction" : "Edit Transaction"),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: userCategories.map((e) => e.category).toSet().map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedCategory = val;
                          selectedSubcategory = null;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Category'),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedSubcategory,
                      items: userCategories
                          .where((e) => e.category == selectedCategory)
                          .map((e) => e.subcategory)
                          .toSet()
                          .map((sub) => DropdownMenuItem(value: sub, child: Text(sub)))
                          .toList(),
                      onChanged: (val) => setDialogState(() => selectedSubcategory = val),
                      decoration: const InputDecoration(labelText: 'Subcategory'),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount'),
                      validator: (val) => val == null || double.tryParse(val) == null ? 'Invalid' : null,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: installmentController,
                      decoration: const InputDecoration(
                        labelText: 'Installment Count',
                        hintText: 'E.g. 3 for 3 months',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text("Provisioned Transaction?"),
                      value: isProvisioned,
                      onChanged: (val) => setDialogState(() => isProvisioned = val ?? false),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Installment Start Date"),
                      subtitle: Text(
                        _installmentStartDate != null
                            ? DateFormat.yMd().format(_installmentStartDate!)
                            : "Choose Date",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              _installmentStartDate = picked;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Transaction Date"),
                      subtitle: Text(
                        _selectedDate != null
                            ? DateFormat.yMd().format(_selectedDate!)
                            : 'No date selected',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.date_range),
                        onPressed: () => _selectDate(context, setDialogState),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final isEditing = existing != null;
              final amount = double.parse(amountController.text);
              final int? installmentCount = int.tryParse(installmentController.text);
              final DateTime baseDate = _installmentStartDate ?? _selectedDate ?? DateTime.now();

              DateTime addMonthsSafe(DateTime date, int monthsToAdd) {
                final newYear = date.year + ((date.month + monthsToAdd - 1) ~/ 12);
                final newMonth = (date.month + monthsToAdd - 1) % 12 + 1;
                final newDay = math.min(date.day, DateTime(newYear, newMonth + 1, 0).day);
                return DateTime(newYear, newMonth, newDay);
              }

              final now = DateTime.now();
              int paidInstallmentCount = 0;
              DateTime normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

              if (installmentCount != null && installmentCount > 1) {
                for (int i = 0; i < installmentCount; i++) {
                  final installmentDate = addMonthsSafe(baseDate, i);
                  if (addMonthsSafe(baseDate, i).isBefore(normalize(now))) {
                    paidInstallmentCount++;
                  }
                }
              }

              final perInstallmentAmount = (installmentCount != null && installmentCount > 1)
                  ? amount / installmentCount
                  : amount;

              if (installmentCount != null && paidInstallmentCount >= installmentCount) {
                paidInstallmentCount = installmentCount - 1;
              }

              final currentInstallmentIndex = (installmentCount != null && installmentCount > 1)
                  ? paidInstallmentCount
                  : 0;

              final newTx = Transaction(
                transactionId: existing?.transactionId ?? DateTime.now().millisecondsSinceEpoch,
                date: addMonthsSafe(baseDate, currentInstallmentIndex),
                amount: perInstallmentAmount,
                currency: selectedAccount?['currency'] ?? 'TRY',
                category: selectedCategory!,
                subcategory: selectedSubcategory!,
                title: installmentCount != null && installmentCount > 1
                    ? '${titleController.text} (${currentInstallmentIndex + 1}/$installmentCount)'
                    : titleController.text,
                description: '',
                isSurplus: false,
                isFromInvoice: false,
                installment: installmentCount,
                initialInstallmentDate: (installmentCount != null && installmentCount > 1) ? baseDate : null,
                isProvisioned: isProvisioned,
              );

              setState(() {
                for (var bank in bankAccounts) {
                  if (bank['bankId'] != selectedAccount!['bankId']) continue;
                  final accounts = bank['accounts'] as List?;
                  if (accounts == null) continue;

                  for (var account in accounts) {
                    if (account['accountId'] != selectedAccount!['accountId']) continue;

                    account['transactions'] = account['transactions'] ?? [];
                    Account accountInstance = Account.fromJson(account);

                    if (isEditing) {
                      final index = (account['transactions'] as List)
                          .indexWhere((tx) => tx.transactionId == existing!.transactionId);
                      if (index != -1) {
                        final oldTx = account['transactions'][index] as Transaction;
                        account['balance'] = (account['balance'] ?? 0.0) - oldTx.amount + amount;
                        account['transactions'][index] = newTx;
                      }
                    } else {
                      account['transactions'].add(newTx);

                      final totalAmountToAdd = newTx.amount + transactions.fold(0.0, (sum, tx) => sum + tx.amount);
                      account['balance'] = (account['balance'] ?? 0.0) + totalAmountToAdd;
                    }

                    if (account['isDebit'] == false) {
                      final currentTransactionDate = newTx.date;
                      double transactionAmount = newTx.amount;

                      account['creditLimit'] = account['creditLimit'] ?? 0.0;
                      account['availableCredit'] = (account['availableCredit'] ?? 0.0) - transactionAmount;

                      if (isProvisioned) {
                        account['currentDebt'] = (account['currentDebt'] ?? 0.0);
                      } else {
                        account['currentDebt'] = (account['currentDebt'] ?? 0.0) + transactionAmount;
                      }

                      account['totalDebt'] = (account['totalDebt'] ?? 0.0) + transactionAmount;

                      DateTime parseDate(String dateStr) {
                        try {
                          return DateFormat('dd/MM/yyyy').parse(dateStr);
                        } catch (_) {
                          return DateTime.now();
                        }
                      }

                      final nextCutoff = parseDate(account['nextCutoffDate'] ?? DateTime.now().toString());

                      if (!currentTransactionDate.isBefore(nextCutoff)) {
                        account['previousDebt'] = account['remainingDebt'] ?? 0.0;
                      }

                      accountInstance = Account.fromJson(account);
                      account['minPayment'] = accountInstance.calculateMinPayment();
                      account['remainingMinPayment'] = account['minPayment'];
                    }

                    selectedAccount = {
                      'accountId': account['accountId'],
                      'accountName': account['accountName'],
                      'balance': account['balance'],
                      'currency': account['currency'],
                      'transactions': account['transactions'],
                      'isDebit': account['isDebit'],
                      'creditLimit': account['creditLimit'],
                      'cutoffDate': account['cutoffDate'],
                      'availableCredit': account['availableCredit'],
                      'currentDebt': account['currentDebt'],
                      'totalDebt': account['totalDebt'],
                      'previousDebt': account['previousDebt'],
                      'remainingDebt': account['remainingDebt'],
                      'minPayment': account['minPayment'],
                      'remainingMinPayment': account['remainingMinPayment'],
                      'nextCutoffDate': account['nextCutoffDate'],
                      'bankId': bank['bankId'],
                      'bankName': bank['bankName'],
                      'bankCurrency': bank['currency'],
                    };

                    break;
                  }
                }
              });

              await _saveToPrefs();
              await _saveSelectedAccount(selectedAccount!);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          )
        ],
      ),
    );

  }

  Map<String, Map<String, List<Transaction>>> transactionsGrouped() {
    Map<String, Map<String, List<Transaction>>> grouped = {};

    List<dynamic>? transactionsJson = selectedAccount?['transactions'];
    if (transactionsJson == null) return grouped;

    for (var t in transactionsJson) {
      late Transaction tx;

      if (t is Map) {
        tx = Transaction.fromJson(Map<String, dynamic>.from(t));
      } else if (t is Transaction) {
        tx = t;
      } else {
        continue; // Geçersiz tür
      }

      if (tx.isSurplus) continue; // Gelir ise dahil etme, sadece giderleri göster

      String category = tx.category.isNotEmpty ? tx.category : 'Diğer';
      String subcategory = tx.subcategory.isNotEmpty ? tx.subcategory : 'Diğer';

      grouped.putIfAbsent(category, () => {});
      grouped[category]!.putIfAbsent(subcategory, () => []);
      grouped[category]![subcategory]!.add(tx);
    }

    return grouped;
  }

  void _deleteTransaction(Transaction tx) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. selectedAccount güncelle
    List<Map<String, dynamic>> transactions = List<Map<String, dynamic>>.from(selectedAccount!['transactions']);
    transactions.removeWhere((t) => t['transactionId'] == tx.transactionId);
    selectedAccount!['transactions'] = transactions;

    // Eğer kredi kartı hesabıysa, borç ve limit değerlerini de güncelle
    if (selectedAccount!['isDebit'] == false) {
      final double txAmount = tx.amount;

      selectedAccount!['currentDebt'] = (selectedAccount!['currentDebt'] ?? 0.0) - txAmount;
      selectedAccount!['totalDebt'] = (selectedAccount!['totalDebt'] ?? 0.0) - txAmount;
      selectedAccount!['availableCredit'] = (selectedAccount!['availableCredit'] ?? 0.0) + txAmount;

      DateTime parseDate(String dateStr) {
        try {
          final dateFormat = DateFormat('dd/MM/yyyy');
          return dateFormat.parse(dateStr);
        } catch (e) {
          return DateTime.now(); // Fallback in case of invalid date format
        }
      }

      final txDate = tx.date;
      final nextCutoff = parseDate(selectedAccount!['nextCutoffDate'] ?? DateTime.now().toString());

      if (txDate.isBefore(nextCutoff)) {
        if(tx.isProvisioned){
          selectedAccount!['remainingDebt'] = (selectedAccount!['remainingDebt'] ?? 0.0);
        } else {
          selectedAccount!['remainingDebt'] = (selectedAccount!['remainingDebt'] ?? 0.0) - txAmount;
        }
      } else {
        selectedAccount!['previousDebt'] = (selectedAccount!['previousDebt'] ?? 0.0) - txAmount;
      }

      // Min ödeme tekrar hesapla
      Account accountInstance = Account.fromJson(selectedAccount!);
      selectedAccount!['minPayment'] = accountInstance.calculateMinPayment();
      selectedAccount!['remainingMinPayment'] = selectedAccount!['minPayment'];
    }

    // 2. bankAccounts içinde bu hesabı bul ve güncelle
    for (var bank in bankAccounts) {
      if (bank['bankId'] == selectedAccount!['bankId']) {
        List accounts = List.from(bank['accounts']);
        for (int i = 0; i < accounts.length; i++) {
          if (accounts[i]['accountId'] == selectedAccount!['accountId']) {
            accounts[i] = selectedAccount!;
            break;
          }
        }
        bank['accounts'] = accounts;
        break;
      }
    }

    // 3. SharedPreferences’a yaz
    await prefs.setString('accountDataList', jsonEncode(bankAccounts));

    // Arayüzü yenile
    setState(() {
      transactionsGrouped(); // Eğer grouped yapısını tekrar oluşturuyorsan burada çağırabilirsin
    });
  }

  Widget buildCategoryProgressBars() {
    final grouped = transactionsGrouped();

    double totalAmount = 0;
    for (var cat in grouped.values) {
      for (var subList in cat.values) {
        totalAmount += subList.fold(0, (sum, tx) => sum + tx.amount);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((catEntry) {
        final categoryName = catEntry.key;

        double categoryTotal = 0;
        for (var subList in catEntry.value.values) {
          categoryTotal += subList.fold(0, (sum, tx) => sum + tx.amount);
        }

        final double percent = totalAmount > 0 ? (categoryTotal / totalAmount) : 0.0;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$categoryName • ${categoryTotal.toStringAsFixed(2)} ₺ (${(percent * 100).toStringAsFixed(1)}%)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: percent.clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                ),
                const SizedBox(height: 12),
                ...catEntry.value.entries.map((subEntry) {
                  final subcategoryName = subEntry.key;
                  final subTotal = subEntry.value.fold<double>(0.0, (sum, tx) => sum + tx.amount);
                  final subPercent = categoryTotal > 0 ? subTotal / categoryTotal : 0;

                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$subcategoryName • ${subTotal.toStringAsFixed(2)} ₺ (${(subPercent * 100).toStringAsFixed(1)}%)',
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: subPercent.clamp(0.0, 1.0).toDouble(),
                            minHeight: 8,
                            backgroundColor: Colors.grey[100],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildGroupedTransactionList() {
    final grouped = transactionsGrouped();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: grouped.length,
      itemBuilder: (context, catIndex) {
        final catEntry = grouped.entries.elementAt(catIndex);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  catEntry.key,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                children: catEntry.value.entries.map((subEntry) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(
                          subEntry.key,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        children: subEntry.value.map((tx) {
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            tileColor: Colors.grey[50],
                            title: Text(tx.title, style: const TextStyle(fontSize: 14)),
                            subtitle: Text('${tx.amount.toStringAsFixed(2)} ${tx.currency}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.grey),
                                  onPressed: () => _addOrUpdateTransaction(tx),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _deleteTransaction(tx),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    for (Invoice invoice in invoices) {
      print('Before ID: ${invoice.id}, Subcategory: ${invoice.subCategory}');
    }

    final grouped = transactionsGrouped();

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: userCategories.map((categoryData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'Kategori: ${categoryData.category}, Alt Kategori: ${categoryData.subcategory}',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
              ),
              Text(
                "Giderler Detayı",
                style: TextStyle(
                  fontFamily: 'Keep Calm',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
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
              buildCategoryProgressBars(),
              buildGroupedTransactionList()
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateTransaction(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Map<String, dynamic>? _findAccountById(int? accountId) {
    if (accountId == null) {
      throw ArgumentError('accountId cannot be null');
    }

    for (var bank in bankAccounts) {
      for (var account in bank['accounts'] ?? []) {
        if (account['accountId'] == accountId) {
          // Return a flattened structure with account + bank info
          return {
            ...account, // Spread all account fields
            'bankId': bank['bankId'],
            'bankName': bank['bankName'],
          };
        }
      }
    }
    return null;
  }



}