import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

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

  Future<Transaction?> _showTransactionDialog([Transaction? existing]) async {
    bool isInstallment = false;
    bool isProvisioned = existing?.isProvisioned ?? false;
    String? selectedCategory = existing?.category ?? (userCategories.isNotEmpty ? userCategories.first.category : null);
    String? selectedSubcategory = existing?.subcategory ??
        (selectedCategory != null
            ? userCategories.firstWhere((e) => e.category == selectedCategory, orElse: () => userCategories.first).subcategory
            : null);
    final titleController = TextEditingController(text: existing?.title ?? '');
    final amountController = TextEditingController(text: existing?.amount.toString() ?? '');
    final TextEditingController installmentController = TextEditingController();
    DateTime? _installmentStartDate;
    DateTime? _selectedDate = existing?.date;

    final formKey = GlobalKey<FormState>();

    DateTime addMonthsSafe(DateTime date, int monthsToAdd) {
      final newYear = date.year + ((date.month + monthsToAdd - 1) ~/ 12);
      final newMonth = (date.month + monthsToAdd - 1) % 12 + 1;
      final newDay = math.min(date.day, DateTime(newYear, newMonth + 1, 0).day);
      return DateTime(newYear, newMonth, newDay);
    }

    return showDialog<Transaction>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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

            return AlertDialog(
              title: Text(existing == null ? "Add Transaction" : "Edit Transaction"),
              content: SingleChildScrollView(
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
                            // Yeni kategoriye göre ilk alt kategoriyi seç
                            final subList = userCategories.where((e) => e.category == val).toList();
                            selectedSubcategory = subList.isNotEmpty ? subList.first.subcategory : null;
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
                      CheckboxListTile(
                        title: const Text("Provisioned Transaction?"),
                        value: isProvisioned,
                        onChanged: (val) => setDialogState(() => isProvisioned = val ?? false),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        title: const Text("Is Installment?"),
                        value: isInstallment,
                        onChanged: (val) => setDialogState(() => isInstallment = val ?? false),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (isInstallment) ...[
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
                      ],
                      const SizedBox(height: 8),
                      if (!isInstallment) ...[
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

                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    final amount = double.parse(amountController.text);
                    final int? installmentCount = isInstallment ? int.tryParse(installmentController.text) : null;
                    final DateTime baseDate = isInstallment ? (_installmentStartDate ?? DateTime.now()) : (_selectedDate ?? DateTime.now());

                    int paidInstallmentCount = 0;
                    final now = DateTime.now();

                    if (installmentCount != null && installmentCount > 1) {
                      for (int i = 0; i < installmentCount; i++) {
                        final installmentDate = addMonthsSafe(baseDate, i);
                        if (installmentDate.isBefore(now)) {
                          paidInstallmentCount++;
                        }
                      }

                      // >>> Yeni cutoff mantığı
                      if (selectedAccount?['previousCutoffDate'] != null && selectedAccount?['nextCutoffDate'] != null) {
                        final dateFormat = DateFormat("dd/MM/yyyy");
                        final previousCutoff = dateFormat.parse(selectedAccount!['previousCutoffDate']);
                        final nextCutoff = dateFormat.parse(selectedAccount!['nextCutoffDate']);

                        // Eğer "normal sayım" 3 taksit bulduysa ama cutoff dönemi 4. taksiti içeriyorsa
                        if (now.isAfter(previousCutoff) && now.isBefore(nextCutoff)) {
                          // Bir sonraki taksitin tarihi cutoff öncesinde mi?
                          final nextInstallmentDate = addMonthsSafe(baseDate, paidInstallmentCount);
                          if (nextInstallmentDate.isBefore(nextCutoff)) {
                            paidInstallmentCount++;
                          }
                        }
                      }

                      // Güvenlik: sınırı aşmasın
                      if (paidInstallmentCount >= installmentCount) {
                        paidInstallmentCount = installmentCount - 1;
                      }
                    }

                    final perInstallmentAmount = (installmentCount != null && installmentCount > 1)
                        ? amount / installmentCount
                        : amount;

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
                          ? '${titleController.text} ($currentInstallmentIndex/$installmentCount)'
                          : titleController.text,
                      description: '',
                      isSurplus: false,
                      isFromInvoice: false,
                      installment: installmentCount,
                      initialInstallmentDate: (installmentCount != null && installmentCount > 1) ? baseDate : null,
                      isProvisioned: isProvisioned,
                    );

                    Navigator.pop(context, newTx);
                  },
                  child: Text(existing == null ? 'Add' : 'Update'),
                )

              ],
            );
          },
        );
      },
    );
  }

  Future<void> _processTransactionUpdate(Transaction newTx, [Transaction? existing]) async {
    final isEditing = existing != null;

    setState(() {
      for (var bank in bankAccounts) {
        if (bank['bankId'] != selectedAccount!['bankId']) continue;
        final accounts = bank['accounts'] as List?;
        if (accounts == null) continue;

        for (var account in accounts) {
          if (account['accountId'] != selectedAccount!['accountId']) continue;

          account['transactions'] = account['transactions'] ?? [];
          Account accountInstance = Account.fromJson(account);
          bool isCredit = account['isDebit'] == false;

          if (isEditing) {
            final txList = account['transactions'] as List;
            final index = txList.indexWhere(
                  (tx) => Transaction.fromJson(tx).transactionId == existing!.transactionId,
            );

            if (index != -1) {
              final oldTx = Transaction.fromJson(txList[index]);

              print('--- DEBUG _processTransactionUpdate (EDIT) ---');
              print('Old Transaction Amount: ${oldTx.amount}');
              print('New Transaction Amount: ${newTx.amount}');
              print('Account Balance BEFORE update: ${account['balance']}');
              print('Account Available Credit BEFORE update: ${account['availableCredit']}');

              account['balance'] = (account['balance'] ?? 0.0) - oldTx.amount + newTx.amount;

              if (isCredit) {
                account['availableCredit'] = (account['availableCredit'] ?? account['creditLimit']) + oldTx.amount;
                account['availableCredit'] = (account['availableCredit'] ?? account['creditLimit']) - newTx.amount;

                if (!oldTx.isProvisioned) {
                  account['currentDebt'] = (account['currentDebt'] ?? 0.0) - oldTx.amount;
                }
                if (!newTx.isProvisioned) {
                  account['currentDebt'] = (account['currentDebt'] ?? 0.0) + newTx.amount;
                }

                account['totalDebt'] = (account['totalDebt'] ?? 0.0) - oldTx.amount + newTx.amount;

                DateTime parseDate(String dateStr) {
                  try {
                    return DateFormat('dd/MM/yyyy').parse(dateStr);
                  } catch (_) {
                    return DateTime.now();
                  }
                }

                final nextCutoff = parseDate(account['nextCutoffDate'] ?? DateTime.now().toString());

                if (!oldTx.date.isBefore(nextCutoff)) {
                  account['previousDebt'] = (account['previousDebt'] ?? 0.0) - oldTx.amount;
                } else {
                  if (!oldTx.isProvisioned) {
                    account['remainingDebt'] = (account['remainingDebt'] ?? 0.0) - oldTx.amount;
                  }
                }

                if (!newTx.date.isBefore(nextCutoff)) {
                  account['previousDebt'] = (account['previousDebt'] ?? 0.0) + newTx.amount;
                } else {
                  if (!newTx.isProvisioned) {
                    account['remainingDebt'] = (account['remainingDebt'] ?? 0.0) + newTx.amount;
                  }
                }

                accountInstance = Account.fromJson(account);
                account['minPayment'] = accountInstance.minPayment;
                account['remainingMinPayment'] = account['minPayment'];
              }

              txList[index] = newTx.toJson();

              print('Account Balance AFTER update: ${account['balance']}');
              print('Account Available Credit AFTER update: ${account['availableCredit']}');
              print('----------------------------------------------');
            }
          } else {
            account['transactions'].add(newTx.toJson());
            account['balance'] = (account['balance'] ?? 0.0) + newTx.amount;

            if (isCredit) {
              account['availableCredit'] = (account['availableCredit'] ?? account['creditLimit']) - newTx.amount;

              if (!newTx.isProvisioned) {
                account['currentDebt'] = (account['currentDebt'] ?? 0.0) + newTx.amount;
              }

              account['totalDebt'] = (account['totalDebt'] ?? 0.0) + newTx.amount;

              DateTime parseDate(String dateStr) {
                try {
                  return DateFormat('dd/MM/yyyy').parse(dateStr);
                } catch (_) {
                  return DateTime.now();
                }
              }

              final nextCutoff = parseDate(account['nextCutoffDate'] ?? DateTime.now().toString());

              if (!newTx.date.isBefore(nextCutoff)) {
                account['previousDebt'] = (account['previousDebt'] ?? 0.0) + newTx.amount;
              } else {
                if (!newTx.isProvisioned) {
                  account['remainingDebt'] = (account['remainingDebt'] ?? 0.0) + newTx.amount;
                }
              }

              accountInstance = Account.fromJson(account);
              account['minPayment'] = accountInstance.minPayment;
              account['remainingMinPayment'] = account['minPayment'];
            }
          }
        }
      }
    });

    await _saveToPrefs();
    await _saveSelectedAccount(selectedAccount!);
  }

  void _addOrUpdateTransaction([Transaction? existing]) async {
    final newTx = await _showTransactionDialog(existing);
    if (newTx == null) return;

    _processTransactionUpdate(newTx, existing);
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
    selectedAccount!['balance'] = (selectedAccount!['balance'] ?? 0.0) - tx.amount;


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

  Widget buildCategoryProgressBars(Map<String, Map<String, List<Transaction>>> grouped, double totalAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((catEntry) {
        final categoryName = catEntry.key;
        double categoryTotal = 0;
        for (var subList in catEntry.value.values) {
          categoryTotal += subList.fold(0, (sum, tx) => sum + tx.amount);
        }
        final percent = totalAmount > 0 ? categoryTotal / totalAmount : 0.0;

        return GlassmorphismContainer(
          borderRadius: 16,
          blur: 10,
          borderColor: Colors.white.withOpacity(0.2),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(categoryName,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                  Text("${categoryTotal.toStringAsFixed(2)} ₺",
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.amberAccent)),
                ],
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: LinearProgressIndicator(
                  value: percent.clamp(0.0, 1.0),
                  minHeight: 10.h,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildGroupedTransactionList(Map<String, Map<String, List<Transaction>>> grouped) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((catEntry) {
        return GlassmorphismContainer(
          borderRadius: 16,
          blur: 10,
          borderColor: Colors.white.withOpacity(0.2),
          padding: EdgeInsets.zero,
          child: ExpansionTile(
            title: Text(catEntry.key,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white)),
            children: catEntry.value.entries.map((subEntry) {
              return ExpansionTile(
                title: Text(subEntry.key, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.white70)),
                children: subEntry.value.map((tx) {
                  return ListTile(
                    title: Text(tx.title, style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(tx.date), style: TextStyle(fontSize: 12.sp, color: Colors.white70)),
                    trailing: Text("${tx.amount.toStringAsFixed(2)} ${tx.currency}", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.redAccent)),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = transactionsGrouped();
    final totalAmount = _calculateTotalAmount(grouped);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Giderler Detayı",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Selection
            if (bankAccounts.isNotEmpty)
              GlassmorphismContainer(
                borderRadius: 16,
                blur: 10,
                borderColor: Colors.white.withOpacity(0.2),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: DropdownButtonFormField<int>(
                  value: selectedAccount?['accountId'],
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: "Hesap Seçiniz",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  items: bankAccounts.expand<DropdownMenuItem<int>>((bank) {
                    return (bank['accounts'] as List?)?.map((account) {
                      return DropdownMenuItem<int>(
                        value: account['accountId'],
                        child: Text(
                          "${bank['bankName']} - ${account['name']}",
                          style: TextStyle(fontSize: 14.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }) ?? [];
                  }).toList(),
                  onChanged: (selectedAccountId) {
                    if (selectedAccountId != null) {
                      final account = _findAccountById(selectedAccountId);
                      if (account != null) {
                        setState(() => selectedAccount = account);
                        _saveSelectedAccount(account);
                      }
                    }
                  },
                ),
              ),
            SizedBox(height: 24.h),

            // Summary Card
            if (totalAmount > 0)
              GlassmorphismContainer(
                borderRadius: 16,
                blur: 10,
                borderColor: Colors.white.withOpacity(0.2),
                padding: EdgeInsets.all(16.h),
                color: isDark ? Colors.grey[900]!.withOpacity(0.4) : Colors.white.withOpacity(0.4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Toplam Gider",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "${totalAmount.toStringAsFixed(2)} ₺",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.pie_chart, color: Colors.amber, size: 32.r),
                  ],
                ),
              ),
            SizedBox(height: 24.h),



            // Category Progress Bars
            if (grouped.isNotEmpty)
              buildCategoryProgressBars(grouped, totalAmount),
            SizedBox(height: 24.h),

            // Transaction List
            if (grouped.isNotEmpty)
              buildGroupedTransactionList(grouped),

            // Empty State
            if (grouped.isEmpty)
              GlassmorphismContainer(
                borderRadius: 16,
                blur: 10,
                borderColor: Colors.white.withOpacity(0.2),
                color: isDark ? Colors.grey[900]!.withOpacity(0.4) : Colors.white.withOpacity(0.4),
                padding: EdgeInsets.symmetric(vertical: 48.h),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, size: 64.r, color: isDark ? Colors.white54 : Colors.black38),
                    SizedBox(height: 16.h),
                    Text(
                      "Henüz işlem bulunmuyor",
                      style: TextStyle(fontSize: 16.sp, color: isDark ? Colors.white54 : Colors.black38),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Yeni işlem eklemek için + butonuna tıklayın",
                      style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.white54 : Colors.black38),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateTransaction(),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
    );
  }


  double _calculateTotalAmount(Map<String, Map<String, List<Transaction>>> grouped) {
    double total = 0;
    for (var cat in grouped.values) {
      for (var subList in cat.values) {
        total += subList.fold(0, (sum, tx) => sum + tx.amount);
      }
    }
    return total;
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

  Widget buildCategoryWidget(Map<String, dynamic> category) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(category['icon'] ?? Icons.category, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category['name'] ?? 'Kategori',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            "${category['amount']?.toStringAsFixed(2) ?? '0.00'} ₺",
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

}

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final Color? color; // opsiyonel arkaplan rengi

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 10,
    required this.borderColor,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}