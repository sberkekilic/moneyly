import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/form-data-provider.dart';
import 'package:moneyly/pages/gelir-ekle.dart';
import 'package:moneyly/pages/selection.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class OutcomePage extends StatefulWidget {
  const OutcomePage({Key? key}) : super(key: key);

  @override
  State<OutcomePage> createState() => _OutcomePageState();
}

class _OutcomePageState extends State<OutcomePage> {
  int biggestIndex = 0;
  final TextEditingController textController = TextEditingController();
  final TextEditingController platformPriceController = TextEditingController();

  bool isSubsAddActive = false;
  bool hasSubsCategorySelected = false;
  // Initial Selected Value
  String dropdownvalue = 'Film, Dizi ve TV';

  // List of items in our dropdown menu
  var items = [
    'Film, Dizi ve TV',
    'Oyun',
    'Müzik',
  ];

  void _showEditDialog(BuildContext context, int index, int page, int orderIndex) {
    final formDataProvider = Provider.of<FormDataProvider>(context, listen: false);

    TextEditingController selectedEditController = TextEditingController();
    TextEditingController selectedPriceController = TextEditingController();

    if(page == 1){
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
    } else if (page == 2){
      switch (orderIndex) {
        case 1:
          TextEditingController editController =
          TextEditingController(text: formDataProvider.homeBillsTitleList[index]);
          TextEditingController priceController =
          TextEditingController(text: formDataProvider.homeBillsPriceList[index]);
          selectedEditController = editController;
          selectedPriceController = priceController;
          break;
        case 2:
          TextEditingController NDeditController =
          TextEditingController(text: formDataProvider.internetTitleList[index]);
          TextEditingController NDpriceController =
          TextEditingController(text: formDataProvider.internetPriceList[index]);
          selectedEditController = NDeditController;
          selectedPriceController = NDpriceController;
          break;
        case 3:
          TextEditingController RDeditController =
          TextEditingController(text: formDataProvider.phoneTitleList[index]);
          TextEditingController RDpriceController =
          TextEditingController(text: formDataProvider.phonePriceList[index]);
          selectedEditController = RDeditController;
          selectedPriceController = RDpriceController;
          break;
      }
    } else if (page == 3){
      switch (orderIndex) {
        case 1:
          TextEditingController editController =
          TextEditingController(text: formDataProvider.rentTitleList[index]);
          TextEditingController priceController =
          TextEditingController(text: formDataProvider.rentPriceList[index]);
          selectedEditController = editController;
          selectedPriceController = priceController;
          break;
        case 2:
          TextEditingController NDeditController =
          TextEditingController(text: formDataProvider.kitchenTitleList[index]);
          TextEditingController NDpriceController =
          TextEditingController(text: formDataProvider.kitchenPriceList[index]);
          selectedEditController = NDeditController;
          selectedPriceController = NDpriceController;
          break;
        case 3:
          TextEditingController RDeditController =
          TextEditingController(text: formDataProvider.cateringTitleList[index]);
          TextEditingController RDpriceController =
          TextEditingController(text: formDataProvider.cateringPriceList[index]);
          selectedEditController = RDeditController;
          selectedPriceController = RDpriceController;
          break;
        case 4:
          TextEditingController THeditController =
          TextEditingController(text: formDataProvider.entertainmentTitleList[index]);
          TextEditingController THpriceController =
          TextEditingController(text: formDataProvider.entertainmentPriceList[index]);
          selectedEditController = THeditController;
          selectedPriceController = THpriceController;
          break;
        case 5:
          TextEditingController otherEditController =
          TextEditingController(text: formDataProvider.otherTitleList[index]);
          TextEditingController otherPriceController =
          TextEditingController(text: formDataProvider.otherPriceList[index]);
          selectedEditController = otherEditController;
          selectedPriceController = otherPriceController;
          break;
      }
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
                  if(page == 1){
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
                  } else if (page == 2){
                    switch (orderIndex){
                      case 1:
                        formDataProvider.homeBillsTitleList[index] = selectedEditController.text;
                        formDataProvider.homeBillsPriceList[index] = selectedPriceController.text;
                        break;
                      case 2:
                        formDataProvider.internetTitleList[index] = selectedEditController.text;
                        formDataProvider.internetPriceList[index] = selectedPriceController.text;
                        break;
                      case 3:
                        formDataProvider.phoneTitleList[index] = selectedEditController.text;
                        formDataProvider.phonePriceList[index] = selectedPriceController.text;
                        break;
                    }
                  } else if (page == 3){
                    switch (orderIndex){
                      case 1:
                        formDataProvider.rentTitleList[index] = selectedEditController.text;
                        formDataProvider.rentPriceList[index] = selectedPriceController.text;
                        break;
                      case 2:
                        formDataProvider.kitchenTitleList[index] = selectedEditController.text;
                        formDataProvider.kitchenPriceList[index] = selectedPriceController.text;
                        break;
                      case 3:
                        formDataProvider.cateringTitleList[index] = selectedEditController.text;
                        formDataProvider.cateringPriceList[index] = selectedPriceController.text;
                        break;
                      case 4:
                        formDataProvider.entertainmentTitleList[index] = selectedEditController.text;
                        formDataProvider.entertainmentPriceList[index] = selectedPriceController.text;
                        break;
                      case 5:
                        formDataProvider.otherTitleList[index] = selectedEditController.text;
                        formDataProvider.otherPriceList[index] = selectedPriceController.text;
                        break;
                    }
                  }
                });
                Navigator.pop(context);
              },

              child: Text('Save'),
            ),
            TextButton(
                onPressed: () {
                  setState(() {
                    if(page == 1){
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
                    } else if (page == 2){
                      switch (orderIndex){
                        case 1:
                          TextEditingController priceController =
                          TextEditingController(text: formDataProvider.homeBillsPriceList[index]);
                          formDataProvider.homeBillsTitleList.removeAt(index);
                          formDataProvider.homeBillsPriceList.removeAt(index);
                          priceController.clear();
                          break;
                        case 2:
                          TextEditingController NDpriceController =
                          TextEditingController(text: formDataProvider.internetPriceList[index]);
                          formDataProvider.internetTitleList.removeAt(index);
                          formDataProvider.internetPriceList.removeAt(index);
                          NDpriceController.clear();
                          break;
                        case 3:
                          TextEditingController RDpriceController =
                          TextEditingController(text: formDataProvider.phonePriceList[index]);
                          formDataProvider.phoneTitleList.removeAt(index);
                          formDataProvider.phonePriceList.removeAt(index);
                          RDpriceController.clear();
                          break;
                      }
                    } else if (page == 3){
                      switch (orderIndex){
                        case 1:
                          TextEditingController priceController =
                          TextEditingController(text: formDataProvider.rentPriceList[index]);
                          formDataProvider.rentTitleList.removeAt(index);
                          formDataProvider.rentPriceList.removeAt(index);
                          priceController.clear();
                          break;
                        case 2:
                          TextEditingController NDpriceController =
                          TextEditingController(text: formDataProvider.kitchenPriceList[index]);
                          formDataProvider.kitchenTitleList.removeAt(index);
                          formDataProvider.kitchenPriceList.removeAt(index);
                          NDpriceController.clear();
                          break;
                        case 3:
                          TextEditingController RDpriceController =
                          TextEditingController(text: formDataProvider.cateringPriceList[index]);
                          formDataProvider.cateringTitleList.removeAt(index);
                          formDataProvider.cateringPriceList.removeAt(index);
                          RDpriceController.clear();
                          break;
                        case 4:
                          TextEditingController THpriceController =
                          TextEditingController(text: formDataProvider.entertainmentPriceList[index]);
                          formDataProvider.entertainmentTitleList.removeAt(index);
                          formDataProvider.entertainmentPriceList.removeAt(index);
                          THpriceController.clear();
                          break;
                        case 5:
                          TextEditingController otherPriceController =
                          TextEditingController(text: formDataProvider.otherPriceList[index]);
                          formDataProvider.otherTitleList.removeAt(index);
                          formDataProvider.otherPriceList.removeAt(index);
                          otherPriceController.clear();
                          break;
                      }
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
    double sumhome = 0.0;
    for(String price in formDataProvider.homeBillsPriceList){
      sumhome += double.parse(price);
    }
    double suminternet = 0.0;
    for(String price in formDataProvider.internetPriceList){
      suminternet += double.parse(price);
    }
    double sumphone = 0.0;
    for(String price in formDataProvider.phonePriceList){
      sumphone += double.parse(price);
    }
    double sumrent = 0.0;
    for(String price in formDataProvider.rentPriceList){
      sumrent += double.parse(price);
    }
    double sumkitchen = 0.0;
    for(String price in formDataProvider.kitchenPriceList){
      sumkitchen += double.parse(price);
    }
    double sumcatering = 0.0;
    for(String price in formDataProvider.cateringPriceList){
      sumcatering += double.parse(price);
    }
    double sument = 0.0;
    for(String price in formDataProvider.entertainmentPriceList){
      sument += double.parse(price);
    }
    double sumother = 0.0;
    for(String price in formDataProvider.otherPriceList){
      sumother += double.parse(price);
    }
    String convertSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum);
    formDataProvider.sumOfTV = convertSum;
    String convertSum2 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumoyun);
    formDataProvider.sumOfGaming = convertSum2;
    String convertSum3 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(summuzik);
    formDataProvider.sumOfMusic = convertSum3;
    String convertSum21 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumhome);
    formDataProvider.sumOfHomeBills = convertSum21;
    String convertSum22 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(suminternet);
    formDataProvider.sumOfInternet = convertSum22;
    String convertSum23 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumphone);
    formDataProvider.sumOfPhone = convertSum23;
    String convertSum31 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumrent);
    formDataProvider.sumOfRent = convertSum31;
    String convertSum32 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumkitchen);
    formDataProvider.sumOfKitchen = convertSum32;
    String convertSum33 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumcatering);
    formDataProvider.sumOfCatering = convertSum33;
    String convertSum34 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sument);
    formDataProvider.sumOfEntertainment = convertSum34;
    String convertSum35 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumother);
    formDataProvider.sumOfOther = convertSum35;
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
                    ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        if(formDataProvider.tvTitleList.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("TV", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                            Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
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
                                              _showEditDialog(context, index, 1, 1); // Show the edit dialog
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
                          ],
                        ),
                        if(formDataProvider.gamingTitleList.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Gaming", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
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
                                              _showEditDialog(context, index, 1, 2); // Show the edit dialog
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
                          ],
                        ),
                        if(formDataProvider.musicTitleList.isNotEmpty)
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Music", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
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
                                              _showEditDialog(context, index, 1, 3); // Show the edit dialog
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
                          ],
                        ),
                        if(!isSubsAddActive)
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Abonelik Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isSubsAddActive = true;
                                  });
                                },
                                icon: Icon(Icons.add_circle),
                              ),
                            ],
                          ),
                        ),
                        if(isSubsAddActive)
                          Container(
                            child:DropdownButton(
                              value: dropdownvalue,
                              icon:Icon(Icons.keyboard_arrow_down),
                              items: items.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownvalue = newValue!;
                                  isSubsAddActive = true;
                                  hasSubsCategorySelected = true;
                                });
                              },
                            )
                          ),
                        if(hasSubsCategorySelected)
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: textController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'ABA',
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: platformPriceController,
                                  keyboardType: TextInputType.number, // Show numeric keyboard
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'GAG',
                                  ),
                                ),
                              ),
                              Wrap(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      final text = textController.text.trim();
                                      final priceText = platformPriceController.text.trim();
                                      if (text.isNotEmpty && priceText.isNotEmpty && dropdownvalue == "Film, Dizi ve TV") {
                                        double dprice = double.tryParse(priceText) ?? 0.0;
                                        String price = dprice.toStringAsFixed(2);
                                        setState(() {
                                          formDataProvider.updateTextValue(text, 2, 1);
                                          formDataProvider.updateNumberValue(price, 2, 1);
                                          //isEditingList = false; // Add a corresponding entry for the new item
                                          textController.clear();
                                          formDataProvider.notifyListeners();
                                          platformPriceController.clear();
                                          formDataProvider.notifyListeners();
                                          //isTextFormFieldVisible = false;
                                          isSubsAddActive = false;
                                          hasSubsCategorySelected = false;
                                        });
                                      } else if (text.isNotEmpty && priceText.isNotEmpty && dropdownvalue == "Oyun") {
                                        double dprice = double.tryParse(priceText) ?? 0.0;
                                        String price = dprice.toStringAsFixed(2);
                                        setState(() {
                                          formDataProvider.updateTextValue(text, 2, 2);
                                          formDataProvider.updateNumberValue(price, 2, 2);
                                          //isEditingList = false; // Add a corresponding entry for the new item
                                          textController.clear();
                                          formDataProvider.notifyListeners();
                                          platformPriceController.clear();
                                          formDataProvider.notifyListeners();
                                          //isTextFormFieldVisible = false;
                                          isSubsAddActive = false;
                                          hasSubsCategorySelected = false;
                                        });
                                      } else if (text.isNotEmpty && priceText.isNotEmpty && dropdownvalue == "Müzik") {
                                        double dprice = double.tryParse(priceText) ?? 0.0;
                                        String price = dprice.toStringAsFixed(2);
                                        setState(() {
                                          formDataProvider.updateTextValue(text, 2, 3);
                                          formDataProvider.updateNumberValue(price, 2, 3);
                                          //isEditingList = false; // Add a corresponding entry for the new item
                                          textController.clear();
                                          formDataProvider.notifyListeners();
                                          platformPriceController.clear();
                                          formDataProvider.notifyListeners();
                                          //isTextFormFieldVisible = false;
                                          isSubsAddActive = false;
                                          hasSubsCategorySelected = false;
                                        });
                                      }
                                    },
                                    icon: Icon(Icons.check_circle, size: 26),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        //isTextFormFieldVisible = false;
                                        isSubsAddActive = false;
                                        textController.clear();
                                        platformPriceController.clear();
                                      });
                                    },
                                    icon: Icon(Icons.cancel, size: 26),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text("Faturalar", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
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
                    Text("${formattedSumOfBills} / ${formattedOutcomeValue}", style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold)),
                    SizedBox(
                      child: LinearPercentIndicator(
                        padding: EdgeInsets.only(right: 10),
                        backgroundColor: Color(0xffc6c6c7),
                        animation: true,
                        lineHeight: 10,
                        animationDuration: 1000,
                        percent: sumOfBills/outcomeValue,
                        trailing: Text("%${((sumOfBills/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                        barRadius: Radius.circular(10),
                        progressColor: Colors.lightBlue,
                      ),
                    ),
                    SizedBox(height: 5),
                    Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                    ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: formDataProvider.homeBillsTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                          itemBuilder: (context, index) {
                            if (index < formDataProvider.homeBillsTitleList.length) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formDataProvider.homeBillsTitleList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        formDataProvider.homeBillsPriceList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      IconButton(
                                        splashRadius: 0.0001,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                        icon: Icon(Icons.edit, size: 21),
                                        onPressed: () {
                                          _showEditDialog(context, index, 2, 1); // Show the edit dialog
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
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: formDataProvider.internetTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                          itemBuilder: (context, index) {
                            if (index < formDataProvider.internetTitleList.length) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formDataProvider.internetTitleList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        formDataProvider.internetPriceList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      IconButton(
                                        splashRadius: 0.0001,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                        icon: Icon(Icons.edit, size: 21),
                                        onPressed: () {
                                          _showEditDialog(context, index, 2, 2); // Show the edit dialog
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
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: formDataProvider.phoneTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                          itemBuilder: (context, index) {
                            if (index < formDataProvider.phoneTitleList.length) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formDataProvider.phoneTitleList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        formDataProvider.phonePriceList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      IconButton(
                                        splashRadius: 0.0001,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                        icon: Icon(Icons.edit, size: 21),
                                        onPressed: () {
                                          _showEditDialog(context, index, 2, 3); // Show the edit dialog
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
                              Text("Fatura Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
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
              Text("Diğer Giderler", style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
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
                    Text("${formattedSumOfOthers} / ${formattedOutcomeValue}", style: GoogleFonts.montserrat(fontSize: 19, fontWeight: FontWeight.bold)),
                    SizedBox(
                      child: LinearPercentIndicator(
                        padding: EdgeInsets.only(right: 10),
                        backgroundColor: Color(0xffc6c6c7),
                        animation: true,
                        lineHeight: 10,
                        animationDuration: 1000,
                        percent: sumOfOthers/outcomeValue,
                        trailing: Text("%${((sumOfOthers/outcomeValue)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                        barRadius: Radius.circular(10),
                        progressColor: Colors.lightBlue,
                      ),
                    ),
                    SizedBox(height: 5),
                    Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: formDataProvider.rentTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                          itemBuilder: (context, index) {
                            if (index < formDataProvider.rentTitleList.length) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formDataProvider.rentTitleList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        formDataProvider.rentPriceList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      IconButton(
                                        splashRadius: 0.0001,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                        icon: Icon(Icons.edit, size: 21),
                                        onPressed: () {
                                          _showEditDialog(context, index, 3, 1); // Show the edit dialog
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
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: formDataProvider.kitchenTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                          itemBuilder: (context, index) {
                            if (index < formDataProvider.kitchenTitleList.length) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formDataProvider.kitchenTitleList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        formDataProvider.kitchenPriceList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      IconButton(
                                        splashRadius: 0.0001,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                        icon: Icon(Icons.edit, size: 21),
                                        onPressed: () {
                                          _showEditDialog(context, index, 3, 2); // Show the edit dialog
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
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: formDataProvider.cateringTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                          itemBuilder: (context, index) {
                            if (index < formDataProvider.cateringTitleList.length) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formDataProvider.cateringTitleList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        formDataProvider.cateringPriceList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      IconButton(
                                        splashRadius: 0.0001,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                        icon: Icon(Icons.edit, size: 21),
                                        onPressed: () {
                                          _showEditDialog(context, index, 3, 3); // Show the edit dialog
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
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: formDataProvider.entertainmentTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                          itemBuilder: (context, index) {
                            if (index < formDataProvider.entertainmentTitleList.length) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formDataProvider.entertainmentTitleList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        formDataProvider.entertainmentPriceList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      IconButton(
                                        splashRadius: 0.0001,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                        icon: Icon(Icons.edit, size: 21),
                                        onPressed: () {
                                          _showEditDialog(context, index, 3, 4); // Show the edit dialog
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
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: formDataProvider.otherTitleList.length + 1, // +1 for the "Abonelik Ekle" row
                          itemBuilder: (context, index) {
                            if (index < formDataProvider.otherTitleList.length) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formDataProvider.otherTitleList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        formDataProvider.otherPriceList[index],
                                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                      IconButton(
                                        splashRadius: 0.0001,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                        icon: Icon(Icons.edit, size: 21),
                                        onPressed: () {
                                          _showEditDialog(context, index, 3, 5); // Show the edit dialog
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
                              Text("Diğer Gider Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
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
            currentIndex: 2,
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


