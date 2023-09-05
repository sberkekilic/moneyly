import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/form-data-provider.dart';
import 'package:moneyly/pages/gelir-ekle.dart';
import 'package:moneyly/pages/selection.dart';
import 'package:multi_circular_slider/multi_circular_slider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class OutcomePage extends StatefulWidget {
  const OutcomePage({Key? key}) : super(key: key);

  @override
  State<OutcomePage> createState() => _OutcomePageState();
}

class _OutcomePageState extends State<OutcomePage> {

  int _currentIndex = 1;
  int biggestIndex = 0;

  void _showEditDialog(BuildContext context, int index, int orderIndex) {
    final formDataProvider = Provider.of<FormDataProvider>(context, listen: false);

    TextEditingController selectedEditController = TextEditingController();
    TextEditingController selectedPriceController = TextEditingController();

    switch (orderIndex) {
      case 1:
        TextEditingController editController =
        TextEditingController(text: formDataProvider.tvTitleList[index]);
        TextEditingController priceController =
        TextEditingController(text: formDataProvider.tvPriceList[index]);
        selectedEditController = editController;
        selectedPriceController = priceController;
        break;
      case 2:
        TextEditingController NDeditController =
        TextEditingController(text: formDataProvider.gamingTitleList[index]);
        TextEditingController NDpriceController =
        TextEditingController(text: formDataProvider.gamingPriceList[index]);
        selectedEditController = NDeditController;
        selectedPriceController = NDpriceController;
        break;
      case 3:
        TextEditingController RDeditController =
        TextEditingController(text: formDataProvider.musicTitleList[index]);
        TextEditingController RDpriceController =
        TextEditingController(text: formDataProvider.musicPriceList[index]);
        selectedEditController = RDeditController;
        selectedPriceController = RDpriceController;
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          title: Text('Edit Item',style: TextStyle(fontSize: 20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(child: Text("Item", style: TextStyle(fontSize: 18),), alignment: Alignment.centerLeft,),
              SizedBox(height: 10),
              TextFormField(
                controller: selectedEditController,
                decoration: InputDecoration(
                  isDense: true,
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(width: 3, color: Colors.black)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 3, color: Colors.black), // Use the same border style for enabled state
                  ),
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                ),
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Align(child: Text("Price",style: TextStyle(fontSize: 18)), alignment: Alignment.centerLeft),
              SizedBox(height: 10),
              TextFormField(
                controller: selectedPriceController,
                decoration: InputDecoration(
                  isDense: true,
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(width: 3, color: Colors.black)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 3, color: Colors.black), // Use the same border style for enabled state
                  ),
                  contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                ),
                style: TextStyle(fontSize: 20),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  switch (orderIndex){
                    case 1:
                      formDataProvider.tvTitleList[index] = selectedEditController.text;
                      formDataProvider.tvPriceList[index] = selectedPriceController.text;
                      break;
                    case 2:
                      formDataProvider.gamingTitleList[index] = selectedEditController.text;
                      formDataProvider.gamingPriceList[index] = selectedPriceController.text;
                      break;
                    case 3:
                      formDataProvider.musicTitleList[index] = selectedEditController.text;
                      formDataProvider.musicPriceList[index] = selectedPriceController.text;
                      break;
                  }
                });
                Navigator.pop(context);
              },

              child: Text('Save'),
            ),
            TextButton(
                onPressed: () {
                  setState(() {
                    switch (orderIndex){
                      case 1:
                        TextEditingController priceController =
                        TextEditingController(text: formDataProvider.tvPriceList[index]);
                        formDataProvider.tvTitleList.removeAt(index);
                        formDataProvider.tvPriceList.removeAt(index);
                        priceController.clear();
                        break;
                      case 2:
                        TextEditingController NDpriceController =
                        TextEditingController(text: formDataProvider.gamingPriceList[index]);
                        formDataProvider.gamingTitleList.removeAt(index);
                        formDataProvider.gamingPriceList.removeAt(index);
                        NDpriceController.clear();
                        break;
                      case 3:
                        TextEditingController RDpriceController =
                        TextEditingController(text: formDataProvider.musicPriceList[index]);
                        formDataProvider.musicTitleList.removeAt(index);
                        formDataProvider.musicPriceList.removeAt(index);
                        RDpriceController.clear();
                        break;
                    }
                    Navigator.of(context).pop();
                  });
                },
                child: Text("Remove"))
          ],
        );
      },
    );
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
    double sum = 0.0;
    for(String price in formDataProvider.tvPriceList){
      sum += double.parse(price);
    }
    double sumoyun = 0.0;
    for(String price in formDataProvider.gamingPriceList){
      sumoyun += double.parse(price);
    }
    double summuzik = 0.0;
    for(String price in formDataProvider.musicPriceList){
      summuzik += double.parse(price);
    }
    String convertSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum);
    formDataProvider.sumOfTV = convertSum;
    String convertSum2 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumoyun);
    formDataProvider.sumOfGaming = convertSum2;
    String convertSum3 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(summuzik);
    formDataProvider.sumOfMusic = convertSum3;
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
    double savingsValue = incomeValue*0.2;
    double wishesValue = incomeValue*0.3;
    double needsValue = incomeValue*0.5;
    double sumOfSubs = sumOfTV+sumOfGaming+sumOfMusic;
    double sumOfBills = sumOfHomeBills+sumOfInternet+sumOfPhone;
    double sumOfOthers = sumOfRent+sumOfKitchen+sumOfCatering+sumOfEnt+sumOfOther;
    double outcomeValue = sumOfSubs+sumOfBills+sumOfOthers;
    double subsPercent = sumOfSubs/outcomeValue;
    double billsPercent = sumOfBills/outcomeValue;
    double othersPercent = sumOfOthers/outcomeValue;
    List<double> percentages = [subsPercent, billsPercent, othersPercent];
    print("First List: $percentages");
    Map<String, double> variableMap = {
      'subsPercent': subsPercent,
      'billsPercent': billsPercent,
      'othersPercent': othersPercent,
    };
    percentages.sort();
    String smallestVariable = variableMap.keys.firstWhere((key) => variableMap[key] == percentages[0]);
    String mediumVariable = variableMap.keys.firstWhere((key) => variableMap[key] == percentages[1]);
    String largestVariable = variableMap.keys.firstWhere((key) => variableMap[key] == percentages[2]);

    print("Biggest value: ${percentages[2]} $largestVariable");
    print("Medium value: ${percentages[1]} $mediumVariable");
    print("Smallest value: ${percentages[0]} $smallestVariable");

    percentages.sort((a, b) => b.compareTo(a),);
    print("Original List: $percentages");
    percentages[0] = 1.0;
    print("Modified List: $percentages");
    String formattedIncomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(incomeValue);
    String formattedOutcomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(outcomeValue);
    String formattedsavingsValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(savingsValue);
    String formattedwishesValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(wishesValue);
    String formattedneedsValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(needsValue);
    String formattedSumOfSubs = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfSubs);
    String formattedSumOfBills = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfBills);
    String formattedSumOfOthers = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfOthers);

    Color smallestColor = Color(0xFFFFD700);
    Color mediumColor = Color(0xFFFFA500);
    Color biggestColor = Color(0xFFFF8C00);

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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(20,0,20,20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Giderler Detayı", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
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
                    Text("Tüm Giderler", style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text(formattedOutcomeValue, style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.w600)),
                    SizedBox(height: 10),
                    Stack(
                      children: [
                        LinearPercentIndicator(
                          padding: EdgeInsets.zero,
                          percent: percentages[0],
                          backgroundColor: Colors.transparent,
                          progressColor: Color(0xFFFF8C00),
                          lineHeight: 10,
                          barRadius: Radius.circular(10),
                        ),
                        LinearPercentIndicator(
                          padding: EdgeInsets.zero,
                          percent: percentages[1]+percentages[2],
                          progressColor: Color(0xFFFFA500),
                          backgroundColor: Colors.transparent,
                          lineHeight: 10,
                          barRadius: Radius.circular(10),
                        ),
                        LinearPercentIndicator(
                          padding: EdgeInsets.zero,
                          percent: percentages[2],
                          progressColor: Color(0xFFFFD700),
                          backgroundColor: Colors.transparent,
                          lineHeight: 10,
                          barRadius: Radius.circular(10),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                    if (largestVariable == "subsPercent" && mediumVariable == "billsPercent")
                      Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              CircularPercentIndicator(
                                radius: 30,
                                lineWidth: 7.0,
                                percent: sumOfOthers/outcomeValue,
                                center: new Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                progressColor: smallestColor,
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
                        Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                        Container(
                          child: Row(
                            children: [
                              CircularPercentIndicator(
                                radius: 30,
                                lineWidth: 7.0,
                                percent: sumOfBills/outcomeValue,
                                center: new Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                progressColor: mediumColor,
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
                                percent: sumOfSubs/outcomeValue,
                                center: Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                progressColor: biggestColor,
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
                      ],
                    ),
                    if (largestVariable == "subsPercent" && mediumVariable == "othersPercent")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfBills/outcomeValue,
                                  center: new Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: smallestColor,
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
                                  center: new Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: mediumColor,
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
                          Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfSubs/outcomeValue,
                                  center: Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: biggestColor,
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
                        ],
                      ),
                    if (largestVariable == "billsPercent" && mediumVariable == "subsPercent")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfOthers/outcomeValue,
                                  center: new Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: smallestColor,
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
                          Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfSubs/outcomeValue,
                                  center: Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: mediumColor,
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
                                  center: new Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: biggestColor,
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
                        ],
                      ),
                    if (largestVariable == "billsPercent" && mediumVariable == "othersPercent")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfSubs/outcomeValue,
                                  center: Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: smallestColor,
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
                                  percent: sumOfOthers/outcomeValue,
                                  center: new Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: mediumColor,
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
                          Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfBills/outcomeValue,
                                  center: new Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: biggestColor,
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
                        ],
                      ),
                    if (largestVariable == "othersPercent" && mediumVariable == "subsPercent")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfBills/outcomeValue,
                                  center: new Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: smallestColor,
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
                                  percent: sumOfSubs/outcomeValue,
                                  center: Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: mediumColor,
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
                                  percent: sumOfOthers/outcomeValue,
                                  center: new Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: biggestColor,
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
                    if (largestVariable == "othersPercent" && mediumVariable == "billsPercent")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfSubs/outcomeValue,
                                  center: Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: smallestColor,
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
                                  center: new Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: mediumColor,
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
                                  center: new Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: biggestColor,
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
                    if (largestVariable == mediumVariable && mediumVariable == smallestVariable)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 30,
                                  lineWidth: 7.0,
                                  percent: sumOfSubs/outcomeValue,
                                  center: Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: smallestColor,
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
                                  center: new Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: mediumColor,
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
                                  center: new Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}",style: GoogleFonts.montserrat(color: Colors.black, fontSize: (sumOfSubs/outcomeValue)*100 == 100 ? 12 : 16, fontWeight: FontWeight.w600)),
                                  progressColor: biggestColor,
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
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text("Abonelikler", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
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
                    Text("Abonelik Harcamaları", style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("${formattedSumOfSubs} / ${formattedOutcomeValue}", style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold)),
                    SizedBox(
                      child: LinearPercentIndicator(
                        padding: EdgeInsets.only(right: 10),
                        backgroundColor: Color(0xffc6c6c7),
                        animation: true,
                        lineHeight: 10,
                        animationDuration: 1000,
                        percent: sumOfSubs/outcomeValue,
                        trailing: Text("%${((sumOfSubs/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                        barRadius: Radius.circular(10),
                        progressColor: Colors.lightBlue,
                      ),
                    ),
                    SizedBox(height: 5),
                    Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                    ListView(
                      shrinkWrap: true,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: formDataProvider.tvTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                          itemBuilder: (context, index) {
                            if (index < formDataProvider.tvTitleList.length) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formDataProvider.tvTitleList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        formDataProvider.tvPriceList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      IconButton(
                                        splashRadius: 0.0001,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                        icon: Icon(Icons.edit, size: 21),
                                        onPressed: () {
                                          _showEditDialog(context, index, 1); // Show the edit dialog
                                        },
                                      ),
                                    ],
                                  ),
                                  Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                ],
                              );
                            }
                          },
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: formDataProvider.gamingTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                          itemBuilder: (context, index) {
                            if (index < formDataProvider.gamingTitleList.length) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formDataProvider.gamingTitleList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        formDataProvider.gamingPriceList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      IconButton(
                                        splashRadius: 0.0001,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                        icon: Icon(Icons.edit, size: 21),
                                        onPressed: () {
                                          _showEditDialog(context, index, 2); // Show the edit dialog
                                        },
                                      ),
                                    ],
                                  ),
                                  Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                ],
                              );
                            }
                          },
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: formDataProvider.musicTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                          itemBuilder: (context, index) {
                            if (index < formDataProvider.musicTitleList.length) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formDataProvider.musicTitleList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        formDataProvider.musicPriceList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      IconButton(
                                        splashRadius: 0.0001,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                        icon: Icon(Icons.edit, size: 21),
                                        onPressed: () {
                                          _showEditDialog(context, index, 3); // Show the edit dialog
                                        },
                                      ),
                                    ],
                                  ),
                                  Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                ],
                              );
                            }
                          },
                        ),
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Abonelik Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
                              IconButton(
                                onPressed: () {
                                  // Handle the "Abonelik Ekle" button click here
                                },
                                icon: Icon(Icons.add_circle),
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text("İstekler", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
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
                    Text("İstekler Hedefi", style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("0,00 / ${formattedwishesValue}", style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold)),
                    SizedBox(
                      child: LinearPercentIndicator(
                        padding: EdgeInsets.only(right: 10),
                        backgroundColor: Color(0xffc6c6c7),
                        animation: true,
                        lineHeight: 10,
                        animationDuration: 1000,
                        percent: 0,
                        trailing: Text("%0", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                        barRadius: Radius.circular(10),
                        progressColor: Colors.lightBlue,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text("İstekleriniz bu sınırı geçmesin.", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.normal)),
                    Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Gider Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
                          IconButton(
                              onPressed: () {

                              },
                              icon: Icon(Icons.add_circle)
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text("İhtiyaçlar", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
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
                    Text("İhtiyaçlar Hedefi", style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("0,00 / ${formattedneedsValue}", style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold)),
                    SizedBox(
                      child: LinearPercentIndicator(
                        padding: EdgeInsets.only(right: 10),
                        backgroundColor: Color(0xffc6c6c7),
                        animation: true,
                        lineHeight: 10,
                        animationDuration: 1000,
                        percent: 0,
                        trailing: Text("%0", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                        barRadius: Radius.circular(10),
                        progressColor: Colors.lightBlue,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text("Temel ihtiyaçlarınız bu sınırı aşmasın.", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.normal)),
                    Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Gider Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
                          IconButton(
                              onPressed: () {

                              },
                              icon: Icon(Icons.add_circle)
                          )
                        ],
                      ),
                    )
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
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), // Adjust as needed
            topRight: Radius.circular(10), // Adjust as needed
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), // Adjust as needed
            topRight: Radius.circular(10), // Adjust as needed
          ),
          child: BottomNavigationBar(
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });

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
                  Navigator.pushNamed(context, 'page5');
                  break;
              }
            },
            type: BottomNavigationBarType.fixed,
            items: [
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
              ),
            ],
          ),
        ),
      ),
    );
  }

}


