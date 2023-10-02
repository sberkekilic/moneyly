import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Map<String, double?> categoryValues = {};
  List<String> selectedItems = [];
  List<String> selectedCategories = [];
  List<double> exchangeDepot = [];
  List<double> cashDepot = [];
  List<double> realEstateDepot = [];
  List<double> carDepot = [];
  List<double> electronicDepot = [];
  List<double> otherDepot = [];
  List<double> sumList = [];
  bool hasExchangeGoalSelected = false;
  bool hasCashGoalSelected = false;
  bool hasRealEstateGoalSelected = false;
  bool hasCarGoalSelected = false;
  bool hasElectronicGoalSelected = false;
  bool hasOtherGoalSelected = false;
  bool isPopupVisible = false;
  String ananim = "";
  String formattedsavingsValue = "";
  String formattedSumOfSavingValue = "";

  Future<void> togglePopupVisibility(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isPopupVisible = !isPopupVisible;
      prefs.setBool('isPopupVisible', isPopupVisible);
    });
  }

  Future<void> addCategoryValue(String category, double value, double sum) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      categoryValues[category] = value;
      totalInvestValue += value;
      ananim = value.toString();
      prefs.setDouble('totalInvestValue', totalInvestValue);
      prefs.setString('ananim', ananim);
      final jsonMap = jsonEncode(categoryValues);
      prefs.setString('categoryValues', jsonMap);
    });
  }

  Future<void> removeCategory(String category, double value, double sum) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalInvestValue -= value;
      print("sumInvestValue 1: before removeCategory ${sumInvestValue}");
      sumInvestValue -= sum;
      print("sumInvestValue 2: after removeCategory ${sumInvestValue}");
      selectedCategories.remove(category);
      categoryValues.remove(category);
      prefs.setDouble('totalInvestValue', totalInvestValue);
      prefs.setDouble('sumInvestValue', sumInvestValue);
      prefs.setStringList('selectedCategories', selectedCategories);
      final jsonMap = jsonEncode(categoryValues);
      prefs.setString('categoryValues', jsonMap);
    });
  }

  void removeValues(List<double> a, List<double> b) {
    for (var value in b) {
      if (a.contains(value)) {
        a.remove(value);
      }
    }
  }

  Future<void> selectCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    if (!selectedCategories.contains(category)) {
      setState(() {
        selectedCategories.add(category);
        prefs.setStringList('selectedCategories', selectedCategories);
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
              const SizedBox(width: 15),
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

    TextEditingController selectedEditController = TextEditingController();

    switch (categoryIndex){
      case 1:
        TextEditingController editController = TextEditingController(text: exchangeDepot[index].toString());
        selectedEditController = editController;
        break;
      case 2:
        TextEditingController editController = TextEditingController(text: cashDepot[index].toString());
        selectedEditController = editController;
        break;
      case 3:
        TextEditingController editController = TextEditingController(text: realEstateDepot[index].toString());
        selectedEditController = editController;
        break;
      case 4:
        TextEditingController editController = TextEditingController(text: carDepot[index].toString());
        selectedEditController = editController;
        break;
      case 5:
        TextEditingController editController = TextEditingController(text: electronicDepot[index].toString());
        selectedEditController = editController;
        break;
      case 6:
        TextEditingController editController = TextEditingController(text: otherDepot[index].toString());
        selectedEditController = editController;
        break;
    }

    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        title: Text('Edit $category',style: const TextStyle(fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(alignment: Alignment.centerLeft,child: Text("Invest Amount", style: TextStyle(fontSize: 18),),),
            const SizedBox(height: 10),
            TextFormField(
              controller: selectedEditController,
              decoration: InputDecoration(
                isDense: true,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(width: 3, color: Colors.black)
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(width: 3, color: Colors.black), // Use the same border style for enabled state
                ),
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              ),
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.cancel)
          ),
          IconButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                setState(() {
                  switch (categoryIndex){
                    case 1:
                      int indexToChange = sumList.indexOf(exchangeDepot[index]);
                      if(indexToChange != -1){
                        sumList[indexToChange] = double.parse(selectedEditController.text);
                      }
                      exchangeDepot[index] = double.parse(selectedEditController.text);
                      sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                      final exchangeDepotJson = jsonEncode(exchangeDepot);
                      prefs.setDouble('sumInvestValue', sumInvestValue);
                      prefs.setString('exchangeDepot', exchangeDepotJson);
                      final sumListJson = jsonEncode(sumList);
                      prefs.setString('sumList', sumListJson);
                      break;
                    case 2:
                      int indexToChange = sumList.indexOf(cashDepot[index]);
                      if(indexToChange != -1){
                        sumList[indexToChange] = double.parse(selectedEditController.text);
                      }
                      cashDepot[index] = double.parse(selectedEditController.text);
                      sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                      final cashDepotJson = jsonEncode(cashDepot);
                      prefs.setDouble('sumInvestValue', sumInvestValue);
                      prefs.setString('cashDepot', cashDepotJson);
                      final sumListJson = jsonEncode(sumList);
                      prefs.setString('sumList', sumListJson);
                      break;
                    case 3:
                      int indexToChange = sumList.indexOf(realEstateDepot[index]);
                      if(indexToChange != -1){
                        sumList[indexToChange] = double.parse(selectedEditController.text);
                      }
                      realEstateDepot[index] = double.parse(selectedEditController.text);
                      sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                      final realEstateDepotJson = jsonEncode(realEstateDepot);
                      prefs.setDouble('sumInvestValue', sumInvestValue);
                      prefs.setString('realEstateDepot', realEstateDepotJson);
                      final sumListJson = jsonEncode(sumList);
                      prefs.setString('sumList', sumListJson);
                      break;
                    case 4:
                      int indexToChange = sumList.indexOf(carDepot[index]);
                      if(indexToChange != -1){
                        sumList[indexToChange] = double.parse(selectedEditController.text);
                      }
                      carDepot[index] = double.parse(selectedEditController.text);
                      sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                      final carDepotJson = jsonEncode(carDepot);
                      prefs.setDouble('sumInvestValue', sumInvestValue);
                      prefs.setString('carDepot', carDepotJson);
                      final sumListJson = jsonEncode(sumList);
                      prefs.setString('sumList', sumListJson);
                      break;
                    case 5:
                      int indexToChange = sumList.indexOf(electronicDepot[index]);
                      if(indexToChange != -1){
                        sumList[indexToChange] = double.parse(selectedEditController.text);
                      }
                      electronicDepot[index] = double.parse(selectedEditController.text);
                      sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                      final electronicDepotJson = jsonEncode(electronicDepot);
                      prefs.setDouble('sumInvestValue', sumInvestValue);
                      prefs.setString('electronicDepot', electronicDepotJson);
                      final sumListJson = jsonEncode(sumList);
                      prefs.setString('sumList', sumListJson);
                      break;
                    case 6:
                      int indexToChange = sumList.indexOf(otherDepot[index]);
                      if(indexToChange != -1){
                        sumList[indexToChange] = double.parse(selectedEditController.text);
                      }
                      otherDepot[index] = double.parse(selectedEditController.text);
                      sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                      final otherDepotJson = jsonEncode(otherDepot);
                      prefs.setDouble('sumInvestValue', sumInvestValue);
                      prefs.setString('otherDepot', otherDepotJson);
                      final sumListJson = jsonEncode(sumList);
                      prefs.setString('sumList', sumListJson);
                      break;
                  }
                });
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save)
          ),
          IconButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                setState(() {
                  switch (categoryIndex){
                    case 1:
                      int indexToDelete = sumList.indexOf(exchangeDepot[index]);
                      if (indexToDelete != -1) {
                        sumList.removeAt(indexToDelete);
                      }
                      exchangeDepot.removeAt(index);
                      sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                      final exchangeDepotJson = jsonEncode(exchangeDepot);
                      prefs.setDouble('sumInvestValue', sumInvestValue);
                      prefs.setString('exchangeDepot', exchangeDepotJson);
                      final sumListJson = jsonEncode(sumList);
                      prefs.setString('sumList', sumListJson);
                      break;
                    case 2:
                      int indexToDelete = sumList.indexOf(cashDepot[index]);
                      if (indexToDelete != -1) {
                        sumList.removeAt(indexToDelete);
                      }
                      cashDepot.removeAt(index);
                      sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                      final cashDepotJson = jsonEncode(cashDepot);
                      prefs.setDouble('sumInvestValue', sumInvestValue);
                      prefs.setString('cashDepot', cashDepotJson);
                      final sumListJson = jsonEncode(sumList);
                      prefs.setString('sumList', sumListJson);
                      break;
                    case 3:
                      int indexToDelete = sumList.indexOf(realEstateDepot[index]);
                      if (indexToDelete != -1) {
                        sumList.removeAt(indexToDelete);
                      }
                      realEstateDepot.removeAt(index);
                      sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                      final realEstateDepotJson = jsonEncode(realEstateDepot);
                      prefs.setDouble('sumInvestValue', sumInvestValue);
                      prefs.setString('realEstateDepot', realEstateDepotJson);
                      final sumListJson = jsonEncode(sumList);
                      prefs.setString('sumList', sumListJson);
                      break;
                    case 4:
                      int indexToDelete = sumList.indexOf(carDepot[index]);
                      if (indexToDelete != -1) {
                        sumList.removeAt(indexToDelete);
                      }
                      carDepot.removeAt(index);
                      sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                      final carDepotJson = jsonEncode(carDepot);
                      prefs.setDouble('sumInvestValue', sumInvestValue);
                      prefs.setString('carDepot', carDepotJson);
                      final sumListJson = jsonEncode(sumList);
                      prefs.setString('sumList', sumListJson);
                      break;
                    case 5:
                      int indexToDelete = sumList.indexOf(electronicDepot[index]);
                      if (indexToDelete != -1) {
                        sumList.removeAt(indexToDelete);
                      }
                      electronicDepot.removeAt(index);
                      sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                      final electronicDepotJson = jsonEncode(electronicDepot);
                      prefs.setDouble('sumInvestValue', sumInvestValue);
                      prefs.setString('electronicDepot', electronicDepotJson);
                      final sumListJson = jsonEncode(sumList);
                      prefs.setString('sumList', sumListJson);
                      break;
                    case 6:
                      int indexToDelete = sumList.indexOf(otherDepot[index]);
                      if (indexToDelete != -1) {
                        sumList.removeAt(indexToDelete);
                      }
                      otherDepot.removeAt(index);
                      sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                      final otherDepotJson = jsonEncode(otherDepot);
                      prefs.setDouble('sumInvestValue', sumInvestValue);
                      prefs.setString('otherDepot', otherDepotJson);
                      final sumListJson = jsonEncode(sumList);
                      prefs.setString('sumList', sumListJson);
                      break;
                  }
                  Navigator.of(context).pop();
                });
              },
              icon: const Icon(Icons.delete_forever)
          )
        ],
      );
    },
    );
  }

  Widget buildSelectedCategories() {
    return Column(
      children:
      selectedCategories.map((category) {
        TextEditingController textController = TextEditingController();
        final isCategoryAdded = categoryValues.containsKey(category);
        double? goal = categoryValues[category];
        double sum = 0.0;
        if(category == "Döviz"){
          sum = exchangeDepot.isNotEmpty ? exchangeDepot.reduce((a, b) => a + b) : 0.0;
        } else if(category == "Nakit"){
          sum = cashDepot.isNotEmpty ? cashDepot.reduce((a, b) => a + b) : 0.0;
        } else if(category == "Gayrimenkül"){
          sum = realEstateDepot.isNotEmpty ? realEstateDepot.reduce((a, b) => a + b) : 0.0;
        } else if(category == "Araba"){
          sum = carDepot.isNotEmpty ? carDepot.reduce((a, b) => a + b) : 0.0;
        } else if(category == "Elektronik"){
          sum = electronicDepot.isNotEmpty ? electronicDepot.reduce((a, b) => a + b) : 0.0;
        } else if(category == "Diğer"){
          sum = otherDepot.isNotEmpty ? otherDepot.reduce((a, b) => a + b) : 0.0;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(category, style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
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
              child: isCategoryAdded
                  ?
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$sum / ${categoryValues[category]}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 19, fontWeight: FontWeight.normal)),
                  SizedBox(
                    child: LinearPercentIndicator(
                      padding: const EdgeInsets.only(right: 10),
                      backgroundColor: const Color(0xffc6c6c7),
                      animation: true,
                      lineHeight: 10,
                      animationDuration: 1000,
                      percent: sum / goal!,
                      trailing: Text("%${((sum / goal)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal)),
                      barRadius: const Radius.circular(10),
                      progressColor: Colors.lightBlue,
                    ),
                  ),
                  const SizedBox(height: 5),
                  ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      if(category == "Döviz")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: exchangeDepot.length + 1,
                              itemBuilder: (context, index) {
                                if (index < exchangeDepot.length) {
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
                                              exchangeDepot[index].toString(),
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              showEditDialog(category, 1, index);
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$category için birikim hedefi',
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                          const SizedBox(height: 10),
                                          TextFormField(
                                            controller: textController, // Assign the TextEditingController
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Enter a number',
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final prefs = await SharedPreferences.getInstance();
                                              setState(() {
                                                String inputText = textController.text; // Get the input text
                                                investValue = double.tryParse(inputText);
                                                if (investValue != null) {
                                                  exchangeDepot.add(investValue!);
                                                  final exchangeDepotJson = jsonEncode(exchangeDepot);
                                                  prefs.setString('exchangeDepot', exchangeDepotJson);
                                                  sumList.add(investValue!);
                                                  final sumListJson = jsonEncode(sumList);
                                                  prefs.setString('sumList', sumListJson);
                                                  sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                                                  prefs.setDouble('sumInvestValue', sumInvestValue);
                                                  Navigator.pop(context); // Close the form
                                                }
                                              });
                                            },
                                            child: const Text('Add'),
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
                                      onPressed: () async{
                                        final prefs = await SharedPreferences.getInstance();
                                        setState(()  {
                                          removeCategory(category, goal, sum);
                                          removeValues(sumList, exchangeDepot);
                                          exchangeDepot = [];
                                          final sumListJson = jsonEncode(sumList);
                                          final exchangeDepotJson = jsonEncode(exchangeDepot);
                                          prefs.setString('sumList', sumListJson);
                                          prefs.setString('exchangeDepot', exchangeDepotJson);
                                        });
                                      },
                                      icon: const Icon(Icons.remove_circle_outline)
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
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: cashDepot.length + 1,
                              itemBuilder: (context, index) {
                                if (index < cashDepot.length) {
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
                                              cashDepot[index].toString(),
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              showEditDialog(category, 2, index);
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$category için birikim hedefi',
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                          const SizedBox(height: 10),
                                          TextFormField(
                                            controller: textController, // Assign the TextEditingController
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Enter a number',
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final prefs = await SharedPreferences.getInstance();
                                              setState(() {
                                                String inputText = textController.text; // Get the input text
                                                investValue = double.tryParse(inputText);
                                                if (investValue != null) {
                                                  cashDepot.add(investValue!);
                                                  final cashDepotJson = jsonEncode(cashDepot);
                                                  prefs.setString('cashDepot', cashDepotJson);
                                                  sumList.add(investValue!);
                                                  final sumListJson = jsonEncode(sumList);
                                                  prefs.setString('sumList', sumListJson);
                                                  sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                                                  prefs.setDouble('sumInvestValue', sumInvestValue);
                                                  Navigator.pop(context); // Close the form
                                                }
                                              });
                                            },
                                            child: const Text('Add'),
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
                                          removeValues(sumList, cashDepot);
                                          cashDepot = [];
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
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: realEstateDepot.length + 1,
                              itemBuilder: (context, index) {
                                if (index < realEstateDepot.length) {
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
                                              realEstateDepot[index].toString(),
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              showEditDialog(category, 3, index);
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$category için birikim hedefi',
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                          const SizedBox(height: 10),
                                          TextFormField(
                                            controller: textController, // Assign the TextEditingController
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Enter a number',
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final prefs = await SharedPreferences.getInstance();
                                              setState(() {
                                                String inputText = textController.text; // Get the input text
                                                investValue = double.tryParse(inputText);
                                                if (investValue != null) {
                                                  realEstateDepot.add(investValue!);
                                                  final realEstateDepotJson = jsonEncode(realEstateDepot);
                                                  prefs.setString('realEstateDepot', realEstateDepotJson);
                                                  sumList.add(investValue!);
                                                  final sumListJson = jsonEncode(sumList);
                                                  prefs.setString('sumList', sumListJson);
                                                  sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                                                  prefs.setDouble('sumInvestValue', sumInvestValue);
                                                  Navigator.pop(context); // Close the form
                                                }
                                              });
                                            },
                                            child: const Text('Add'),
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
                                          removeValues(sumList, realEstateDepot);
                                          realEstateDepot = [];
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
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: carDepot.length + 1,
                              itemBuilder: (context, index) {
                                if (index < carDepot.length) {
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
                                              carDepot[index].toString(),
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              showEditDialog(category, 4, index);
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$category için birikim hedefi',
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                          const SizedBox(height: 10),
                                          TextFormField(
                                            controller: textController, // Assign the TextEditingController
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Enter a number',
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final prefs = await SharedPreferences.getInstance();
                                              setState(() {
                                                String inputText = textController.text; // Get the input text
                                                investValue = double.tryParse(inputText);
                                                if (investValue != null) {
                                                  carDepot.add(investValue!);
                                                  final carDepotJson = jsonEncode(carDepot);
                                                  prefs.setString('carDepot', carDepotJson);
                                                  sumList.add(investValue!);
                                                  final sumListJson = jsonEncode(sumList);
                                                  prefs.setString('sumList', sumListJson);
                                                  sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                                                  prefs.setDouble('sumInvestValue', sumInvestValue);
                                                  Navigator.pop(context); // Close the form
                                                }
                                              });
                                            },
                                            child: const Text('Add'),
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
                                          removeValues(sumList, carDepot);
                                          carDepot = [];
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
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: electronicDepot.length + 1,
                              itemBuilder: (context, index) {
                                if (index < electronicDepot.length) {
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
                                              electronicDepot[index].toString(),
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              showEditDialog(category, 5, index);
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$category için birikim hedefi',
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                          const SizedBox(height: 10),
                                          TextFormField(
                                            controller: textController, // Assign the TextEditingController
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Enter a number',
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final prefs = await SharedPreferences.getInstance();
                                              setState(() {
                                                String inputText = textController.text; // Get the input text
                                                investValue = double.tryParse(inputText);
                                                if (investValue != null) {
                                                  electronicDepot.add(investValue!);
                                                  final electronicDepotJson = jsonEncode(electronicDepot);
                                                  prefs.setString('electronicDepot', electronicDepotJson);
                                                  sumList.add(investValue!);
                                                  final sumListJson = jsonEncode(sumList);
                                                  prefs.setString('sumList', sumListJson);
                                                  sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                                                  prefs.setDouble('sumInvestValue', sumInvestValue);
                                                  Navigator.pop(context); // Close the form
                                                }
                                              });
                                            },
                                            child: const Text('Add'),
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
                                          removeValues(sumList, electronicDepot);
                                          electronicDepot = [];
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
                            const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: otherDepot.length + 1,
                              itemBuilder: (context, index) {
                                if (index < otherDepot.length) {
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
                                              otherDepot[index].toString(),
                                              style: GoogleFonts.montserrat(fontSize: 20),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          IconButton(
                                            splashRadius: 0.0001,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                            icon: const Icon(Icons.edit, size: 21),
                                            onPressed: () {
                                              showEditDialog(category, 6, index);
                                            },
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                    ],
                                  );
                                }
                                return null;
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$category için birikim hedefi',
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                          const SizedBox(height: 10),
                                          TextFormField(
                                            controller: textController, // Assign the TextEditingController
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Enter a number',
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final prefs = await SharedPreferences.getInstance();
                                              setState(() {
                                                String inputText = textController.text; // Get the input text
                                                investValue = double.tryParse(inputText);
                                                if (investValue != null) {
                                                  otherDepot.add(investValue!);
                                                  final otherDepotJson = jsonEncode(otherDepot);
                                                  prefs.setString('otherDepot', otherDepotJson);
                                                  sumList.add(investValue!);
                                                  final sumListJson = jsonEncode(sumList);
                                                  prefs.setString('sumList', sumListJson);
                                                  sumInvestValue = sumList.isNotEmpty ? sumList.reduce((a, b) => a + b) : 0.0;
                                                  prefs.setDouble('sumInvestValue', sumInvestValue);
                                                  Navigator.pop(context); // Close the form
                                                }
                                              });
                                            },
                                            child: const Text('Add'),
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
                                          removeValues(sumList, otherDepot);
                                          otherDepot = [];
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
                                      padding: const EdgeInsets.fromLTRB(20,20,20,50),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Add a value for $category',
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                          const SizedBox(height: 10),
                                          TextFormField(
                                            controller: textController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: 'Enter a number',
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                String inputText = textController.text;
                                                enteredValue = double.parse(inputText);
                                                if (enteredValue != null) {
                                                  addCategoryValue(category, enteredValue ?? 0, sum);
                                                  Navigator.pop(context); // Close the form
                                                }
                                              });
                                            },
                                            child: const Text('Add'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.add_circle_outline)
                          ),
                          IconButton(
                              onPressed: () async {
                                final prefs = await SharedPreferences.getInstance();
                                setState(() {
                                  removeCategory(category, 0, 0);
                                  final sumListJson = jsonEncode(sumList);
                                  final realEstateDepotJson = jsonEncode(realEstateDepot);
                                  prefs.setString('sumList', sumListJson);
                                  prefs.setString('realEstateDepot', realEstateDepotJson);
                                  realEstateDepot = [];
                                });
                              },
                              icon: const Icon(Icons.remove_circle_outline)
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
  void initState() {
    super.initState();
    _load();
  }

  double sumOfSavingValue = 0.0;
  double savingsValue = 0.0;
  double totalInvestValue = 0.0;
  double sumInvestValue = 0.0;
  double result = 0.0;

  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ab1 = prefs.getDouble('sumInvestValue') ?? 0.0;
    final ab2 = prefs.getDouble('totalInvestValue') ?? 0.0;
    final ab3 = prefs.getStringList('selectedCategories') ?? [];
    final ab4 = prefs.getBool('hasExchangeGoalSelected') ?? false;
    final ab5 = prefs.getBool('hasCashGoalSelected') ?? false;
    final ab6 = prefs.getBool('hasRealEstateGoalSelected') ?? false;
    final ab7 = prefs.getBool('hasCarGoalSelected') ?? false;
    final ab8 = prefs.getBool('hasElectronicGoalSelected') ?? false;
    final ab9 = prefs.getBool('hasOtherGoalSelected') ?? false;
    final ab10 = prefs.getString('ananim') ?? "";
    final ab11 = prefs.getBool('isPopupVisible') ?? false;
    final jsonMap = prefs.getString('categoryValues') ?? "";
    final decodedMap = jsonDecode(jsonMap) as Map<String, dynamic>;
    final jsonMap2 = prefs.getString('exchangeDepot') ?? "";
    final decodedMap2 = jsonDecode(jsonMap2) as List<dynamic>;
    final jsonMap3 = prefs.getString('sumList') ?? "";
    final jsonMap4 = prefs.getString('cashDepot') ?? "";
    setState(() {
      sumInvestValue = ab1;
      totalInvestValue = ab2;
      selectedCategories = ab3;
      hasExchangeGoalSelected = ab4;
      hasCashGoalSelected = ab5;
      hasRealEstateGoalSelected = ab6;
      hasCarGoalSelected = ab7;
      hasElectronicGoalSelected = ab8;
      hasOtherGoalSelected = ab9;
      ananim = ab10;
      isPopupVisible = ab11;
      categoryValues = Map<String, double>.from(decodedMap.map((key, value) {
        return MapEntry(key, value is double ? value : 0.0); // Ensure it's a double
      }));
      exchangeDepot = decodedMap2.map((e){
        return e is double ? e : 0.0;
      }).toList();
      print("sumList EX : $sumList");
      if (jsonMap3.isNotEmpty) {
        try {
          final ab14 = jsonDecode(jsonMap3) as List<dynamic>;
          if (ab14.every((element) => element is double)) {
            setState(() {
              sumList = ab14.cast<double>().toList();
              print("sumList ED : $sumList");
            });
          }
        } catch (e) {
          // Handle any other JSON decoding errors here
        }
      }
      if (jsonMap4.isNotEmpty) {
        try {
          final ab15 = jsonDecode(jsonMap4) as List<dynamic>;
          if (ab15.every((element) => element is double)) {
            setState(() {
              cashDepot = ab15.cast<double>().toList();
            });
          }
        } catch (e) {
          // Handle any other JSON decoding errors here
        }
      }
      print("categoryValues LOAD : $categoryValues");
      print("exchangeDepot LOAD : $exchangeDepot");
    });
  }

  @override
  Widget build(BuildContext context) {
    sumOfSavingValue = sumInvestValue.isNaN ? 0.0 : sumInvestValue;
    savingsValue = totalInvestValue.isNaN ? 0.0 : totalInvestValue;
    result = (savingsValue == 0.0) ? 0.0 : sumOfSavingValue / savingsValue;
    formattedsavingsValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(savingsValue);
    formattedSumOfSavingValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfSavingValue);
    return Material(
      child: Stack(
        children: [
              Scaffold(
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
                        Text("Hedefler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal)),
                        const SizedBox(height: 10),
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
                              Text("Birikim Hedefi", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 19, fontWeight: FontWeight.normal)),
                              const SizedBox(height: 10),
                              Text("$formattedSumOfSavingValue / $formattedsavingsValue", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 19, fontWeight: FontWeight.normal)),
                              SizedBox(
                                child: LinearPercentIndicator(
                                  padding: const EdgeInsets.only(right: 10),
                                  backgroundColor: const Color(0xffc6c6c7),
                                  animation: true,
                                  lineHeight: 10,
                                  animationDuration: 1000,
                                  percent: result,
                                  trailing: Text("%${((result)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal)),
                                  barRadius: const Radius.circular(10),
                                  progressColor: Colors.lightBlue,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text("Birikimlerinizi buraya ekleyin.", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal)),
                              const SizedBox(height: 5),
                              SizedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Birikim Ekle", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal)),
                                    IconButton(
                                      onPressed: () {
                                        togglePopupVisibility(context);
                                      },
                                      icon: const Icon(Icons.add_circle),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            buildSelectedCategories(),
                          ],
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: categoryValues.length,
                          itemBuilder: (context, index) {
                            final key = categoryValues.keys.elementAt(index);
                            final value = categoryValues[key];
                            return ListTile(
                              title: Text('$key'),
                              subtitle: Text('Value: ${value.toString()}'),
                            );
                          },
                        ),
                        Text("sumInvestValue : $sumInvestValue"),
                        Text("sumList : $sumList"),
                        Text("formattedSumOfSavingValue : $formattedSumOfSavingValue")
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500), // Duration for the animation
            top: 0,
            right: 0,
            left: 0,
            bottom: 0,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: isPopupVisible ? 5 : 0, sigmaY: isPopupVisible ? 5 : 0),
              child: AnimatedOpacity(
                opacity: isPopupVisible ? 0.7 : 0.0, // Fade in/out based on visibility
                duration: const Duration(milliseconds: 500), // Duration for the opacity animation
                child: Visibility(
                  visible: isPopupVisible,
                  child: Container(
                    padding: const EdgeInsets.only(top: 320),
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
                      child: const Icon(
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