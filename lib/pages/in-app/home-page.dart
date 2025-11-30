import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';


import '../../../blocs/income-selections.dart';
import '../../../models/account.dart';
import '../../../models/transaction-widget.dart';
import '../../../models/transaction.dart';
import '../../../models/upcoming-payments-section.dart';
import '../../storage/income_storage_service.dart';
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
  double _calculateTotalAmount(List<Transaction> transactions) {
    return transactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  Future<double> getTotalIncomeByDateRange(DateTime? startDate, DateTime? endDate) async {
    if (startDate != null && endDate != null) {
      // Use date range specific method
      return await IncomeStorageService.getTotalIncomeByDateRange(startDate, endDate);
    } else {
      // Use all-time total
      return await IncomeStorageService.getTotalIncome();
    }
  }

  Future<Map<String, String>> calculateFormattedValues(DateTime? startDate, DateTime? endDate, List<Transaction> transactions) async {
    // Get income from the new storage system
    final totalIncome = await getTotalIncomeByDateRange(startDate, endDate);

    // Get income breakdown by source for more detailed information
    final incomeSummary = await IncomeStorageService.getIncomeSummary();

    // Calculate outcome from transactions (this stays the same)
    final outcomeValue = _calculateTotalAmount(transactions);

    final profitValue = totalIncome - outcomeValue;

    final format = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2);

    return {
      'income': format.format(totalIncome),
      'outcome': format.format(outcomeValue),
      'profit': format.format(profitValue),
      'work': format.format(incomeSummary['work'] ?? 0.0),
      'scholarship': format.format(incomeSummary['scholarship'] ?? 0.0),
      'pension': format.format(incomeSummary['pension'] ?? 0.0),
    };
  }

  Future<double> getTotalIncomeByCurrencyAndDateRange(String currency, DateTime? startDate, DateTime? endDate) async {
    final allIncomes = await IncomeStorageService.loadIncomes();

    double total = 0.0;
    for (final income in allIncomes) {
      // Filter by currency
      if (income.currency != currency) continue;

      // Filter by date range if provided
      if (startDate != null && income.date.isBefore(DateTime(startDate.year, startDate.month, startDate.day))) {
        continue;
      }
      if (endDate != null && income.date.isAfter(DateTime(endDate.year, endDate.month, endDate.day))) {
        continue;
      }

      total += income.amount;
    }

    return total;
  }

  double getTotalDearthAmountByCurrency(List<Map<String, dynamic>> bankAccounts, String currency, DateTime? startDate, DateTime? endDate) {
    DateTime toDateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

    double totalOutcome = 0.0;

    // Iterate through all bank accounts
    for (final bank in bankAccounts) {
      final accounts = bank['accounts'] as List<dynamic>? ?? [];

      for (final account in accounts) {
        final transactions = List<Map<String, dynamic>>.from(account['transactions'] ?? []);

        // Sum outcomes for this account
        final accountOutcome = transactions
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

        totalOutcome += accountOutcome;
      }
    }

    return totalOutcome;
  }
  @override
  Widget build(BuildContext context) {
    final currency = selectedAccount?['currency'] ?? "";
    final transactions = List<Map<String, dynamic>>.from(selectedAccount?['transactions'] ?? []);
    final debts = List<Map<String, dynamic>>.from(selectedAccount?['debts'] ?? []);

    // 1. Seçili hesabın önceki dönem borcunu hesapla
    final remainingDebt = debts.fold<double>(
      0,
          (sum, debt) => sum + ((debt['amount'] as num?)?.toDouble() ?? 0),
    );

    // 2. Tüm bankalardaki kredi hesaplarının toplam borcunu hesapla
    double totalAmount = 0;
    for (final bank in bankAccounts) {
      final accounts = bank['accounts'] as List<dynamic>? ?? [];
      for (final account in accounts) {
        if (account['type'] == 'credit') {
          final balance = (account['balance'] as num?)?.toDouble() ?? 0;
          totalAmount += balance;
        }
      }
    }

    // 3. Toplam borç
    final totalDebt = remainingDebt + totalAmount;
    final totalDearth = getTotalDearthAmountByCurrency(bankAccounts, currency, startDate, endDate);
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
    Widget _creditUsageCard({
      required String usageLabel,
      required double progress,
      required double maxValue,
      required double currentValue,
      required BuildContext context,
    }) {
      final moneyFormat = NumberFormat.currency(locale: "tr_TR", symbol: "₺", decimalDigits: 2);
      final percentage = (progress * 100).toStringAsFixed(1);
      final progressColor = progress > 0.8
          ? Colors.orange
          : progress > 0.6
          ? Colors.amber
          : Theme.of(context).colorScheme.primary;

      return Container(
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]!.withOpacity(0.6)
              : Colors.blue[50]!.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  usageLabel.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "%$percentage",
                    style: GoogleFonts.montserrat(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: progressColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6.h,
                backgroundColor: Theme.of(context).dividerColor.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Kullanım",
                  style: GoogleFonts.montserrat(
                    fontSize: 10.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                Text(
                  "Limit",
                  style: GoogleFonts.montserrat(
                    fontSize: 10.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  moneyFormat.format(currentValue),
                  style: GoogleFonts.montserrat(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: progressColor,
                  ),
                ),
                Text(
                  moneyFormat.format(maxValue),
                  style: GoogleFonts.montserrat(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }


    Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 50.r,
              height: 50.r,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24.r,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    Widget _buildQuickActions() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            icon: Icons.arrow_upward_rounded,
            label: "Para Gönder",
            onTap: () {

            },
          ),
          _buildActionButton(
            icon: Icons.arrow_downward_rounded,
            label: "Para Yatır",
            onTap: () {

            },
          ),
          _buildActionButton(
            icon: Icons.receipt_long_rounded,
            label: "Dekont",
            onTap: () {

            },
          ),
          _buildActionButton(
            icon: Icons.more_horiz_rounded,
            label: "Diğer",
            onTap: () => _showAccountInfo(context),
          ),
        ],
      );
    }
    Widget _buildLoadingState() {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                strokeWidth: 2.5,
              ),
              SizedBox(height: 16.h),
              Text(
                "Hesaplar yükleniyor...",
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }
    Widget _buildNoAccountsState() {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 40.r,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "Henüz hesap eklenmemiş",
                style: GoogleFonts.montserrat(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "Hesap eklemek için aşağıdaki butona tıklayın\nveya banka bağlantısı yapın",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 32.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to add manual account
                      context.push('/add-account');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Hesap Ekle",
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  OutlinedButton(
                    onPressed: () {
                      // Navigate to bank connection
                      context.push('/connect-bank');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    child: Text(
                      "Banka Bağla",
                      style: GoogleFonts.montserrat(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    Widget _buildSelectAccountPrompt() {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_drop_up_rounded,
                size: 48.h,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              ),
              SizedBox(height: 16.h),
              Text(
                "Hesap Seçin",
                style: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Yukarıdaki menüden görüntülemek istediğiniz\nhesabı seçin",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(16.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]!.withOpacity(0.5)
                      : Colors.grey[100]!.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20.h,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        "${bankAccounts.length} hesap mevcut",
                        style: GoogleFonts.montserrat(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    Widget _buildAccountDetails() {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Details Card
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(selectedAccount?['accountId']),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[50],
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!
                        : Colors.grey[200]!,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                      blurRadius: 8.r,
                      spreadRadius: 1.r,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account header with name and balance
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedAccount?['name'] ?? 'Hesap',
                              style: GoogleFonts.montserrat(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${selectedAccount?['balance']?.toStringAsFixed(2) ?? '0.00'} $currency',
                            style: GoogleFonts.montserrat(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      Row(
                        children: [
                          Expanded(
                            child: _InfoChip(
                              icon: Icons.attach_money,
                              label: "Para Birimi",
                              value: currency,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _InfoChip(
                              icon: Icons.account_balance_wallet,
                              label: "Hesap Türü",
                              value: (selectedAccount?['isDebit'] ?? true)
                                  ? "Banka"
                                  : "Kredi",
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Credit Usage (if credit card)
                      if ((selectedAccount?['isDebit'] ?? true) == false)
                        _creditUsageCard(
                            usageLabel: "Kredi Kullanımı",
                            progress: (selectedAccount?['availableCredit'] != null &&
                                selectedAccount?['creditLimit'] != null &&
                                selectedAccount?['creditLimit'] != 0)
                                ? (selectedAccount!['availableCredit'] as num) /
                                (selectedAccount!['creditLimit'] as num)
                                : 0.0,
                            maxValue: ((selectedAccount?['creditLimit'] ?? 0) as num)
                                .toDouble(),
                            currentValue:
                            ((selectedAccount?['availableCredit'] ?? 0) as num)
                                .toDouble(),
                            context: context
                        ),


                      // Payment Due Warning
                      if ((selectedAccount?['previousCutoffDate'] != null &&
                          selectedAccount?['previousDueDate'] != null) ||
                          (selectedAccount?['cutoffDate'] != null &&
                              selectedAccount?['dueDate'] != null))
                        _PaymentDueWarning(
                          previousCutoffDate: selectedAccount?['previousCutoffDate'],
                          previousDueDate: selectedAccount?['previousDueDate'],
                          currentCutoffDate: DateTime(DateTime.now().year,
                              DateTime.now().month, selectedAccount?['cutoffDate']),
                          currentDueDate: selectedAccount?['dueDate'],
                          debt: selectedAccount?['previousDebt'],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Quick Actions
            _buildQuickActions(),
            SizedBox(height: 24.h),

            // Transactions
            TransactionWidget(
              transactions: getTransactionsForSelectedAccount(),
              invoices: invoices,
              startDate: startDate,
              endDate: endDate,
            ),
          ],
        ),
      );
    }
    return FutureBuilder(
      future: getTotalIncomeByDateRange(startDate, endDate),
      builder: (context, incomeSnapshot) {
        // Calculate values based on income data
        double totalIncome = 0.0;
        double netProfitTransaction = 0.0;
        String formattedIncomeValue = "0,00";
        String formattedOutcomeValue = "0,00";
        String formattedProfitValue = "0,00";
        String formattedRemainingDebt = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(totalDebt);
        int bolum = 0;

        if (incomeSnapshot.connectionState == ConnectionState.done && incomeSnapshot.hasData) {
          totalIncome = incomeSnapshot.data!;
          netProfitTransaction = totalIncome - totalDearth;
          formattedIncomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(totalIncome);
          formattedOutcomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(totalDearth);
          formattedProfitValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(netProfitTransaction);
          // Calculate percentage
          if (totalIncome != 0.0 || totalDearth != 0.0) {
            double bolumDouble = netProfitTransaction / totalIncome;
            if (bolumDouble.isFinite) {
              bolum = (bolumDouble.abs() * 100).toInt();
            } else {
              bolum = 0;
            }
          } else {
            bolum = 0;
          }
        }

        // Show loading while waiting for income data
        if (incomeSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Özet", style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  if (selectedAccount == null || selectedAccount!['isDebit'] != false)
                    Row(
                      children: [
                        GestureDetector(
                            onTap: _showDateRangePicker,
                            child: FutureBuilder<String>(
                              future: _formatDateRange(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Text('Loading...', style: GoogleFonts.montserrat(fontSize: 10.sp, fontWeight: FontWeight.normal));
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}', style: GoogleFonts.montserrat(fontSize: 10.sp, fontWeight: FontWeight.normal));
                                } else {
                                  return Text(snapshot.data ?? 'Gün Aralığı Seç', style: GoogleFonts.montserrat(fontSize: 10.sp, fontWeight: FontWeight.normal));
                                }
                              },
                            )
                        ),
                        SizedBox(width: 10.w),
                        ElevatedButton(
                            onPressed: _resetDateRange,
                            child: Text("Sıfırla", style: GoogleFonts.montserrat(fontSize: 8.sp, fontWeight: FontWeight.w500))
                        )
                      ],
                    ),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.all(16.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[900]
                          : Colors.grey[50],
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]!
                            : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// --- HEADER: BALANCE + VISIBILITY ---
                        Column(
                          children: [
                            // Kalan (üstte full width + buton)
                            GlassmorphismCard(
                              title: "Kalan",
                              value: () {
                                final result = formattedProfitValue == null ? "---" : formattedProfitValue;
                                print('DEBUG GlassmorphismCard:');
                                print('  formattedProfitValue: $formattedProfitValue');
                                print('  condition result: $result');
                                print('  netProfitTransaction: $netProfitTransaction');
                                return result;
                              }(),
                              icon: Icons.account_balance_wallet,
                              color: Colors.blueAccent,
                              trailing: IconButton(
                                icon: Icon(
                                  isDebtVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() => isDebtVisible = !isDebtVisible);
                                },
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Gelir & Gider (yan yana)
                            Row(
                              children: [
                                Expanded(
                                  child: GlassmorphismCard(
                                    title: "Gelir",
                                    value: formattedIncomeValue == "0,00" ? "---" : formattedIncomeValue,
                                    icon: Icons.arrow_upward,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GlassmorphismCard(
                                    title: "Gider",
                                    value: formattedOutcomeValue == "0,00" ? "---" : formattedOutcomeValue,
                                    icon: Icons.arrow_downward,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        if (isDebtVisible) ...[
                          SizedBox(height: 8.h),
                          Text(
                            "Toplam Borç: $formattedRemainingDebt",
                            style: GoogleFonts.montserrat(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                        /// --- DEBT SECTION ---
                        AnimatedSize(
                          duration: Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          child: Visibility(
                            visible: isDebtVisible,
                            child: Column(
                              children: [
                                SizedBox(height: 8.h),
                                Container(
                                  padding: EdgeInsets.all(12.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.r),
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey[850]
                                        : Colors.white,
                                    border: Border.all(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.grey[800]!
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      /// --- TITLE & TOGGLE ---
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Toplam Borç",
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              showDebtDetails
                                                  ? Icons.expand_less
                                                  : Icons.expand_more,
                                              size: 22.r,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                showDebtDetails = !showDebtDetails;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),

                                      /// --- PREVIOUS PERIOD & NEW DEBTS ---
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Önceki Dönem",
                                            style: GoogleFonts.montserrat(
                                              fontSize: 13.sp,
                                              color: Theme.of(context).hintColor,
                                            ),
                                          ),
                                          Text(
                                            "${remainingDebt.toStringAsFixed(2)} ₺",
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Yeni Borçlar",
                                            style: GoogleFonts.montserrat(
                                              fontSize: 13.sp,
                                              color: Theme.of(context).hintColor,
                                            ),
                                          ),
                                          Text(
                                            "${totalAmount.toStringAsFixed(2)} ₺",
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.sp,
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 16.h),

                                      LinearProgressIndicator(
                                        value: totalDebt == 0 ? 0 : remainingDebt / totalDebt,
                                        backgroundColor: Colors.grey.withOpacity(0.2),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Theme.of(context).colorScheme.primary),
                                        minHeight: 8.h,
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),

                                      /// --- DEBT DETAILS ---
                                      AnimatedSize(
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                        child: Visibility(
                                          visible: showDebtDetails,
                                          child: Column(
                                            children: [
                                              SizedBox(height: 16.h),
                                              if (debts.isNotEmpty)
                                                Column(
                                                  children: debts.map((debt) {
                                                    final amount =
                                                    (debt['amount'] as num).toDouble();
                                                    final title =
                                                        debt['title'] ?? 'İsimsiz Borç';
                                                    final percent = totalAmount == 0
                                                        ? 0.0
                                                        : amount / totalAmount;
                                                    return Padding(
                                                      padding: EdgeInsets.symmetric(
                                                          vertical: 6.h),
                                                      child: Row(
                                                        children: [
                                                          CircularPercentIndicator(
                                                            radius: 20.r,
                                                            lineWidth: 4.r,
                                                            percent: percent.clamp(0.0, 1.0),
                                                            center: Text(
                                                              '${(percent * 100).toStringAsFixed(0)}%',
                                                              style: GoogleFonts.montserrat(
                                                                fontSize: 11.sp,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                            progressColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                            backgroundColor: Colors.grey
                                                                .withOpacity(0.2),
                                                            circularStrokeCap:
                                                            CircularStrokeCap.round,
                                                          ),
                                                          SizedBox(width: 12.w),
                                                          Expanded(
                                                            child: Text(
                                                              "$title - ${amount.toStringAsFixed(2)} ₺",
                                                              style:
                                                              GoogleFonts.montserrat(
                                                                fontSize: 13.sp,
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              if (debts.isEmpty)
                                                Padding(
                                                  padding:
                                                  EdgeInsets.symmetric(vertical: 12.h),
                                                  child: Text(
                                                    "Borç bilgisi yok",
                                                    style: GoogleFonts.montserrat(
                                                      fontSize: 12.sp,
                                                      fontStyle: FontStyle.italic,
                                                      color: Theme.of(context).hintColor,
                                                    ),
                                                  ),
                                                ),

                                              if (debts.isNotEmpty) SizedBox(height: 16.h),

                                              /// --- BANKS & ACCOUNTS ---
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: bankAccounts.map((bank) {
                                                  final bankName =
                                                      bank['bankName'] ?? 'Banka İsmi Yok';
                                                  final accounts = bank['accounts']
                                                  as List<dynamic>? ??
                                                      [];
                                                  return Padding(
                                                    padding: EdgeInsets.only(bottom: 16.h),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          bankName,
                                                          style: GoogleFonts.montserrat(
                                                            fontSize: 14.sp,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8.h),
                                                        ...accounts.map((account) {
                                                          final accountName =
                                                              account['name'] ??
                                                                  'Hesap İsmi Yok';
                                                          final debts =
                                                          List<Map<String, dynamic>>.from(
                                                              account['debts'] ?? []);
                                                          if (debts.isEmpty) {
                                                            return Padding(
                                                              padding: EdgeInsets.only(
                                                                  left: 16.w, bottom: 6.h),
                                                              child: Text(
                                                                "Borç Yok - $accountName",
                                                                style:
                                                                GoogleFonts.montserrat(
                                                                  fontSize: 12.sp,
                                                                  color: Theme.of(context)
                                                                      .hintColor,
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          return Padding(
                                                            padding: EdgeInsets.only(
                                                                left: 16.w, bottom: 8.h),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  accountName,
                                                                  style:
                                                                  GoogleFonts.montserrat(
                                                                    fontSize: 13.sp,
                                                                    fontWeight:
                                                                    FontWeight.w600,
                                                                  ),
                                                                ),
                                                                SizedBox(height: 4.h),
                                                                ...debts.map((debt) {
                                                                  final amount = (debt['amount']
                                                                  as num?)
                                                                      ?.toDouble() ??
                                                                      0;
                                                                  final title = debt['title'] ??
                                                                      'İsimsiz Borç';
                                                                  return Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left: 12.w,
                                                                        bottom: 4.h),
                                                                    child: Text(
                                                                      "• $title: ${amount.toStringAsFixed(2)} ₺",
                                                                      style: GoogleFonts
                                                                          .montserrat(
                                                                        fontSize: 12.sp,
                                                                        color: Theme.of(
                                                                            context)
                                                                            .hintColor,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              ],
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  isLoading
                      ? _buildLoadingState()
                      : bankAccounts.isEmpty
                      ? _buildNoAccountsState()
                      : selectedAccount == null
                      ? _buildSelectAccountPrompt()
                      : _buildAccountDetails(),
                  SizedBox(height: 20.h),
                  Text("Yaklaşan Ödemeler", style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  //ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), itemCount: invoices.length,itemBuilder: (context, index) {return Text(invoices[index].toDisplayString());},),
                  SizedBox(height: 20.h),
                  selectedAccount != null
                      ? UpcomingPaymentsSection(account: Account.fromJson(selectedAccount!))
                      : const SizedBox.shrink(),
                  const SizedBox(height: 20)
                ],
              ),
            ),
          )
        );
      },
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
            'currency': account['currency'],
            'isDebit': account['isDebit'],
            'creditLimit': account['creditLimit'],
            'availableCredit': account['availableCredit'],
            'cutoffDate': account['cutoffDate']
            // Don't include nested accounts array since we're selecting one account
          };
        }
      }
    }
    return null;
  }
}

class GlassmorphismCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Widget? trailing;

  const GlassmorphismCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sol taraf
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 28, color: color),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // Sağ taraf (opsiyonel buton vb.)
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]!.withOpacity(0.6)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24.r,
            height: 24.r,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 12.h,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 9.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentDueWarning extends StatelessWidget {
  final String? previousCutoffDate;
  final String? previousDueDate;
  final DateTime? currentCutoffDate;
  final String? currentDueDate;
  final dynamic debt;

  const _PaymentDueWarning({
    this.previousCutoffDate,
    this.previousDueDate,
    this.currentCutoffDate,
    this.currentDueDate,
    required this.debt,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final inputFormat = DateFormat('dd/MM/yyyy');
    final outputDateFormat = DateFormat("d MMMM", "tr_TR");
    final moneyFormat = NumberFormat.currency(
      locale: "tr_TR",
      symbol: "₺",
      decimalDigits: 2,
    );

    DateTime? prevCutoff;
    DateTime? prevDue;
    DateTime? currCutoff;
    DateTime? currDue;

    if (previousCutoffDate != null && previousDueDate != null) {
      prevCutoff = inputFormat.parse(previousCutoffDate!);
      prevDue = inputFormat.parse(previousDueDate!);
    }

    if (currentCutoffDate != null && currentDueDate != null) {
      currCutoff = currentCutoffDate;
      currDue = inputFormat.parse(currentDueDate!);
    }

    final inPrevRange = prevCutoff != null &&
        prevDue != null &&
        (now.isAfter(prevCutoff) || now.isAtSameMomentAs(prevCutoff)) &&
        now.isBefore(prevDue);

    final inCurrRange = currCutoff != null &&
        currDue != null &&
        (now.isAfter(currCutoff) || now.isAtSameMomentAs(currCutoff)) &&
        now.isBefore(currDue);

    if (!inPrevRange && !inCurrRange) return const SizedBox.shrink();

    final shownDueDate = inPrevRange ? prevDue : currDue;
    final isOverdue = shownDueDate != null && now.isAfter(shownDueDate);
    final daysUntilDue = shownDueDate != null ? shownDueDate.difference(now).inDays : 0;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: isOverdue
            ? Colors.red.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.08)
            : Colors.orange.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isOverdue
              ? Colors.red.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: isOverdue
                      ? Colors.red.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOverdue ? Icons.error_outline : Icons.warning_amber_rounded,
                  size: 18.h,
                  color: isOverdue ? Colors.red : Colors.orange,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOverdue ? "ÖDEME GECİKTİ" : "SON ÖDEME YAKLAŞIYOR",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                        color: isOverdue ? Colors.red : Colors.orange[800],
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (shownDueDate != null)
                      Text(
                        isOverdue
                            ? "${outputDateFormat.format(shownDueDate)} tarihinde sona erdi"
                            : "${daysUntilDue} gün kaldı",
                        style: GoogleFonts.montserrat(
                          fontSize: 10.sp,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Kalan borç:",
                  style: GoogleFonts.montserrat(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  moneyFormat.format(debt),
                  style: GoogleFonts.montserrat(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: isOverdue ? Colors.red : Colors.orange[800],
                  ),
                ),
              ],
            ),
          ),
          if (isOverdue) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Add payment action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "HEMEN ÖDE",
                  style: GoogleFonts.montserrat(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}