import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';


import '../../blocs/income-selections.dart';
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
        DateTime periodDate = DateTime.parse(invoice.periodDate!);
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
        DateTime periodDate = DateTime.parse(invoice.periodDate!);
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
            title: Text("Are you sure?"),
            content: Text("Do you really want to delete this invoice?"),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Delete"),
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
    final ab16 = prefs.getString('transactions');

    setState(() {
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
        setState(() {
          startDate = DateTime.parse(ab14);
          endDate = DateTime.parse(ab15);
        });
      }
      if (ab2.isNotEmpty) {
        final decodedData = json.decode(ab2);
        if (decodedData is Map<String, dynamic>) {
          incomeMap = {};
          decodedData.forEach((key, value) {
            if (value is List<dynamic>) {
              incomeMap[key] = List<Map<String, dynamic>>.from(value.map((e) => Map<String, dynamic>.from(e)));
            }
            if (incomeMap.containsKey(key) && incomeMap[key]!.isNotEmpty) {
              // Get the first amount from the list (use the 'amount' field inside the map)
              String valueToParse = incomeMap[selectedKey.isNotEmpty ? selectedKey : key]![0]["amount"];
              selectedKey = key;
              incomeValue = NumberFormat.decimalPattern('tr_TR').parse(valueToParse) as double;
              double sum = 0.0;
              for (var values in incomeMap.values) {
                for (var value in values) {
                  // Parse the "amount" field as double
                  String amount = value["amount"];
                  if (amount.isNotEmpty) {
                    double parsedValue = NumberFormat.decimalPattern('tr_TR').parse(amount).toDouble();
                    sum += parsedValue;
                  }
                }
              }
              incomeValue = sum;
            } else {
              incomeValue = 0.0; // Default value if the key or value is not found
            }
          });
        }
        print('Final incomeMap: ${jsonEncode(incomeMap)}');
      }
      if (savedInvoicesJson != null) {
        setState(() {
          invoices = savedInvoicesJson.map((json) => Invoice.fromJson(jsonDecode(json))).toList();
          setState(() {
            invoices.forEach((invoice) {
              if (invoice.dueDate != null){
                invoice.updateDifference(invoice, invoice.periodDate, invoice.dueDate);
              } else {
                invoice.updateDifference(invoice, invoice.periodDate, null);
              }
            });

            invoices.sort((a, b) {
              int differenceA = int.parse(a.difference);
              int differenceB = int.parse(b.difference);
              return differenceA.compareTo(differenceB);
            });

            final invoiceJsonList = invoices.map((invoice) => jsonEncode(invoice.toJson())).toList();
            prefs.setStringList('invoices', invoiceJsonList);

          });
          categorizeInvoices(invoices);
          transactions.clear();
          transactions = mergeInvoicesToTransactions(invoices, transactions);
          if (startDate != null && endDate != null) {

            transactions = transactions.where((transaction) {
              print("COXK: $startDate and $endDate");
              final date = transaction.date;
              return (date.isAfter(startDate!) || date.isAtSameMomentAs(startDate!)) &&
                  (date.isBefore(endDate!) || date.isAtSameMomentAs(endDate!));
            }).toList();
          }
          transactions.sort((a, b) => a.date.compareTo(b.date));
          final jsonData = jsonEncode(transactions.map((t) => t.toJson()).toList());
          prefs.setString('transactions', jsonData);
        });
      }
      loadSharedPreferencesData(actualDesiredKeys);
    });

    // Clear the existing transactions before loading new data
    setState(() {
      transactions.clear(); // Clear the existing transaction list
    });

    await TransactionService.generateAndSaveTransactions();
    // Load the transactions again from storage
    List<Transaction> loadedTransactions = await TransactionService.loadTransactions();

    setState(() {
      transactions = loadedTransactions; // Update the transaction list with new data
    });

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
          id: invoice.id,
          amount: double.parse(invoice.price),
          description: invoice.subCategory,
          currency: invoice.name,
          date: (invoice.dueDate != null && invoice.dueDate!.isNotEmpty)
              ? DateTime.parse(invoice.dueDate!)
              : (invoice.periodDate != null && invoice.periodDate!.isNotEmpty)
              ? DateTime.parse(invoice.periodDate!)
              : DateTime.now(), // Fallback to current date if both are null or empty.
          isSurplus: false,
          isFromInvoice: true,
          initialInstallmentDate: null,
          installment: null
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
      if (dueDate != null && currentDate.isAfter(DateTime.parse(periodDate))) {
        diff = (DateTime.parse(dueDate!).difference(currentDate).inDays + 1).toString();
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
        print("The delete has been confirmed. Current diff is : ${diff} while period date is now : ${stringPeriodDate}");
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
  double calculateTotalAmount(List<Transaction> transactions) {
    return transactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }
  double getTotalSurplusAmountByCurrency(List<Transaction> transactions, String currency) {
    return transactions
        .where((t) => t.isSurplus && t.currency == currency) // Filter by isSurplus and currency
        .fold(0.0, (sum, t) => sum + t.amount); // Sum the amounts
  }
  double gettotalDearthAmountByCurrency(List<Transaction> transactions, String currency) {
    return transactions
        .where((t) => t.isSurplus == false && t.currency == currency) // Filter by isSurplus and currency
        .fold(0.0, (sum, t) => sum + t.amount); // Sum the amounts
  }

  @override
  Widget build(BuildContext context) {
    double sumOfSubs = calculateCategorySum(invoices, 'Abonelikler');
    double sumOfBills = calculateCategorySum(invoices, 'Faturalar');
    double sumOfOthers = calculateCategorySum(invoices, 'Diğer Giderler');
    double outcomeValue = sumOfSubs+sumOfBills+sumOfOthers;
    double outcomeValue2 = calculateTotalAmount(transactions);
    double netProfit = incomeValue - outcomeValue2; //OLD NET PROFIT
    double totalSurplusTRY = getTotalSurplusAmountByCurrency(transactions, 'TRY');
    double totalDearthTRY = gettotalDearthAmountByCurrency(transactions, 'TRY');
    double netProfitTransaction = totalSurplusTRY - totalDearthTRY;
    String formattedIncomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(totalSurplusTRY);
    String formattedOutcomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(totalDearthTRY);
    String formattedProfitValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(netProfitTransaction);
    String formattedSumOfSubs = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfSubs);
    String formattedSumOfBills = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfBills);
    String formattedSumOfOthers = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfOthers);
    String formattedSavingsValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(savingsValue);
    String formattedWishesValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(wishesValue);
    String formattedNeedsValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(needsValue);
    int incomeYuzdesi = (incomeValue * 100).toInt();
    int netProfitYuzdesi = (netProfit * 100).toInt();
    int bolum;



    if (incomeValue != 0.0) {
      double bolumDouble = netProfit / incomeValue;
      if (bolumDouble.isFinite) {
        bolum = (bolumDouble.abs() * 100).toInt();
        netProfit = incomeValue * bolumDouble;
      } else {
        // Handle the case where bolumDouble is Infinity or NaN
        bolum = 0; // or any other appropriate value
      }
    } else {
      bolum = 0; // Handle the case where incomeValue is 0
    }
    String formattedBolum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(bolum);
    incomeYuzdesi = incomeYuzdesi*10;

    final List<String> texts = ["Abonelikler", "Faturalar", "Diğer"];
    final List<String> formattedSums = [
      formattedSumOfSubs,
      formattedSumOfBills,
      formattedSumOfOthers
    ];

    double calculateMaxFontSize(BoxConstraints constraints) {
      double maxFontSize = 14.sp;
      final textPainters = texts.map((text) {
        return TextPainter(
          text: TextSpan(
            text: text,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.normal,
              fontSize: maxFontSize,
            ),
          ),
          maxLines: 1,
          textDirection: ui.TextDirection.ltr,
        );
      }).toList();

      textPainters.forEach((painter) {
        painter.layout(maxWidth: constraints.maxWidth / 3 - 20.w);
        if (painter.didExceedMaxLines) {
          maxFontSize = maxFontSize * (constraints.maxWidth / 3 - 20.w) / painter.size.width;
        }
      });

      return maxFontSize;
    }

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
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Pick a Date Range'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.range,
                onSelectionChanged: _onDateRangeSelected,
                showActionButtons: true,
                onSubmit: (value) {
                 setState(() {
                   Navigator.pop(context);
                   _load();
                 });
                },
                onCancel: () {
                  Navigator.pop(context);
                },
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
                          return Text('Loading...');
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
                        color: Color.fromARGB(125, 155, 228, 242),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Kalan',
                              style: GoogleFonts.montserrat(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              formattedProfitValue, // KALAN BİLGİSİ
                              style: GoogleFonts.montserrat(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
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
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(10),
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
                                    formattedIncomeValue, // GELİR BİLGİSİ
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
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(120, 152, 255, 170),
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
                                    formattedOutcomeValue, // GİDER BİLGİSİ
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
                    SizedBox(height: 10),
                    LayoutBuilder(
                          builder: (context, constraints) {
                            final maxFontSize = calculateMaxFontSize(constraints);
                            return Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Color.fromARGB(125, 255, 204, 178)
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            "Abonelikler",
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.normal,
                                              fontSize: maxFontSize,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5.h),
                                        LinearPercentIndicator(
                                          padding: EdgeInsets.zero,
                                          backgroundColor: const Color(0xffc6c6c7),
                                          animation: true,
                                          lineHeight: 9.h,
                                          animationDuration: 1000,
                                          percent: (outcomeValue != 0) ? (sumOfSubs / outcomeValue) : 0,
                                          barRadius: const Radius.circular(10),
                                          progressColor: const Color(0xFFFF8C00),
                                        ),
                                        SizedBox(height: 5.h),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            formattedSumOfSubs,
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.bold,
                                              fontSize: maxFontSize,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                        color: Color.fromARGB(125, 255, 204, 178)
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            "Faturalar",
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.normal,
                                              fontSize: maxFontSize,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5.h),
                                        LinearPercentIndicator(
                                          padding: EdgeInsets.zero,
                                          backgroundColor: const Color(0xffc6c6c7),
                                          animation: true,
                                          lineHeight: 9.h,
                                          animationDuration: 1000,
                                          percent: (outcomeValue != 0) ? (sumOfBills / outcomeValue) : 0,
                                          barRadius: const Radius.circular(10),
                                          progressColor: const Color(0xFFFFA500),
                                        ),
                                        SizedBox(height: 5.h),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            formattedSumOfBills,
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.bold,
                                              fontSize: maxFontSize,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                        color: Color.fromARGB(125, 255, 204, 178)
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            "Diğer",
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.normal,
                                              fontSize: maxFontSize,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5.h),
                                        LinearPercentIndicator(
                                          padding: EdgeInsets.zero,
                                          backgroundColor: const Color(0xffc6c6c7),
                                          animation: true,
                                          lineHeight: 9.h,
                                          animationDuration: 1000,
                                          percent: (outcomeValue != 0) ? (sumOfOthers / outcomeValue) : 0,
                                          barRadius: const Radius.circular(10),
                                          progressColor: const Color(0xFFFFD700),
                                        ),
                                        SizedBox(height: 5.h),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            formattedSumOfOthers,
                                            style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.bold,
                                              fontSize: maxFontSize,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Text("Hareketlerim", style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.bold)),
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
                    TransactionWidget(
                        transactions: transactions,
                        invoices: invoices,
                        startDate: startDate,
                        endDate: endDate,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Text("Faturalarım", style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.bold)),
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

  void _reloadTransactionData() {
  }
}

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  InvoiceCard({super.key,
    required this.invoice,
    required this.onDelete,
    required this.onEdit
  }) {
    faturaDonemi = DateTime.parse(invoice.periodDate);
    if (invoice.dueDate != null){
      sonOdeme = DateTime.parse(invoice.dueDate!);
    }
  }

  DateTime faturaDonemi = DateTime.now();
  DateTime sonOdeme = DateTime.now();
  bool isPaidActive = false;

  String getDaysRemainingMessage2() {
    final currentDate = DateTime.now();
    final formattedCurrentDate = DateFormat('yyyy-MM-dd').format(currentDate);
    final formattedPeriodDate = DateFormat('yyyy-MM-dd').format(faturaDonemi);
    final dueDateKnown = invoice.dueDate != null;

    if (currentDate.isBefore(faturaDonemi)) {
      isPaidActive = false;
      return "Fatura kesimine kalan gün";
    } else if (dueDateKnown) {
      isPaidActive = true;
      if (currentDate.isBefore(sonOdeme)) {
        return "Son ödeme tarihine kalan gün";
      } else {
        isPaidActive = true;
        return "Ödeme için son gün";
      }
    } else if (formattedCurrentDate == formattedPeriodDate){
      isPaidActive = true;
      return "Ödeme dönemi";
    } else {
      return "Gecikme süresi";
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysRemainingMessage = getDaysRemainingMessage2();
    return IntrinsicWidth(
      child: Container(
        width: 200.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color.fromARGB(125, 169, 219, 255),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color.fromARGB(125, 70, 181, 255),
              ),
              child: ListTile(
                dense: true,
                title: Text(
                  invoice.name,
                  style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  invoice.category,
                  style: GoogleFonts.montserrat(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.normal),
                ),
              ),
            ),
            ListTile(
              dense: true,
              title: Text(
                "Fatura Dönemi",
                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                invoice.periodDate,
                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.normal),
              ),
            ),
            ListTile(
              dense: true,
              title: Text(
                "Son Ödeme Tarihi",
                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                invoice.dueDate ?? "Bilinmiyor",
                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.normal),
              ),
            ),
            Flexible( // Use Flexible here
              child: Container(
                constraints: BoxConstraints(
                  minHeight: 70.h,
                ),
                child: ListTile(
                  title: Text(
                    daysRemainingMessage,
                    style: GoogleFonts.montserrat(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.normal),
                  ),
                  subtitle: daysRemainingMessage != "Ödeme dönemi" ? Text(
                    invoice.difference,
                    style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ) : null,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color.fromARGB(125, 173, 198, 255),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: SizedBox(
                      width: 22.h,
                      height: 22.h,
                      child: IconButton(
                        padding: EdgeInsets.zero, // Remove the default padding
                        onPressed: onDelete,
                        icon: Icon(Icons.done_rounded, size: 24),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 22.h,
                      height: 22.h,
                      child: IconButton(
                        padding: EdgeInsets.zero, // Remove the default padding
                        onPressed: onEdit,
                        icon: Icon(Icons.edit_rounded, size: 24),
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
}

class InvoicePage extends StatefulWidget {
  final VoidCallback onReload;

  InvoicePage({required this.onReload});
  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showRightArrow = false;
  bool _showLeftArrow = false;
  bool _isTouching = false;
  final GlobalKey _intrinsicHeightKey = GlobalKey();
  final Map<int, GlobalKey> _intrinsicHeightKeys = {};
  final GlobalKey _scrollWidthKey = GlobalKey();
  double? _height;
  double? _width;
  double? _widthIntrinsic;
  int _currentPage = 0;
  double _rightArrowOpacity = 0.0;
  double _leftArrowOpacity = 0.0;
  List<Invoice> upcomingInvoices = [];
  List<Invoice> todayInvoices = [];
  List<Invoice> approachingDueInvoices = [];
  List<Invoice> paymentDueInvoices = [];
  List<Invoice> overdueInvoices = [];
  List<Invoice> selectedInvoices = [];
  List<Invoice> originalInvoices = [];


  @override
  void initState() {
    super.initState();
    _loadInvoices(); // Load invoices from SharedPreferences
    if (overdueInvoices.isNotEmpty){
      _currentPage = 4;
    } else if (paymentDueInvoices.isNotEmpty){
      _currentPage = 3;
    } else if (approachingDueInvoices.isNotEmpty){
      _currentPage = 2;
    } else if (todayInvoices.isNotEmpty){
      _currentPage = 1;
    } else {
      _currentPage = 0;
    }
  }

  Future<void> addSampleInvoice() async {
    try {
      print("DEBUG: Starting addSampleInvoice");
      final prefs = await SharedPreferences.getInstance();
      print("DEBUG: SharedPreferences instance obtained");

      final sampleInvoice = Invoice(
        id: 1,
        name: 'Sample Invoice',
        price: '100.0',
        periodDate: '2024-12-12',
        category: 'category',
        difference: 'diff',
        subCategory: 'sub',
        dueDate: null,
      );

      final invoicesJson = prefs.getStringList('invoices') ?? [];
      print("DEBUG: Initial invoicesJson: $invoicesJson");

      invoicesJson.add(jsonEncode(sampleInvoice.toJson()));
      print("DEBUG: Updated invoicesJson: $invoicesJson");

      await prefs.setStringList('invoices', invoicesJson);
      print("DEBUG: Invoices saved to SharedPreferences");
    } catch (e) {
      print("ERROR: $e");
    }
  }

  Future<void> _loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final invoicesJson = prefs.getStringList('invoices') ?? [];
    setState(() {
      selectedInvoices = invoicesJson.map((e) => Invoice.fromJson(jsonDecode(e))).toList();
      originalInvoices = invoicesJson.map((e) => Invoice.fromJson(jsonDecode(e))).toList();
    });
    print("HOME-PAGE 3| selectedInvoices:");
    for (var invoice in selectedInvoices) {
      print(invoice.toDisplayString());
    }
    _getHeightForAll();
    _getWidth();
    categorizeInvoices(selectedInvoices);
  }

  void _getHeightForAll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only calculate height for page 4
      double maxHeight = 0.0;

      // Ensure page 4 has a key for height measurement
      if (!_intrinsicHeightKeys.containsKey(_currentPage)) {
        _intrinsicHeightKeys[_currentPage] = GlobalKey();
      }

      final RenderBox? renderBox =
      _intrinsicHeightKeys[_currentPage]?.currentContext?.findRenderObject() as RenderBox?;
      final categoryHeight = renderBox?.size.height ?? 0.0;

      // Check if the height is too large
      if (categoryHeight > 800) { // Example threshold (e.g., 800px)
        print('Page 4 has an unexpectedly large height: $categoryHeight');
      }

      setState(() {
        _height = categoryHeight;
      });
    });
  }

  void categorizeInvoices(List<Invoice> faturalar) {
    print("faturalar length : ${faturalar.length}");
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    // 1. Upcoming Invoice Date (those with PeriodDate before today)
    upcomingInvoices = faturalar.where((invoice) {
      print("AJAX1");
      DateTime periodDate = DateTime.parse(invoice.periodDate);
      return periodDate.isAfter(today);
    }).toList();

    // 2. Invoice Day (with PeriodDate today)
    todayInvoices = faturalar.where((invoice) {
      print("AJAX2");
      DateTime periodDate = DateTime.parse(invoice.periodDate);
      return periodDate.day == today.day && periodDate.month == today.month && periodDate.year == today.year;
    }).toList();

    // 3. Approaching Due Date (those with DueDate data and this date is before today)
    approachingDueInvoices = faturalar.where((invoice) {
      print("AJAX3");
      if (invoice.dueDate!= null) {
        DateTime periodDate = DateTime.parse(invoice.periodDate!);
        DateTime dueDate = DateTime.parse(invoice.dueDate!);
        return periodDate.isBefore(today) && today.isBefore(dueDate);
      }
      return false;
    }).toList();

    // 4. Payment Due Date (those with DueDate data and this date is today)
    paymentDueInvoices = faturalar.where((invoice) {
      print("AJAX4");
      if (invoice.dueDate!= null) {
        DateTime dueDate = DateTime.parse(invoice.dueDate!);
        return dueDate.day == today.day && dueDate.month == today.month && dueDate.year == today.year;
      }
      return false;
    }).toList();

    // 5. Overdue Invoices (Invoices with DueDate data that are overdue or invoices without DueDate data but with an overdue PeriodDate)
    overdueInvoices = faturalar.where((invoice) {
      print("AJAX");
      if (invoice.dueDate != null) {
        DateTime periodDate = DateTime.parse(invoice.periodDate!);
        DateTime dueDate = DateTime.parse(invoice.dueDate!);
        return dueDate.isBefore(today) && periodDate.isBefore(today);
      } else if (invoice.dueDate == null){
        DateTime periodDate = DateTime.parse(invoice.periodDate!);
        return periodDate.isBefore(today);
      }
      return false;
    }).toList();

    print("upcomingInvoices:${upcomingInvoices.length}\n"
        "todayInvoices:${todayInvoices.length}\n"
        "approachingDueInvoices:${approachingDueInvoices.length}\n"
        "paymentDueInvoices:${paymentDueInvoices.length}\n"
        "overdueInvoices:${overdueInvoices.length}");
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
      if (dueDate != null && currentDate.isAfter(DateTime.parse(periodDate))) {
        diff = (DateTime.parse(dueDate!).difference(currentDate).inDays + 1).toString();
        return diff;
      } else {
        return "error1";
      }
    } else {
      return "error2";
    }
  }

  Future<void> _saveInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final invoicesJson = originalInvoices.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('invoices', invoicesJson);
  }

  void payInvoice(Invoice invoice, int id, String periodDate, String? dueDate) async {
    for (var invoice in originalInvoices) {
      print("IPA01\n${invoice.toDisplayString()}");
    }
    for (var invoice in selectedInvoices) {
      print("IPA02\n${invoice.toDisplayString()}");
    }
    int index = originalInvoices.indexWhere((invoice) => invoice.id == id);
    int index2 = selectedInvoices.indexWhere((invoice) => invoice.id == id);
    // Debugging: Check the indices
    print('Index in originalInvoices: $index');
    print('Index in selectedInvoices: $index2');
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
        print("The delete has been confirmed. Current diff is : ${diff} while period date is now : ${stringPeriodDate}");
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
        // Debugging: Print the updated invoice details
        print('Updated Invoice: ${updatedInvoice.toString()}');
        originalInvoices[index] = updatedInvoice;
        selectedInvoices[index2] = updatedInvoice;
        // Debugging: Verify the update
        print('Updated originalInvoices at index $index: ${originalInvoices[index].name}');
        print('Updated selectedInvoices at index $index2: ${selectedInvoices[index2].name}');
        categorizeInvoices(selectedInvoices);
        _saveInvoices();
        _getHeight(_currentPage); // Recalculate height
        widget.onReload; // UPDATE THE WIDGET BY CALLING _LOAD FUNCTION OF HOMEPAGESTATE
      });
    }
  }

  void _getHeight(int categoryIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
      _intrinsicHeightKeys[categoryIndex]?.currentContext?.findRenderObject() as RenderBox?;
      setState(() {
        _height = renderBox?.size.height;
        _widthIntrinsic = renderBox?.size.width;
      });
    });
  }

  void _getWidth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
      _scrollWidthKey.currentContext?.findRenderObject() as RenderBox?;
      setState(() {
        _width = (renderBox?.size.width ?? 0.0) - (_widthIntrinsic ?? 0.0);
      });
    });
  }

  Widget buildIndicator(int itemCount, int currentIndex) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
          // Swiped left
          if (_currentPage < itemCount - 1) {
            setState(() {
              _currentPage++;
            });
          } else {
            setState(() {
              _currentPage = 0;
            });
          }
        } else if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          // Swiped right
          if (_currentPage > 0) {
            setState(() {
              _currentPage--;
            });
          } else {
            setState(() {
              _currentPage = itemCount - 1;
            });
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2), // Highlight color for the touchable area
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: IntrinsicWidth(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(itemCount, (index) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (currentIndex % itemCount == index)
                      ? Color.fromARGB(125, 0, 149, 30)
                      : Colors.grey,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  String getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return "Fatura Tarihi Yaklaşan";
      case 1:
        return "Fatura Günü";
      case 2:
        return "Son Ödeme Tarihi Yaklaşan";
      case 3:
        return "Son Ödeme Günü";
      case 4:
        return "Tarihi Geçmiş Faturalar";
      default:
        return "null";
    }
  }

  @override
  Widget build(BuildContext context) {
    _getHeightForAll();
    List<List<Invoice>> categorizedInvoices = [
      upcomingInvoices,
      todayInvoices,
      approachingDueInvoices,
      paymentDueInvoices,
      overdueInvoices
    ];
    double width = _width ?? 0.0;
    double _dragDistance = 0.0; // To track the drag distance
    final double _dragThreshold = 50.0; // Set your desired threshold
    selectedInvoices = categorizedInvoices[_currentPage];
    // If no key exists for the category, create one
    if (!_intrinsicHeightKeys.containsKey(_currentPage)) {
      _intrinsicHeightKeys[_currentPage] = GlobalKey();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            getTitleForIndex(_currentPage),
            style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        IntrinsicHeight(
          key: _intrinsicHeightKeys[_currentPage],
          child: selectedInvoices.isEmpty
              ? GestureDetector(
            onHorizontalDragUpdate: (details) {
              // Update the drag distance
              _dragDistance += details.primaryDelta ?? 0;

              // Check if the drag exceeds the threshold to change the page
              if (_dragDistance > _dragThreshold) {
                // Swiped right (moving to previous page)
                setState(() {
                  _currentPage--;
                  if (_currentPage < 0) {
                    _currentPage = 0; // Ensure it doesn't go below the first page
                  }
                });
                _dragDistance = 0; // Reset the drag distance
              } else if (_dragDistance < -_dragThreshold) {
                // Swiped left (moving to next page)
                setState(() {
                  _currentPage++;
                  if (_currentPage >= 5) {
                    _currentPage = 0; // Wrap around to the first page if exceeded
                  }
                });
                _dragDistance = 0; // Reset the drag distance
              }
            },
            onHorizontalDragEnd: (details) {
              // Reset the drag distance when the drag ends
              _dragDistance = 0;
            },

            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, // Allow vertical scrolling
              child: Container(
                height: _height,
                child: Center(
                  child: Text('Add Sample Invoice'),
                ),
              ),
            ),
          )
              : NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                double currentOffset = scrollNotification.metrics.pixels;
                width = selectedInvoices.length == 1 ? 20 : width;
                print("currentOffset : $currentOffset");
                print("selectedInvoices.length : ${selectedInvoices.length}");
                if (currentOffset < width) {
                  setState(() {
                    _showRightArrow = false;
                    _rightArrowOpacity = 0.0;
                  });
                } else if (currentOffset >= width && currentOffset < (width + 90)) {
                  setState(() {
                    _showRightArrow = true;
                    _rightArrowOpacity = (currentOffset - width) / ((width + 90) - width);
                  });
                } else if (currentOffset >= (width + 90)) {
                  setState(() {
                    _showRightArrow = true;
                    _rightArrowOpacity = 1.0;
                  });
                }

                if (currentOffset < 0) {
                  if (currentOffset > -100) {
                    // User is scrolling to the left but not beyond -100
                    setState(() {
                      _showLeftArrow = true;
                      _leftArrowOpacity = (currentOffset.abs()) / 100;
                    });
                  } else if (currentOffset <= -100 && !_isTouching) {
                    // User has scrolled more than -100, go to the last page (4)
                    if (_currentPage == 0) {
                      setState(() {
                        _currentPage = 4;
                        _showLeftArrow = false;
                      });
                    } else {
                      setState(() {
                        _currentPage--;
                        _showLeftArrow = false;
                      });
                    }
                  }
                }


                if (_rightArrowOpacity == 1.0 && !_isTouching) {
                  int nextPage = (_currentPage + 1) % categorizedInvoices.length;
                  if (_currentPage != nextPage) {
                    setState(() {
                      _currentPage = nextPage;
                      _showRightArrow = false;
                    });
                  }
                }
              }
              return false;
            },
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                setState(() {
                  _isTouching = true; // User started touching the screen
                });
              },
              onPointerUp: (event) {
                setState(() {
                  _isTouching = false; // User stopped touching the screen
                });
              },
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      key: _scrollWidthKey,
                      children: selectedInvoices.length == 1
                          ? [
                        // Add extra width to the container if there is only one InvoiceCard
                        SizedBox(width: (_widthIntrinsic != null ? (_widthIntrinsic! - 200.w) / 2 : 0)),

                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 50, 0),
                          child: InvoiceCard(
                            invoice: selectedInvoices.first,
                            onDelete: () => payInvoice(selectedInvoices.first, selectedInvoices.first.id, selectedInvoices.first.periodDate, selectedInvoices.first.dueDate),
                            onEdit: () {
                              // Handle edit logic
                            },
                          ),
                        ),
                      ]
                          : selectedInvoices.map((invoice) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: InvoiceCard(
                            invoice: invoice,
                            onDelete: () => payInvoice(invoice, invoice.id, invoice.periodDate, invoice.dueDate),
                            onEdit: () {
                              // Handle edit logic
                            },
                          ),
                        );
                      }).toList(),
                    ),

                  ),
                  if (_showLeftArrow)
                    Positioned(
                      left:10,
                      top:((_height! / 2)-20).toDouble(),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: AnimatedOpacity(
                          opacity: _leftArrowOpacity,
                          duration: Duration(milliseconds: 300),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  if (_showRightArrow)
                    Positioned(
                      right:10,
                      top:((_height! / 2)-20).toDouble(),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: AnimatedOpacity(
                          opacity: _rightArrowOpacity,
                          duration: Duration(milliseconds: 300),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        buildIndicator(5, _currentPage),
        if (_height != null)
          Text('Height of IntrinsicHeight: ${_height!.toString()} px'),
      ],
    );
  }
}

