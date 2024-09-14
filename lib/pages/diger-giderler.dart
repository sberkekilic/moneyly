import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../deneme.dart';
import 'faturalar.dart';

class OtherExpenses extends StatefulWidget {
  const OtherExpenses({Key? key}) : super(key: key);

  @override
  State<OtherExpenses> createState() => _OtherExpensesState();
}

class _OtherExpensesState extends State<OtherExpenses> {
  List<String> sharedPreferencesData = [];
  List<String> desiredKeys = [
    'rentTitleList2', 'rentPriceList2', 'hasRentSelected2', 'sumOfRent2',
    'kitchenTitleList2', 'kitchenPriceList2', 'hasKitchenSelected2', 'sumOfKitchen2',
    'cateringTitleList2', 'cateringPriceList2', 'hasCateringSelected2', 'sumOfCatering2',
    'entertainmentTitleList2', 'entertainmentPriceList2', 'hasEntertainmentSelected2', 'sumOfEnt2',
    'otherTitleList2', 'otherPriceList2', 'hasOtherSelected2', 'sumOfOther2'
  ];
  List<Invoice> invoices = [];

  bool hasRentSelected = false;
  bool hasKitchenSelected = false;
  bool hasCateringSelected = false;
  bool hasEntertainmentSelected = false;
  bool hasOtherSelected = false;

  List<String> rentTitleList = [];
  List<String> kitchenTitleList = [];
  List<String> cateringTitleList = [];
  List<String> entertainmentTitleList = [];
  List<String> otherTitleList = [];
  List<String> rentPriceList = [];
  List<String> kitchenPriceList = [];
  List<String> cateringPriceList = [];
  List<String> entertainmentPriceList = [];
  List<String> otherPriceList = [];

  double sumOfRent = 0.0;
  double sumOfKitchen = 0.0;
  double sumOfCatering = 0.0;
  double sumOfEnt = 0.0;
  double sumOfOther = 0.0;

  String convertSum = "";
  String convertSum2 = "";
  String convertSum3 = "";
  String convertSum4 = "";
  String convertSum5 = "";

  List<TextEditingController> editTextControllers = [];
  List<TextEditingController> NDeditTextControllers = [];
  List<TextEditingController> RDeditTextControllers = [];
  List<TextEditingController> THeditTextControllers = [];
  List<TextEditingController> otherEditTextControllers = [];

  final TextEditingController textController = TextEditingController();
  TextEditingController NDtextController = TextEditingController();
  TextEditingController RDtextController = TextEditingController();
  TextEditingController THtextController = TextEditingController();
  TextEditingController otherTextController = TextEditingController();

  final TextEditingController platformPriceController = TextEditingController();
  TextEditingController NDplatformPriceController = TextEditingController();
  TextEditingController RDplatformPriceController = TextEditingController();
  TextEditingController THplatformPriceController = TextEditingController();
  TextEditingController otherPlatformPriceController = TextEditingController();

  TextEditingController editController = TextEditingController();
  TextEditingController NDeditController = TextEditingController();
  TextEditingController RDeditController = TextEditingController();
  TextEditingController THeditController = TextEditingController();
  TextEditingController otherEditController = TextEditingController();

  bool isTextFormFieldVisible = false;
  bool isTextFormFieldVisibleND = false;
  bool isTextFormFieldVisibleRD = false;
  bool isTextFormFieldVisibleTH = false;
  bool isTextFormFieldVisibleOther = false;

  bool isEditingList = false;
  bool isEditingListND = false;
  bool isEditingListRD = false;
  bool isEditingListTH = false;
  bool isEditingListOther = false;

  bool isAddButtonActive = false;
  bool isAddButtonActiveND = false;
  bool isAddButtonActiveRD = false;
  bool isAddButtonActiveTH = false;
  bool isAddButtonActiveOther = false;

  int? _selectedBillingDay;
  int? _selectedBillingMonth;
  int? _selectedDueDay;
  String faturaDonemi = "";
  String? sonOdeme;

  List<int> daysList = List.generate(31, (index) => index + 1);
  List<int> monthsList = List.generate(12, (index) => index + 1);

