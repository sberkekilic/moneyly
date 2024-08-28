import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/blocs/settings/settings-cubit.dart';
import 'package:moneyly/blocs/settings/settings-state.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class InvestmentPage extends StatefulWidget {
  const InvestmentPage({Key? key}) : super(key: key);

  @override
  State<InvestmentPage> createState() => _InvestmentPageState();
}

class _InvestmentPageState extends State<InvestmentPage> {
  InvestmentService investmentService = InvestmentService();
  List<Investment> investmentList = [];
  List<Investment> exchangeList = [];
  List<Investment> cashList = [];
  List<Investment> realEstateList = [];
  List<Investment> carList = [];
  List<Investment> electronicList = [];
  List<Investment> otherList = [];
  List<String> itemList = ["Döviz", "Nakit", "Gayrimenkül", "Araba", "Elektronik", "Diğer"];
  List<FaIcon> itemIcons = [
    FaIcon(FontAwesomeIcons.dollarSign, size: 20.sp, color: Colors.black,),
    FaIcon(FontAwesomeIcons.moneyBill, size: 20.sp),
    FaIcon(FontAwesomeIcons.handHoldingDollar, size: 20.sp),
    FaIcon(FontAwesomeIcons.carSide, size: 20.sp),
    FaIcon(FontAwesomeIcons.mobile, size: 20.sp),
    FaIcon(FontAwesomeIcons.chevronDown, size: 20.sp),
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
  DateTime? _savedDate;

  Future<void> togglePopupVisibility(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isPopupVisible = !isPopupVisible;
      prefs.setBool('isPopupVisible', isPopupVisible);
    });
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      setState(() {});
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

