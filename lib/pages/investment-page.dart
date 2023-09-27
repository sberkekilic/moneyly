import 'dart:ui';

import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/pages/selection.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class InvestmentTypeProvider extends ChangeNotifier {
  Map<String, double?> categoryValues = {};
  List<String> selectedCategories = [];
  List<double> exchangeDepot = [];
  List<double> cashDepot = [];
  List<double> realEstateDepot = [];
  List<double> carDepot = [];
  List<double> electronicDepot = [];
  List<double> otherDepot = [];
  double totalInvestValue = 0.0;
  double sumInvestValue = 0.0;
  List<double> sumList = [];
  bool hasExchangeGoalSelected = false;
  bool hasCashGoalSelected = false;
  bool hasRealEstateGoalSelected = false;
  bool hasCarGoalSelected = false;
  bool hasElectronicGoalSelected = false;
  bool hasOtherGoalSelected = false;
  String _selectedInvestmentType = "";
  String get selectedInvestmentType => _selectedInvestmentType;
}

class InvestmentPage extends StatefulWidget {
  const InvestmentPage({Key? key}) : super(key: key);

  @override
  State<InvestmentPage> createState() => _InvestmentPageState();
}

class _InvestmentPageState extends State<InvestmentPage> {
  List<String> itemList = ["Döviz", "Nakit", "Gayrimenkül", "Araba", "Elektronik", "Diğer"];

  List<String> itemIcons = [
    'assets/currency.svg',
    'assets/cash.svg',
    'assets/real-estate.svg',
    'assets/car.svg',
    'assets/electronic.svg',
    'assets/chevron-down.svg',
  ];
  String selectedInvestmentType = "";

  List<String> selectedItems = [];
  bool isPopupVisible = false;
  String? ananim;

  void togglePopupVisibility(BuildContext context) {
    print("togglePopupVisibility");
    setState(() {
      isPopupVisible = !isPopupVisible;
    });
  }

  void addCategoryValue(String category, double value, double sum) {
    final investDataProvider = Provider.of<InvestmentTypeProvider>(context, listen: false);
    setState(() {
      investDataProvider.categoryValues[category] = value;
      investDataProvider.totalInvestValue += value;
      ananim = value.toString();
      print("categoryValues[category] ${investDataProvider.categoryValues[category]}");
    });
  }

  void removeCategory(String category, double value, double sum) {
    final investDataProvider = Provider.of<InvestmentTypeProvider>(context, listen: false);
    setState(() {
      print("sumInvestValue 1: before removeCategory ${investDataProvider.sumInvestValue}");
      investDataProvider.totalInvestValue -= value;
      investDataProvider.sumInvestValue -= sum;
      print("sumInvestValue 2: after removeCategory ${investDataProvider.sumInvestValue}");
      investDataProvider.selectedCategories.remove(category);
      investDataProvider.categoryValues.remove(category);
    });
  }

  void removeValues(List<double> a, List<double> b) {
    for (var value in b) {
      if (a.contains(value)) {
        a.remove(value);
      }
    }
  }

  void selectCategory(String category) {
    final investDataProvider = Provider.of<InvestmentTypeProvider>(context, listen: false);
    if (!investDataProvider.selectedCategories.contains(category)) {
      setState(() {
        investDataProvider.selectedCategories.add(category);
      });
    }
  }

