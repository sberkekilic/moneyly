import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';


import '../../blocs/income-selections.dart';
import '../../models/invoice-page.dart';
import '../../models/transaction-widget.dart';
import '../../models/transaction.dart';
import '../add-expense/faturalar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List<Invoice> invoices = [];
  Map<String, List<Map<String, dynamic>>> incomeMap = {};
  String selectedKey = "";
  List<String> sharedPreferencesData = [];
  List<String> desiredKeys = [
    'selected_option', 'income_value', 'sumOfTV2', 'sumOfGame2',
    'sumOfMusic2', 'sumOfHome2', 'sumOfInternet2', 'sumOfPhone2',
    'sumOfRent2', 'sumOfKitchen2', 'sumOfCatering2', 'sumOfEnt2',
    'sumOfOther2'
  ];
  List<String> actualDesiredKeys = [
    'selected_option', 'income_value', 'sumOfSubs2', 'sumOfBills2', 'sumOfOthers2'
  ];
  double incomeValue = 0.0;
  double savingsValue = 0.0;
  double wishesValue = 0.0;
  double needsValue = 0.0;
  String sumOfTV = "0.0";
  String sumOfGame = "0.0";
  String sumOfMusic = "0.0";
  String sumOfHome = "0.0";
  String sumOfInternet = "0.0";
  String sumOfPhone = "0.0";
  String sumOfRent = "0.0";
  String sumOfKitchen = "0.0";
  String sumOfCatering = "0.0";
  String sumOfEnt = "0.0";
  String sumOfOther = "0.0";
  String selectedTitle = '';

  int? _selectedBillingDay;
  int? _selectedBillingMonth;
  int? _selectedDueDay;
  String faturaDonemi = "";
  String? sonOdeme;

  List<Invoice> selectedInvoices = [];
  List<Transaction> transactions = [];

  List<Map<String, dynamic>> bankAccounts = [];
  Map<String, dynamic>? selectedAccount;
  bool isLoading = true; // Flag to indicate loading state
  bool isDebtVisible = false;
  bool showDebtDetails = false;

  List<Invoice> upcomingInvoices = [];
  List<Invoice> todayInvoices = [];
  List<Invoice> approachingDueInvoices = [];
  List<Invoice> paymentDueInvoices = [];
  List<Invoice> overdueInvoices = [];

  List<int> daysList = List.generate(31, (index) => index + 1);
  List<int> monthsList = List.generate(12, (index) => index + 1);

  DateTime? startDate;
  DateTime? endDate;

  List<int> getIdsWithSubcategory(List<Invoice> invoices, String subCategory) {
    return invoices
        .where((invoice) => invoice.subCategory == subCategory)
        .map((invoice) => invoice.id)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<List<Transaction>> _loadTransactionsFromAccountData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accountDataString = prefs.getString('selectedAccount');
    print("${accountDataString} is _loadTransactionsFromAccountData");

    if (accountDataString == null) {
      return [];  // Eğer 'selectedAccount' verisi yoksa boş liste döndürüyoruz.
    }

    final Map<String, dynamic> accountData = jsonDecode(accountDataString);
    final List<dynamic> transactionsJson = accountData['transactions'] ?? [];

    // JSON verisini Transaction modeline dönüştür
    return transactionsJson.map((json) => Transaction.fromJson(json)).toList();
  }

  void categorizeInvoices(List<Invoice> faturalar) {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);
    // 1. Upcoming Invoice Date (those with PeriodDate before today)
    upcomingInvoices = faturalar.where((invoice) {
      DateTime periodDate = DateTime.parse(invoice.periodDate);
      return periodDate.isAfter(today);
    }).toList();

    // 2. Invoice Day (with PeriodDate today)
    todayInvoices = faturalar.where((invoice) {
      DateTime periodDate = DateTime.parse(invoice.periodDate);
      return periodDate.day == today.day && periodDate.month == today.month && periodDate.year == today.year;
    }).toList();

    // 3. Approaching Due Date (those with DueDate data and this date is before today)
    approachingDueInvoices = faturalar.where((invoice) {
      if (invoice.dueDate!= null) {
        DateTime periodDate = DateTime.parse(invoice.periodDate);
        DateTime dueDate = DateTime.parse(invoice.dueDate!);
        return periodDate.isBefore(today) && today.isBefore(dueDate);
      }
      return false;
    }).toList();

    // 4. Payment Due Date (those with DueDate data and this date is today)
    paymentDueInvoices = faturalar.where((invoice) {
      if (invoice.dueDate!= null) {
        DateTime dueDate = DateTime.parse(invoice.dueDate!);
        return dueDate.day == today.day && dueDate.month == today.month && dueDate.year == today.year;
      }
      return false;
    }).toList();

    // 5. Overdue Invoices (Invoices with DueDate data that are overdue or invoices without DueDate data but with an overdue PeriodDate)
    overdueInvoices = faturalar.where((invoice) {
      if (invoice.dueDate != null) {
        DateTime periodDate = DateTime.parse(invoice.periodDate);
        DateTime dueDate = DateTime.parse(invoice.dueDate!);
        return dueDate.isBefore(today) && periodDate.isBefore(today);
      } else {
        return false;
      }
    }).toList();
  }
  void showDeleteConfirmation(Invoice invoice){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Are you sure?"),
            content: const Text("Do you really want to delete this invoice?"),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Delete"),
                onPressed: () {
                  setState(() {
                    invoices.removeWhere((item) => item.id == invoice.id);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
    );
  }
  Future<void> loadSharedPreferencesData(List<String> desiredKeys) async {
    final prefs = await SharedPreferences.getInstance();
    sharedPreferencesData = [];
    bool allKeysHaveValues = true; // Assume all keys have values initially

    for (var key in desiredKeys) {
      final value = prefs.get(key);
      if (value != null) {
        sharedPreferencesData.add('$key: $value');
      } else {
        allKeysHaveValues = false; // If any key is empty, set the flag to false
      }
    }

    setState(() {
    }); // Trigger a rebuild of the widget to display the data

    if (allKeysHaveValues) {
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
    final ab2 = prefs.getString('incomeMap') ?? "0";
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
    final ab14 = prefs.getString('startDate');
    final ab15 = prefs.getString('endDate');
    final savedInvoicesJson = prefs.getStringList('invoices');
    String? accountDataListJson = prefs.getString('accountDataList'); //TÜM HESAP
    String? accountData = prefs.getString('selectedAccount');

    // Load data from SharedPreferences asynchronously
    selectedTitle = labelForOption(SelectedOption.values[ab1]);
    sumOfTV = ab3.toString();
    sumOfGame = ab4.toString();
    sumOfMusic = ab5.toString();
    sumOfHome = ab6.toString();
    sumOfInternet = ab7.toString();
    sumOfPhone = ab8.toString();
    sumOfRent = ab9.toString();
    sumOfKitchen = ab10.toString();
    sumOfCatering = ab11.toString();
    sumOfEnt = ab12.toString();
    sumOfOther = ab13.toString();

    if (ab14 != null && ab15 != null) {
      startDate = DateTime.parse(ab14);
      endDate = DateTime.parse(ab15);
    }

    // Async block for decoding and setting incomeMap
    if (ab2.isNotEmpty) {
      final decodedData = json.decode(ab2);
      if (decodedData is Map<String, dynamic>) {
        incomeMap = {};
        decodedData.forEach((key, value) {
          if (value is List<dynamic>) {
            incomeMap[key] = List<Map<String, dynamic>>.from(value.map((e) => Map<String, dynamic>.from(e)));
          }
          if (incomeMap.containsKey(key) && incomeMap[key]!.isNotEmpty) {
            // Get the first amount from the list
            String? valueToParse;

            final currentKey = selectedKey.isNotEmpty ? selectedKey : key;
            final entryList = incomeMap[currentKey];

            if (entryList != null && entryList.isNotEmpty) {
              final amount = entryList[0]["amount"];
              if (amount != null) {
                valueToParse = amount;
              } else {
                print("amount is null for key: $currentKey");
              }
            } else {
              print("No entries found for key: $currentKey");
            }

            selectedKey = key;
            try {
              final parsed = NumberFormat.decimalPattern('tr_TR').parse(valueToParse!);
              incomeValue = parsed.toDouble();
            } catch (e) {
              print("Parsing error: $e, value: $valueToParse");
              incomeValue = 0.0; // ya da null yapacaksan double? incomeValue kullan
            }
            double sum = 0.0;
            for (var values in incomeMap.values) {
              for (var value in values) {
                String amount = value["amount"];
                if (amount.isNotEmpty) {
                  double parsedValue = NumberFormat.decimalPattern('tr_TR').parse(amount).toDouble();
                  sum += parsedValue;
                }
              }
            }
            incomeValue = sum;
          } else {
            incomeValue = 0.0; // Default value if not found
          }
        });
      }
    }

    // Handle saved invoices
    if (savedInvoicesJson != null) {
      List<Invoice> tempInvoices = savedInvoicesJson.map((json) => Invoice.fromJson(jsonDecode(json))).toList();
      for (var invoice in tempInvoices) {
        if (invoice.dueDate != null) {
          invoice.updateDifference(invoice, invoice.periodDate, invoice.dueDate);
        } else {
          invoice.updateDifference(invoice, invoice.periodDate, null);
        }
      }
      tempInvoices.sort((a, b) => int.parse(a.difference).compareTo(int.parse(b.difference)));
      final invoiceJsonList = tempInvoices.map((invoice) => jsonEncode(invoice.toJson())).toList();
      await prefs.setStringList('invoices', invoiceJsonList);

      categorizeInvoices(tempInvoices);
      transactions.clear();
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
    debugPrint('Selected account1: $selectedAccount', wrapWidth: 1024);

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

    if (startDate != null && endDate != null) {
      // Load transactions from SharedPreferences instead of generating
      List<Transaction> loadedTransactions = await _loadTransactionsFromAccountData();
      print("Loaded Transactions: $loadedTransactions");

      // Assign the loaded transactions to transactions
      transactions = loadedTransactions;

      transactions = transactions.where((transaction) {
        print("COXK: $startDate and $endDate");
        final date = DateTime(transaction.date.year, transaction.date.month, transaction.date.day); //Saat detayını çıkar
        return (date.isAfter(startDate!) || date.isAtSameMomentAs(startDate!)) &&
            (date.isBefore(endDate!) || date.isAtSameMomentAs(endDate!));
      }).toList();
    }

    transactions.sort((a, b) => a.date.compareTo(b.date));
    final jsonData = jsonEncode(transactions.map((t) => t.toJson()).toList());
    prefs.setString('transactions', jsonData);

    loadSharedPreferencesData(actualDesiredKeys);
  }

  // Save the selected account in SharedPreferences
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

  Map<String, dynamic>? _loadSelectedAccount(String? accountData) {
    if (accountData == null) return null;

    final savedAccount = jsonDecode(accountData);
    // Find the matching account in your bankAccounts
    for (var bank in bankAccounts) {
      for (var account in bank['accounts'] ?? []) {
        if (account['accountId'] == savedAccount['accountId']) {
          return {
            'bankId': bank['bankId'],
            'bankName': bank['bankName'],
            'currency': bank['currency'],
            'isDebit': bank['isDebit'],
            'creditLimit': bank['creditLimit'],
            'cutoffDate': bank['cutoffDate'],
            ...account,
          };
        }
      }
    }
    return null;
  }

  List<Transaction> getTransactionsForSelectedAccount() {
    if (selectedAccount == null) {
      print('[DEBUG] No account selected');
      return [];
    }

    print('[DEBUG] Looking for account ${selectedAccount!['accountId']} in bank ${selectedAccount!['bankId']}');

    // Find the account in bankAccounts
    for (var bank in bankAccounts) {
      print('[DEBUG] Checking bank ${bank['bankId']}');

      if (bank['bankId'] == selectedAccount!['bankId']) {
        final accounts = bank['accounts'] as List?;
        if (accounts == null) {
          print('[DEBUG] No accounts found in bank');
          continue;
        }

        print('[DEBUG] Found ${accounts.length} accounts in bank');

        for (var account in accounts) {
          print('[DEBUG] Checking account ${account['accountId']}');

          if (account['accountId'] == selectedAccount!['accountId']) {
            final transactions = account['transactions'] as List?;
            if (transactions == null) {
              print('[DEBUG] No transactions found in account');
              return [];
            }

            print('[DEBUG] Found ${transactions.length} transactions in account');

            final transactionList = transactions.map((t) {
              try {
                final transaction = Transaction.fromJson(t);
                print('[DEBUG] Transaction ${transaction.transactionId}: '
                    'Date: ${transaction.date}, '
                    'Amount: ${transaction.amount}, '
                    'Title: ${transaction.title}');
                return transaction;
              } catch (e) {
                print('[ERROR] Failed to parse transaction: $e\nRaw data: $t');
                return null;
              }
            }).where((t) => t != null).cast<Transaction>().toList();

            print('[DEBUG] Successfully parsed ${transactionList.length} transactions');
            return transactionList;
          }
        }
      }
    }

    print('[DEBUG] Account not found in bankAccounts');
    return [];
  }

  // Reset the selected account in SharedPreferences
  void _resetSelectedAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedAccount'); // Remove the selected account data
    setState(() {
      selectedAccount = null; // Reset the selected account in the app
    });
    _load(); //REFRESH PAGE
  }
  Future<void> saveInvoices() async {
    final invoicesCopy = invoices.toList();
    final prefs = await SharedPreferences.getInstance();
    final invoiceList = invoicesCopy.map((invoice) => invoice.toJson()).toList();
    await prefs.setStringList('invoices', invoiceList.map((invoice) => jsonEncode(invoice)).toList());
  }
  List<Transaction> mergeInvoicesToTransactions(List<Invoice> invoices, List<Transaction> transactions) {
    for (Invoice invoice in invoices) {
      transactions.add(Transaction(
          transactionId: invoice.id,
          amount: double.parse(invoice.price),
          description: invoice.subCategory,
          currency: 'TRY',
          subcategory: invoice.subCategory,
          category: invoice.category,
          title: invoice.name,
          date: (invoice.dueDate != null && invoice.dueDate!.isNotEmpty)
              ? DateTime.parse(invoice.dueDate!)
              : (invoice.periodDate.isNotEmpty)
              ? DateTime.parse(invoice.periodDate)
              : DateTime.now(), // Fallback to current date if both are null or empty.
          isSurplus: false,
          isFromInvoice: true,
          initialInstallmentDate: null,
          installment: null,
          isProvisioned: false
      ));
    }
    return transactions;
  }
  bool isLeapYear(int year) {
    if (year % 4 != 0) return false;
    if (year % 100 != 0) return true;
    return year % 400 == 0;
  }
  String? calculateNewDiff(String? dueDate, String periodDate){
    final diff;
    final currentDate = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    final dueDateKnown = dueDate != null;
    if (currentDate.isBefore(DateTime.parse(periodDate))) {
      diff = (DateTime.parse(periodDate).difference(currentDate).inDays + 1).toString();
      return diff;
    } else if (formattedDate == periodDate) {
      diff = "0";
      return diff;
    } else if (dueDateKnown) {
      if (currentDate.isAfter(DateTime.parse(periodDate))) {
        diff = (DateTime.parse(dueDate).difference(currentDate).inDays + 1).toString();
        return diff;
      } else {
        return "error1";
      }
    } else {
      return "error2";
    }
  }
  String getDaysRemainingMessage(Invoice invoice) {
    final currentDate = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    final dueDateKnown = invoice.dueDate != null;
    if (currentDate.isBefore(DateTime.parse(invoice.periodDate))) {
      invoice.difference = (DateTime.parse(invoice.periodDate).difference(currentDate).inDays + 1).toString();
      return invoice.difference;
    } else if (formattedDate == invoice.periodDate) {
      invoice.difference = "0";
      return invoice.difference;
    } else if (dueDateKnown) {
      if (invoice.dueDate != null && currentDate.isAfter(DateTime.parse(invoice.periodDate))) {
        invoice.difference = (DateTime.parse(invoice.dueDate!).difference(currentDate).inDays + 1).toString();
        return invoice.difference;
      } else {
        return "error1";
      }
    } else {
      return "error2";
    }
  }
  String formatPeriodDate(int day, int month, int year) {
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

    // Parse the periodDay string to DateTime
    DateTime parsedPeriodDay = DateTime.parse(periodDay);
    int month = parsedPeriodDay.month;
    int year = parsedPeriodDay.year;

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
  void editInvoice(int id, String periodDate, String? dueDate) {
    int index = invoices.indexWhere((invoice) => invoice.id == id);
    if (index != -1) {
      setState(() {
        final invoice = invoices[index];
        invoice.periodDate = periodDate;
        String diff = getDaysRemainingMessage(invoice);
        print("BTK2:$diff");
        final updatedInvoice = Invoice(
            id: invoice.id,
            price: invoice.price,
            subCategory: invoice.subCategory,
            category: invoice.category,
            name: invoice.name,
            periodDate: invoice.periodDate,
            dueDate: dueDate,
            difference: diff
        );
        invoices[index] = updatedInvoice;
        saveInvoices();
      });
    }
  }
  void showEditInvoice(int id, String periodDate, String? dueDate) {
    Invoice invoice = invoices.firstWhere((invoice) => invoice.id == id);
    TextEditingController selectedEditController = TextEditingController(text: invoice.name);
    TextEditingController selectedPriceController = TextEditingController(text: invoice.price);
    _selectedBillingMonth = invoice.getPeriodMonth();
    _selectedBillingDay = invoice.getPeriodDay();
    _selectedDueDay = invoice.getDueDay();
    invoice.periodDate = formatPeriodDate(_selectedBillingDay ?? 0, _selectedBillingMonth ?? 0, invoice.getPeriodYear());
    if (_selectedDueDay != null) {
      invoice.dueDate = formatDueDate(_selectedDueDay, invoice.periodDate);
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Edit ${invoice.category}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Item Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Item", style: GoogleFonts.montserrat(fontSize: 18)),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: selectedEditController,
                    decoration: InputDecoration(
                      hintText: "e.g., Subscription",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(width: 2, color: Colors.black),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: GoogleFonts.montserrat(fontSize: 18),
                  ),
                  const SizedBox(height: 15),

                  // Price Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Price", style: GoogleFonts.montserrat(fontSize: 18)),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: selectedPriceController,
                    decoration: InputDecoration(
                      hintText: "e.g., 10.00",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(width: 2, color: Colors.black),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: GoogleFonts.montserrat(fontSize: 18),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 15),

                  // Period Date Fields
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Period Date", style: GoogleFonts.montserrat(fontSize: 18)),
                  ),
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
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(width: 2, color: Colors.black),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(width: 2, color: Colors.black),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Due Date Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Due Date", style: GoogleFonts.montserrat(fontSize: 18)),
                  ),
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(width: 2, color: Colors.black),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.cancel),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        final priceText = selectedPriceController.text.trim();
                        double dprice = double.tryParse(priceText) ?? 0.0;
                        String price = dprice.toStringAsFixed(2);
                        String name = selectedEditController.text;
                        invoice.name = name;
                        invoice.price = price;
                        if (_selectedDueDay != null) {
                          editInvoice(
                            id,
                            formatPeriodDate(
                                _selectedBillingDay!, _selectedBillingMonth!, invoice.getPeriodYear()),
                            formatDueDate(_selectedDueDay,
                                formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!, invoice.getPeriodYear())),
                          );
                        } else {
                          editInvoice(
                            id,
                            formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!, invoice.getPeriodYear()),
                            null,
                          );
                        }
                        _load();
                        Navigator.of(context).pop();
                      });
                    },
                    icon: const Icon(Icons.save),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        List<int> quantityOfCategory = getIdsWithSubcategory(invoices, invoice.subCategory);
                        if (quantityOfCategory.length != 1) {
                          removeInvoice(id);
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
                    icon: const Icon(Icons.delete_forever),
                  ),
                ],
              ),
            ],
          );

        },
    );
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
  void payInvoice(Invoice invoice, int id, String periodDate, String? dueDate) async {
    int index = invoices.indexWhere((invoice) => invoice.id == id);
    bool confirmDelete = false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Disclaimer"),
          content: Text("Are you sure you paid your invoice?\nID : ${invoice.id}\nInvoice name : ${invoice.name}\nInvoice amount : ${invoice.price}"),
          actions: <Widget>[
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                setState(() {
                  confirmDelete = true;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      setState(() {
        DateTime incrementMonth(DateTime date) {
          // Calculate the next month
          int nextMonth = date.month + 1;
          int nextYear = date.year;

          // Check if we need to increment the year
          if (nextMonth > 12) {
            nextMonth = 1;
            nextYear++;
          }

          // Find the last day of the next month
          int lastDayOfNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;

          // Adjust the day if the original date is the last day of the month
          int adjustedDay = date.day > lastDayOfNextMonth ? lastDayOfNextMonth : date.day;

          // Use the adjusted day of the next month
          return DateTime(nextYear, nextMonth, adjustedDay);
        }
        DateTime originalPeriodDate = DateTime.parse(invoice.periodDate);
        DateTime newPeriodDate = incrementMonth(originalPeriodDate);
        String stringPeriodDate = DateFormat('yyyy-MM-dd').format(newPeriodDate);
        String? stringDueDate;
        if (invoice.dueDate != null){
          DateTime originalDueDate = DateTime.parse(invoice.dueDate!);
          DateTime newDueDate = incrementMonth(originalDueDate);
          stringDueDate = DateFormat('yyyy-MM-dd').format(newDueDate);
        }
        String? diff = calculateNewDiff(stringDueDate, stringPeriodDate);
        print("The delete has been confirmed. Current diff is : $diff while period date is now : $stringPeriodDate");
        final updatedInvoice = Invoice(
            id: invoice.id,
            price: invoice.price,
            subCategory: invoice.subCategory,
            category: invoice.category,
            name: invoice.name,
            periodDate: stringPeriodDate,
            dueDate: stringDueDate,
            difference: diff!
        );
        invoices[index] = updatedInvoice;
        saveInvoices();
        saveInvoicesToSharedPreferences();
        _load(); //Update the invoice immediately
      });
    }
  }
  void saveInvoicesToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final invoicesJson = invoices.map((invoice) => jsonEncode(invoice.toJson())).toList();
    prefs.setStringList('invoices', invoicesJson);
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
  double calculateCategorySum(List<Invoice> invoices, String category) {
    double sum = 0.0;

    for (var invoice in invoices) {
      if (invoice.category == category) {
        double price = double.parse(invoice.price);
        sum += price;
      }
    }

    return sum;
  }
  double sumAmountForCategory(List<Transaction> transactions, String category) {
    double sum = 0;

    for (var transaction in transactions) {
      if (transaction.category == category) {
        sum += transaction.amount;
      }
    }

    return sum;
  }

  double calculateTotalAmount(List<Transaction> transactions) {
    return transactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }
  double getTotalSurplusAmountByCurrency(List<Map<String, dynamic>> transactions, String currency, DateTime? startDate, DateTime? endDate) {

    DateTime toDateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

    return transactions
        .where((t) {
      if (t['isSurplus'] != true) return false;
      if (t['currency'] != currency) return false;

      final DateTime txDate = toDateOnly(t['date'] is DateTime
          ? t['date']
          : DateTime.tryParse(t['date'].toString()) ?? DateTime.now());

      if (startDate != null && txDate.isBefore(toDateOnly(startDate))) return false;
      if (endDate != null && txDate.isAfter(toDateOnly(endDate))) return false;

      return true;
    })
        .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0.0));
  }

  double getTotalDearthAmountByCurrency(List<Map<String, dynamic>> transactions, String currency, DateTime? startDate, DateTime? endDate) {

    DateTime toDateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

    return transactions
        .where((t) {
      if (t['isSurplus'] == true) return false;
      if (t['currency'] != currency) return false;

      final DateTime txDate = toDateOnly(t['date'] is DateTime
          ? t['date']
          : DateTime.tryParse(t['date'].toString()) ?? DateTime.now());

      if (startDate != null && txDate.isBefore(toDateOnly(startDate))) return false;
      if (endDate != null && txDate.isAfter(toDateOnly(endDate))) return false;

      return true;
    })
        .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0.0));
  }

  @override
  Widget build(BuildContext context) {
    final currency = selectedAccount?['currency'] ?? "";
    final transactions = List<Map<String, dynamic>>.from(selectedAccount?['transactions'] ?? []);
    final debts = List<Map<String, dynamic>>.from(selectedAccount?['debts'] ?? []);
    // Toplam miktar
    final totalAmount = debts.fold<double>(
      0,
          (sum, debt) => sum + (debt['amount'] as num).toDouble(),
    );
    print(transactions);
    final totalSurplus = getTotalSurplusAmountByCurrency(transactions, currency, startDate, endDate);
    final totalDearth = getTotalDearthAmountByCurrency(transactions, currency, startDate, endDate);
    double netProfitTransaction = totalSurplus - totalDearth; // NEW NET PROFIT
    double remainingDebt = selectedAccount?['remainingDebt'] ?? 0.0;
    double totalDebt = remainingDebt + totalAmount;
    String formattedIncomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(totalSurplus);
    String formattedOutcomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(totalDearth);
    String formattedProfitValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(netProfitTransaction);
    String formattedRemainingDebt = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(totalDebt);
    int incomeYuzdesi = (incomeValue * 100).toInt();
    int bolum;

    if (totalSurplus != 0.0 || totalDearth != 0.0) {
      double bolumDouble = netProfitTransaction / totalSurplus;
      if (bolumDouble.isFinite) {
        bolum = (bolumDouble.abs() * 100).toInt();
      } else {
        // Handle the case where bolumDouble is Infinity or NaN
        bolum = 0; // or any other appropriate value
      }
    } else {
      bolum = 0; // Handle the case where incomeValue is 0
    }
    incomeYuzdesi = incomeYuzdesi*10;

    void _onDateRangeSelected(DateRangePickerSelectionChangedArgs args) async{
      final prefs = await SharedPreferences.getInstance();
      // Save the selected date range to SharedPreferences
      if (args.value.startDate != null) {
        await prefs.setString('startDate', args.value.startDate!.toIso8601String());
      }

      if (args.value.endDate != null) {
        await prefs.setString('endDate', args.value.endDate!.toIso8601String());
      }

      // Call the reloadData callback to update the TransactionWidget
      setState(() {
        startDate = args.value.startDate;
        endDate = args.value.endDate;
      });

    }
    void _resetDateRange() async {
      final prefs = await SharedPreferences.getInstance();

      // Clear the saved dates from SharedPreferences
      await prefs.remove('startDate');
      await prefs.remove('endDate');

      // Reset the date range in the UI
      setState(() {
        startDate = null;
        endDate = null;
        _load(); //Reload the UI so expense can be refresh
      });
    }

    void _showDateRangePicker() async {
      final prefs = await SharedPreferences.getInstance();
      final startDateStr = prefs.getString('startDate');
      final endDateStr = prefs.getString('endDate');

      // Parse stored dates (if available)
      DateTime? startDate = startDateStr != null ? DateTime.parse(startDateStr) : null;
      DateTime? endDate = endDateStr != null ? DateTime.parse(endDateStr) : null;

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pick a Date Range',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SfDateRangePicker(
                    backgroundColor: const Color(0xFFFCF5FD),
                    selectionMode: DateRangePickerSelectionMode.range,
                    onSelectionChanged: _onDateRangeSelected,
                    showActionButtons: false,
                    initialSelectedRange: startDate != null && endDate != null
                        ? PickerDateRange(startDate, endDate)
                        : null, // Set initial range if available
                    headerStyle: const DateRangePickerHeaderStyle(
                      backgroundColor: Color(0xFFFCF5FD),
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    monthViewSettings: DateRangePickerMonthViewSettings(
                      weekendDays: const [6, 7],
                      firstDayOfWeek: 1,
                      showTrailingAndLeadingDates: true,
                      viewHeaderStyle: DateRangePickerViewHeaderStyle(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                    selectionColor: Colors.blueAccent.withOpacity(0.5),
                    startRangeSelectionColor: Colors.blue,
                    endRangeSelectionColor: Colors.blue,
                    rangeSelectionColor: Colors.blue.withOpacity(0.2),
                    todayHighlightColor: Colors.red,
                    toggleDaySelection: true,
                    showNavigationArrow: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                            _load();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    Future<String> _formatDateRange() async{
      final prefs = await SharedPreferences.getInstance();
      final startDateStr = prefs.getString('startDate');
      final endDateStr = prefs.getString('endDate');

      if (startDateStr != null && endDateStr != null) {
        final DateTime startDate = DateTime.parse(startDateStr);
        final DateTime endDate = DateTime.parse(endDateStr);
        final DateFormat dateFormat = DateFormat('dd MMMM yyyy', 'tr'); // TURKISH DATE FORMAT
        return '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';
      }
      return 'Pick a Date Range';
    }

    Widget _compactInfo(String label, dynamic value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            children: [
              TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(text: "$value"),
            ],
          ),
        ),
      );
    }

    Widget _progressBar({
      required String label,
      required double progress,
      required double maxValue,
      required double currentValue,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${currentValue.toStringAsFixed(2)} / ${maxValue.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 14),
              ),
              Text(
                "${(progress * 100).toStringAsFixed(1)}% Used",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      );
    }

    Widget _infoChip(IconData icon, String label, String value) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.blueAccent),
            const SizedBox(width: 6),
            Text(
              "$label: ",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      );
    }

    Widget _creditUsageCard({
      required String usageLabel,
      required double progress,
      required double maxValue,
      required double currentValue,
    }) {
      final moneyFormat = NumberFormat.currency(locale: "tr_TR", symbol: "₺", decimalDigits: 2);

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              usageLabel,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${moneyFormat.format(currentValue)} / ${moneyFormat.format(maxValue)}",
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  "%${(progress * 100).toStringAsFixed(1)} Kullanıldı",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      );
    }


    void _showAccountInfo(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Kredi Kartı Bilgileri"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _compactInfo("Para Birimi", currency),
                  _compactInfo("Hesap Türü", (selectedAccount?['isDebit'] ?? true) ? 'Banka' : 'Kredi'),
                  const Divider(),
                  if ((selectedAccount?['isDebit'] ?? true) == false) ...[
                    _compactInfo("Kredi Limiti", selectedAccount!['creditLimit']),
                    _compactInfo("Kullanılabilir Kredi", selectedAccount!['availableCredit']),
                    _compactInfo("Güncel Borç", selectedAccount!['currentDebt']),
                    _compactInfo("Toplam Borç", selectedAccount!['totalDebt']),
                    _compactInfo("Kalan Borç", selectedAccount!['remainingDebt']),
                    _compactInfo("Minimum Ödeme", selectedAccount!['minPayment']),
                    _compactInfo("Kalan Minimum Ödeme", selectedAccount!['remainingMinPayment']),
                    const Divider(),
                    _compactInfo("Önceki Borç", selectedAccount!['previousDebt']),
                    _compactInfo("Önceki Kesim Tarihi", selectedAccount!['previousCutoffDate']),
                    _compactInfo("Önceki Son Ödeme", selectedAccount!['previousDueDate']),
                    _compactInfo("Yeni Kesim Tarihi", selectedAccount!['nextCutoffDate']),
                    _compactInfo("Yeni Son Ödeme", selectedAccount!['nextDueDate']),
                    _compactInfo("Aktif Kesim Tarihi", selectedAccount!['cutoffDate']),
                  ],
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Kapat"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Özet", style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  GestureDetector(
                    onTap: _showDateRangePicker,
                    child: FutureBuilder<String>(
                      future: _formatDateRange(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text('Loading...');
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Text(snapshot.data ?? 'Pick a Date Range');
                        }
                      },
                    )
                  ),
                  ElevatedButton(
                      onPressed: _resetDateRange,
                      child: Text("Reset", style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w500))
                  )
                ],
              ),
              SizedBox(height: 20.h),
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
                        color: const Color.fromARGB(125, 155, 228, 242),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Kalan',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDebtVisible
                                        ? Colors.orange.withOpacity(0.2)  // aktif renk
                                        : Colors.grey.withOpacity(0.2),   // pasif renk
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      isDebtVisible ? Icons.visibility : Icons.visibility_off,
                                      color: isDebtVisible ? Colors.orange.shade800 : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isDebtVisible = !isDebtVisible;
                                      });
                                    },
                                    tooltip: isDebtVisible ? 'Borç durumunu gizle' : 'Borç durumunu göster',
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              formattedProfitValue == "0,00" ? "---" : formattedProfitValue, // KALAN BİLGİSİ
                              style: GoogleFonts.montserrat(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Visibility(
                              visible: isDebtVisible,
                              child: Text(
                                  "Toplam Borç: ${formattedRemainingDebt}",
                                style: GoogleFonts.montserrat(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            LinearPercentIndicator(
                              padding: const EdgeInsets.only(right: 10),
                              backgroundColor: const Color(0xffc6c6c7),
                              animation: true,
                              lineHeight: 12.h,
                              animationDuration: 1000,
                              percent: bolum/100,
                              trailing: Text(
                                  netProfitTransaction < 0 ? "-%${bolum.abs()}" : "%${bolum.abs()}",
                                  style: GoogleFonts.montserrat(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                              barRadius: const Radius.circular(10),
                              progressColor: const Color(0xff017b94),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 13,
                                      backgroundColor: Color.fromARGB(255, 152, 255, 170),
                                      child: Icon(Icons.arrow_upward, color: Colors.black, size: 16),
                                    ),
                                    SizedBox(width: 5.w),
                                    Text("Gelir", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w500,)),
                                  ],
                                ),
                                SizedBox(height: 7.h),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    formattedIncomeValue == "0,00" ? "---" : formattedIncomeValue, // GELİR BİLGİSİ
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const CircleAvatar(
                                      radius: 13,
                                      backgroundColor: Color.fromARGB(255, 152, 255, 170),
                                      child: Icon(Icons.arrow_downward, color: Colors.black, size: 16),
                                    ),
                                    SizedBox(width: 5.w),
                                    Text("Gider", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                SizedBox(height: 7.h),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    formattedOutcomeValue == "0,00" ? "---" : formattedOutcomeValue, // GİDER BİLGİSİ
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    debts.isEmpty
                        ? Text(
                      "Borç bilgisi yok",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    )
                        : Visibility(
                      visible: isDebtVisible,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.shade100.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Toplam Borç",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.orange.shade900,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Önceki Dönem Borcu",
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "${remainingDebt.toStringAsFixed(2)} ₺",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Yeni Borçlar",
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "${totalAmount.toStringAsFixed(2)} ₺",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            LinearProgressIndicator(
                              value: totalDebt == 0 ? 0 : remainingDebt / totalDebt,
                              backgroundColor: Colors.orange.shade100,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(8),
                            ),

                            const SizedBox(height: 16),

                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(
                                  showDebtDetails ? Icons.expand_less : Icons.expand_more,
                                  color: Colors.orange.shade800,
                                ),
                                onPressed: () {
                                  setState(() {
                                    showDebtDetails = !showDebtDetails;
                                  });
                                },
                                tooltip: showDebtDetails ? "Detayları Gizle" : "Detayları Göster",
                              ),
                            ),

                            if (showDebtDetails)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: debts.map((debt) {
                                  final amount = (debt['amount'] as num).toDouble();
                                  final title = debt['title'] ?? 'İsimsiz Borç';
                                  final percent = totalAmount == 0 ? 0.0 : amount / totalAmount;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        CircularPercentIndicator(
                                          radius: 18,
                                          lineWidth: 4,
                                          percent: percent.clamp(0.0, 1.0),
                                          center: Text(
                                            '${(percent * 100).toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade800,
                                            ),
                                          ),
                                          progressColor: Colors.orange.shade600,
                                          backgroundColor: Colors.orange.shade200.withOpacity(0.3),
                                          circularStrokeCap: CircularStrokeCap.round,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            '$title - ${amount.toStringAsFixed(2)} ₺',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Colors.orange.shade900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      )
                    ),
                    const SizedBox(height: 10)
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              bankAccounts.isEmpty
              ? Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.redAccent.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    "Lütfen önce hesap ekleyin.",
                    style: GoogleFonts.montserrat(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              )
                  : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : bankAccounts.isEmpty
                          ? const Text("No accounts available.")
                          : Wrap(
                        runSpacing: 8,
                        children: [
                          DropdownButtonFormField<int>(
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
                          if (selectedAccount != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey[850]
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 12,
                                        children: [
                                          _infoChip(Icons.attach_money, "Para Birimi", currency),
                                          _infoChip(
                                            Icons.account_balance_wallet,
                                            "Hesap Türü",
                                            (selectedAccount?['isDebit'] ?? true) ? "Banka" : "Kredi",
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.info_outline, size: 20),
                                            tooltip: "Hesap Bilgileri",
                                            onPressed: () => _showAccountInfo(context),
                                          ),
                                          const SizedBox(width: 8),
                                          TextButton.icon(
                                            onPressed: _resetSelectedAccount,
                                            icon: const Icon(Icons.refresh, size: 18),
                                            label: const Text("Sıfırla", style: TextStyle(fontSize: 13)),
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                              backgroundColor: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.white.withOpacity(0.05)
                                                  : Colors.grey.withOpacity(0.1),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              visualDensity: VisualDensity.compact,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if ((selectedAccount?['isDebit'] ?? true) == false)
                                        _creditUsageCard(
                                          usageLabel: "Kredi Kullanımı",
                                          progress: selectedAccount!['availableCredit']! / selectedAccount!['creditLimit']!,
                                          maxValue: selectedAccount!['creditLimit']!,
                                          currentValue: selectedAccount!['availableCredit']!,
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (selectedAccount?['previousCutoffDate'] != null &&
                                    selectedAccount?['previousDueDate'] != null)
                                  Builder(
                                    builder: (context) {
                                      final now = DateTime.now();
                                      final inputFormat = DateFormat('dd/MM/yyyy');
                                      final outputDateFormat = DateFormat("d MMMM", "tr_TR"); // Örn: 23 Mayıs
                                      final moneyFormat = NumberFormat.currency(locale: "tr_TR", symbol: "₺", decimalDigits: 2);

                                      final previousCutoff = inputFormat.parse(selectedAccount!['previousCutoffDate']);
                                      final previousDue = inputFormat.parse(selectedAccount!['previousDueDate']);

                                      // Son ödeme günü bugün veya geçtiyse kırmızı, değilse sarı
                                      final isOverdue = now.isAfter(previousDue) || now.isAtSameMomentAs(previousDue);
                                      final isInRange = now.isAfter(previousCutoff) && now.isBefore(previousDue);

                                      if (!isOverdue) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.grey[850]
                                                : Colors.grey[200],
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.warning_rounded,
                                                    color: isOverdue ? Colors.red : Colors.orange,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    "Son Ödeme: ${outputDateFormat.format(previousDue)}",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: isOverdue ? Colors.red : Colors.orange[800],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(Icons.payments_outlined, size: 20),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    "Kalan Ekstre Borcu: ${moneyFormat.format(selectedAccount!['previousDebt'])}",
                                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return const SizedBox.shrink(); // Tarih aralığında değilse gizle
                                      }
                                    },
                                  ),

                              ],
                            )
                        ],
                      ),
                    ),
                    TransactionWidget(
                      transactions: getTransactionsForSelectedAccount(),
                      invoices: invoices,
                      startDate: startDate,
                      endDate: endDate,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Text("Yaklaşan Ödemeler", style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.bold)),
              //ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), itemCount: invoices.length,itemBuilder: (context, index) {return Text(invoices[index].toDisplayString());},),
              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
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
                child: InvoicePage(onReload: _load),
              ),
              const SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }

// Add this inside your _HomePageState class
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

