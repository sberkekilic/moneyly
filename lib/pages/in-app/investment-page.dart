import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:moneyly/blocs/settings/settings-cubit.dart';
import 'package:moneyly/blocs/settings/settings-state.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../blocs/settings/selected-index-cubit.dart';

class InvestmentPage extends StatefulWidget {
  const InvestmentPage({Key? key}) : super(key: key);

  @override
  State<InvestmentPage> createState() => _InvestmentPageState();
}

class _InvestmentPageState extends State<InvestmentPage> {
  InvestmentService investmentService = InvestmentService();
  List<Investment> investmentList = [];
  List<Investment> exchangeList = [];
  List<InvestmentModel> exchangeDollarList = [];
  List<InvestmentModel> exchangeEuroList = [];
  List<InvestmentModel> exchangeLiraList = [];
  List<Investment> cashList = [];
  List<Investment> realEstateList = [];
  List<Investment> carList = [];
  List<Investment> electronicList = [];
  List<Investment> otherList = [];
  List<String> itemList = ["Döviz", "Nakit", "Gayrimenkül", "Araba", "Elektronik", "Diğer"];
  List<FaIcon> itemIcons = [
    FaIcon(FontAwesomeIcons.dollarSign, size: 26.sp),
    FaIcon(FontAwesomeIcons.moneyBill, size: 26.sp),
    FaIcon(FontAwesomeIcons.handHoldingDollar, size: 26.sp),
    FaIcon(FontAwesomeIcons.carSide, size: 26.sp),
    FaIcon(FontAwesomeIcons.mobile, size: 26.sp),
    FaIcon(FontAwesomeIcons.chevronDown, size: 26.sp),
  ];
  String selectedInvestmentType = "";
  String currencyType = "";
  Map<String, double?> categoryValues = {};
  Map<String, double?> totalInvestValue = {};
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
  String currencySymbol = r'$';
  String exchangeCurrencySymbol = r'$';
  String exchangeCurrency = 'Dolar';
  String cashCurrencySymbol = r'₺';
  String realEstateCurrencySymbol = r'₺';
  String carCurrencySymbol = r'₺';
  String electronicCurrencySymbol = r'₺';
  String otherCurrencySymbol = r'₺';
  String formattedTotal = "";
  String formattedDollarTotal = "";
  String formattedEuroTotal = "";
  String formattedLiraTotal = "";
  String formattedSumOfSavingValue = "";
  DateTime? _savedDate;
  double latestValue = 0;

  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
            toolbarButtons: [
                  (node) {
                return GestureDetector(
                  onTap: () => node.unfocus(),
                  child: Padding(
                    padding: EdgeInsets.only(right:20),
                    child: Text('Done'),
                  ),
                );
              }
            ]
        ),
        KeyboardActionsItem(
            focusNode: _nodeText2,
          toolbarButtons: [
            (node) {
             return GestureDetector(
               onTap: () => node.unfocus(),
               child: Padding(
                 padding: EdgeInsets.only(right:20),
                 child: Text('Done'),
               ),
             );
            }
          ]
        )
      ]
    );
  }

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

  Future<void> addCategoryValue(String category, String currency, double value, double sum) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      print("category:${category} and value:${value}");
      categoryValues[category] = value;
      totalInvestValue[currency] = value;
      print("categoryValues is at that point:${categoryValues}");
      ananim = value.toString();
      prefs.setString('ananim', ananim);
      final jsonMapCategory = jsonEncode(categoryValues);
      prefs.setString('categoryValues', jsonMapCategory);
      final jsonMapCurrency = jsonEncode(totalInvestValue);
      prefs.setString('totalInvestValue', jsonMapCurrency);
    });
  }

  Future<void> removeCategory(String category, String currency, double value, double sum) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      print("sumInvestValue 1: before removeCategory ${sumInvestValue}");
      sumInvestValue -= sum;
      print("sumInvestValue 2: after removeCategory ${sumInvestValue}");
      selectedCategories.remove(category);
      print("ANA1: selectedCategories removed category : ${selectedCategories}");
      categoryValues.remove(category);
      totalInvestValue.remove(category);
      prefs.setDouble('sumInvestValue', sumInvestValue);
      prefs.setStringList('selectedCategories', selectedCategories);
      final jsonMapCategory = jsonEncode(categoryValues);
      prefs.setString('categoryValues', jsonMapCategory);
      final jsonMapCurrency = jsonEncode(totalInvestValue);
      prefs.setString('totalInvestValue', jsonMapCurrency);
    });
  }

  void removeValues(List<double> a, List<double> b) {
    for (var value in b) {
      if (a.contains(value)) {
        a.remove(value);
      }
    }
  }

  String getInitials(String title) {
    List<String> words = title.split(" ");
    String initials = words.length > 1
        ? "${words[0][0]}${words[1][0]}"
        : words[0][0];
    return initials.toUpperCase();
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
                    radius: 20.sp,
                    backgroundColor: Colors.white,
                    child: iconAsset
                  )
                ),
                const SizedBox(width: 15),
                Text(
                  category,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  void showEditDialog(int index, int categoryIndex){
    TextEditingController nameEditController = TextEditingController();
    TextEditingController amountEditController = TextEditingController();

    switch (categoryIndex){
      case 1:
        List<Investment> filteredList = exchangeList.where((investment) => investment.category == 'Döviz').toList();
        Investment investment = filteredList[index];
        InvestmentModel? investmentModel = exchangeDollarList.firstWhere(
              (model) => model.id == investment.id,
          orElse: () => null as InvestmentModel, // Return null if no match is found
        );
        TextEditingController nameController = TextEditingController(text: investment.name);
        TextEditingController editController = TextEditingController(text: investmentModel.amount.toString());
        amountEditController = editController;
        nameEditController = nameController;
        break;
      case 2:
        TextEditingController editController = TextEditingController(text: cashDepot[index].toString());
        amountEditController = editController;
        break;
      case 3:
        TextEditingController editController = TextEditingController(text: realEstateDepot[index].toString());
        amountEditController = editController;
        break;
      case 4:
        TextEditingController editController = TextEditingController(text: carDepot[index].toString());
        amountEditController = editController;
        break;
      case 5:
        TextEditingController editController = TextEditingController(text: electronicDepot[index].toString());
        amountEditController = editController;
        break;
      case 6:
        TextEditingController editController = TextEditingController(text: otherDepot[index].toString());
        amountEditController = editController;
        break;
    }

    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
        ),
        title: Text('Edit category',style: const TextStyle(fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(alignment: Alignment.centerLeft,child: Text("Invest Name", style: TextStyle(fontSize: 18),),),
            const SizedBox(height: 10),
            TextFormField(
              controller: nameEditController,
              decoration: InputDecoration(
                isDense: true,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(width: 3, color: Colors.black)
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(width: 3, color: Colors.black), // Use the same border style for enabled state
                ),
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              ),
              style: const TextStyle(fontSize: 20),
            ),
            const Align(alignment: Alignment.centerLeft,child: Text("Invest Amount", style: TextStyle(fontSize: 18),),),
            const SizedBox(height: 10),
            TextFormField(
              controller: amountEditController,
              decoration: InputDecoration(
                isDense: true,
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(width: 3, color: Colors.black)
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
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
                        sumList[indexToChange] = double.parse(amountEditController.text);
                      }
                      exchangeDepot[index] = double.parse(amountEditController.text);
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
                        sumList[indexToChange] = double.parse(amountEditController.text);
                      }
                      cashDepot[index] = double.parse(amountEditController.text);
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
                        sumList[indexToChange] = double.parse(amountEditController.text);
                      }
                      realEstateDepot[index] = double.parse(amountEditController.text);
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
                        sumList[indexToChange] = double.parse(amountEditController.text);
                      }
                      carDepot[index] = double.parse(amountEditController.text);
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
                        sumList[indexToChange] = double.parse(amountEditController.text);
                      }
                      electronicDepot[index] = double.parse(amountEditController.text);
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
                        sumList[indexToChange] = double.parse(amountEditController.text);
                      }
                      otherDepot[index] = double.parse(amountEditController.text);
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

        double? goal = 0.0;
        double sum = 0.0;
        double result = 0.0;

        print("exchangeDepot da bu:${exchangeDepot.join(', ')}");
        print("buildSelectedCategories ÇALIŞTI ve category:${category} ve isCategoryAdded:${isCategoryAdded}");

        String formattedSum = "";
        String formattedGoal = "";
        String currency = "bi";
        if (category == "Döviz") {
          List<Investment> filteredList = exchangeList.where((investment) =>
          investment.category == 'Döviz' && investment.currency == exchangeCurrency
          ).toList();
          goal = filteredList.fold(0.0, (acc, investment) => acc + (double.tryParse(investment.amount) ?? 0.0));
          if (filteredList.isNotEmpty) {
            currency = filteredList[0].currency; // Assign the currency from the first investment
          }
          if (exchangeCurrency == "Dolar") {
            result = resultDollar;
          } else if (exchangeCurrency == "Euro") {
            result = resultEuro;
          } else if (exchangeCurrency == "Türk Lirası"){
            result = resultLira;
          }
        } else if (category == "Nakit") {
          sum = cashDepot.isNotEmpty ? cashDepot.reduce((a, b) => a + b) : 0.0;
        } else if (category == "Gayrimenkül") {
          sum = realEstateDepot.isNotEmpty ? realEstateDepot.reduce((a, b) => a + b) : 0.0;
        } else if (category == "Araba") {
          sum = carDepot.isNotEmpty ? carDepot.reduce((a, b) => a + b) : 0.0;
        } else if (category == "Elektronik") {
          sum = electronicDepot.isNotEmpty ? electronicDepot.reduce((a, b) => a + b) : 0.0;
        } else if (category == "Diğer") {
          sum = otherDepot.isNotEmpty ? otherDepot.reduce((a, b) => a + b) : 0.0;
        }

        formattedSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum);
        formattedGoal = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(goal ?? 0.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
            category,
            style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold
            )
        ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color(0xFFD5E1F5),
              ),
              child: isCategoryAdded
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFF70B8FF),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          CircularPercentIndicator(
                            radius: 30,
                            lineWidth: 7.0,
                            percent: result,
                            center: Text(
                                "%${((result) * 100).toStringAsFixed(0)}",
                                style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontSize: (result) * 100 == 100
                                        ? 12
                                        : 16,
                                    fontWeight: FontWeight.w600
                                )
                            ),
                            progressColor: Colors.amber,
                          ),
                          SizedBox(width: 20.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "${category == 'Döviz' ? 'Döviz Hedefi' : category == 'Nakit' ? 'Nakit Hedefi' : 'Diğer Kategori Hedefi'}",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 15.sp, fontWeight: FontWeight.bold)
                              ),
                              Text(
                                  "${formattedGoal}${exchangeCurrencySymbol}",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 25.sp, fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  CustomSlidingSegmentedControl<int>(
                    initialValue: 0,
                    isStretch: true,
                    children: const {
                      0: Text(
                        'Dolar',
                        textAlign: TextAlign.center,
                      ),
                      1: Text(
                        'Euro',
                        textAlign: TextAlign.center,
                      ),
                      2: Text(
                        'Türk Lirası',
                        textAlign: TextAlign.center,
                      ),
                    },
                    innerPadding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Color(0xFF86CDEA),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [],
                    ),
                    thumbDecoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [],
                    ),
                    onValueChanged: (v) {
                      setState(() {
                        if (v == 0) {
                          exchangeCurrencySymbol = r'$';
                          exchangeCurrency = "Dolar";
                        } else if (v == 1) {
                          exchangeCurrencySymbol = r'€';
                          exchangeCurrency = "Euro";
                        } else if (v == 2) {
                          exchangeCurrencySymbol = r'₺';
                          exchangeCurrency = "Türk Lirası";
                        }

                        goal = categoryValues[category];
                        formattedGoal = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(goal ?? 0.0);
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFFD5E1F5),
                    ),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        if(category == "Döviz")
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: exchangeList.where((investment) => investment.currency == exchangeCurrency).length,
                                itemBuilder: (context, index) {
                                  List<Investment> filteredList = exchangeList.where((investment) => investment.category == 'Döviz').toList();
                                  Investment investment = filteredList[index];
                                  InvestmentModel? investmentModel = exchangeDollarList.firstWhere(
                                        (model) => model.id == investment.id,
                                    orElse: () => null as InvestmentModel, // Return null if no match is found
                                  );
                                  if (index < exchangeList.length) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                            ),
                                            color: Color(0xFF70B8FF),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Row(
                                              children: [
                                                buildMonogram(investment.name),
                                                SizedBox(width: 20.w),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        investment.name,
                                                        style: GoogleFonts.montserrat(
                                                            fontSize: 15.sp, fontWeight: FontWeight.bold)
                                                    ),
                                                    Text(
                                                        investment.amount + exchangeCurrencySymbol,
                                                        style: GoogleFonts.montserrat(
                                                            fontSize: 25.sp, fontWeight: FontWeight.bold)
                                                    ),
                                                  ],
                                                ),
                                                Expanded(child: Container()),
                                                IconButton(
                                                  splashRadius: 0.0001,
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                                  icon: const Icon(Icons.edit, size: 21),
                                                  onPressed: () {
                                                    showEditDialog(index, 1);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(20),
                                              bottomRight: Radius.circular(20),
                                            ),
                                            color: Color(0xFF87CEEB),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "${NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(investmentModel.aim)}/${NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(double.parse(investment.amount))}${exchangeCurrencySymbol}",
                                                    style: GoogleFonts.montserrat(
                                                        fontSize: 20.sp, fontWeight: FontWeight.bold)
                                                ),
                                                SizedBox(height: 10),
                                                LinearPercentIndicator(
                                                  padding: const EdgeInsets.only(right: 10),
                                                  backgroundColor: Colors.grey[200],
                                                  animation: true,
                                                  lineHeight: 14.h,
                                                  animationDuration: 1000,
                                                  percent: investmentModel.aim/investmentModel.amount,
                                                  trailing: Text("%${((investmentModel.aim/investmentModel.amount)*100).toStringAsFixed(0)}", style: GoogleFonts.montserrat(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold)),
                                                  barRadius: const Radius.circular(10),
                                                  progressColor: const Color(0xff017b94),
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 32,
                                                      child: Container(
                                                          padding: const EdgeInsets.all(10),
                                                          decoration: BoxDecoration(
                                                            color: Color(0xFF70B7FE),
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          child: InkWell(
                                                            onTap: () {
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
                                                                                if (exchangeDollarList.isNotEmpty) {
                                                                                  // Find the current investment based on the ID
                                                                                  InvestmentModel? currentInvestment = exchangeDollarList.firstWhere(
                                                                                        (model) => model.id == investment.id, // Assuming 'investment' is accessible here
                                                                                    orElse: () => null as InvestmentModel,
                                                                                  );

                                                                                  if (currentInvestment != null) {
                                                                                    double newAim = currentInvestment.aim + investValue!;
                                                                                    print("AJAX1: Before ${exchangeDollarList.length}");
                                                                                    exchangeDollarList[exchangeDollarList.indexOf(currentInvestment)] = InvestmentModel(
                                                                                      id: currentInvestment.id,
                                                                                      aim: newAim,
                                                                                      amount: double.parse(investment.amount),
                                                                                    );
                                                                                    print("AJAX1: After ${exchangeDollarList.length}");

                                                                                    final exchangeDollarMap = exchangeDollarList.map((investment) => investment.toMap()).toList();
                                                                                    prefs.setStringList('exchangeDollarList', exchangeDollarMap.map((investment) => jsonEncode(investment)).toList());
                                                                                    prefs.setDouble('latestValue', newAim);

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
                                                                                }
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
                                                            child: const Text("Ekle", textAlign: TextAlign.center),
                                                          )
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      flex: 32,
                                                      child: Container(
                                                          padding: const EdgeInsets.all(10),
                                                          decoration: BoxDecoration(
                                                            color: Color(0xFF70B7FE),
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          child: InkWell(
                                                            onTap: () {
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
                                                                                if (exchangeDollarList.isNotEmpty) {
                                                                                  // Find the current investment based on the ID
                                                                                  InvestmentModel? currentInvestment = exchangeDollarList.firstWhere(
                                                                                        (model) => model.id == investment.id, // Assuming 'investment' is accessible here
                                                                                    orElse: () => null as InvestmentModel,
                                                                                  );

                                                                                  if (currentInvestment != null) {
                                                                                    double newAim = currentInvestment.aim - investValue!;
                                                                                    print("AJAX1: Before ${exchangeDollarList.length}");

                                                                                    exchangeDollarList[exchangeDollarList.indexOf(currentInvestment)] = InvestmentModel(
                                                                                      id: currentInvestment.id,
                                                                                      aim: newAim,
                                                                                      amount: double.parse(investment.amount),
                                                                                    );

                                                                                    print("AJAX1: After ${exchangeDollarList.length}");
                                                                                    final exchangeDollarMap = exchangeDollarList.map((investment) => investment.toMap()).toList();
                                                                                    prefs.setStringList('exchangeDollarList', exchangeDollarMap.map((investment) => jsonEncode(investment)).toList());
                                                                                    prefs.setDouble('latestValue', newAim);

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
                                                                                }
                                                                              }
                                                                            });
                                                                          },
                                                                          child: const Text('Remove'),
                                                                        ),

                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: const Text("Çıkart",textAlign: TextAlign.center),
                                                          )
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      flex: 19,
                                                      child: Container(
                                                          padding: const EdgeInsets.all(10),
                                                          decoration: BoxDecoration(
                                                            color: Color(0xFF70B7FE),
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          child: InkWell(
                                                            onTap: () => _removeInvestment(investment.id, category, currency),
                                                            child: Icon(Icons.delete, size: 20.sp),
                                                          )
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (exchangeList.where((investment) => investment.currency == exchangeCurrency).length > 1 && index < exchangeList.where((investment) => investment.currency == exchangeCurrency).length - 1)
                                          SizedBox(height: 10)
                                      ],
                                    );
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF70B7FE),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: InkWell(
                                    onTap: () {
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
                                    child: SizedBox(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Döviz Ekle", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal)),
                                          Icon(Icons.add_circle),
                                        ],
                                      ),
                                    ),
                                  ),
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
                                                showEditDialog(index, 2);
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
                                            removeCategory(category, currency, goal!, sum);
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
                                                showEditDialog(index, 3);
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
                                            removeCategory(category, currency, goal!, sum);
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
                                                showEditDialog(index, 4);
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
                                            removeCategory(category, currency, goal!, sum);
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
                                                showEditDialog(index, 5);
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
                                            removeCategory(category, currency, goal!, sum);
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
                                                showEditDialog(index, 6);
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
                                            removeCategory(category, currency, goal!, sum);
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
                                  removeCategory(category, currency, 0, 0);
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

  Widget buildMonogram(String title) {
    return Container(
      width: 70.r,
      height: 70.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey
      ),
      child: Center(
        child: Text(
          getInitials(title),
          style: TextStyle(
            color: Colors.white, // Text color
            fontSize: 20.0, // Font size
            fontWeight: FontWeight.bold, // Font weight
          ),
        ),
      ),
    );
  }

  void _saveInvestment(int id, String name, String category, String currency, DateTime deadline, String amount) async {
    Investment newInvestment = Investment(
      id: id,
      name: name,
      category: category,
      currency : currency,
      deadline: deadline,
      amount: amount
    );

    InvestmentService investmentService = InvestmentService();
    await investmentService.saveInvestment(newInvestment);

    setState(() {
      investmentList.add(newInvestment);
      switch (category) {
        case 'Döviz':
          exchangeList.add(newInvestment);
          print("AJAX1: eklenme 2");
          break;
        case 'Nakit':
          cashList.add(newInvestment);
          break;
        case 'Gayrimenkul':
          realEstateList.add(newInvestment);
          break;
        case 'Araba':
          carList.add(newInvestment);
          break;
        case 'Elektronik':
          electronicList.add(newInvestment);
          break;
        case 'Diğer':
          otherList.add(newInvestment);
          break;
        default:
          print('Unknown category: $category');
          break;
      }
    });

    print('_saveInvestment (New investment added): ${newInvestment.toMap()}');
  }

  void _saveInvestmentModel(int id, double latestValue, String amount, String category) async {
    InvestmentModel modelInvestment = InvestmentModel(
        id: id,
        aim: 0,
        amount: double.parse(amount)
    );

    InvestmentService investmentService = InvestmentService();
    await investmentService.saveInvestmentModel(modelInvestment);

    setState(() {
      switch (category) {
        case 'Döviz':
          print("AJAX2: Before ${exchangeDollarList.length}");
          exchangeDollarList.add(modelInvestment);
          print("AJAX2: After ${exchangeDollarList.length}");
          break;
        case 'Nakit':

          break;
        case 'Gayrimenkul':

          break;
        case 'Araba':

          break;
        case 'Elektronik':

          break;
        case 'Diğer':

          break;
        default:
          print('Unknown category: $category');
          break;
      }
    });

    print('_saveInvestmentModel (New investmentModel added): ${modelInvestment.toMap()}');
  }

  void _clearInvestments() async {
    InvestmentService investmentService = InvestmentService();
    await investmentService.clearInvestments();
    setState(() {
      investmentList.clear();
    });
  }

  double calculateTotalInvestment(String category, String currency) {
    double total = 0.0;

    // Assuming investmentList is a list of Investment objects with a `category` and a `value`
    for (var investment in investmentList) {
      if (investment.category == category && investment.currency == currency) {
        total += double.parse(investment.amount); // Update this based on your Investment model
      }
    }

    return total;
  }

  void _removeInvestment(int id, String category, String currency) async {
    final prefs = await SharedPreferences.getInstance();

    // Perform asynchronous work outside of setState
    int index = investmentList.indexWhere((investment) => investment.id == id);
    int indexExchange = exchangeList.indexWhere((investment) => investment.id == id);
    int indexDollar = exchangeDollarList.indexWhere((investment) => investment.id == id);

    // Only remove if the index is valid
    if (index != -1) {
      // Perform the removals
      investmentList.removeAt(index);
      exchangeList.removeAt(indexExchange);
      exchangeDollarList.removeAt(indexDollar);
      // Remove the category from selectedCategories and update totals
      if (currency == 'Dolar' && exchangeDollarList.length == 0) {
        print("AXAJ1");
        selectedCategories.remove(category);
        categoryValues.remove(category);
        totalInvestValue.remove(category);
      } else if (currency == 'Euro' && exchangeEuroList.length == 0) {
        print("AXAJ");
        selectedCategories.remove(category);
        categoryValues.remove(category);
        totalInvestValue.remove(category);
      } else if (currency == 'Türk Lirası' && exchangeLiraList.length == 0) {
        print("AXAJ3");
        selectedCategories.remove(category);
        categoryValues.remove(category);
        totalInvestValue.remove(category);
      }

      // Update total values
      totalInvestValue[category] = calculateTotalInvestment(category, currency);

      // Save the updates to SharedPreferences
      await prefs.setStringList('selectedCategories', selectedCategories);
      final jsonMapCategory = jsonEncode(categoryValues);
      await prefs.setString('categoryValues', jsonMapCategory);
      final jsonMapCurrency = jsonEncode(totalInvestValue);
      await prefs.setString('totalInvestValue', jsonMapCurrency);

      final investmentMap = investmentList.map((investment) => investment.toMap()).toList();
      await prefs.setStringList('investments', investmentMap.map((investment) => jsonEncode(investment)).toList());
      final exchangeDollarMap = exchangeDollarList.map((investment) => investment.toMap()).toList();
      await prefs.setStringList('exchangeDollarList', exchangeDollarMap.map((investment) => jsonEncode(investment)).toList());

      // Update the state after all operations are done
      setState(() {});
    }
  }

  Widget _addInvestmentBottomSheet(BuildContext context, String category, TextEditingController amountController, TextEditingController nameController) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Padding for keyboard overlap
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Color(0xffD7CECE),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: KeyboardActions(
                config: _buildConfig(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Döviz Cinsi',
                      style: TextStyle(fontSize: 18.sp),
                    ),
                    SizedBox(height: 10.h),
                    CustomSlidingSegmentedControl<int>(
                      initialValue: 2,
                      isStretch: true,
                      children: const {
                        0: Text(
                          'Dolar',
                          textAlign: TextAlign.center,
                        ),
                        1: Text(
                          'Euro',
                          textAlign: TextAlign.center,
                        ),
                        2: Text(
                          'Türk Lirası',
                          textAlign: TextAlign.center,
                        ),
                      },
                      innerPadding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [],
                      ),
                      thumbDecoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [],
                      ),
                      onValueChanged: (value) {
                        print("onValueChanged çalıştı, value:${value}");
                        if(value == 0){
                          setState(() {
                            currencyType = 'Dolar';
                            print("value 0, currencyType:${currencyType}");
                          });
                        }
                        if(value == 1){
                          setState(() {
                            currencyType = 'Euro';
                            print("value 1, currencyType:${currencyType}");
                          });
                        }
                        if(value == 2){
                          setState(() {
                            currencyType = 'Türk Lirası';
                            print("value 2, currencyType:${currencyType}");
                          });
                        }
                      },
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Hedef İsmi',
                      style: TextStyle(fontSize: 18.sp),
                    ),
                    SizedBox(height: 10.h),
                    TextFormField(
                      controller: nameController,
                      keyboardType: TextInputType.name,
                      focusNode: _nodeText1,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.white, width: 3),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.black, width: 3),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          hintStyle: TextStyle(color: Colors.black)
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Hedef Miktarı',
                      style: TextStyle(fontSize: 18.sp),
                    ),
                    SizedBox(height: 10.h),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      focusNode: _nodeText2,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.white, width: 3),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.black, width: 3),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          hintStyle: TextStyle(color: Colors.black)
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Hedef Tarihi',
                      style: TextStyle(fontSize: 18.sp),
                    ),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () {
                        _openDatePicker(setModalState);
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: _savedDate == null
                                  ? ''
                                  : '${DateFormat('yyyy-MM-dd').format(_savedDate!)}',
                              filled: true,
                              fillColor: Colors.white,
                              isDense: true,
                              contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.white, width: 3),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.black, width: 3),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              hintStyle: TextStyle(color: Colors.black)
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 40),
                        ),
                        clipBehavior: Clip.hardEdge,
                        onPressed: () async {
                          setState(() {
                            int maxId = 0;
                            for (var i in investmentList) {
                              if (i.id > maxId) {
                                maxId = i.id;
                              }
                            }
                            int newId = maxId + 1;
                            String amountText = amountController.text;
                            double enteredValue = double.parse(amountText);
                            String nameText = nameController.text;
                            if (amountText.isNotEmpty && nameText.isNotEmpty) {
                              print("currencyType at _saveInvestment:${currencyType}");
                              _saveInvestment(
                                newId,
                                nameText,
                                category,
                                currencyType,
                                _savedDate!,
                                amountText,
                              );
                              _saveInvestmentModel(
                                  newId,
                                  latestValue,
                                  amountText,
                                  category
                              );
                              Navigator.pop(context); // Close the form
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please select a deadline')),
                              );
                            }
                            _savedDate; // Ensure _savedDate is used properly
                            _deleteSavedDate(); // Ensure _deleteSavedDate is called properly
                            if (enteredValue != null) {
                              addCategoryValue(category, currencyType, enteredValue, 0);
                            }
                          });
                        },
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void categorizeInvestments(List<Investment> investments) {
    print("categorizeInvestments called with investments:");
    for (var investment in investments) {
      print("Investment - ID: ${investment.id}, Category: ${investment.category}, Name: ${investment.name}, Deadline: ${investment.deadline}, Amount: ${investment.amount}");
      switch (investment.category) {
        case 'Döviz':
          print("Adding to exchangeList: ID: ${investment.id}");
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

    print("Final exchangeList contents:");
    exchangeList.forEach((inv) => print("ID: ${inv.id}, Category: ${inv.category}, Name: ${inv.name}"));
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
            borderRadius: BorderRadius.circular(20),
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

  double calculateTotalInvestmentForCurrency(String currency) {
    double total = 0.0;
    for (var investment in investmentList) {
      if (investment.currency == currency) {
        print("Adding: ${investment.amount} from investment ID: ${investment.id}");
        total += double.parse(investment.amount);
      }
    }
    print("Total $currency Amount: $total");
    return total;
  }


  double sumAims(List<InvestmentModel> investments) {
    // Use map to extract the aim values and then fold to sum them
    return investments.map((investment) => investment.aim).fold(0.0, (a, b) => a + b);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  double sumOfSavingValue = 0.0;
  double savingsValue = 0.0;
  double sumInvestValue = 0.0;
  double resultDollar = 0.0;
  double resultEuro = 0.0;
  double resultLira = 0.0;
  double dollarTotal = 0.0;
  double euroTotal = 0.0;
  double liraTotal = 0.0;

  void _load() async {
    InvestmentService investmentService = InvestmentService();
    List<Investment> investments = await investmentService.getInvestments();
    List<InvestmentModel> investmentModel = await investmentService.getInvestmentModels();
    //await investmentService.clearInvestments();
    final prefs = await SharedPreferences.getInstance();
    //prefs.setStringList('exchangeDollarList', []);
    //prefs.setStringList('selectedCategories', []);
    //prefs.setString('categoryValues', '');
    final ab1 = prefs.getDouble('sumInvestValue') ?? 0.0;
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
    final jsonMap5 = prefs.getString('totalInvestValue') ?? "";

    setState(() {
      investmentList = investments;
      print("AJAX4: Before ${exchangeDollarList.length}");
      exchangeDollarList = investmentModel;
      print("AJAX4: After ${exchangeDollarList.length}");
      dollarTotal = calculateTotalInvestmentForCurrency('Dolar');
      liraTotal = calculateTotalInvestmentForCurrency('Türk Lirası');
      euroTotal = calculateTotalInvestmentForCurrency('Euro');
      print("investmentList:${
        investmentList
            .map((investment) =>
                'ID: ${investment.id}, '
                    'Category: ${investment.category}, '
                    'Currency: ${investment.currency}, '
                    'Name: ${investment.name}, '
                    'Deadline: ${investment.deadline}, '
                    'Amount: ${investment.amount}'
        )
            .join('\n')
      }");
      categorizeInvestments(investmentList);
      print("categoryValues:${categoryValues.entries.map((entry) => '${entry.key}: ${entry.value}').join('\n')}");
      print("exchangeList:${exchangeList.map((investment) => 'ID: ${investment.id}, Category: ${investment.category}, Name: ${investment.name}, Deadline: ${investment.deadline}, Amount: ${investment.amount}')
      .join('\n')
      }");
      sumInvestValue = ab1;
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

      if (jsonMap5.isNotEmpty) {
        final decodedMap = jsonDecode(jsonMap5) as Map<String, dynamic>;
        totalInvestValue = Map<String, double>.from(decodedMap.map((key, value) {
          return MapEntry(key, value is double ? value : 0.0); // Ensure it's a double
        }));
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
    double totalDollarAim = sumAims(exchangeDollarList);
    double totalEuroAim = sumAims(exchangeEuroList);
    double totalLiraAim = sumAims(exchangeLiraList);
    double totalDollar = calculateTotalInvestmentForCurrency('Dolar');
    double totalEuro = calculateTotalInvestmentForCurrency('Euro');
    double totalLira = calculateTotalInvestmentForCurrency('Türk Lirası');
    sumOfSavingValue = sumInvestValue.isNaN ? 0.0 : sumInvestValue;
    resultDollar = totalDollar == 0.0 ? 0.0 : totalDollarAim / totalDollar;
    resultEuro = totalEuro == 0.0 ? 0.0 : totalEuroAim / totalEuro;
    resultLira = totalLira == 0.0 ? 0.0 : totalLiraAim / totalLira;
    print("resultDollar $resultDollar, resultEuro$resultEuro, resultLira$resultLira");
    formattedDollarTotal = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(calculateTotalInvestmentForCurrency('Dolar'));
    formattedEuroTotal = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(calculateTotalInvestmentForCurrency('Euro'));
    formattedLiraTotal = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(calculateTotalInvestmentForCurrency('Türk Lirası'));
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
                        Text("Birikim",
                            style: GoogleFonts.montserrat(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Color(0x7D67C5FF) // Dark mode color
                                : Color(0xFFD5E1F5),// Light mode color
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Color(0xFF87CEEB),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Color(0xFF70B8FF),
                                      ),
                                      child: Text(
                                        "Toplam Birikim Hedefi(${currencySymbol})",
                                        textAlign: TextAlign.left, // Centers text within the container
                                        style: GoogleFonts.montserrat(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2, // Adjusts line height for better control
                                        ),
                                      ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          children: [
                                            CircularPercentIndicator(
                                              radius: 35.r,
                                              lineWidth: 7.h,
                                              percent: currencySymbol == r'$' ? resultDollar : currencySymbol == '€' ? resultEuro : resultLira,
                                              center: Text(
                                                  "%${((currencySymbol == r'$' ? resultDollar : currencySymbol == '€' ? resultEuro : resultLira) * 100).toStringAsFixed(0)}",
                                                  style: GoogleFonts.montserrat(
                                                      color: Colors.black,
                                                      fontSize: (currencySymbol == r'$' ? resultDollar : currencySymbol == '€' ? resultEuro : resultLira) * 100 == 100
                                                          ? 12
                                                          : 16,
                                                      fontWeight: FontWeight.w600
                                                  )
                                              ),
                                              progressColor: Colors.amber,
                                            ),
                                            SizedBox(width: 15.w),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "${currencySymbol == r'$' ? 'Dolar Hedefi ' : currencySymbol == '€' ? 'Euro Hedefi' : 'Türk Lirası Hedefi'}",
                                                    style: GoogleFonts.montserrat(
                                                        fontSize: 15.sp, fontWeight: FontWeight.bold)
                                                ),
                                                Text(
                                                    "${currencySymbol == r'$' ? "${formattedDollarTotal}${currencySymbol}" : currencySymbol == "${formattedEuroTotal}${currencySymbol}" ? 'Euro Hedefi' : "${formattedLiraTotal}${currencySymbol}"}",
                                                    style: GoogleFonts.montserrat(
                                                        fontSize: 25.sp, fontWeight: FontWeight.bold)
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              CustomSlidingSegmentedControl<int>(
                                initialValue: 0,
                                isStretch: true,
                                children: const {
                                  0: Text(
                                    'Dolar',
                                    textAlign: TextAlign.center,
                                  ),
                                  1: Text(
                                    'Euro',
                                    textAlign: TextAlign.center,
                                  ),
                                  2: Text(
                                    'Türk Lirası',
                                    textAlign: TextAlign.center,
                                  ),
                                },
                                innerPadding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Color(0xFF86CDEA),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [],
                                ),
                                thumbDecoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [],
                                ),
                                onValueChanged: (v) {
                                  setState(() {
                                    if (v == 0) {
                                      currencySymbol = r'$';
                                      formattedTotal = formattedDollarTotal;
                                    } else if (v == 1) {
                                      currencySymbol = r'€';
                                      formattedTotal = formattedEuroTotal;
                                    } else if (v == 2) {
                                      currencySymbol = r'₺';
                                      formattedTotal = formattedLiraTotal;
                                    }
                                  });
                                },
                              ),
                              SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF70B7FE),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        togglePopupVisibility(context);
                                      });
                                    },
                                    child: SizedBox(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Birikim Ekle", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal)),
                                          Icon(Icons.add_circle),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        ListView(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            buildSelectedCategories(),
                          ],
                        ),
                        Text("investmentList",
                            style: GoogleFonts.montserrat(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          investmentList
                              .map((investment) => 'ID: ${investment.id}, Category: ${investment.category}, Currency: ${investment.currency}, Name: ${investment.name}, Deadline: ${investment.deadline}, Amount: ${investment.amount}')
                              .join('\n'),
                        ),
                        Text("exchangeList",
                            style: GoogleFonts.montserrat(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          exchangeList
                              .map((investment) => 'ID: ${investment.id}, Category: ${investment.category}, Currency: ${investment.currency}, Name: ${investment.name}, Deadline: ${investment.deadline}, Amount: ${investment.amount}')
                              .join('\n'),
                        ),
                        Text("exchangeDollarList",
                            style: GoogleFonts.montserrat(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          exchangeDollarList
                              .map((investment) => 'ID: ${investment.id}, Aim: ${investment.aim}, Amount: ${investment.amount}')
                              .join('\n'),
                        ),
                        Text("cashList",
                            style: GoogleFonts.montserrat(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          cashList
                              .map((investment) => 'ID: ${investment.id}, Category: ${investment.category}, Currency: ${investment.currency}, Name: ${investment.name}, Deadline: ${investment.deadline}, Amount: ${investment.amount}')
                              .join('\n'),
                        ),
                        Text("latestValue:${latestValue.toString()}",
                            style: GoogleFonts.montserrat(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("selectedCategories:${selectedCategories}",
                            style: GoogleFonts.montserrat(
                                fontSize: 16, fontWeight: FontWeight.bold)),
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

class MonogramCircleAvatar extends StatelessWidget {
  final String name;

  MonogramCircleAvatar({required this.name});

  String _getInitials(String name) {
    // Split the name by spaces and take the first letter of the first and last word
    List<String> nameParts = name.split(" ");
    if (nameParts.length > 1) {
      return nameParts[0][0] + nameParts[1][0]; // Initials from first and last names
    } else {
      return nameParts[0][0]; // Single name case
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.blueAccent,
      radius: 40,
      child: Text(
        _getInitials(name).toUpperCase(), // Convert initials to uppercase
        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
      width: MediaQuery.of(context).size.width*0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20)
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
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
  String currency;
  String name;
  DateTime? deadline;
  String amount;

  Investment({required this.name, this.deadline, required this.id, required this.category, required this.amount, required this.currency});

  Map<String, dynamic> toMap(){ // Convert Investment object to a map
    return {
      'id': id,
      'category': category,
      'currency' : currency,
      'name': name,
      'deadline': deadline?.toIso8601String(),
      'amount' : amount
    };
  }

  factory Investment.fromMap(Map<String, dynamic> map){
    return Investment(
        id: map['id'] ?? 0,
        category: map['category'] ?? '',
        currency: map['currency'] ?? '',
        name: map['name'] ?? '',
        deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
        amount: map['amount'] ?? ''
    );
  }
}

class InvestmentService {
  final String key = 'investments';
  final String key2 = 'exchangeDollarList';

  Future<void> saveInvestment(Investment investment) async { // Save an investment to local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> investments = prefs.getStringList(key) ?? [];
    investments.add(jsonEncode(investment.toMap())); // Convert Investment object to JSON and add to the list
    await prefs.setStringList(key, investments); // Save the updated list
  }

  Future<void> saveInvestmentModel(InvestmentModel investment) async { // Save an investment to local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> investments = prefs.getStringList(key2) ?? [];
    investments.add(jsonEncode(investment.toMap())); // Convert Investment object to JSON and add to the list
    await prefs.setStringList(key2, investments); // Save the updated list
  }

  Future<List<Investment>> getInvestments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> investments = prefs.getStringList(key) ?? [];

    List<Investment> investmentList = [];
    for (var investmentString in investments) {
      if (investmentString != null) {
        Map<String, dynamic> investmentMap = jsonDecode(investmentString);
        Investment investment = Investment.fromMap(investmentMap);
        investmentList.add(investment);
      }
    }
    return investmentList;
  }

  Future<List<InvestmentModel>> getInvestmentModels() async{ // Retrieve all investments from local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> investments = prefs.getStringList(key2) ?? [];

    return investments.map((investmentString) { // Convert JSON string back to Investment object
      Map<String, dynamic> investmentMap = jsonDecode(investmentString);
      return InvestmentModel.fromMap(investmentMap);
    }).toList();
  }

  Future<void> clearInvestments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    print('All investments cleared.');
  }
}

class InvestmentModel {
  final int id;
  final double aim;
  final double amount;

  InvestmentModel({required this.id, required this.aim, required this.amount});

  Map<String, dynamic> toMap(){ // Convert Investment object to a map
    return {
      'id': id,
      'aim': aim,
      'amount' : amount
    };
  }

  factory InvestmentModel.fromMap(Map<String, dynamic> map){
    return InvestmentModel(
        id: map['id'],
        aim: map['aim'],
        amount: map['amount']
    );
  }
}