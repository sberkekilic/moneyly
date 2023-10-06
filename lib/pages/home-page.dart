import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/pages/gelir-ekle.dart';
import 'package:moneyly/pages/selection.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      loadSharedPreferencesData(actualDesiredKeys);
    });
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
              "Eylül 2023",
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
              Text("Özet", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
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
                  children: [
                    SizedBox(
                      child: CircularStepProgressIndicator(
                        totalSteps: 100,
                        currentStep: bolum,
                        stepSize: 10,
                        selectedStepSize: 10,
                        width: 140,
                        height: 140,
                        padding: 0,
                        circularDirection: CircularDirection.clockwise,
                        selectedColor: Color(0xff1ab738),
                        unselectedColor: Color(0xffc6c6c7),
                        roundedCap: (_, __) => true,
                        arcSize: 2 * math.pi * 0.75,
                        startingAngle: -math.pi * 1.25,
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                formattedProfitValue,
                                style: GoogleFonts.montserrat(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Kalan',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  // You can also customize other text styles here
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Column(
                            children: [
                              Text(
                                formattedIncomeValue,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text("Gelir", style: GoogleFonts.montserrat(fontSize: 16))
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Column(
                            children: [
                              Text(
                                formattedOutcomeValue,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text("Gider", style: GoogleFonts.montserrat(fontSize: 16))
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Abonelikler",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                                LinearPercentIndicator(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Color(0xffc6c6c7),
                                  animation: true,
                                  lineHeight: 10,
                                  animationDuration: 1000,
                                  percent: sumOfSubs/outcomeValue,
                                  barRadius: Radius.circular(10),
                                  progressColor: Colors.orange,
                                ),
                                Text(
                                  formattedSumOfSubs,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
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
                                    fontSize: 12,
                                  ),
                                ),
                                LinearPercentIndicator(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Color(0xffc6c6c7),
                                  animation: true,
                                  lineHeight: 10,
                                  animationDuration: 1000,
                                  percent: sumOfBills/outcomeValue,
                                  barRadius: Radius.circular(10),
                                  progressColor: Colors.orange,
                                ),
                                Text(
                                  formattedSumOfBills,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
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
                                    fontSize: 12,
                                  ),
                                ),
                                LinearPercentIndicator(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Color(0xffc6c6c7),
                                  animation: true,
                                  lineHeight: 10,
                                  animationDuration: 1000,
                                  percent: sumOfOthers/outcomeValue,
                                  barRadius: Radius.circular(10),
                                  progressColor: Colors.orange,
                                ),
                                Text(
                                  formattedSumOfOthers,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text("Gelir", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
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
                    Text("$selectedTitle Geliri", style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(formattedIncomeValue, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600)),
                    SizedBox(
                      child: LinearPercentIndicator(
                        padding: EdgeInsets.only(right: 10),
                        backgroundColor: Color(0xffc6c6c7),
                        animation: true,
                        lineHeight: 10,
                        animationDuration: 1000,
                        percent: 1,
                        trailing: Text("%100", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                        barRadius: Radius.circular(10),
                        progressColor: Colors.lightBlue,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text("Başka geliriniz bulunmamaktadır.", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.normal)),
                    Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                    Container(
                      child: Row(
                        children: [
                          CircularPercentIndicator(
                            radius: 30,
                            lineWidth: 7.0,
                            percent: 0.20,
                            center: new Text("%20",style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                            progressColor: Colors.green,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Birikim", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                              Text("0,00 / ${formattedSavingsValue}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                            ],
                          )
                        ],
                      ),
                    ),
                    Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                    Container(
                      child: Row(
                        children: [
                          CircularPercentIndicator(
                            radius: 30,
                            lineWidth: 7.0,
                            percent: 0.30,
                            center: new Text("%30", style: GoogleFonts.montserrat(color: Colors.black, fontSize:16, fontWeight: FontWeight.w600)),
                            progressColor: Colors.green,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("İstekler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                              Text("0,00 / ${formattedWishesValue}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                            ],
                          )
                        ],
                      ),
                    ),
                    Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                    Container(
                      child: Row(
                        children: [
                          CircularPercentIndicator(
                            radius: 30,
                            lineWidth: 7.0,
                            percent: 0.50,
                            center: new Text("%50",style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                            progressColor: Colors.green,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("İhtiyaçlar", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                              Text("0,00 / ${formattedNeedsValue}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text("Gider", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
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
                    Text("Tüm Giderler", style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(formattedOutcomeValue, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600)),
                    SizedBox(
                      child: LinearPercentIndicator(
                        padding: EdgeInsets.only(right: 10),
                        backgroundColor: Color(0xffc6c6c7),
                        animation: true,
                        lineHeight: 10,
                        animationDuration: 1000,
                        percent: 1,
                        trailing: Text("%100", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                        barRadius: Radius.circular(10),
                        progressColor: Colors.purple,
                      ),
                    ),
                    Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                    Container(
                      child: Row(
                        children: [
                          CircularPercentIndicator(
                            radius: 30,
                            lineWidth: 7.0,
                            percent: sumOfSubs/outcomeValue,
                            center: new Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                            progressColor: Colors.green,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Abonelikler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                              Text("${formattedSumOfSubs} / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                            ],
                          )
                        ],
                      ),
                    ),
                    Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                    Container(
                      child: Row(
                        children: [
                          CircularPercentIndicator(
                            radius: 30,
                            lineWidth: 7.0,
                            percent: sumOfBills/outcomeValue,
                            center: new Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfBills/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                            progressColor: Colors.green,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Faturalar", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                              Text("${formattedSumOfBills} / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                            ],
                          )
                        ],
                      ),
                    ),
                    Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                    Container(
                      child: Row(
                        children: [
                          CircularPercentIndicator(
                            radius: 30,
                            lineWidth: 7.0,
                            percent: sumOfOthers/outcomeValue,
                            center: new Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfOthers/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                            progressColor: Colors.green,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Diğer Giderler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                              Text("${formattedSumOfOthers} / $formattedOutcomeValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600))
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: GoogleFonts.montserrat(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.montserrat(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 30),
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
                icon: Icon(Icons.star, size: 30),
                label: 'İstekler',
              )
            ],
          ),
        ),
      ),
    );
  }
}