class TransactionWidget extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Invoice> invoices;
  final DateTime? startDate;
  final DateTime? endDate;

  TransactionWidget({
    required this.transactions,
    required this.invoices,
    this.startDate,
    this.endDate,
  });
  @override
  _TransactionWidgetState createState() => _TransactionWidgetState();
}
class _TransactionWidgetState extends State<TransactionWidget> {
  Map<String, List<Map<String, dynamic>>> incomeMap = {};
  double incomeValue = 0.0;
  List<Transaction> transactions = [];
  final _formKey = GlobalKey<FormState>();
  int? editingTransactionId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _installmentController = TextEditingController();
  DateTime? selectedDate;
  String currency = 'USD';
  bool isSurplus = true;
  bool isFromInvoice = false;
  DateTime? startDate;
  DateTime? endDate;
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final ab2 = prefs.getString('incomeMap') ?? '0';
    final ab14 = prefs.getString('startDate');
    final ab15 = prefs.getString('endDate');

    if (ab2.isNotEmpty) {
      final decodedData = json.decode(ab2);
      if (decodedData is Map<String, dynamic>) {
        incomeMap = {};
        decodedData.forEach((key, value) {
          if (value is List<dynamic>) {
            incomeMap[key] = List<Map<String, dynamic>>.from(value.map((e) => Map<String, dynamic>.from(e)));
          }
        });
      }
      print('Final incomeMap: ${jsonEncode(incomeMap)}');
    }

