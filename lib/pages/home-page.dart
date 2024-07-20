import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/pages/page6.dart';
import 'package:moneyly/pages/selection.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'faturalar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PersistentTabController _controller;
  List<double> pageHeights = [403, 150, 100, 50];
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

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _pageController = PageController(initialPage: _currentPage);
    pageHeights = List.filled(4, 200.0);
    Future.delayed(Duration.zero, () {
      calculatePageHeights(context);
    });
    _load();
  }

  List<Widget> _buildScreens() {
    return [
      Container(color: Colors.red), // Replace with your pages
      Container(color: Colors.green),
      Container(color: Colors.blue),
      Container(color: Colors.yellow),
    ];
  }
  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.looks_one),
        title: "One",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.looks_two),
        title: "Two",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.looks_3),
        title: "Three",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.looks_4),
        title: "Four",
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  List<Invoice> upcomingInvoices = [];
  List<Invoice> dueDateInvoices = [];
  List<Invoice> lastDayInvoices = [];
  List<Invoice> otherInvoices = [];

  List<Invoice> getInvoicesForIndex(int index) {
    switch (index) {
      case 0:
        return upcomingInvoices;
      case 1:
        return dueDateInvoices;
      case 2:
        return lastDayInvoices;
      case 3:
        return otherInvoices;
      default:
        return [];
    }
  }
  String getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return "Yaklaşan Faturalar";
      case 1:
        return "Son Ödeme Tarihi Yaklaşan";
      case 2:
        return "Ödeme İçin Son Gün";
      case 3:
        return "Ödeme Dönemi";
      default:
        return "null";
    }
  }
  Widget buildInvoiceListView(BuildContext context, int index) {
    List<Invoice> invoices = getInvoicesForIndex(index);
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              var invoice = invoices[index];
              double height = 550;// Adjust index to cycle through pageHeights list
              return SizedBox(
                height: height,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InvoiceCard(
                    invoices: invoices,
                    invoice: invoice,
                    onDelete: () {
                      setState(() {
                        invoices.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            },
          )
        ),
      ],
    );
  }
  Future<void> calculatePageHeights(BuildContext context) async {
    pageHeights = [];

    for (int index = 0; index < 4; index++) {
      double maxHeight = 0.0;
      List<Invoice> invoices = getInvoicesForIndex(index);

      await Future.wait(
        invoices.map((invoice) async {
          final cardHeight = await calculateCardHeight(invoice, context);
          maxHeight = maxHeight < cardHeight ? cardHeight : maxHeight;
        }),
      );

      double height = maxHeight + 21.0; // Add padding
      print('Page $index height: $height');
      pageHeights.add(height);
    }
  }
  Future<double> calculateCardHeight(Invoice invoice, BuildContext context) async {
    Completer<double> cardHeightCompleter = Completer<double>();
    final card = Builder(
      builder: (BuildContext context) {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          cardHeightCompleter.complete(renderBox.size.height);
        });

        return InvoiceCard(
            invoice: invoice,
            onDelete: () {},
            invoices: getInvoicesForIndex(0)
        ); // Update with appropriate index
      },
    );

    // To force the widget to be built for measurement
    Overlay.of(context)!.context.findRenderObject()!.markNeedsLayout();

    return cardHeightCompleter.future;
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
          DateTime currentDate = DateTime.now(); // Recalculates the difference data for current date and save the invoice
          setState(() {
            invoices.forEach((invoice) {
              invoice.updateDifference(currentDate);
            });

            invoices.sort((a, b) {
              int differenceA = int.parse(a.difference);
              int differenceB = int.parse(b.difference);
              return differenceA.compareTo(differenceB);
            });

            final invoiceJsonList = invoices.map((invoice) => jsonEncode(invoice.toJson())).toList();
            prefs.setStringList('invoices', invoiceJsonList);

          });
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
  String getDaysRemainingMessage(Invoice invoice, String faturaDonemi, String? sonOdeme) {
    final currentDate = DateTime.now();
    final dueDateKnown = invoice.dueDate != null;
    if (currentDate.isBefore(DateTime.parse(faturaDonemi))) {
      invoice.difference = DateTime.parse(faturaDonemi).difference(currentDate).inDays.toString();
      return invoice.difference;
    } else if (dueDateKnown) {
      if (currentDate.isBefore(DateTime.parse(sonOdeme!))) {
        invoice.difference = DateTime.parse(sonOdeme).difference(currentDate).inDays.toString();
        return invoice.difference;
      } else {
        return invoice.difference;
      }
    } else {
      return invoice.difference;
    }
  }
  void editInvoice(int id, String periodDate, String? dueDate) {
    int index = invoices.indexWhere((invoice) => invoice.id == id);
    if (index != -1) {
      setState(() {
        final invoice = invoices[index];
        String diff = getDaysRemainingMessage(invoice, invoice.periodDate, invoice.dueDate);
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
  void removeInvoice(Invoice invoice, int index, String periodDate, String? dueDate) async {
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
                confirmDelete = true;
                Navigator.of(context).pop();
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
        String diff = getDaysRemainingMessage(invoice, stringPeriodDate, stringDueDate);
        final updatedInvoice = Invoice(
            id: invoice.id,
            price: invoice.price,
            subCategory: invoice.subCategory,
            category: invoice.category,
            name: invoice.name,
            periodDate: stringPeriodDate,
            dueDate: stringDueDate,
            difference: diff
        );
        invoices[index] = updatedInvoice;
        saveInvoices();
      });
      saveInvoicesToSharedPreferences();
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

  PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    _pageController.animateToPage(
      _currentPage + 1,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _previousPage() {
    _pageController.animateToPage(
      _currentPage - 1,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
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
        bolum = (bolumDouble * 100).toInt();
        netProfit = incomeValue * bolumDouble;
      } else {
        // Handle the case where bolumDouble is Infinity or NaN
        bolum = 0; // or any other appropriate value
      }
    } else {
      bolum = 0; // Handle the case where incomeValue is 0
    }
    String formattedBolum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(bolum);
    String currentDate = DateFormat('dd MMMM yyyy').format(DateTime.now());
    incomeYuzdesi = incomeYuzdesi*10;
    // Print as an integer

    String getDaysRemainingMessage(Invoice invoice) {
      final currentDate = DateTime.now();
      final dueDateKnown = invoice.dueDate != null;

      if (currentDate.isBefore(DateTime.parse(invoice.periodDate))) {
        return "Fatura kesimine kalan gün";
      } else if (dueDateKnown) {
        final periodDate = DateTime.parse(invoice.periodDate);
        final dueDate = DateTime.parse(invoice.dueDate!);

        if (currentDate.isBefore(dueDate) && currentDate.isAfter(periodDate)) {
          return "Son ödeme tarihine kalan gün";
        } else if (currentDate.day == dueDate.day && currentDate.month == dueDate.month && currentDate.year == dueDate.year) {
          return "Ödeme için son gün";
        }
      } else if (currentDate.day == DateTime.parse(invoice.periodDate).day && currentDate.month == DateTime.parse(invoice.periodDate).month && currentDate.year == DateTime.parse(invoice.periodDate).year) {
        return "Ödeme dönemi";
      }

      return "Error";
    }

    for (var invoice in invoices) {
      if (getDaysRemainingMessage(invoice) == "Fatura kesimine kalan gün") {
        upcomingInvoices.add(invoice);
      } else if (getDaysRemainingMessage(invoice) == "Son ödeme tarihine kalan gün") {
        dueDateInvoices.add(invoice);
      } else if (getDaysRemainingMessage(invoice) == "Ödeme için son gün") {
        lastDayInvoices.add(invoice);
      } else if (getDaysRemainingMessage(invoice) == "Ödeme dönemi") {
        otherInvoices.add(invoice);
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff0f0f1),
        elevation: 0,
        toolbarHeight: 50.h,
        automaticallyImplyLeading: false,
        leadingWidth: 30,
        title: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CategoryScroll()),
                    );
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
              currentDate,
              style: GoogleFonts.montserrat(color: Colors.black, fontSize: 24.sp, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Özet", style: GoogleFonts.montserrat(fontSize: 24.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 20.h),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Kalan',
                          style: GoogleFonts.montserrat(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          formattedProfitValue, // KALAN BİLGİSİ
                          style: GoogleFonts.montserrat(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                    LinearPercentIndicator(
                      padding: const EdgeInsets.only(right: 10),
                      backgroundColor: const Color(0xffc6c6c7),
                      animation: true,
                      lineHeight: 7.h,
                      animationDuration: 1000,
                      percent: bolum/100,
                      trailing: Text("%${((bolum/100)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                      barRadius: const Radius.circular(10),
                      progressColor: const Color(0xff1ab738),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const CircleAvatar(
                                    radius: 13,
                                    backgroundColor: Color.fromARGB(255, 184, 248, 197),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const CircleAvatar(
                                    radius: 13,
                                    backgroundColor: Color.fromARGB(255, 184, 248, 197),
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
                        )
                      ],
                    ),
                    Divider(color: Color(0xffc6c6c7), thickness: 3, height: 30.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Abonelikler",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.h),
                              LinearPercentIndicator(
                                padding: EdgeInsets.zero,
                                backgroundColor: const Color(0xffc6c6c7),
                                animation: true,
                                lineHeight: 6.h,
                                animationDuration: 1000,
                                percent: sumOfSubs/outcomeValue,
                                barRadius: const Radius.circular(10),
                                progressColor: const Color(0xffb71a1a),
                              ),
                              SizedBox(height: 5.h),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  formattedSumOfSubs,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20.w),
                        Expanded(
                          child: Column(
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Faturalar",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.h),
                              LinearPercentIndicator(
                                padding: EdgeInsets.zero,
                                backgroundColor: const Color(0xffc6c6c7),
                                animation: true,
                                lineHeight: 6.h,
                                animationDuration: 1000,
                                percent: sumOfBills/outcomeValue,
                                barRadius: const Radius.circular(10),
                                progressColor: const Color(0xff1a9eb7),
                              ),
                              SizedBox(height: 5.h),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  formattedSumOfBills,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20.w),
                        Expanded(
                          child: Column(
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Diğer",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.h),
                              LinearPercentIndicator(
                                padding: EdgeInsets.zero,
                                backgroundColor: const Color(0xffc6c6c7),
                                animation: true,
                                lineHeight: 6.h,
                                animationDuration: 1000,
                                percent: sumOfOthers/outcomeValue,
                                barRadius: const Radius.circular(10),
                                progressColor: const Color(0xff381ab7),
                              ),
                              SizedBox(height: 5.h),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  formattedSumOfOthers,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Text("Faturalarım", style: GoogleFonts.montserrat(fontSize: 24.sp, fontWeight: FontWeight.bold)),
              //ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), itemCount: invoices.length,itemBuilder: (context, index) {return Text(invoices[index].toDisplayString());},),
              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
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
                  children: [
                    Text(
                      getTitleForIndex(_currentPage),
                      style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 347.h, // Adjust height as needed
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return buildInvoiceListView(context, index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20)
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(10)
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed, // Set the type to shifting
            selectedItemColor: const Color.fromARGB(255, 26, 183, 56),
            selectedLabelStyle: GoogleFonts.montserrat(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.montserrat(color: const Color.fromARGB(255, 26, 183, 56), fontSize: 11, fontWeight: FontWeight.w600),
            currentIndex: 0,
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
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(125, 26, 183, 56), // Background color
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                    ),
                    child: const Icon(Icons.home, size: 30),
                  ),
                ),
                label: 'Ana Sayfa',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.attach_money, size: 30),
                label: 'Gelir',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.money_off, size: 30),
                label: 'Gider',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.trending_up, size: 30),
                label: 'Yatırım',
              ),
              const BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: Icon(FontAwesome.bank, size: 20),
                ),
                label: 'İstekler',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvoiceCard extends StatelessWidget {
  final List<Invoice> invoices;
  Invoice invoice;
  final VoidCallback onDelete;

  InvoiceCard({super.key,
    required this.invoices,
    required this.invoice,
    required this.onDelete,
  }) {
    faturaDonemi = DateTime.parse(invoice.periodDate);
    if (invoice.dueDate != null){
      print("dueDate:${invoice.dueDate!}");
      sonOdeme = DateTime.parse(invoice.dueDate!);
    }
  }

  DateTime faturaDonemi = DateTime.now();
  DateTime sonOdeme = DateTime.now();
  bool isPaidActive = false;

  Future<void> saveInvoices() async {
    final invoicesCopy = invoices.toList();
    final prefs = await SharedPreferences.getInstance();
    final invoiceList = invoicesCopy.map((invoice) => invoice.toJson()).toList();
    await prefs.setStringList('invoices', invoiceList.map((invoice) => jsonEncode(invoice)).toList());
  }

  String getDaysRemainingMessage() {
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
    final daysRemainingMessage = getDaysRemainingMessage();
    return IntrinsicWidth(
      child: Container(
        width: 200.w,
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
            ListTile(
              title: Text(
                invoice.name,
                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                invoice.category,
                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.normal),
              ),
            ),
            Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20.h),
            ListTile(
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
              title: Text(
                "Son Ödeme Tarihi",
                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                invoice.dueDate ?? "Bilinmiyor",
                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.normal),
              ),
            ),
            ListTile(
              title: Text(
                daysRemainingMessage,
                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.normal),
              ),
              subtitle: daysRemainingMessage != "Ödeme dönemi" ? Text(
                invoice.difference,
                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ) : null,
            ),
            SizedBox(height: 12.h),
            InkWell(
              onTap: isPaidActive ? onDelete : null,
              child: Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  color: isPaidActive ? Colors.black : Colors.grey,
                ),
                child: Center(
                  child: Text(
                    'Ödendi',
                    style: GoogleFonts.montserrat(fontSize: 18.sp, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}