  Widget buildCategoryButton(String category, List<FaIcon> itemIcons) {
    int index = itemList.indexOf(category);
    FaIcon iconAsset = itemIcons[index];

    return Padding(
        padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
        child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {
              selectCategory(category);
              togglePopupVisibility(context);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 16.sp,
                    backgroundColor: Colors.white,
                    child: iconAsset
                  )
                ),
                const SizedBox(width: 15),
                Text(
                  category,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
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
        TextEditingController amountController = TextEditingController();
        TextEditingController nameController = TextEditingController();
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
                      lineHeight: 7.h,
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
                                  isScrollControlled: true,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: EdgeInsets.fromLTRB(20,20,20,MediaQuery.of(context).viewInsets.bottom+20),
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
                                            controller: amountController, // Assign the TextEditingController
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
                                                String inputText = amountController.text; // Get the input text
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
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom+20),
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
                                            controller: amountController, // Assign the TextEditingController
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
                                                String inputText = amountController.text; // Get the input text
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
                                  IconButton(
                                      onPressed: () async{
                                        final prefs = await SharedPreferences.getInstance();
                                        setState(()  {
                                          removeCategory(category, goal, sum);
                                          removeValues(sumList, cashDepot);
                                          cashDepot = [];
                                          final sumListJson = jsonEncode(sumList);
                                          final cashDepotJson = jsonEncode(cashDepot);
                                          prefs.setString('sumList', sumListJson);
                                          prefs.setString('cashDepot', cashDepotJson);
                                        });
                                      },
                                      icon: const Icon(Icons.remove_circle_outline)
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
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom+20),
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
                                            controller: amountController, // Assign the TextEditingController
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
                                                String inputText = amountController.text; // Get the input text
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
                                  IconButton(
                                      onPressed: () async{
                                        final prefs = await SharedPreferences.getInstance();
                                        setState(()  {
                                          removeCategory(category, goal, sum);
                                          removeValues(sumList, realEstateDepot);
                                          realEstateDepot = [];
                                          final sumListJson = jsonEncode(sumList);
                                          final realEstateDepotJson = jsonEncode(realEstateDepot);
                                          prefs.setString('sumList', sumListJson);
                                          prefs.setString('realEstateDepot', realEstateDepotJson);
                                        });
                                      },
                                      icon: const Icon(Icons.remove_circle_outline)
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
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom+20),
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
                                            controller: amountController, // Assign the TextEditingController
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
                                                String inputText = amountController.text; // Get the input text
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
                                  IconButton(
                                      onPressed: () async{
                                        final prefs = await SharedPreferences.getInstance();
                                        setState(()  {
                                          removeCategory(category, goal, sum);
                                          removeValues(sumList, carDepot);
                                          carDepot = [];
                                          final sumListJson = jsonEncode(sumList);
                                          final carDepotJson = jsonEncode(carDepot);
                                          prefs.setString('sumList', sumListJson);
                                          prefs.setString('carDepot', carDepotJson);
                                        });
                                      },
                                      icon: const Icon(Icons.remove_circle_outline)
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
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom+20),
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
                                            controller: amountController, // Assign the TextEditingController
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
                                                String inputText = amountController.text; // Get the input text
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
                                  IconButton(
                                      onPressed: () async{
                                        final prefs = await SharedPreferences.getInstance();
                                        setState(()  {
                                          removeCategory(category, goal, sum);
                                          removeValues(sumList, electronicDepot);
                                          electronicDepot = [];
                                          final sumListJson = jsonEncode(sumList);
                                          final electronicDepotJson = jsonEncode(electronicDepot);
                                          prefs.setString('sumList', sumListJson);
                                          prefs.setString('electronicDepot', electronicDepotJson);
                                        });
                                      },
                                      icon: const Icon(Icons.remove_circle_outline)
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
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    double? investValue;
                                    return Padding(
                                      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom+20),
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
                                            controller: amountController, // Assign the TextEditingController
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
                                                String inputText = amountController.text; // Get the input text
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
                                  IconButton(
                                      onPressed: () async{
                                        final prefs = await SharedPreferences.getInstance();
                                        setState(()  {
                                          removeCategory(category, goal, sum);
                                          removeValues(sumList, otherDepot);
                                          otherDepot = [];
                                          final sumListJson = jsonEncode(sumList);
                                          final otherDepotJson = jsonEncode(otherDepot);
                                          prefs.setString('sumList', sumListJson);
                                          prefs.setString('otherDepot', otherDepotJson);
                                        });
                                      },
                                      icon: const Icon(Icons.remove_circle_outline)
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
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    return _addInvestmentBottomSheet(
                                      context,
                                      category,
                                      amountController,
                                      nameController,
                                    );
                                  }
                                ).whenComplete(() {
                                  amountController.clear();
                                  nameController.clear();
                                  _deleteSavedDate();
                                });
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

  void _saveInvestment(int id, String name, String category, DateTime deadline, String amount) async {
    Investment newInvestment = Investment(
      id: id,
      name: name,
      category: category,
      deadline: deadline,
      amount: amount
    );

    InvestmentService investmentService = InvestmentService();
    await investmentService.saveInvestment(newInvestment);

    setState(() {
      investmentList.add(newInvestment);
    });

    print('New investment added: ${newInvestment.toMap()}');
  }

  void _clearInvestments() async {
    InvestmentService investmentService = InvestmentService();
    await investmentService.clearInvestments();
    setState(() {
      investmentList.clear();
    });
  }

  void _removeInvestment(int id) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      int index = investmentList.indexWhere((investment) => investment.id == id);
      if (index != -1){
        setState(() {
          investmentList.removeAt(index);
        });
      } else{

      }
      });

    final investmentMap = investmentList.map((investment) => investment.toMap()).toList();
    await prefs.setStringList('investments', investmentMap.map((investment) => jsonEncode(investment)).toList());
  }

  Widget _addInvestmentBottomSheet(BuildContext context, String category, TextEditingController amountController, TextEditingController nameController){
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          height: 500.h,
          decoration: BoxDecoration(
            color: Colors.white, // Background color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Padding(
            padding:  EdgeInsets.fromLTRB(20,20,20,MediaQuery.of(context).viewInsets.bottom+50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$category hedefin için tutar belirle.',
                  style: TextStyle(fontSize: 18.sp),
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Hedef İsmi',
                  ),
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tutar',
                  ),
                ),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: () {
                    _openDatePicker(setModalState);
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: _savedDate == null
                              ? 'Tap to choose a date'
                              : '${DateFormat('yyyy-MM-dd').format(_savedDate!)}'
                      ),
                    ),
                  ),
                ),
                Expanded(child: Container()), // Create a space to push ElevatedButton to bottom.
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.black,
                      minimumSize: Size(double.infinity, 40),
                    ),
                    clipBehavior: Clip.hardEdge,
                    onPressed: () async {
                      int maxId = 0;
                      for (var i in investmentList){
                        if (i.id > maxId) {
                          maxId = i.id;
                        }
                      }
                      int newId = maxId + 1;
                      String amountText = amountController.text;
                      String nameText = nameController.text;
                      if (amountText.isNotEmpty && nameText.isNotEmpty) {
                        _saveInvestment(newId, nameText, category, _savedDate!, amountText, );
                        //addCategoryValue(category, enteredValue ?? 0, sum);
                        Navigator.pop(context); // Close the form
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select a deadline')),
                        );
                      }
                      _savedDate;
                      _deleteSavedDate();
                    },
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void categorizeInvestments(List<Investment> investments) {
    for (var investment in investments) {
      switch (investment.category) {
        case 'Döviz':
          exchangeList.add(investment);
          break;
        case 'Cash':
          cashList.add(investment);
          break;
        case 'Real Estate':
          realEstateList.add(investment);
          break;
        case 'Car':
          carList.add(investment);
          break;
        case 'Electronic':
          electronicList.add(investment);
          break;
        case 'Other':
          otherList.add(investment);
          break;
      // Add more cases for additional categories
        default:
        // Handle uncategorized investments if necessary
          break;
      }
    }
  }

  void _deleteSavedDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedDate');
    setState(() {
      _savedDate = null;
    });
  }

  void _openDatePicker(StateSetter setModalState) async {
    DateTime? selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ChooseDateBottomSheet(
            onDateSelected: (date) {
              _savedDate = date;
            },
          ),
        );
      },
    );

    if (selectedDate != null) {
      setModalState(() {
        _savedDate = selectedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
    categorizeInvestments(investmentList);
  }

  double sumOfSavingValue = 0.0;
  double savingsValue = 0.0;
  double totalInvestValue = 0.0;
  double sumInvestValue = 0.0;
  double result = 0.0;

  void _load() async {
    InvestmentService investmentService = InvestmentService();
    List<Investment> investments = await investmentService.getInvestments();
    //await investmentService.clearInvestments();
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
    final ab12 = prefs.getString('selectedDate');
    final jsonMap = prefs.getString('categoryValues') ?? "";
    final jsonMap2 = prefs.getString('exchangeDepot') ?? "";
    final jsonMap3 = prefs.getString('sumList') ?? "";
    final jsonMap4 = prefs.getString('cashDepot') ?? "";

    setState(() {
      investmentList = investments;
      print("investmentList:${investmentList}");
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

      // Check if the JSON strings are not empty before decoding
      if (jsonMap.isNotEmpty) {
        final decodedMap = jsonDecode(jsonMap) as Map<String, dynamic>;
        categoryValues = Map<String, double>.from(decodedMap.map((key, value) {
          return MapEntry(key, value is double ? value : 0.0); // Ensure it's a double
        }));
      }

      if (jsonMap2.isNotEmpty) {
        final decodedMap2 = jsonDecode(jsonMap2) as List<dynamic>;
        exchangeDepot = decodedMap2.map((e) {
          return e is double ? e : 0.0;
        }).toList();
      }

      if (jsonMap3.isNotEmpty) {
        try {
          final ab14 = jsonDecode(jsonMap3) as List<dynamic>;
          if (ab14.every((element) => element is double)) {
            setState(() {
              sumList = ab14.cast<double>().toList();
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

      if (ab12 != null){
        setState(() {
          _savedDate = DateTime.parse(ab12);
        });
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('dd MMMM yyyy').format(DateTime.now());
    sumOfSavingValue = sumInvestValue.isNaN ? 0.0 : sumInvestValue;
    savingsValue = totalInvestValue.isNaN ? 0.0 : totalInvestValue;
    result = (savingsValue == 0.0) ? 0.0 : sumOfSavingValue / savingsValue;
    formattedsavingsValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(savingsValue);
    formattedSumOfSavingValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfSavingValue);
    return Material(
      child: Stack(
        children: [
              Scaffold(
                body: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              Text("Hedefler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal)),
                              Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                              //Text("Birikimlerinizi buraya ekleyin.", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal)),
                              SizedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Birikim Ekle", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal)),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          togglePopupVisibility(context);
                                        });
                                      },
                                      child: const Icon(Icons.add_circle),
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
                        SizedBox(
                          height: 300,
                          child: investmentList.isEmpty
                              ? Center(child: Text('No investments found.'))
                              : ListView.builder(
                            itemCount: investmentList.length,
                            itemBuilder: (context, index) {
                              Investment investment = investmentList[index];
                              return ListTile(
                                title: Text(investment.name+investment.amount+DateFormat('yyyy-MM-dd').format(investment.deadline!)),
                                subtitle: Text('Category: ${investment.category}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('ID: ${investment.id}'),
                                    SizedBox(width: 8),
                                    InkWell(
                                      child: FaIcon(FontAwesomeIcons.xmark),
                                      onTap: () => _removeInvestment(investment.id),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
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
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: isPopupVisible ? 5 : 0, sigmaY: isPopupVisible ? 5 : 0),
                  child: AnimatedOpacity(
                    opacity: isPopupVisible ? 0.7 : 0.0, // Fade in/out based on visibility
                    duration: const Duration(milliseconds: 500), // Duration for the opacity animation
                    child: Visibility(
                      visible: isPopupVisible,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              togglePopupVisibility(context);
                            },
                            child: Container(
                              padding: EdgeInsets.only(bottom: 50.h),
                              color: Colors.black.withOpacity(0.2), // Darkened background
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: itemList.map((category) {
                                    return GestureDetector(
                                      onTap: () {}, // Add an empty callback to prevent togglePopupVisibility from being called
                                      child: buildCategoryButton(category, itemIcons),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ]
                      ),
                    ),
                  ),
                ),
              ],
            )
          ),
        ],
      ),
    );
  }
}

class ChooseDateBottomSheet extends StatefulWidget{
  final Function(DateTime) onDateSelected;

  ChooseDateBottomSheet({required this.onDateSelected});

  @override
  _ChooseDateBottomSheetState createState() => _ChooseDateBottomSheetState();
}

class _ChooseDateBottomSheetState extends State<ChooseDateBottomSheet>{
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadSelectedDate();
  }

  void _loadSelectedDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dateString = prefs.getString('selectedDate');
    if (dateString != null){
      setState(() {
        _selectedDate = DateTime.parse(dateString);
      });
    } else {
      setState(() {
        _selectedDate = DateTime.now();
      });
    }
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args){
    setState(() {
      _selectedDate = args.value;
      _saveDate();
    });
  }
  
  void _saveDate() async {
    if (_selectedDate != null){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedDate', _selectedDate!.toIso8601String());
      widget.onDateSelected(_selectedDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.6,
      width: MediaQuery.of(context).size.width*0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10)
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          Align(child: Text("Hedef Tarihi", style: TextStyle(fontSize: 24.sp)), alignment: Alignment.bottomLeft,),
          SizedBox(height: 20),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return SfDateRangePicker(
                onSelectionChanged: _onSelectionChanged,
                backgroundColor: Colors.white,
                selectionColor: Colors.blue,
                todayHighlightColor: Colors.red,
                selectionMode: DateRangePickerSelectionMode.single,
                selectionTextStyle: TextStyle(
                  color: Colors.white, // Color of selected day text
                  fontSize: 18.sp, // Font size of selected day text
                  fontWeight: FontWeight.bold, // Font weight of selected day text
                ),
                monthViewSettings: DateRangePickerMonthViewSettings(
                  dayFormat: 'EEE',
                  viewHeaderStyle: DateRangePickerViewHeaderStyle(
                    textStyle: TextStyle(
                      fontSize: 12.sp, // Custom font size for day names
                      fontWeight: FontWeight.bold, // Custom font weight for day names
                      color: Colors.black, // Custom color for day names
                    ),
                  ),
                ),
                monthCellStyle: DateRangePickerMonthCellStyle(
                  disabledDatesTextStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      color: Colors.black54),
                    blackoutDateTextStyle: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18.sp,
                        color: Colors.black54),
                    blackoutDatesDecoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle),
                    cellDecoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      border: Border.all(color: Colors.transparent, width: 8), // add some gap between cells
                    ),
                    textStyle: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400,
                        fontSize: 18.sp,
                        color: Colors.blue
                    )
                ),
                initialSelectedDate: _selectedDate != null
                  ? DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day)
                : DateTime.now(),
                minDate: DateTime.now(),
                showTodayButton: false,
                showNavigationArrow: true,
                headerHeight: 60,
                headerStyle: DateRangePickerHeaderStyle(
                  textAlign: TextAlign.left,
                  textStyle: TextStyle(
                    color: Colors.blue,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  backgroundColor: Colors.transparent,
                ),
              );
            },
          ),
          Expanded(child: Container()), // Create a space to push ElevatedButton to bottom.
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 40),
              ),
              onPressed: () {
                setState(() {
                  Navigator.of(context).pop(_selectedDate);
                });
              },
              child: Text('Tamam')
          )
        ],
      ),
    );
  }

}