  Future<void> handleRentContainerTouch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasRentSelected2', true);
    await prefs.setBool('hasKitchenSelected2', false);
    await prefs.setBool('hasCateringSelected2', false);
    await prefs.setBool('hasEntertainmentSelected2', false);
    await prefs.setBool('hasOtherSelected2', false);
    setState(() {
      hasRentSelected = true;
      hasKitchenSelected = false;
      hasCateringSelected = false;
      hasEntertainmentSelected = false;
      hasOtherSelected = false;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isTextFormFieldVisibleTH = false;
      isTextFormFieldVisibleOther = false;
      isEditingList = false;
    });
  }
  Future<void> handleKitchenContainerTouch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasRentSelected2', false);
    await prefs.setBool('hasKitchenSelected2', true);
    await prefs.setBool('hasCateringSelected2', false);
    await prefs.setBool('hasEntertainmentSelected2', false);
    await prefs.setBool('hasOtherSelected2', false);
    setState(() {
      hasRentSelected = false;
      hasKitchenSelected = true;
      hasCateringSelected = false;
      hasEntertainmentSelected = false;
      hasOtherSelected = false;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isTextFormFieldVisibleTH = false;
      isTextFormFieldVisibleOther = false;
      isEditingListND = false;
    });
  }
  Future<void> handleCateringContainerTouch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasRentSelected2', false);
    await prefs.setBool('hasKitchenSelected2', false);
    await prefs.setBool('hasCateringSelected2', true);
    await prefs.setBool('hasEntertainmentSelected2', false);
    await prefs.setBool('hasOtherSelected2', false);
    setState(() {
      hasRentSelected = false;
      hasKitchenSelected = false;
      hasCateringSelected = true;
      hasEntertainmentSelected = false;
      hasOtherSelected = false;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isTextFormFieldVisibleTH = false;
      isTextFormFieldVisibleOther = false;
      isEditingListRD = false;
    });
  }
  Future<void> handleEntContainerTouch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasRentSelected2', false);
    await prefs.setBool('hasKitchenSelected2', false);
    await prefs.setBool('hasCateringSelected2', false);
    await prefs.setBool('hasEntertainmentSelected2', true);
    await prefs.setBool('hasOtherSelected2', false);
    setState(() {
      hasRentSelected = false;
      hasKitchenSelected = false;
      hasCateringSelected = false;
      hasEntertainmentSelected = true;
      hasOtherSelected = false;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isTextFormFieldVisibleTH = true;
      isTextFormFieldVisibleOther = false;
      isEditingListTH = false;
    });
  }
  Future<void> handleOtherContainerTouch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasRentSelected2', false);
    await prefs.setBool('hasKitchenSelected2', false);
    await prefs.setBool('hasCateringSelected2', false);
    await prefs.setBool('hasEntertainmentSelected2', false);
    await prefs.setBool('hasOtherSelected2', true);
    setState(() {
      hasRentSelected = false;
      hasKitchenSelected = false;
      hasCateringSelected = false;
      hasEntertainmentSelected = false;
      hasOtherSelected = true;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isTextFormFieldVisibleTH = false;
      isTextFormFieldVisibleOther = true;
      isEditingListOther = false;
    });
  }

  void goToPreviousPage() {
    Navigator.pop(context);
  }
  void goToNextPage() {
    Navigator.pushNamed(context, 'page6');
  }

  void _showEditDialog(BuildContext context, int index, int orderIndex, int id) {
    final formDataProvider2 = Provider.of<FormDataProvider2>(context, listen: false);

    TextEditingController selectedEditController = TextEditingController();
    TextEditingController selectedPriceController = TextEditingController();
    Invoice invoice = invoices.firstWhere((invoice) => invoice.id == id);
    _selectedBillingDay = invoice.getPeriodDay();
    _selectedDueDay = invoice.getDueDay();
    invoice.periodDate = formatPeriodDate(_selectedBillingDay ?? 0, _selectedBillingMonth ?? 0);
    if (_selectedDueDay != null) {
      invoice.dueDate = formatDueDate(_selectedDueDay, invoice.periodDate);
    }

    switch (orderIndex) {
      case 1:
        TextEditingController editController =
        TextEditingController(text: invoice.name);
        TextEditingController priceController =
        TextEditingController(text: invoice.price);
        selectedEditController = editController;
        selectedPriceController = priceController;
        break;
      case 2:
        TextEditingController NDeditController =
        TextEditingController(text: kitchenTitleList[index]);
        TextEditingController NDpriceController =
        TextEditingController(text: kitchenPriceList[index]);
        selectedEditController = NDeditController;
        selectedPriceController = NDpriceController;
        break;
      case 3:
        TextEditingController RDeditController =
        TextEditingController(text: cateringTitleList[index]);
        TextEditingController RDpriceController =
        TextEditingController(text: cateringPriceList[index]);
        selectedEditController = RDeditController;
        selectedPriceController = RDpriceController;
        break;
      case 4:
        TextEditingController THeditController =
        TextEditingController(text: entertainmentTitleList[index]);
        TextEditingController THpriceController =
        TextEditingController(text: entertainmentPriceList[index]);
        selectedEditController = THeditController;
        selectedPriceController = THpriceController;
        break;
      case 5:
        TextEditingController otherEditController =
        TextEditingController(text: otherTitleList[index]);
        TextEditingController otherPriceController =
        TextEditingController(text: otherPriceList[index]);
        selectedEditController = otherEditController;
        selectedPriceController = otherPriceController;
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          title: Text('Edit Item id:$id',style: GoogleFonts.montserrat(fontSize: 20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(alignment: Alignment.centerLeft,child: Text("Item", style: GoogleFonts.montserrat(fontSize: 18),),),
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
                style: GoogleFonts.montserrat(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: Text("Price",style: GoogleFonts.montserrat(fontSize: 18))),
              const SizedBox(height: 10),
              TextFormField(
                controller: selectedPriceController,
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
                style: GoogleFonts.montserrat(fontSize: 20),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: Text("Period Date",style: GoogleFonts.montserrat(fontSize: 18))),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedBillingDay,
                      onChanged: (value) {
                        setState(() {
                          _selectedBillingDay = value;
                        });
                      },
                      items: daysList.map((day) {
                        return DropdownMenuItem<int>(
                          value: day,
                          child: Text(day.toString()),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedBillingMonth,
                      onChanged: (value) {
                        setState(() {
                          _selectedBillingMonth = value;
                        });
                      },
                      items: monthsList.map((month) {
                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text(month.toString()),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: Text("Due Date",style: GoogleFonts.montserrat(fontSize: 18))),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _selectedDueDay,
                onChanged: (value) {
                  setState(() {
                    _selectedDueDay = value;
                  });
                },
                items: daysList.map((day) {
                  return DropdownMenuItem<int>(
                    value: day,
                    child: Text(day.toString()),
                  );
                }).toList(),
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
                      final priceText = selectedPriceController.text.trim();
                      double dprice = double.tryParse(priceText) ?? 0.0;
                      String price = dprice.toStringAsFixed(2);
                      String name = selectedEditController.text;
                      invoice.name = name;
                      invoice.price = price;
                      if (_selectedDueDay != null) {
                        editInvoice(
                          id,
                          formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!),
                          formatDueDate(_selectedDueDay, formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!)),
                        );
                      } else {
                        editInvoice(
                          id,
                          formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!),
                          null, // or provide any default value you want for dueDate when _selectedDueDay is null
                        );
                      }
                      break;
                    case 2:
                      final priceText = selectedPriceController.text.trim();
                      double dprice = double.tryParse(priceText) ?? 0.0;
                      String price = dprice.toStringAsFixed(2);
                      kitchenTitleList[index] = selectedEditController.text;
                      kitchenPriceList[index] = price;
                      formDataProvider2.setKitchenTitleValue(selectedEditController.text, kitchenTitleList);
                      formDataProvider2.setKitchenPriceValue(price, kitchenPriceList);
                      formDataProvider2.calculateSumOfKitchen(kitchenPriceList);
                      break;
                    case 3:
                      final priceText = selectedPriceController.text.trim();
                      double dprice = double.tryParse(priceText) ?? 0.0;
                      String price = dprice.toStringAsFixed(2);
                      cateringTitleList[index] = selectedEditController.text;
                      cateringPriceList[index] = price;
                      formDataProvider2.setCateringTitleValue(selectedEditController.text, cateringTitleList);
                      formDataProvider2.setCateringPriceValue(price, cateringPriceList);
                      formDataProvider2.calculateSumOfCatering(cateringPriceList);
                      break;
                    case 4:
                      final priceText = selectedPriceController.text.trim();
                      double dprice = double.tryParse(priceText) ?? 0.0;
                      String price = dprice.toStringAsFixed(2);
                      entertainmentTitleList[index] = selectedEditController.text;
                      entertainmentPriceList[index] = price;
                      formDataProvider2.setEntertainmentTitleValue(selectedEditController.text, entertainmentTitleList);
                      formDataProvider2.setEntertainmentPriceValue(price, entertainmentPriceList);
                      formDataProvider2.calculateSumOfEnt(entertainmentPriceList);
                      break;
                    case 5:
                      final priceText = selectedPriceController.text.trim();
                      double dprice = double.tryParse(priceText) ?? 0.0;
                      String price = dprice.toStringAsFixed(2);
                      otherTitleList[index] = selectedEditController.text;
                      otherPriceList[index] = price;
                      formDataProvider2.setOtherTitleValue(selectedEditController.text, otherTitleList);
                      formDataProvider2.setOtherPriceValue(price, otherPriceList);
                      formDataProvider2.calculateSumOfOther(otherPriceList);
                      break;
                  }
                });
                Navigator.of(context).pop();
              },

              child: Text('Save'),
            ),
            TextButton(
                onPressed: () {
                  setState(() {
                    switch (orderIndex){
                      case 1:
                        formDataProvider2.removeRentTitleValue(rentTitleList);
                        formDataProvider2.removeRentPriceValue(rentPriceList);
                        isEditingList = false;
                        isAddButtonActive = false;
                        removeInvoice(id);
                        break;
                      case 2:
                        kitchenTitleList.removeAt(index);
                        kitchenPriceList.removeAt(index);
                        formDataProvider2.removeKitchenTitleValue(kitchenTitleList);
                        formDataProvider2.removeKitchenPriceValue(kitchenPriceList);
                        formDataProvider2.calculateSumOfKitchen(kitchenPriceList);
                        isEditingListND = false;
                        isAddButtonActiveND = false;
                        break;
                      case 3:
                        cateringTitleList.removeAt(index);
                        cateringPriceList.removeAt(index);
                        formDataProvider2.removeCateringTitleValue(cateringTitleList);
                        formDataProvider2.removeCateringPriceValue(cateringPriceList);
                        formDataProvider2.calculateSumOfCatering(cateringPriceList);
                        isEditingListRD = false;
                        isAddButtonActiveRD = false;
                        break;
                      case 4:
                        entertainmentTitleList.removeAt(index);
                        entertainmentPriceList.removeAt(index);
                        formDataProvider2.removeEntertainmentTitleValue(entertainmentTitleList);
                        formDataProvider2.removeEntertainmentPriceValue(entertainmentPriceList);
                        formDataProvider2.calculateSumOfEnt(entertainmentPriceList);
                        isEditingListTH = false;
                        isAddButtonActiveTH = false;
                        break;
                      case 5:
                        otherTitleList.removeAt(index);
                        otherPriceList.removeAt(index);
                        formDataProvider2.removeOtherTitleValue(otherTitleList);
                        formDataProvider2.removeOtherPriceValue(otherPriceList);
                        formDataProvider2.calculateSumOfOther(otherPriceList);
                        isEditingListOther = false;
                        isAddButtonActiveOther = false;
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
  void initState() {
    super.initState();
    _load();
  }

  Future<void> loadSharedPreferencesData(List<String> desiredKeys) async {
    final prefs = await SharedPreferences.getInstance();
    sharedPreferencesData = [];

    for (var key in desiredKeys) {
      final value = prefs.get(key);
      if (value != null) {
        sharedPreferencesData.add('$key: $value');
      }
    }

    setState(() {
    }); // Trigger a rebuild of the widget to display the data
  }

  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ab1 = prefs.getBool('hasRentSelected2') ?? false;
    final ab2 = prefs.getBool('hasKitchenSelected2') ?? false;
    final ab3 = prefs.getBool('hasCateringSelected2') ?? false;
    final ab4 = prefs.getBool('hasEntertainmentSelected2') ?? false;
    final ab5 = prefs.getBool('hasOtherSelected2') ?? false;
    final bb1 = prefs.getStringList('rentTitleList2') ?? [];
    final bb2 = prefs.getStringList('kitchenTitleList2') ?? [];
    final bb3 = prefs.getStringList('cateringTitleList2') ?? [];
    final bb4 = prefs.getStringList('entertainmentTitleList2') ?? [];
    final bb5 = prefs.getStringList('otherTitleList2') ?? [];
    final cb1 = prefs.getStringList('rentPriceList2') ?? [];
    final cb2 = prefs.getStringList('kitchenPriceList2') ?? [];
    final cb3 = prefs.getStringList('cateringPriceList2') ?? [];
    final cb4 = prefs.getStringList('entertainmentPriceList2') ?? [];
    final cb5 = prefs.getStringList('otherPriceList2') ?? [];
    final db1 = prefs.getDouble('sumOfRent2') ?? 0.0;
    final db2 = prefs.getDouble('sumOfKitchen2') ?? 0.0;
    final db3 = prefs.getDouble('sumOfCatering2') ?? 0.0;
    final db4 = prefs.getDouble('sumOfEnt2') ?? 0.0;
    final db5 = prefs.getDouble('sumOfOther2') ?? 0.0;
    final eb1 = prefs.getStringList('invoices') ?? [];
    setState(() {
      hasRentSelected = ab1;
      hasKitchenSelected = ab2;
      hasCateringSelected = ab3;
      hasEntertainmentSelected = ab4;
      hasOtherSelected = ab5;
      rentTitleList = bb1;
      kitchenTitleList = bb2;
      cateringTitleList = bb3;
      entertainmentTitleList = bb4;
      otherTitleList = bb5;
      rentPriceList = cb1;
      kitchenPriceList = cb2;
      cateringPriceList = cb3;
      entertainmentPriceList = cb4;
      otherPriceList = cb5;
      sumOfRent = db1;
      sumOfKitchen = db2;
      sumOfCatering = db3;
      sumOfEnt = db4;
      sumOfOther = db5;
      for (final invoiceString in eb1) {
        final Map<String, dynamic> invoiceJson = jsonDecode(invoiceString);
        final Invoice invoice = Invoice.fromJson(invoiceJson);
        invoices.add(invoice);
      }
      loadSharedPreferencesData(desiredKeys);
    });
    convertSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfRent);
    convertSum2 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfKitchen);
    convertSum3 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfCatering);
    convertSum4 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfEnt);
    convertSum5 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfOther);
  }

  Future<void> setSumAll(double value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('sumOfOthers2', value);
  }

  Future<void> saveInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final invoiceList = invoices.map((invoice) => invoice.toJson()).toList();
    await prefs.setStringList('invoices', invoiceList.map((invoice) => jsonEncode(invoice)).toList());
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

  bool isLeapYear(int year) {
    if (year % 4 != 0) return false;
    if (year % 100 != 0) return true;
    return year % 400 == 0;
  }

  String formatPeriodDate(int day, int month) {
    final currentDate = DateTime.now();
    int year = currentDate.year;

    if (month > 12) {
      month = 1;
      year++;
    }

    // Handle the case where the day is 29th February and it's not a leap year
    if (day == 29 && month == 2 && !isLeapYear(year)) {
      day = 28;
    }

    return faturaDonemi = '${year.toString()}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  String formatDueDate(int? day, String periodDay) {
    final currentDate = DateTime.now();
    int year = currentDate.year;

    // Parse the periodDay string to DateTime
    DateTime parsedPeriodDay = DateTime.parse(periodDay);
    int month = parsedPeriodDay.month;

    if (month > 12) {
      month = 1;
      year++;
    }

    // Handle the case where day is not null and is 29th February, and it's not a leap year
    if (day != null && day == 29 && month == 2 && !isLeapYear(year)) {
      day = 28;
    }

    // Use a default value of null if day is null
    int? calculatedDay = day;

    DateTime calculatedDate = DateTime(year, month, calculatedDay ?? 1);

    // Check if calculatedDate is before the parsedPeriodDay and increase the month if needed
    if (calculatedDate.isBefore(parsedPeriodDay)) {
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
      calculatedDate = DateTime(year, month, calculatedDay ?? 1);
    }

    // Return the formatted date as a string
    return sonOdeme = '${calculatedDate.year}-${calculatedDate.month.toString().padLeft(2, '0')}-${calculatedDate.day.toString().padLeft(2, '0')}';
  }

  String getDaysRemainingMessage(Invoice invoice) {
    final currentDate = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    final dueDateKnown = invoice.dueDate != null;

    if (currentDate.isBefore(DateTime.parse(faturaDonemi))) {
      invoice.difference = (DateTime.parse(faturaDonemi).difference(currentDate).inDays + 1).toString();
      return invoice.difference;
    } else if (formattedDate == faturaDonemi) {
      invoice.difference = "0";
      return invoice.difference;
    } else if (dueDateKnown) {
      if (sonOdeme != null && currentDate.isAfter(DateTime.parse(faturaDonemi))) {
        invoice.difference = (DateTime.parse(sonOdeme!).difference(currentDate).inDays + 1).toString();
        return invoice.difference;
      } else {
        return "error1";
      }
    } else {
      return "error2";
    }
  }

  void onSave(Invoice invoice) {
    getDaysRemainingMessage(invoice);
    setState(() {
      invoices.add(invoice);
    });
    saveInvoices();
  }

  void editInvoice(int id, String periodDate, String? dueDate) {
    int index = invoices.indexWhere((invoice) => invoice.id == id);
    if (index != -1) {
      setState(() {
        final invoice = invoices[index];
        String diff = getDaysRemainingMessage(invoice);
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

  void removeInvoice(int id) {
    setState(() {
      int index = invoices.indexWhere((invoice) => invoice.id == id);
      if (index != -1) {
        setState(() {
          invoices.removeAt(index);
        });
      } else {
        // Entry with the target ID not found
      }
    });
    saveInvoices();
  }

  @override
  Widget build(BuildContext context) {
    final formDataProvider2 = Provider.of<FormDataProvider2>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
    double rentSum = calculateSubcategorySum(invoices, 'Kira');
    String formattedRentSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(rentSum);
    double sumAll = 0.0;
    sumAll += rentSum;
    sumAll += sumOfKitchen;
    sumAll += sumOfCatering;
    sumAll += sumOfEnt;
    sumAll += sumOfOther;
    setSumAll(sumAll);
    List<int> idsWithRentTargetCategory = [];
    for (Invoice invoice in invoices) {
      if (invoice.subCategory == "Kira") {
        idsWithRentTargetCategory.add(invoice.id);
      }
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xfff0f0f1),
          elevation: 0,
          toolbarHeight: 70,
          automaticallyImplyLeading: false,
          leadingWidth: 30,
          title: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'faturalar');
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.black), // Replace with the desired left icon
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'gelir-ekle');
                    },
                    icon: Icon(Icons.clear, color: Colors.black), // Replace with the desired right icon
                  ),
                ],
              ),
              Text(
                "Gider Ekle",
                style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 20),
                Expanded(
                  child: Container(
                    height: 50,
                    color: Colors.white,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: sumAll!=0.0 ? Colors.black : Colors.grey,
                      ),
                      clipBehavior: Clip.hardEdge,
                      onPressed: sumAll!=0.0 ? () {
                        goToNextPage();
                      } : null,
                      child: const Text('Sonraki', style: TextStyle(fontSize: 18),),
                    ),
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
          ),
        ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Color(
                  0xfff0f0f1),
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    child: ListView(
                      controller: ScrollController(initialScrollOffset: (screenWidth - 60) / 3 + 30),
                      scrollDirection: Axis.horizontal,
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.pushNamed(context, 'gelir-ekle');
                          },
                          splashColor: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 50,
                            width: (screenWidth-60) / 3,
                            child: Column(
                              children: [
                                Align(child: Text("Gelir", style: TextStyle(color: Colors.black, fontSize: 15)), alignment: Alignment.center),
                                SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                      height: 8,
                                      width: (screenWidth-60) / 3,
                                      color: Color(0xff1ab738)
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: (){
                            Navigator.pushNamed(context, 'abonelikler');
                          },
                          splashColor: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 50,
                            width: (screenWidth-60) / 3,
                            child: Column(
                              children: [
                                Align(child: Text("Abonelikler", style: TextStyle(color: Colors.black, fontSize: 15)), alignment: Alignment.center),
                                SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 8,
                                    width: (screenWidth-60) / 3,
                                    color: Color(
                                        0xff1ab738),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: (){
                            Navigator.pushNamed(context, 'faturalar');
                          },
                          splashColor: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 50,
                            width: (screenWidth-60) / 3,
                            child: Column(
                              children: [
                                Align(child: Text("Faturalar", style: TextStyle(color: Colors.black, fontSize: 15)), alignment: Alignment.center),
                                SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 8,
                                    width: (screenWidth-60) / 3,
                                    color: Color(0xff1ab738)
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          onTap: (){
                            Navigator.pushNamed(context, 'diger-giderler');
                          },
                          splashColor: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 50,
                            width: ((screenWidth-60) / 3)+20,
                            child: Column(
                              children: [
                                Align(child: Text("Diğer Giderler", style: TextStyle(color: Color(0xff1ab738), fontWeight: FontWeight.bold, fontSize: 15)), alignment: Alignment.center),
                                SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 8,
                                    width: ((screenWidth-60) / 3)+20,
                                    color: Color(0xff1ab738)
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 60, // Adjust the top position as needed
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 4)
                    )
                  ]
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Padding(
                      padding: const EdgeInsets.only(left:20, right: 20, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: hasRentSelected ? Colors.black : Colors.black.withOpacity(0.5),
                                        width: hasRentSelected ? 4 : 2,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if(isAddButtonActive==false){
                                          handleRentContainerTouch();
                                          isAddButtonActiveND = false;
                                          isAddButtonActiveRD = false;
                                        } else {
                                          isAddButtonActiveND = false;
                                          isAddButtonActiveRD = false;
                                        }
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text("Kira",style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)
                                          ),
                                          if (invoices.isNotEmpty && invoices.isNotEmpty)
                                            Container(
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: idsWithRentTargetCategory.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  int id = idsWithRentTargetCategory[i];
                                                  Invoice invoice = invoices.firstWhere((invoice) => invoice.id == id);
                                                  return Container(
                                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 4,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            textAlign: TextAlign.center,
                                                            invoice.name,
                                                            style: GoogleFonts.montserrat(fontSize: 20),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          flex: 4,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            invoice.price,
                                                            style: GoogleFonts.montserrat(fontSize: 20),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          flex: 4,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            invoice.subCategory,
                                                            style: GoogleFonts.montserrat(fontSize: 20),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          flex: 4,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            id.toString(),
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
                                                            _showEditDialog(context, i, 1, id); // Show the edit dialog
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          if (isTextFormFieldVisible && hasRentSelected)
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Fatura Adı"),
                                                    SizedBox(height: 5.h),
                                                    TextFormField(
                                                      controller: textController,
                                                      decoration: InputDecoration(
                                                        isDense: true,
                                                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                                        filled: true,
                                                        hoverColor: Colors.blue,
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        hintText: 'ABA',
                                                      ),
                                                    ),
                                                    SizedBox(height: 10.h),
                                                    Text("Tutar"),
                                                    SizedBox(height: 5.h),
                                                    TextFormField(
                                                      controller: platformPriceController,
                                                      keyboardType: TextInputType.number, // Show numeric keyboard
                                                      decoration: InputDecoration(
                                                        isDense: true,
                                                        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                                        filled: true,
                                                        hoverColor: Colors.blue,
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        hintText: 'GAG',
                                                      ),
                                                    ),
                                                    SizedBox(height: 10.h),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text("Başlangıç Tarihi"),
                                                              SizedBox(height: 5.h),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: DropdownButtonFormField2<int>(
                                                                      value: _selectedBillingDay,
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          _selectedBillingDay = value;
                                                                        });
                                                                      },
                                                                      isExpanded: true,
                                                                      decoration: InputDecoration(
                                                                        contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                        isDense: true,
                                                                        border: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                        ),
                                                                      ),
                                                                      hint: const Text(
                                                                        'Gün',
                                                                        style: TextStyle(fontSize: 14),
                                                                      ),
                                                                      buttonStyleData: const ButtonStyleData(
                                                                        padding: EdgeInsets.only(right: 8),
                                                                      ),
                                                                      iconStyleData: const IconStyleData(
                                                                        icon: Icon(
                                                                          Icons.arrow_drop_down,
                                                                          color: Colors.black45,
                                                                        ),
                                                                        iconSize: 24,
                                                                      ),
                                                                      dropdownStyleData: DropdownStyleData(
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(15),
                                                                        ),
                                                                      ),
                                                                      menuItemStyleData: const MenuItemStyleData(
                                                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                                                      ),
                                                                      items: daysList.map((day) {
                                                                        return DropdownMenuItem<int>(
                                                                          value: day,
                                                                          child: Text(day.toString()),
                                                                        );
                                                                      }).toList(),
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 10),
                                                                  Expanded(
                                                                    child: DropdownButtonFormField2<int>(
                                                                      value: _selectedBillingMonth,
                                                                      onChanged: (value) {
                                                                        setState(() {
                                                                          _selectedBillingMonth = value;
                                                                        });
                                                                      },
                                                                      isExpanded: true,
                                                                      decoration: InputDecoration(
                                                                        contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                        isDense: true,
                                                                        border: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                        ),
                                                                      ),
                                                                      hint: const Text(
                                                                        'Ay',
                                                                        style: TextStyle(fontSize: 14),
                                                                      ),
                                                                      buttonStyleData: const ButtonStyleData(
                                                                        padding: EdgeInsets.only(right: 8),
                                                                      ),
                                                                      iconStyleData: const IconStyleData(
                                                                        icon: Icon(
                                                                          Icons.arrow_drop_down,
                                                                          color: Colors.black45,
                                                                        ),
                                                                        iconSize: 24,
                                                                      ),
                                                                      dropdownStyleData: DropdownStyleData(
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(15),
                                                                        ),
                                                                      ),
                                                                      menuItemStyleData: const MenuItemStyleData(
                                                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                                                      ),
                                                                      items: monthsList.map((month) {
                                                                        return DropdownMenuItem<int>(
                                                                          value: month,
                                                                          child: Text(month.toString()),
                                                                        );
                                                                      }).toList(),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(height: 10.h),
                                                              Text("Son Ödeme Tarihi"),
                                                              SizedBox(height: 5.h),
                                                              DropdownButtonFormField2<int>(
                                                                value: _selectedDueDay,
                                                                onChanged: (value) {
                                                                  setState(() {
                                                                    _selectedDueDay = value;
                                                                  });
                                                                },
                                                                isExpanded: true,
                                                                decoration: InputDecoration(
                                                                  contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                  isDense: true,
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                  ),
                                                                ),
                                                                hint: const Text(
                                                                  'Gün',
                                                                  style: TextStyle(fontSize: 14),
                                                                ),
                                                                buttonStyleData: const ButtonStyleData(
                                                                  padding: EdgeInsets.only(right: 8),
                                                                ),
                                                                iconStyleData: const IconStyleData(
                                                                  icon: Icon(
                                                                    Icons.arrow_drop_down,
                                                                    color: Colors.black45,
                                                                  ),
                                                                  iconSize: 24,
                                                                ),
                                                                dropdownStyleData: DropdownStyleData(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(15),
                                                                  ),
                                                                ),
                                                                menuItemStyleData: const MenuItemStyleData(
                                                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                                                ),
                                                                items: daysList.map((day) {
                                                                  return DropdownMenuItem<int>(
                                                                    value: day,
                                                                    child: Text(day.toString()),
                                                                  );
                                                                }).toList(),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Column(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  int maxId = 0; // Initialize with the lowest possible value
                                                                  for (var invoice in invoices) {
                                                                    if (invoice.id > maxId) {
                                                                      maxId = invoice.id;
                                                                    }
                                                                  }
                                                                  int newId = maxId + 1;
                                                                  final text = textController.text.trim();
                                                                  final priceText = platformPriceController.text.trim();
                                                                  double dprice = double.tryParse(priceText) ?? 0.0;
                                                                  String price = dprice.toStringAsFixed(2);
                                                                  final invoice = Invoice(
                                                                      id: newId,
                                                                      price: price,
                                                                      subCategory: 'Kira',
                                                                      category: "Diğer Giderler",
                                                                      name: text,
                                                                      periodDate: formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!),
                                                                      dueDate: _selectedDueDay != null
                                                                          ? formatDueDate(_selectedDueDay!, formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!))
                                                                          : null,
                                                                      difference: "do2"
                                                                  );
                                                                  onSave(invoice);
                                                                  if (text.isNotEmpty && priceText.isNotEmpty) {
                                                                    setState(() {
                                                                      rentTitleList.add(text);
                                                                      rentPriceList.add(price);
                                                                      formDataProvider2.setRentTitleValue(text, rentTitleList);
                                                                      formDataProvider2.setRentPriceValue(price, rentPriceList);
                                                                      formDataProvider2.calculateSumOfRent(rentPriceList);
                                                                      isEditingList = false; // Add a corresponding entry for the new item
                                                                      textController.clear();
                                                                      platformPriceController.clear();
                                                                      isTextFormFieldVisible = false;
                                                                      isAddButtonActive = false;
                                                                    });
                                                                  }
                                                                });
                                                              },
                                                              icon: Icon(Icons.check_circle, size: 26),
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  isTextFormFieldVisible = false;
                                                                  isAddButtonActive = false;
                                                                  textController.clear();
                                                                  platformPriceController.clear();
                                                                });
                                                              },
                                                              icon: Icon(Icons.cancel, size: 26),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          if (!isEditingList && !isTextFormFieldVisible)
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        hasRentSelected = true;
                                                        hasKitchenSelected = false;
                                                        hasCateringSelected = false;
                                                        hasEntertainmentSelected = false;
                                                        hasOtherSelected = false;
                                                        isAddButtonActive = true;
                                                        isTextFormFieldVisible = true;
                                                        isTextFormFieldVisibleND =false;
                                                        isTextFormFieldVisibleRD = false;
                                                        isTextFormFieldVisibleTH = false;
                                                        isTextFormFieldVisibleOther = false;
                                                        platformPriceController.clear();
                                                      });
                                                    },
                                                    child: Icon(Icons.add_circle, size: 26),
                                                  ),
                                                  if (formattedRentSum != "0,00")
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 43),
                                                      child: Text("Toplam: ${formattedRentSum}", style: TextStyle(fontSize: 20),),
                                                    ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: hasKitchenSelected ? Colors.black : Colors.black.withOpacity(0.5),
                                        width: hasKitchenSelected ? 4 : 2,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: isAddButtonActiveND ? null : handleKitchenContainerTouch,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text("Mutfak",style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)
                                          ),
                                          if (kitchenTitleList.isNotEmpty && kitchenPriceList.isNotEmpty)
                                            Container(
                                              child:
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: kitchenTitleList.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  double sum2 = double.parse(kitchenPriceList[i]);
                                                  String convertSumo = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum2);
                                                  return Container(
                                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            kitchenTitleList[i],
                                                            style: TextStyle(fontSize: 20),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            textAlign: TextAlign.right,
                                                            convertSumo,
                                                            style: TextStyle(fontSize: 20),
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
                                                            _showEditDialog(context, i, 2, 0); // Show the edit dialog
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          if (isTextFormFieldVisibleND && hasKitchenSelected)
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: TextFormField(
                                                      controller: NDtextController,
                                                      decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        hintText: 'ABA',
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: TextFormField(
                                                      controller: NDplatformPriceController,
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
                                                          final text = NDtextController.text.trim();
                                                          final priceText = NDplatformPriceController.text.trim();
                                                          if (text.isNotEmpty && priceText.isNotEmpty) {
                                                            double dprice = double.tryParse(priceText) ?? 0.0;
                                                            String price = dprice.toStringAsFixed(2);
                                                            setState(() {
                                                              kitchenTitleList.add(text);
                                                              kitchenPriceList.add(price);
                                                              formDataProvider2.setKitchenTitleValue(text, kitchenTitleList);
                                                              formDataProvider2.setKitchenPriceValue(price, kitchenPriceList);
                                                              formDataProvider2.calculateSumOfKitchen(kitchenPriceList);
                                                              isEditingListND = false; // Add a corresponding entry for the new item
                                                              NDtextController.clear();
                                                              NDplatformPriceController.clear();
                                                              isTextFormFieldVisibleND = false;
                                                              isAddButtonActiveND = false;
                                                            });
                                                          }
                                                        },
                                                        icon: Icon(Icons.check_circle, size: 26),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            isTextFormFieldVisibleND = false;
                                                            isAddButtonActiveND = false;
                                                            NDtextController.clear();
                                                            NDplatformPriceController.clear();
                                                          });
                                                        },
                                                        icon: Icon(Icons.cancel, size: 26),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (!isEditingListND && !isTextFormFieldVisibleND)
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        hasRentSelected = false;
                                                        hasKitchenSelected = true;
                                                        hasCateringSelected = false;
                                                        hasEntertainmentSelected = false;
                                                        hasOtherSelected = false;
                                                        isAddButtonActiveND = true;
                                                        isTextFormFieldVisible = false;
                                                        isTextFormFieldVisibleND =true;
                                                        isTextFormFieldVisibleRD = false;
                                                        isTextFormFieldVisibleTH = false;
                                                        isTextFormFieldVisibleOther = false;
                                                        NDplatformPriceController.clear();
                                                      });
                                                    },
                                                    child: Icon(Icons.add_circle, size: 26),
                                                  ),
                                                  if (convertSum2 != "0,00")
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 43),
                                                      child: Text("Toplam: ${convertSum2}", style: TextStyle(fontSize: 20),),
                                                    ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: hasCateringSelected ? Colors.black : Colors.black.withOpacity(0.5),
                                        width: hasCateringSelected ? 4 : 2,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: isAddButtonActiveRD ? null :handleCateringContainerTouch,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text("Yeme İçme",style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)
                                          ),
                                          if (cateringTitleList.isNotEmpty && cateringPriceList.isNotEmpty)
                                            Container(
                                              child:
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: cateringTitleList.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  double sum2 = double.parse(cateringPriceList[i]);
                                                  String convertSumo = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum2);
                                                  return Container(
                                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            cateringTitleList[i],
                                                            style: TextStyle(fontSize: 20),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            textAlign: TextAlign.right,
                                                            convertSumo,
                                                            style: TextStyle(fontSize: 20),
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
                                                            _showEditDialog(context, i, 3, 0); // Show the edit dialog
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          if (isTextFormFieldVisibleRD && hasCateringSelected)
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: TextFormField(
                                                      controller: RDtextController,
                                                      decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        hintText: 'ABA',
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: TextFormField(
                                                      controller: RDplatformPriceController,
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
                                                          final text = RDtextController.text.trim();
                                                          final priceText = RDplatformPriceController.text.trim();
                                                          if (text.isNotEmpty && priceText.isNotEmpty) {
                                                            double dprice = double.tryParse(priceText) ?? 0.0;
                                                            String price = dprice.toStringAsFixed(2);
                                                            setState(() {
                                                              cateringTitleList.add(text);
                                                              cateringPriceList.add(price);
                                                              formDataProvider2.setCateringTitleValue(text, cateringTitleList);
                                                              formDataProvider2.setCateringPriceValue(price, cateringPriceList);
                                                              formDataProvider2.calculateSumOfCatering(cateringPriceList);
                                                              isEditingListRD = false; // Add a corresponding entry for the new item
                                                              RDtextController.clear();
                                                              RDplatformPriceController.clear();
                                                              isTextFormFieldVisibleRD = false;
                                                              isAddButtonActiveRD = false;
                                                            });
                                                          }
                                                        },
                                                        icon: Icon(Icons.check_circle, size: 26),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            isTextFormFieldVisibleRD = false;
                                                            isAddButtonActiveRD = false;
                                                            RDtextController.clear();
                                                            RDplatformPriceController.clear();
                                                          });
                                                        },
                                                        icon: Icon(Icons.cancel, size: 26),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (!isEditingListRD && !isTextFormFieldVisibleRD)
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        hasRentSelected = false;
                                                        hasKitchenSelected = false;
                                                        hasCateringSelected = true;
                                                        hasEntertainmentSelected = false;
                                                        hasOtherSelected = false;
                                                        isAddButtonActiveRD = true;
                                                        isTextFormFieldVisible = false;
                                                        isTextFormFieldVisibleND =false;
                                                        isTextFormFieldVisibleRD = true;
                                                        isTextFormFieldVisibleTH = false;
                                                        isTextFormFieldVisibleOther = false;
                                                        RDplatformPriceController.clear();
                                                      });
                                                    },
                                                    child: Icon(Icons.add_circle, size: 26),
                                                  ),
                                                  if (convertSum3 != "0,00")
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 43),
                                                      child: Text("Toplam: ${convertSum3}", style: TextStyle(fontSize: 20),),
                                                    ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: hasEntertainmentSelected ? Colors.black : Colors.black.withOpacity(0.5),
                                        width: hasEntertainmentSelected ? 4 : 2,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: isAddButtonActiveTH ? null :handleEntContainerTouch,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text("Eğlence",style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)
                                          ),
                                          if (entertainmentTitleList.isNotEmpty && entertainmentPriceList.isNotEmpty)
                                            Container(
                                              child:
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: entertainmentTitleList.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  double sum2 = double.parse(entertainmentPriceList[i]);
                                                  String convertSumo = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum2);
                                                  return Container(
                                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            entertainmentTitleList[i],
                                                            style: TextStyle(fontSize: 20),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            textAlign: TextAlign.right,
                                                            convertSumo,
                                                            style: TextStyle(fontSize: 20),
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
                                                            _showEditDialog(context, i, 4, 0); // Show the edit dialog
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          if (isTextFormFieldVisibleTH && hasEntertainmentSelected)
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: TextFormField(
                                                      controller: THtextController,
                                                      decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        hintText: 'ABA',
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: TextFormField(
                                                      controller: THplatformPriceController,
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
                                                          final text = THtextController.text.trim();
                                                          final priceText = THplatformPriceController.text.trim();
                                                          if (text.isNotEmpty && priceText.isNotEmpty) {
                                                            double dprice = double.tryParse(priceText) ?? 0.0;
                                                            String price = dprice.toStringAsFixed(2);
                                                            setState(() {
                                                              entertainmentTitleList.add(text);
                                                              entertainmentPriceList.add(price);
                                                              formDataProvider2.setEntertainmentTitleValue(text, entertainmentTitleList);
                                                              formDataProvider2.setEntertainmentPriceValue(price, entertainmentPriceList);
                                                              formDataProvider2.calculateSumOfEnt(entertainmentPriceList);
                                                              isEditingListTH = false; // Add a corresponding entry for the new item
                                                              THtextController.clear();
                                                              THplatformPriceController.clear();
                                                              isTextFormFieldVisibleTH = false;
                                                              isAddButtonActiveTH = false;
                                                            });
                                                          }
                                                        },
                                                        icon: Icon(Icons.check_circle, size: 26),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            isTextFormFieldVisibleTH = false;
                                                            isAddButtonActiveTH = false;
                                                            THtextController.clear();
                                                            THplatformPriceController.clear();
                                                          });
                                                        },
                                                        icon: Icon(Icons.cancel, size: 26),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (!isEditingListTH && !isTextFormFieldVisibleTH)
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        hasRentSelected = false;
                                                        hasKitchenSelected = false;
                                                        hasCateringSelected = false;
                                                        hasEntertainmentSelected = true;
                                                        hasOtherSelected = false;
                                                        isAddButtonActiveTH = true;
                                                        isTextFormFieldVisible = false;
                                                        isTextFormFieldVisibleND =false;
                                                        isTextFormFieldVisibleRD = false;
                                                        isTextFormFieldVisibleTH = true;
                                                        isTextFormFieldVisibleOther = false;
                                                        THplatformPriceController.clear();
                                                      });
                                                    },
                                                    child: Icon(Icons.add_circle, size: 26),
                                                  ),
                                                  if (convertSum4 != "0,00")
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 43),
                                                      child: Text("Toplam: ${convertSum4}", style: TextStyle(fontSize: 20),),
                                                    ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: Radius.circular(10),
                                    color: hasOtherSelected ? Colors.black : Colors.black.withOpacity(0.5),
                                    strokeWidth: hasOtherSelected ? 4 : 2,
                                    dashPattern: [6,3],
                                    child: Container(
                                      width: double.infinity,
                                      child: InkWell(
                                        onTap: isAddButtonActiveOther ? null :handleOtherContainerTouch,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Text("Diğer",style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)
                                            ),
                                            if (otherTitleList.isNotEmpty && otherPriceList.isNotEmpty)
                                              Container(
                                                child:
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: otherTitleList.length,
                                                  itemBuilder: (BuildContext context, int i) {
                                                    double sum2 = double.parse(otherPriceList[i]);
                                                    String convertSumo = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum2);
                                                    return Container(
                                                      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                      child: Row(
                                                        children: [
                                                          Flexible(
                                                            flex: 2,
                                                            fit: FlexFit.tight,
                                                            child: Text(
                                                              otherTitleList[i],
                                                              style: TextStyle(fontSize: 20),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          Flexible(
                                                            flex: 2,
                                                            fit: FlexFit.tight,
                                                            child: Text(
                                                              textAlign: TextAlign.right,
                                                              convertSumo,
                                                              style: TextStyle(fontSize: 20),
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
                                                              _showEditDialog(context, i, 5, 0); // Show the edit dialog
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            if (isTextFormFieldVisibleOther && hasOtherSelected)
                                              Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: otherTextController,
                                                        decoration: InputDecoration(
                                                          border: InputBorder.none,
                                                          hintText: 'ABA',
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: otherPlatformPriceController,
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
                                                            final text = otherTextController.text.trim();
                                                            final priceText = otherPlatformPriceController.text.trim();
                                                            if (text.isNotEmpty && priceText.isNotEmpty) {
                                                              double dprice = double.tryParse(priceText) ?? 0.0;
                                                              String price = dprice.toStringAsFixed(2);
                                                              setState(() {
                                                                otherTitleList.add(text);
                                                                otherPriceList.add(price);
                                                                formDataProvider2.setOtherTitleValue(text, otherTitleList);
                                                                formDataProvider2.setOtherPriceValue(price, otherPriceList);
                                                                formDataProvider2.calculateSumOfOther(otherPriceList);
                                                                isEditingListOther = false; // Add a corresponding entry for the new item
                                                                otherTextController.clear();
                                                                otherPlatformPriceController.clear();
                                                                isTextFormFieldVisibleOther = false;
                                                                isAddButtonActiveOther = false;
                                                              });
                                                            }
                                                          },
                                                          icon: Icon(Icons.check_circle, size: 26),
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              isTextFormFieldVisibleOther = false;
                                                              isAddButtonActiveOther = false;
                                                              otherTextController.clear();
                                                              otherPlatformPriceController.clear();
                                                            });
                                                          },
                                                          icon: Icon(Icons.cancel, size: 26),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (!isEditingListOther && !isTextFormFieldVisibleOther)
                                              Container(
                                                padding: EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          hasRentSelected = false;
                                                          hasKitchenSelected = false;
                                                          hasCateringSelected = false;
                                                          hasEntertainmentSelected = false;
                                                          hasOtherSelected = true;
                                                          isAddButtonActiveOther = true;
                                                          isTextFormFieldVisible = false;
                                                          isTextFormFieldVisibleND =false;
                                                          isTextFormFieldVisibleRD = false;
                                                          isTextFormFieldVisibleTH = false;
                                                          isTextFormFieldVisibleOther = true;
                                                          otherPlatformPriceController.clear();
                                                        });
                                                      },
                                                      child: Icon(Icons.add_circle, size: 26),
                                                    ),
                                                    if (convertSum5 != "0,00")
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 43),
                                                        child: Text("Toplam: ${convertSum5}", style: TextStyle(fontSize: 20),),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  ListView.builder(
                                    itemCount: sharedPreferencesData.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text(sharedPreferencesData[index]),
                                      );
                                    },
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}
