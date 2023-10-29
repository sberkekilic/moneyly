import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/pages/gelir-ekle.dart';
import 'package:moneyly/pages/selection.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'dart:math' as math;

import 'faturalar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    _load();
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
      print("ANAN!");
    }
    print("sharedPreferencesData: $sharedPreferencesData");
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
              incomeMap.values.forEach((values) {
                values.forEach((value) {
                  // Replace ',' with '.' and parse as double
                  double parsedValue = NumberFormat.decimalPattern('tr_TR').parse(value) as double;
                  sum += parsedValue;
                });
              });
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
        });
      }
      loadSharedPreferencesData(actualDesiredKeys);
    });
  }


  void removeInvoice(int index) async {
    setState(() {
      invoices.removeAt(index);
    });
    saveInvoicesToSharedPreferences();
  }

  void saveInvoicesToSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final invoicesJson = invoices.map((invoice) => jsonEncode(invoice.toJson())).toList();
    prefs.setStringList('invoices', invoicesJson);
  }

  @override
  Widget build(BuildContext context) {
    savingsValue = incomeValue * 0.2;
    wishesValue = incomeValue  * 0.3;
    needsValue = incomeValue * 0.5;
    double sumOfSubs = double.parse(sumOfTV)+double.parse(sumOfGame)+double.parse(sumOfMusic);
    double sumOfBills = double.parse(sumOfHome)+double.parse(sumOfInternet)+double.parse(sumOfPhone);
    double sumOfOthers = double.parse(sumOfRent)+double.parse(sumOfKitchen)+double.parse(sumOfCatering)+double.parse(sumOfEnt)+double.parse(sumOfOther);
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
      print("$bolumDouble $netProfit bolumDouble IF");

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
    print("$netProfitYuzdesi netProfitYuzdesi SON");
    print("${bolum} bolum SON"); // Print as an integer
    print("$incomeYuzdesi incomeYuzdesi SON");
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
                  onPressed: () {

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
              style: GoogleFonts.montserrat(color: Colors.black, fontSize: 28, fontWeight: FontWeight.normal),
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
              Text("Özet", style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Kalan',
                            style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w500
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            formattedProfitValue,
                            style: GoogleFonts.montserrat(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    LinearPercentIndicator(
                      padding: EdgeInsets.only(right: 10),
                      backgroundColor: Color(0xffc6c6c7),
                      animation: true,
                      lineHeight: 15,
                      animationDuration: 1000,
                      percent: bolum/100,
                      trailing: Text("%${((bolum/100)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                      barRadius: Radius.circular(10),
                      progressColor: Color(0xff1ab738),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Color.fromARGB(155, 26, 183, 56),
                                  child: Icon(Icons.arrow_upward, color: Colors.black, size: 16),
                                ),
                                SizedBox(width: 5),
                                Text("Gelir", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w500,)),
                              ],
                            ),
                            SizedBox(height: 7),
                            Text(
                              formattedIncomeValue,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 13,
                                  backgroundColor: Color.fromARGB(155, 26, 183, 56),
                                  child: Icon(Icons.arrow_downward, color: Colors.black, size: 16),
                                ),
                                SizedBox(width: 5),
                                Text("Gider", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            SizedBox(height: 7),
                            Text(
                              formattedOutcomeValue,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    const Divider(color: Color(0xffc6c6c7), thickness: 3, height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "Abonelikler",
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 5),
                              LinearPercentIndicator(
                                padding: EdgeInsets.zero,
                                backgroundColor: Color(0xffc6c6c7),
                                animation: true,
                                lineHeight: 12,
                                animationDuration: 1000,
                                percent: sumOfSubs/outcomeValue,
                                barRadius: Radius.circular(10),
                                progressColor: Color(0xffb71a1a),
                              ),
                              SizedBox(height: 5),
                              Text(
                                formattedSumOfSubs,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "Faturalar",
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 5),
                              LinearPercentIndicator(
                                padding: EdgeInsets.zero,
                                backgroundColor: Color(0xffc6c6c7),
                                animation: true,
                                lineHeight: 12,
                                animationDuration: 1000,
                                percent: sumOfBills/outcomeValue,
                                barRadius: Radius.circular(10),
                                progressColor: Color(0xff1a9eb7),
                              ),
                              SizedBox(height: 5),
                              Text(
                                formattedSumOfBills,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "Diğer",
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 5),
                              LinearPercentIndicator(
                                padding: EdgeInsets.zero,
                                backgroundColor: Color(0xffc6c6c7),
                                animation: true,
                                lineHeight: 12,
                                animationDuration: 1000,
                                percent: sumOfOthers/outcomeValue,
                                barRadius: Radius.circular(10),
                                progressColor: Color(0xff381ab7),
                              ),
                              SizedBox(height: 5),
                              Text(
                                formattedSumOfOthers,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
              SizedBox(height: 20),
              Text("Faturalarım", style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
              //ListView.builder(shrinkWrap: true,itemCount: invoices.length,itemBuilder: (context, index) {return Text(invoices[index].toDisplayString());},),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(invoices.length, (index) {
                          var invoice = invoices[index];
                          return Padding(
                            padding: EdgeInsets.all(10.0),
                            child: InvoiceCard(
                              invoice: invoice,
                              onDelete: () {
                                removeInvoice(index);
                              },
                            ),
                          );
                        }
                        ),
                      ),
                    ),
                  ],
                )
              ),
              SizedBox(height: 20),
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
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Color.fromARGB(255, 26, 183, 56),
              selectedLabelStyle: GoogleFonts.montserrat(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.montserrat(color: Color.fromARGB(255, 26, 183, 56), fontSize: 11, fontWeight: FontWeight.w600),
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
                    padding: EdgeInsets.only(left: 5,right: 5),
                    child: Container(
                      width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(125, 26, 183, 56), // Background color
                          borderRadius: BorderRadius.circular(20), // Rounded corners
                        ),
                        child: Icon(Icons.home, size: 30)
                    ),
                  ),
                  label: 'Ana Sayfa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.attach_money, size: 30),
                  label: 'Gelir',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.money_off, size: 30),
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

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onDelete;

  InvoiceCard({
    required this.invoice,
    required this.onDelete,
  });

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

  void formatDate2(int day) {
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

  bool isPaidActive = false;
  String difference = "";

  String getDaysRemainingMessage() {
    final currentDate = DateTime.now();
    final dueDateKnown = invoice.dueDate != null;

    if (currentDate.isBefore(faturaDonemi)) {
      isPaidActive = false;
      difference = faturaDonemi.difference(currentDate).inDays.toString();
      return "Fatura kesimine kalan gün";
    } else if (dueDateKnown) {
      isPaidActive = true;
      if (currentDate.isBefore(sonOdeme)) {
        difference = sonOdeme.difference(currentDate).inDays.toString();
        return "Son ödeme tarihine kalan gün";
      } else {
        isPaidActive = true;
        return "Ödeme için son gün";
      }
    } else {
      isPaidActive = false;
      return "Fatura dönemi";
    }
  }

  @override
  Widget build(BuildContext context) {
    formatDate(invoice.periodDate);
    formatDate2(invoice.dueDate ?? invoice.periodDate);
    final daysRemainingMessage = getDaysRemainingMessage();
    return IntrinsicWidth(
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                    invoice.name,
                  style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                    invoice.category,
                  style: GoogleFonts.montserrat(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ),
              Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
              ListTile(
                title: Text(
                    "Fatura Dönemi",
                  style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                    "${faturaDonemi.day.toString().padLeft(2, '0')}/${faturaDonemi.month.toString().padLeft(2, '0')}/${faturaDonemi.year}",
                  style: GoogleFonts.montserrat(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ),
              ListTile(
                title: Text(
                    "Son Ödeme Tarihi",
                  style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  invoice.dueDate != null ? "${sonOdeme.day.toString().padLeft(2, '0')}/${sonOdeme.month.toString().padLeft(2, '0')}/${sonOdeme.year}" : "Bilinmiyor",
                  style: GoogleFonts.montserrat(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ),
              ListTile(
                title: Text(
                    daysRemainingMessage,
                  style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal),
                ),
                subtitle: Text(
                    "\n$difference",
                  style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 12),
              InkWell(
                onTap: isPaidActive ? onDelete : null,
                child: Container(
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: isPaidActive ? Colors.black : Colors.grey,
                  ),
                  child: Center(
                    child: Text(
                      'Ödendi',
                      style: GoogleFonts.montserrat(fontSize: 18, color: Colors.white),
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