    if (ab2 != null && ab2.isNotEmpty) {
      final decodedData = json.decode(ab2);
      if (decodedData is Map<String, dynamic>) {
        setState(() {
          incomeMap = Map<String, List<Map<String, dynamic>>>.from(decodedData);
        });
      }
    }

    if (ab14 != null && ab15 != null) {
      setState(() {
        startDate = DateTime.parse(ab14);
        endDate = DateTime.parse(ab15);
      });
    }

    // Clear the existing transactions before loading new data
    setState(() {
      transactions.clear(); // Clear the existing transaction list
    });

    List<Transaction> loadedTransactions = await TransactionService.loadTransactions();

    setState(() {
      transactions = loadedTransactions; // Update the transaction list with new data
    });
  }
  Future<void> _saveTransaction() async {
    if (_formKey.currentState?.validate() ?? false) {
      int newId = (transactions.isEmpty ? 0 : transactions.last.id) + 1;
      Transaction transaction = Transaction(
        id: newId,
        date: DateTime.now(),
        amount: double.parse(_amountController.text),
        installment: _installmentController.text.isNotEmpty
            ? int.tryParse(_installmentController.text)
            : null,
        currency: currency,
        description: _descriptionController.text,
        isSurplus: isSurplus,
        isFromInvoice: isFromInvoice,
        initialInstallmentDate: selectedDate,
      );
      if (editingTransactionId == null) {
        await TransactionService.addTransaction(transaction);
      } else {
        await TransactionService.updateTransaction(transaction);
        editingTransactionId = null;
      }
      _clearForm();
      //await _loadTransactions();
    }
  }
  Future<void> _deleteTransaction(int id) async {
    await TransactionService.deleteTransaction(id);
    //await _loadTransactions();
  }
  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
    _installmentController.clear();
    setState(() {
      currency = 'USD';
      isSurplus = true;
      selectedDate = null;
    });
  }
  void _editTransaction(Transaction transaction) {
    setState(() {
      editingTransactionId = transaction.id;
      _amountController.text = transaction.amount.toString();
      _descriptionController.text = transaction.description;
      _installmentController.text = transaction.installment?.toString() ?? '';
      currency = transaction.currency;
      isSurplus = transaction.isSurplus;
      selectedDate = transaction.initialInstallmentDate;
    });
    _showEditTransactionDialog();
  }
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }
  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Transaction'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Amount'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _installmentController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Installment (optional)'),
                  ),
                  DropdownButtonFormField<String>(
                    value: currency,
                    items: ['USD', 'EUR', 'TRY']
                        .map((currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        currency = value ?? 'USD';
                      });
                    },
                    decoration: InputDecoration(labelText: 'Currency'),
                  ),
                  Row(
                    children: [
                      Text('Surplus'),
                      Switch(
                        value: isSurplus,
                        onChanged: (value) {
                          setState(() {
                            isSurplus = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(selectedDate != null
                          ? 'Date: ${DateFormat.yMMMd().format(selectedDate!)}'
                          : 'Pick Installment Date'),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: _pickDate,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveTransaction();
                  Navigator.of(context).pop(); // Close dialog
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
  void _showEditTransactionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Transaction'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Amount'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _installmentController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Installment (optional)'),
                  ),
                  DropdownButtonFormField<String>(
                    value: currency,
                    items: ['USD', 'EUR', 'TRY']
                        .map((currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        currency = value ?? 'USD';
                      });
                    },
                    decoration: InputDecoration(labelText: 'Currency'),
                  ),
                  Row(
                    children: [
                      Text('Surplus'),
                      Switch(
                        value: isSurplus,
                        onChanged: (value) {
                          setState(() {
                            isSurplus = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(selectedDate != null
                          ? 'Date: ${DateFormat.yMMMd().format(selectedDate!)}'
                          : 'Pick Installment Date'),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: _pickDate,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Find the transaction with the editingTransactionId
                  Transaction transaction = transactions.firstWhere((transaction) => transaction.id == editingTransactionId);
                  // Update the transaction with new values
                  setState(() {
                    transaction.amount = double.parse(_amountController.text);
                    transaction.description = _descriptionController.text;
                    transaction.installment = _installmentController.text.isNotEmpty
                    ? int.tryParse(_installmentController.text)
                        : null;
                    transaction.currency = currency;
                    transaction.isSurplus = isSurplus;
                    transaction.initialInstallmentDate = selectedDate;
                  });

                  // Save the updated transaction (replace this with your save logic)
                  TransactionService.updateTransaction(transaction);
                  Navigator.of(context).pop(); // Close dialog
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> _getStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final startDateString = prefs.getString('startDate');
    if (startDateString != null) {
      return DateTime.parse(startDateString);
    }
    return null; // Return null if no start date is found
  }

  Future<DateTime?> _getEndDate() async {
    final prefs = await SharedPreferences.getInstance();
    final endDateString = prefs.getString('endDate');
    if (endDateString != null) {
      return DateTime.parse(endDateString);
    }
    return null; // Return null if no end date is found
  }

  // Function to validate and adjust the day
  DateTime _validateDay(int day, DateTime referenceDate) {
    final lastDayOfMonth = DateTime(referenceDate.year, referenceDate.month + 1, 0).day;

    // Ensure the day is within the valid range
    if (day > lastDayOfMonth) {
      day = lastDayOfMonth;
    }

    DateTime validatedDate = DateTime(referenceDate.year, referenceDate.month, day);

    // If it's Saturday (6) or Sunday (7), move to the next Monday
    if (validatedDate.weekday == DateTime.saturday) {
      validatedDate = validatedDate.add(Duration(days: 2)); // Move to Monday
    } else if (validatedDate.weekday == DateTime.sunday) {
      validatedDate = validatedDate.add(Duration(days: 1)); // Move to Monday
    }

    return validatedDate;
  }

  // Create a list of Transactions from incomeMap
  Future<List<Transaction>> _createTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    String? startDateString = prefs.getString('startDate');
    String? endDateString = prefs.getString('endDate');

    if (startDateString == null || endDateString == null) {
      print('Start date or end date is missing!');
      return [];
    }

    DateTime startDate = DateTime.parse(startDateString);
    DateTime endDate = DateTime.parse(endDateString);

    List<Transaction> transactions = [];

    print('Processing transactions from $startDate to $endDate');

    for (DateTime currentDate = startDate;
    currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate);
    currentDate = DateTime(currentDate.year, currentDate.month + 1, 1)) {

      print('Processing month: ${currentDate.month}-${currentDate.year}');

      incomeMap.forEach((key, incomeList) {
        if (incomeList == null || incomeList.isEmpty) {
          print('Skipping key: $key because it has no data');
          return;
        }

        for (var income in incomeList) {
          int day = income['day'] ?? 1;
          DateTime transactionDate = _validateDay(day, currentDate);

          if (transactionDate.isAfter(endDate)) {
            print('Skipping transaction beyond end date: $transactionDate');
            continue;
          }

          double amount = NumberFormat.decimalPattern('tr_TR').parse(income['amount'].toString()) as double;

          transactions.add(Transaction(
            id: DateTime.now().millisecondsSinceEpoch,
            date: transactionDate,
            amount: amount,
            installment: null,
            currency: 'TRY',
            description: 'Income',
            isSurplus: true,
            isFromInvoice: false,
            initialInstallmentDate: null,
          ));

          print('Added transaction: $transactionDate, Amount: $amount');
        }
      });
    }

    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<List<DateTime?>>(
          future: Future.wait([_getStartDate(), _getEndDate()]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Show a loading spinner while fetching data
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final startDate = snapshot.data?[0]; // Get the start date from the list of results
              final endDate = snapshot.data?[1];   // Get the end date from the list of results

              // Fetch transactions after the dates are loaded
              return FutureBuilder<List<Transaction>>(
                future: TransactionService.loadTransactions(),
                builder: (context, transactionsSnapshot) {
                  if (transactionsSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Show loading spinner while fetching transactions
                  } else if (transactionsSnapshot.hasError) {
                    return Text('Error: ${transactionsSnapshot.error}');
                  } else {
                    List<Transaction> transactions = transactionsSnapshot.data!;
                    return Column(
                      children: [
                        Text(startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : 'No start date'),
                        Text(endDate != null ? DateFormat('yyyy-MM-dd').format(endDate) : 'No end date'),
                        Text(
                            transactions.map((e) => e.toDisplayString()).join("\n\n")
                        ),
                        ListView(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: transactions.map((transaction) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 0),
                              child: Container(
                                child: Slidable(
                                  key: ValueKey(transaction.id),
                                  endActionPane: ActionPane(
                                    motion: DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) => _deleteTransaction(transaction.id),
                                        borderRadius: BorderRadius.circular(10),
                                        backgroundColor: Color(0xFFFE4A49),
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Delete',
                                      ),
                                      SlidableAction(
                                        onPressed: (context) => _editTransaction(transaction),
                                        borderRadius: BorderRadius.circular(10),
                                        backgroundColor: Color(0xFF21B7CA),
                                        foregroundColor: Colors.white,
                                        icon: Icons.edit,
                                        label: 'Edit',
                                      ),
                                    ],
                                  ),
                                  child: TransactionCard(transaction: transaction),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(120, 152, 255, 170),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Hareket Ekle",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16, fontWeight: FontWeight.w600)),
                                IconButton(
                                  onPressed: () => _showAddTransactionDialog(),
                                  icon: Icon(Icons.add_circle),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );

                  }
                },
              );
            }
          },
        ),
      ],
    );
  }
}