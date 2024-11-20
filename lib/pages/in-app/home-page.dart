import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../blocs/income-selections.dart';
import '../add-expense/faturalar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Invoice> invoices = [];
  Map<String, List<String>> incomeMap = {};
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

  List<Invoice> upcomingInvoices = [];
  List<Invoice> todayInvoices = [];
  List<Invoice> approachingDueInvoices = [];
  List<Invoice> paymentDueInvoices = [];
  List<Invoice> overdueInvoices = [];

  List<int> daysList = List.generate(31, (index) => index + 1);
  List<int> monthsList = List.generate(12, (index) => index + 1);

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
  List<Invoice> getCurrentPageInvoices(int currentPage) {
    switch (currentPage) {
      case 0:
        return upcomingInvoices;
      case 1:
        return todayInvoices;
      case 2:
        return approachingDueInvoices;
      case 3:
        return paymentDueInvoices;
      case 4:
        return overdueInvoices;
      default:
        return [];
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
    final savedInvoicesJson = prefs.getStringList('invoices');
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
      if (ab2.isNotEmpty) {
        final decodedData = json.decode(ab2);
        if (decodedData is Map<String, dynamic>) {
          decodedData.forEach((key, value) {
            if (value is List<dynamic>) {
              incomeMap[key] = value.cast<String>();
            }
            if (incomeMap.containsKey(key) && incomeMap[key]!.isNotEmpty) {
              String valueToParse = incomeMap[selectedKey.isNotEmpty ? selectedKey : key]![0]; // Take the first (and only) string from the list
              selectedKey = key;
              incomeValue = NumberFormat.decimalPattern('tr_TR').parse(valueToParse) as double;
              double sum = 0.0;
              for (var values in incomeMap.values) {
                for (var value in values) {
                  // Replace ',' with '.' and parse as double
                  double parsedValue = NumberFormat.decimalPattern('tr_TR').parse(value) as double;
                  sum += parsedValue;
                }
              }
              incomeValue = sum;
            } else {
              incomeValue = 0.0; // Default value if the key or value is not found
            }
          });
        }
      }
      if (savedInvoicesJson != null) {
        setState(() {
          invoices = savedInvoicesJson.map((json) => Invoice.fromJson(jsonDecode(json))).toList();
          print("HOME-PAGE 3| invoices:");
          for (var invoice in invoices) {
            print(invoice.toDisplayString());
          }
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
        });
      }
      loadSharedPreferencesData(actualDesiredKeys);
    });
  }
  Future<void> saveInvoices() async {
    final invoicesCopy = invoices.toList();
    final prefs = await SharedPreferences.getInstance();
    final invoiceList = invoicesCopy.map((invoice) => invoice.toJson()).toList();
    await prefs.setStringList('invoices', invoiceList.map((invoice) => jsonEncode(invoice)).toList());
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

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    List<List<Invoice>> categorizedInvoices = [
      upcomingInvoices,
      todayInvoices,
      approachingDueInvoices,
      paymentDueInvoices,
      overdueInvoices
    ];
    List<Invoice> selectedInvoices = categorizedInvoices[_currentPage];
    savingsValue = incomeValue * 0.2;
    wishesValue = incomeValue  * 0.3;
    needsValue = incomeValue * 0.5;
    double tvSum = calculateSubcategorySum(invoices, 'TV');
    double hbSum = calculateSubcategorySum(invoices, 'Ev Faturaları');
    double rentSum = calculateSubcategorySum(invoices, 'Kira');
    double sumOfSubs = tvSum + double.parse(sumOfGame)+double.parse(sumOfMusic);
    double sumOfBills = hbSum + double.parse(sumOfInternet)+double.parse(sumOfPhone);
    double sumOfOthers = rentSum +double.parse(sumOfKitchen)+double.parse(sumOfCatering)+double.parse(sumOfEnt)+double.parse(sumOfOther);
    double outcomeValue = sumOfSubs+sumOfBills+sumOfOthers;
    double netProfit = incomeValue - outcomeValue;
    String formattedIncomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(incomeValue);
    String formattedOutcomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(outcomeValue);
    String formattedProfitValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(netProfit);
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

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Özet", style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.bold)),
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
                                  netProfit < 0 ? "-%${bolum.abs()}" : "%${bolum.abs()}",
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
                child: Column(
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
                        child: selectedInvoices.isEmpty
                            ? Center(child: Text('${getTitleForIndex(_currentPage)} sınıfına ait bir fatura bulunmuyor.'))
                            : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: selectedInvoices.map((invoice) {
                              return Padding(
                                padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                                child: InvoiceCard(
                                  invoice: invoice,
                                  onDelete: () => payInvoice(invoice, invoice.id, invoice.periodDate, invoice.dueDate),
                                  onEdit: () => showEditInvoice(invoice.id, invoice.periodDate, invoice.dueDate),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        ),
                    const SizedBox(height: 20),
                    buildIndicator(5, _currentPage),
                  ]
                ),
              ),
              const SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
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
      return "Error";
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