class Investment {
  int id;
  String category;
  String name;
  DateTime? deadline;
  String amount;

  Investment({required this.name, this.deadline, required this.id, required this.category, required this.amount});

  Map<String, dynamic> toMap(){ // Convert Investment object to a map
    return {
      'id': id,
      'category': category,
      'name': name,
      'deadline': deadline?.toIso8601String(),
      'amount' : amount
    };
  }

  factory Investment.fromMap(Map<String, dynamic> map){ // Create an Investment object from a map
    return Investment(
        id: map['id'],
        category: map['category'],
        name: map['name'],
        deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
        amount: map['amount']
    );
  }
}

class InvestmentService {
  final String key = 'investments';

  Future<void> saveInvestment(Investment investment) async { // Save an investment to local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> investments = prefs.getStringList(key) ?? [];
    investments.add(jsonEncode(investment.toMap())); // Convert Investment object to JSON and add to the list
    await prefs.setStringList(key, investments); // Save the updated list
  }

  Future<List<Investment>> getInvestments() async{ // Retrieve all investments from local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> investments = prefs.getStringList(key) ?? [];
    
    return investments.map((investmentString) { // Convert JSON string back to Investment object
      Map<String, dynamic> investmentMap = jsonDecode(investmentString);
      return Investment.fromMap(investmentMap);
    }).toList();
  }

  Future<void> clearInvestments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    print('All investments cleared.');
  }
}