  Widget buildCategoryButton(String category, List<String> itemIcons) {
    int index = itemList.indexOf(category);
    String iconAsset = itemIcons[index];

    return GestureDetector(
      onTap: () {
        selectCategory(category);
        togglePopupVisibility(context);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Center(
                child: ClipOval(
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: SvgPicture.asset(
                        iconAsset,
                        width: 34,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Text(
                category,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showEditDialog(String category, int categoryIndex, int index){

    final investDataProvider = Provider.of<InvestmentTypeProvider>(context, listen: false);
    TextEditingController selectedEditController = TextEditingController();

    switch (categoryIndex){
      case 1:
        TextEditingController editController = TextEditingController(text: investDataProvider.exchangeDepot[index].toString());
        selectedEditController = editController;
        break;
      case 2:
        TextEditingController editController = TextEditingController(text: investDataProvider.cashDepot[index].toString());
        selectedEditController = editController;
        break;
      case 3:
        TextEditingController editController = TextEditingController(text: investDataProvider.realEstateDepot[index].toString());
        selectedEditController = editController;
        break;
      case 4:
        TextEditingController editController = TextEditingController(text: investDataProvider.carDepot[index].toString());
        selectedEditController = editController;
        break;
      case 5:
        TextEditingController editController = TextEditingController(text: investDataProvider.electronicDepot[index].toString());
        selectedEditController = editController;
        break;
      case 6:
        TextEditingController editController = TextEditingController(text: investDataProvider.otherDepot[index].toString());
        selectedEditController = editController;
        break;
    }

    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        title: Text('Edit $category',style: TextStyle(fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(child: Text("Invest Amount", style: TextStyle(fontSize: 18),), alignment: Alignment.centerLeft,),
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
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.cancel)
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  switch (categoryIndex){
                    case 1:
                      int indexToChange = investDataProvider.sumList.indexOf(investDataProvider.exchangeDepot[index]);
                      if(indexToChange != -1){
                        investDataProvider.sumList[indexToChange] = double.parse(selectedEditController.text);
                      }
                      investDataProvider.exchangeDepot[index] = double.parse(selectedEditController.text);
                      investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                      break;
                    case 2:
                      int indexToChange = investDataProvider.sumList.indexOf(investDataProvider.cashDepot[index]);
                      if(indexToChange != -1){
                        investDataProvider.sumList[indexToChange] = double.parse(selectedEditController.text);
                      }
                      investDataProvider.cashDepot[index] = double.parse(selectedEditController.text);
                      investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                      break;
                    case 3:
                      int indexToChange = investDataProvider.sumList.indexOf(investDataProvider.realEstateDepot[index]);
                      if(indexToChange != -1){
                        investDataProvider.sumList[indexToChange] = double.parse(selectedEditController.text);
                      }
                      investDataProvider.realEstateDepot[index] = double.parse(selectedEditController.text);
                      investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                      break;
                    case 4:
                      int indexToChange = investDataProvider.sumList.indexOf(investDataProvider.carDepot[index]);
                      if(indexToChange != -1){
                        investDataProvider.sumList[indexToChange] = double.parse(selectedEditController.text);
                      }
                      investDataProvider.carDepot[index] = double.parse(selectedEditController.text);
                      investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                      break;
                    case 5:
                      int indexToChange = investDataProvider.sumList.indexOf(investDataProvider.electronicDepot[index]);
                      if(indexToChange != -1){
                        investDataProvider.sumList[indexToChange] = double.parse(selectedEditController.text);
                      }
                      investDataProvider.electronicDepot[index] = double.parse(selectedEditController.text);
                      investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                      break;
                    case 6:
                      int indexToChange = investDataProvider.sumList.indexOf(investDataProvider.otherDepot[index]);
                      if(indexToChange != -1){
                        investDataProvider.sumList[indexToChange] = double.parse(selectedEditController.text);
                      }
                      investDataProvider.otherDepot[index] = double.parse(selectedEditController.text);
                      investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                      break;
                  }
                });
                Navigator.pop(context);
              },
              icon: Icon(Icons.save)
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  switch (categoryIndex){
                    case 1:
                      int indexToDelete = investDataProvider.sumList.indexOf(investDataProvider.exchangeDepot[index]);
                      if (indexToDelete != -1) {
                        investDataProvider.sumList.removeAt(indexToDelete);
                      }
                      investDataProvider.exchangeDepot.removeAt(index);
                      investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                      break;
                    case 2:
                      int indexToDelete = investDataProvider.sumList.indexOf(investDataProvider.cashDepot[index]);
                      if (indexToDelete != -1) {
                        investDataProvider.sumList.removeAt(indexToDelete);
                      }
                      investDataProvider.cashDepot.removeAt(index);
                      investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                      break;
                    case 3:
                      int indexToDelete = investDataProvider.sumList.indexOf(investDataProvider.realEstateDepot[index]);
                      if (indexToDelete != -1) {
                        investDataProvider.sumList.removeAt(indexToDelete);
                      }
                      investDataProvider.realEstateDepot.removeAt(index);
                      investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                      break;
                    case 4:
                      int indexToDelete = investDataProvider.sumList.indexOf(investDataProvider.carDepot[index]);
                      if (indexToDelete != -1) {
                        investDataProvider.sumList.removeAt(indexToDelete);
                      }
                      investDataProvider.carDepot.removeAt(index);
                      investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                      break;
                    case 5:
                      int indexToDelete = investDataProvider.sumList.indexOf(investDataProvider.electronicDepot[index]);
                      if (indexToDelete != -1) {
                        investDataProvider.sumList.removeAt(indexToDelete);
                      }
                      investDataProvider.electronicDepot.removeAt(index);
                      investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                      break;
                    case 6:
                      int indexToDelete = investDataProvider.sumList.indexOf(investDataProvider.otherDepot[index]);
                      if (indexToDelete != -1) {
                        investDataProvider.sumList.removeAt(indexToDelete);
                      }
                      investDataProvider.otherDepot.removeAt(index);
                      investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                      break;
                  }
                  Navigator.of(context).pop();
                });
          },
              icon: Icon(Icons.delete_forever)
          )
        ],
      );
    },
    );
  }

  Widget buildSelectedCategories() {
    final investDataProvider = Provider.of<InvestmentTypeProvider>(context, listen: false);
    return Column(
      children:
      investDataProvider.selectedCategories.map((category) {
        TextEditingController textController = TextEditingController();
        final isCategoryAdded = investDataProvider.categoryValues.containsKey(category);
        double? goal = investDataProvider.categoryValues[category];
        double sum = 0.0;
        if(category == "Döviz"){
          sum = investDataProvider.exchangeDepot.isNotEmpty ? investDataProvider.exchangeDepot.reduce((a, b) => a + b) : 0.0;
        } else if(category == "Nakit"){
          sum = investDataProvider.cashDepot.isNotEmpty ? investDataProvider.cashDepot.reduce((a, b) => a + b) : 0.0;
        } else if(category == "Gayrimenkül"){
          sum = investDataProvider.realEstateDepot.isNotEmpty ? investDataProvider.realEstateDepot.reduce((a, b) => a + b) : 0.0;
        } else if(category == "Araba"){
          sum = investDataProvider.carDepot.isNotEmpty ? investDataProvider.carDepot.reduce((a, b) => a + b) : 0.0;
        } else if(category == "Elektronik"){
          sum = investDataProvider.electronicDepot.isNotEmpty ? investDataProvider.electronicDepot.reduce((a, b) => a + b) : 0.0;
        } else if(category == "Diğer"){
          sum = investDataProvider.otherDepot.isNotEmpty ? investDataProvider.otherDepot.reduce((a, b) => a + b) : 0.0;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(category, style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
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
              child: isCategoryAdded
                  ?
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$sum / ${investDataProvider.categoryValues[category]}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 19, fontWeight: FontWeight.normal)),
                  SizedBox(
                    child: LinearPercentIndicator(
                      padding: EdgeInsets.only(right: 10),
                      backgroundColor: Color(0xffc6c6c7),
                      animation: true,
                      lineHeight: 10,
                      animationDuration: 1000,
                      percent: sum / goal!,
                      trailing: Text("%${((sum / goal!)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal)),
                      barRadius: Radius.circular(10),
                      progressColor: Colors.lightBlue,
                    ),
                  ),
                  SizedBox(height: 5),
                  ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      if(category == "Döviz")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: investDataProvider.exchangeDepot.length + 1,
                              itemBuilder: (context, index) {
                                if (index < investDataProvider.exchangeDepot.length)
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              investDataProvider.exchangeDepot[index].toString(),
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              showEditDialog(category, 1, index);
                                            },
                                          ),
                                        ],
                                      ),
                                      Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$category için birikim hedefi',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          SizedBox(height: 10),
                                          TextFormField(
                                            controller: textController, // Assign the TextEditingController
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'Enter a number',
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                String inputText = textController.text; // Get the input text
                                                investValue = double.tryParse(inputText);
                                                if (investValue != null) {
                                                  investDataProvider.exchangeDepot.add(investValue!);
                                                  investDataProvider.sumList.add(investValue!);
                                                  investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                                                  Navigator.pop(context); // Close the form
                                                }
                                              });
                                            },
                                            child: Text('Add'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    "Biriktir",
                                    style: GoogleFonts.montserrat(fontSize: 20),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          removeCategory(category, goal, sum);
                                          removeValues(investDataProvider.sumList, investDataProvider.exchangeDepot);
                                          investDataProvider.exchangeDepot = [];
                                        });
                                      },
                                      icon: Icon(Icons.remove_circle_outline)
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      if(category == "Nakit")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: investDataProvider.cashDepot.length + 1,
                              itemBuilder: (context, index) {
                                if (index < investDataProvider.cashDepot.length)
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              investDataProvider.cashDepot[index].toString(),
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              showEditDialog(category, 2, index);
                                            },
                                          ),
                                        ],
                                      ),
                                      Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$category için birikim hedefi',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          SizedBox(height: 10),
                                          TextFormField(
                                            controller: textController, // Assign the TextEditingController
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'Enter a number',
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                String inputText = textController.text; // Get the input text
                                                investValue = double.tryParse(inputText);
                                                if (investValue != null) {
                                                  investDataProvider.cashDepot.add(investValue!);
                                                  investDataProvider.sumList.add(investValue!);
                                                  investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                                                  Navigator.pop(context); // Close the form
                                                }
                                              });
                                            },
                                            child: Text('Add'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    "Biriktir",
                                    style: GoogleFonts.montserrat(fontSize: 20),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          removeCategory(category, goal, sum);
                                          removeValues(investDataProvider.sumList, investDataProvider.cashDepot);
                                          investDataProvider.cashDepot = [];
                                        });
                                      },
                                      child: Text("Sil", style: GoogleFonts.montserrat(fontSize: 20),)
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      if(category == "Gayrimenkül")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: investDataProvider.realEstateDepot.length + 1,
                              itemBuilder: (context, index) {
                                if (index < investDataProvider.realEstateDepot.length)
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              investDataProvider.realEstateDepot[index].toString(),
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              showEditDialog(category, 3, index);
                                            },
                                          ),
                                        ],
                                      ),
                                      Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$category için birikim hedefi',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          SizedBox(height: 10),
                                          TextFormField(
                                            controller: textController, // Assign the TextEditingController
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'Enter a number',
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                String inputText = textController.text; // Get the input text
                                                investValue = double.tryParse(inputText);
                                                if (investValue != null) {
                                                  investDataProvider.realEstateDepot.add(investValue!);
                                                  investDataProvider.sumList.add(investValue!);
                                                  investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                                                  Navigator.pop(context); // Close the form
                                                }
                                              });
                                            },
                                            child: Text('Add'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    "Biriktir",
                                    style: GoogleFonts.montserrat(fontSize: 20),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          removeCategory(category, goal, sum);
                                          removeValues(investDataProvider.sumList, investDataProvider.realEstateDepot);
                                          investDataProvider.realEstateDepot = [];
                                        });
                                      },
                                      child: Text("Sil", style: GoogleFonts.montserrat(fontSize: 20),)
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      if(category == "Araba")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: investDataProvider.carDepot.length + 1,
                              itemBuilder: (context, index) {
                                if (index < investDataProvider.carDepot.length)
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              investDataProvider.carDepot[index].toString(),
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              showEditDialog(category, 4, index);
                                            },
                                          ),
                                        ],
                                      ),
                                      Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$category için birikim hedefi',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          SizedBox(height: 10),
                                          TextFormField(
                                            controller: textController, // Assign the TextEditingController
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'Enter a number',
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                String inputText = textController.text; // Get the input text
                                                investValue = double.tryParse(inputText);
                                                if (investValue != null) {
                                                  investDataProvider.carDepot.add(investValue!);
                                                  investDataProvider.sumList.add(investValue!);
                                                  investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                                                  Navigator.pop(context); // Close the form
                                                }
                                              });
                                            },
                                            child: Text('Add'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    "Biriktir",
                                    style: GoogleFonts.montserrat(fontSize: 20),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          removeCategory(category, goal, sum);
                                          removeValues(investDataProvider.sumList, investDataProvider.carDepot);
                                          investDataProvider.carDepot = [];
                                        });
                                      },
                                      child: Text("Sil", style: GoogleFonts.montserrat(fontSize: 20),)
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      if(category == "Elektronik")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: investDataProvider.electronicDepot.length + 1,
                              itemBuilder: (context, index) {
                                if (index < investDataProvider.electronicDepot.length)
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            fit: FlexFit.tight,
                                            child: Text(
                                              investDataProvider.electronicDepot[index].toString(),
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              showEditDialog(category, 5, index);
                                            },
                                          ),
                                        ],
                                      ),
                                      Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$category için birikim hedefi',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          SizedBox(height: 10),
                                          TextFormField(
                                            controller: textController, // Assign the TextEditingController
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'Enter a number',
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                String inputText = textController.text; // Get the input text
                                                investValue = double.tryParse(inputText);
                                                if (investValue != null) {
                                                  investDataProvider.electronicDepot.add(investValue!);
                                                  investDataProvider.sumList.add(investValue!);
                                                  investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                                                  Navigator.pop(context); // Close the form
                                                }
                                              });
                                            },
                                            child: Text('Add'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    "Biriktir",
                                    style: GoogleFonts.montserrat(fontSize: 20),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          removeCategory(category, goal, sum);
                                          removeValues(investDataProvider.sumList, investDataProvider.electronicDepot);
                                          investDataProvider.electronicDepot = [];
                                        });
                                      },
                                      child: Text("Sil", style: GoogleFonts.montserrat(fontSize: 20),)
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      if(category == "Diğer")
                      Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: investDataProvider.otherDepot.length + 1,
                          itemBuilder: (context, index) {
                            if (index < investDataProvider.otherDepot.length)
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                          flex: 1,
                                          fit: FlexFit.tight,
                                          child: Text(
                                              investDataProvider.otherDepot[index].toString(),
                                            style: GoogleFonts.montserrat(fontSize: 20),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ),
                                      SizedBox(width: 20),
                                      IconButton(
                                        splashRadius: 0.0001,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                        icon: Icon(Icons.edit, size: 21),
                                        onPressed: () {
                                          showEditDialog(category, 6, index);
                                        },
                                      ),
                                    ],
                                  ),
                                  Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                ],
                              );
                          },
                        ),
                        TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                double? investValue;
                                return Padding(
                                  padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$category için birikim hedefi',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: textController, // Assign the TextEditingController
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Enter a number',
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            String inputText = textController.text; // Get the input text
                                            investValue = double.tryParse(inputText);
                                            if (investValue != null) {
                                              investDataProvider.otherDepot.add(investValue!);
                                              investDataProvider.sumList.add(investValue!);
                                              investDataProvider.sumInvestValue = investDataProvider.sumList.isNotEmpty ? investDataProvider.sumList.reduce((a, b) => a + b) : 0.0;
                                              Navigator.pop(context); // Close the form
                                            }
                                          });
                                        },
                                        child: Text('Add'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                  "Biriktir",
                                style: GoogleFonts.montserrat(fontSize: 20),
                              ),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      removeCategory(category, goal, sum);
                                      removeValues(investDataProvider.sumList, investDataProvider.otherDepot);
                                      investDataProvider.otherDepot = [];
                                    });
                                  },
                                  child: Text("Sil", style: GoogleFonts.montserrat(fontSize: 20),)
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    ],
                  ),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hedef Ekle',
                            style: GoogleFonts.montserrat(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        double? enteredValue;
                                        return Padding(
                                          padding: EdgeInsets.fromLTRB(20,20,20,50),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Add a value for $category',
                                                style: TextStyle(fontSize: 18),
                                              ),
                                              SizedBox(height: 10),
                                              TextFormField(
                                                controller: textController,
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                  labelText: 'Enter a number',
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    String inputText = textController.text;
                                                    enteredValue = double.parse(inputText);
                                                    if (enteredValue != null) {
                                                      addCategoryValue(category, enteredValue ?? 0, sum ?? 0);
                                                      Navigator.pop(context); // Close the form
                                                    }
                                                  });
                                                },
                                                child: Text('Add'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.add_circle_outline)
                              ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      removeCategory(category, 0, 0);
                                      investDataProvider.realEstateDepot = [];
                                    });
                                  },
                                  icon: Icon(Icons.remove_circle_outline)
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {

    final page1 = Provider.of<IncomeSelections>(context, listen: false);
    final investDataProvider = Provider.of<InvestmentTypeProvider>(context, listen: false);
    double incomeValue = NumberFormat.decimalPattern('tr_TR').parse(page1.incomeValue) as double;
    print("sumInvestValue 5: before sumOfSavingValue ${investDataProvider.sumInvestValue}");
    double sumOfSavingValue = investDataProvider.sumInvestValue.isNaN ? 0.0 : investDataProvider.sumInvestValue;
    print("sumInvestValue 6: after sumOfSavingValue ${investDataProvider.sumInvestValue}");
    double savingsValue = investDataProvider.totalInvestValue.isNaN ? 0.0 : investDataProvider.totalInvestValue;
    double result = (savingsValue == 0.0) ? 0.0 : sumOfSavingValue / savingsValue;
    String formattedsavingsValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(savingsValue);
    String formattedSumOfSavingValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfSavingValue);


    return Material(
      child: Stack(
        children: [
          Consumer<InvestmentTypeProvider>(
            builder: (context, provider, _) {
              final selectedInvestmentType = provider.selectedInvestmentType;
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
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hedefler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal)),
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
                              Text("Birikim Hedefi", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 19, fontWeight: FontWeight.normal)),
                              SizedBox(height: 10),
                              Text("$formattedSumOfSavingValue / $formattedsavingsValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 19, fontWeight: FontWeight.normal)),
                              SizedBox(
                                child: LinearPercentIndicator(
                                  padding: EdgeInsets.only(right: 10),
                                  backgroundColor: Color(0xffc6c6c7),
                                  animation: true,
                                  lineHeight: 10,
                                  animationDuration: 1000,
                                  percent: result,
                                  trailing: Text("%${((result)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal)),
                                  barRadius: Radius.circular(10),
                                  progressColor: Colors.lightBlue,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text("Birikimlerinizi buraya ekleyin.", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal)),
                              SizedBox(height: 5),
                              SizedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Birikim Ekle", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal)),
                                    IconButton(
                                      onPressed: () {
                                        togglePopupVisibility(context);
                                      },
                                      icon: Icon(Icons.add_circle),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            buildSelectedCategories(),
                          ],
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
                      currentIndex: 3,
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
            },
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 500), // Duration for the animation
            top: 0,
            right: 0,
            left: 0,
            bottom: 0,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: isPopupVisible ? 5 : 0, sigmaY: isPopupVisible ? 5 : 0),
            child: AnimatedOpacity(
              opacity: isPopupVisible ? 0.7 : 0.0, // Fade in/out based on visibility
              duration: Duration(milliseconds: 500), // Duration for the opacity animation
              child: Visibility(
                visible: isPopupVisible,
                  child: Container(
                    padding: EdgeInsets.only(top: 320),
                    color: Colors.black.withOpacity(0.5), // Darkened background
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: itemList.map((category) {
                          return buildCategoryButton(category, itemIcons);
                        }).toList(),
                      )
                    ),
                ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 20,
            child: Visibility(
              visible: isPopupVisible,
              child: Center(
                  child: GestureDetector(
                    onTap: () {
                      togglePopupVisibility(context);
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 50,
                      shadows: <Shadow>[
                        Shadow(color: Colors.black, blurRadius: 10.0, offset: Offset(6, 3))
                      ],
                    ),
                  )
              )
            ),
          ),
        ],
      ),
    );
  }
}
