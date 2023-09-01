import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/form-data-provider.dart';
import 'package:moneyly/pages/gelir-ekle.dart';
import 'package:moneyly/pages/selection.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final page1 = Provider.of<IncomeSelections>(context, listen: false);
    String incomeType = "";
    if (page1.selectedOption == SelectedOption.Is){
      incomeType = "İş";
    } else if (page1.selectedOption == SelectedOption.Burs){
      incomeType = "Burs";
    } else if (page1.selectedOption == SelectedOption.Emekli){
      incomeType = "Emekli";
    }
    final formDataProvider = Provider.of<FormDataProvider>(context, listen: false);
    double incomeValue = NumberFormat.decimalPattern('tr_TR').parse(page1.incomeValue) as double;
    double sumOfTV = NumberFormat.decimalPattern('tr_TR').parse(formDataProvider.sumOfTV) as double;
    double sumOfGaming = NumberFormat.decimalPattern('tr_TR').parse(formDataProvider.sumOfGaming) as double;
    double sumOfMusic = NumberFormat.decimalPattern('tr_TR').parse(formDataProvider.sumOfMusic) as double;
    double sumOfHomeBills = NumberFormat.decimalPattern('tr_TR').parse(formDataProvider.sumOfHomeBills) as double;
    double sumOfInternet = NumberFormat.decimalPattern('tr_TR').parse(formDataProvider.sumOfInternet) as double;
    double sumOfPhone = NumberFormat.decimalPattern('tr_TR').parse(formDataProvider.sumOfPhone) as double;
    double sumOfRent = NumberFormat.decimalPattern('tr_TR').parse(formDataProvider.sumOfRent) as double;
    double sumOfKitchen = NumberFormat.decimalPattern('tr_TR').parse(formDataProvider.sumOfKitchen) as double;
    double sumOfCatering = NumberFormat.decimalPattern('tr_TR').parse(formDataProvider.sumOfCatering) as double;
    double sumOfEnt= NumberFormat.decimalPattern('tr_TR').parse(formDataProvider.sumOfEntertainment) as double;
    double sumOfOther = NumberFormat.decimalPattern('tr_TR').parse(formDataProvider.sumOfOther) as double;
    double sumOfSubs = sumOfTV+sumOfGaming+sumOfMusic;
    double sumOfBills = sumOfHomeBills+sumOfInternet+sumOfPhone;
    double sumOfOthers = sumOfRent+sumOfKitchen+sumOfCatering+sumOfEnt+sumOfOther;
    double outcomeValue = sumOfSubs+sumOfBills+sumOfOthers;
    double netProfit = incomeValue - outcomeValue;
    String formattedIncomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(incomeValue);
    String formattedOutcomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(outcomeValue);
    String formattedProfitValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(netProfit);
    String formattedSumOfSubs = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfSubs);
    String formattedSumOfBills = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfBills);
    String formattedSumOfOthers = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfOthers);

    int incomeYuzdesi = incomeValue.toInt() ~/ 100;
    int netProfitYuzdesi = netProfit.toInt() ~/ 100;
    double bolum = netProfit.toInt()/incomeValue.toInt();
    if (netProfit.toInt() % incomeValue.toInt() != 0){
      bolum = double.parse(bolum.toStringAsFixed(2));
      netProfit = incomeValue.toInt()*bolum;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff0f0f1),
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
                  icon: Icon(Icons.settings, color: Colors.black), // Replace with the desired left icon
                ),
                IconButton(
                  onPressed: () {

                  },
                  icon: Icon(Icons.person, color: Colors.black), // Replace with the desired right icon
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
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Özet", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
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
                            totalSteps: incomeYuzdesi,
                            currentStep: netProfitYuzdesi,
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
                ],
              ),
            ),
            Text("Gelir", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
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
                        Text("${incomeType} Geliri", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        SizedBox(
                          child: LinearPercentIndicator(
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
                        SizedBox(height: 10),
                        Text("${formattedIncomeValue} / ${formattedIncomeValue}", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
                        Divider(color: Color(0xffc6c6c7), thickness: 2),
                        Container(
                          child: Row(
                            children: [
                              CircularPercentIndicator(
                                radius: 30,
                                lineWidth: 7.0,
                                percent: 0.90,
                                center: new Text("90%"),
                                progressColor: Colors.green,
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
          ],
        ),
      ),
    );

  }
}
