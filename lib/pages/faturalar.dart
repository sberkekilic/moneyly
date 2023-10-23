import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../deneme.dart';

class Invoice {
  final String category;
  final String name;
  final int periodDate;
  final int? dueDate;

  Invoice({
    required this.category,
    required this.name,
    required this.periodDate,
    this.dueDate,
  });

  // JSON serialization and deserialization methods
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'name': name,
      'periodDate': periodDate,
      'dueDate': dueDate,
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      category: json['category'],
      name: json['name'],
      periodDate: json['periodDate'],
      dueDate: json['dueDate'] != null ? json['dueDate'] : null,
    );
  }

  String toDisplayString() {
    return 'Category: $category\nName: $name\nPeriod Date: $periodDate\nDue Date: ${dueDate ?? 'N/A'}';
  }
}

class Bills extends StatefulWidget {
  const Bills({Key? key}) : super(key: key);

  @override
  State<Bills> createState() => _BillsState();
}

class _BillsState extends State<Bills> {
  List<String> sharedPreferencesData = [];
  List<String> desiredKeys = ['invoices', 'homeBillsTitleList2', 'homeBillsPriceList2', 'hasHomeSelected2', 'sumOfHome2', 'internetTitleList2', 'internetPriceList2', 'hasInternetSelected2', 'sumOfInternet2', 'phoneTitleList2', 'phonePriceList2', 'hasPhoneSelected2', 'sumOfPhone2'];
  final List<Invoice> invoices = [];
  bool hasHomeSelected = false;
  bool hasInternetSelected = false;
  bool hasPhoneSelected = false;

  List<String> homeBillsTitleList = [];
  List<String> internetTitleList = [];
  List<String> phoneTitleList = [];

  List<String> homeBillsPriceList = [];
  List<String> internetPriceList = [];
  List<String> phonePriceList = [];

  double sumOfHomeBills = 0.0;
  double sumOfInternet = 0.0;
  double sumOfPhone = 0.0;

  String convertSum = "";
  String convertSum2 = "";
  String convertSum3 = "";

  List<TextEditingController> editTextControllers = [];
  List<TextEditingController> NDeditTextControllers = [];
  List<TextEditingController> RDeditTextControllers = [];

  final TextEditingController textController = TextEditingController();
  TextEditingController NDtextController = TextEditingController();
  TextEditingController RDtextController = TextEditingController();

  final TextEditingController platformPriceController = TextEditingController();
  TextEditingController NDplatformPriceController = TextEditingController();
  TextEditingController RDplatformPriceController = TextEditingController();

  int? _selectedBillingDay;
  int? _selectedDueDay;

  List<int> daysList = List.generate(31, (index) => index + 1);

  TextEditingController editController = TextEditingController();
  TextEditingController NDeditController = TextEditingController();
  TextEditingController RDeditController = TextEditingController();

  bool isTextFormFieldVisible = false;
  bool isTextFormFieldVisibleND = false;
  bool isTextFormFieldVisibleRD = false;

  bool isEditingList = false;
  bool isEditingListND = false;
  bool isEditingListRD = false;

  bool isAddButtonActive = false;
  bool isAddButtonActiveND = false;
  bool isAddButtonActiveRD = false;

  Future<void> handleHomeBillsContainer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasHomeSelected2', true);
    await prefs.setBool('hasInternetSelected2', false);
    await prefs.setBool('hasPhoneSelected2', false);
    setState(() {
      hasHomeSelected = true;
      hasInternetSelected = false;
      hasPhoneSelected = false;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isEditingList = false;
      _load();
    });
  }
  Future<void> handleInternetContainerTouch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasHomeSelected2', false);
    await prefs.setBool('hasInternetSelected2', true);
    await prefs.setBool('hasPhoneSelected2', false);
    setState(() {
      hasHomeSelected = false;
      hasInternetSelected = true;
      hasPhoneSelected = false;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isEditingListND = false;
      _load();
    });
  }
  Future<void> handlePhoneContainerTouch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasHomeSelected2', false);
    await prefs.setBool('hasInternetSelected2', false);
    await prefs.setBool('hasPhoneSelected2', true);
    setState(() {
      hasHomeSelected = false;
      hasInternetSelected = false;
      hasPhoneSelected = true;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isEditingListRD = false;
      _load();
    });
  }

  void goToPreviousPage() {
    Navigator.pop(context);
  }
  void goToNextPage() {
    Navigator.pushNamed(context, 'diger-giderler');
  }

  void _showEditDialog(BuildContext context, int index, int orderIndex) {
    final formDataProvider2 = Provider.of<FormDataProvider2>(context, listen: false);

    TextEditingController selectedEditController = TextEditingController();
    TextEditingController selectedPriceController = TextEditingController();

    switch (orderIndex) {
      case 1:
        TextEditingController editController =
        TextEditingController(text: homeBillsTitleList[index]);
        TextEditingController priceController =
        TextEditingController(text: homeBillsPriceList[index]);
        selectedEditController = editController;
        selectedPriceController = priceController;
        break;
      case 2:
        TextEditingController NDeditController =
        TextEditingController(text: internetTitleList[index]);
        TextEditingController NDpriceController =
        TextEditingController(text: internetPriceList[index]);
        selectedEditController = NDeditController;
        selectedPriceController = NDpriceController;
        break;
      case 3:
        TextEditingController RDeditController =
        TextEditingController(text: phoneTitleList[index]);
        TextEditingController RDpriceController =
        TextEditingController(text: phonePriceList[index]);
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
          title: Text('Edit Item',style: GoogleFonts.montserrat(fontSize: 20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(child: Text("Item", style: GoogleFonts.montserrat(fontSize: 18),), alignment: Alignment.centerLeft,),
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
                style: GoogleFonts.montserrat(fontSize: 20),
              ),
              SizedBox(height: 10),
              Align(child: Text("Price",style: GoogleFonts.montserrat(fontSize: 18)), alignment: Alignment.centerLeft),
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
                style: GoogleFonts.montserrat(fontSize: 20),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              Align(child: Text("Period",style: GoogleFonts.montserrat(fontSize: 18)), alignment: Alignment.centerLeft),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
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
              SizedBox(height: 10),
              Align(child: Text("Due Date",style: GoogleFonts.montserrat(fontSize: 18)), alignment: Alignment.centerLeft),
              SizedBox(height: 10),
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
                      homeBillsTitleList[index] = selectedEditController.text;
                      homeBillsPriceList[index] = price;
                      formDataProvider2.setHomeTitleValue(selectedEditController.text, homeBillsTitleList);
                      formDataProvider2.setHomePriceValue(price, homeBillsPriceList);
                      formDataProvider2.calculateSumOfHome(homeBillsPriceList);
                      final invoice = Invoice(
                        category: "Ev Faturaları",
                        name: selectedEditController.text,
                        periodDate: _selectedBillingDay!,
                        dueDate: _selectedDueDay != null
                            ? _selectedDueDay
                            : null,
                      );
                      editInvoice(index, invoice);
                      break;
                    case 2:
                      final priceText = selectedPriceController.text.trim();
                      double dprice = double.tryParse(priceText) ?? 0.0;
                      String price = dprice.toStringAsFixed(2);
                      internetTitleList[index] = selectedEditController.text;
                      internetPriceList[index] = price;
                      formDataProvider2.setInternetTitleValue(selectedEditController.text, internetTitleList);
                      formDataProvider2.setInternetPriceValue(price, internetPriceList);
                      formDataProvider2.calculateSumOfInternet(internetPriceList);
                      break;
                    case 3:
                      final priceText = selectedPriceController.text.trim();
                      double dprice = double.tryParse(priceText) ?? 0.0;
                      String price = dprice.toStringAsFixed(2);
                      phoneTitleList[index] = selectedEditController.text;
                      phonePriceList[index] = price;
                      formDataProvider2.setPhoneTitleValue(selectedEditController.text, phoneTitleList);
                      formDataProvider2.setPhonePriceValue(price, phonePriceList);
                      formDataProvider2.calculateSumOfPhone(phonePriceList);
                      break;
                  }
                });
                _load();
                Navigator.of(context).pop();
              },

              child: Text('Save'),
            ),
            TextButton(
                onPressed: () {
                  setState(() {
                    switch (orderIndex){
                      case 1:
                        homeBillsTitleList.removeAt(index);
                        homeBillsPriceList.removeAt(index);
                        formDataProvider2.removeHomeTitleValue(homeBillsTitleList);
                        formDataProvider2.removeHomePriceValue(homeBillsPriceList);
                        formDataProvider2.calculateSumOfHome(homeBillsPriceList);
                        removeInvoice(index);
                        isEditingList = false;
                        isAddButtonActive = false;
                        break;
                      case 2:
                        internetTitleList.removeAt(index);
                        internetPriceList.removeAt(index);
                        formDataProvider2.removeInternetTitleValue(internetTitleList);
                        formDataProvider2.removeInternetPriceValue(internetPriceList);
                        formDataProvider2.calculateSumOfInternet(internetPriceList);
                        isEditingListND = false;
                        isAddButtonActiveND = false;
                        break;
                      case 3:
                        phoneTitleList.removeAt(index);
                        phonePriceList.removeAt(index);
                        formDataProvider2.removePhoneTitleValue(phoneTitleList);
                        formDataProvider2.removePhonePriceValue(phoneTitleList);
                        formDataProvider2.calculateSumOfPhone(phonePriceList);
                        isEditingListRD = false;
                        isAddButtonActiveRD = false;
                        break;
                    }
                    _load();
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
    final ab1 = prefs.getBool('hasHomeSelected2') ?? false;
    final ab2 = prefs.getBool('hasInternetSelected2') ?? false;
    final ab3 = prefs.getBool('hasPhoneSelected2') ?? false;
    final bb1 = prefs.getStringList('homeBillsTitleList2') ?? [];
    final bb2 = prefs.getStringList('internetTitleList2') ?? [];
    final bb3 = prefs.getStringList('phoneTitleList2') ?? [];
    final cb1 = prefs.getStringList('homeBillsPriceList2') ?? [];
    final cb2 = prefs.getStringList('internetPriceList2') ?? [];
    final cb3 = prefs.getStringList('phonePriceList2') ?? [];
    final db1 = prefs.getDouble('sumOfHome2') ?? 0.0;
    final db2 = prefs.getDouble('sumOfInternet2') ?? 0.0;
    final db3 = prefs.getDouble('sumOfPhone2') ?? 0.0;
    final eb1 = prefs.getStringList('invoices') ?? [];
    setState(() {
      hasHomeSelected = ab1;
      hasInternetSelected = ab2;
      hasPhoneSelected = ab3;
      homeBillsTitleList = bb1;
      internetTitleList = bb2;
      phoneTitleList = bb3;
      homeBillsPriceList = cb1;
      internetPriceList = cb2;
      phonePriceList = cb3;
      sumOfHomeBills = db1;
      sumOfInternet = db2;
      sumOfPhone = db3;
      for (final invoiceString in eb1) {
        final Map<String, dynamic> invoiceJson = jsonDecode(invoiceString);
        final Invoice invoice = Invoice.fromJson(invoiceJson);
        invoices.add(invoice);
      }
      loadSharedPreferencesData(desiredKeys);
    });
    convertSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfHomeBills);
    convertSum2 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfInternet);
    convertSum3 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfPhone);
  }

  Future<void> setSumAll(double value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('sumOfBills2', value);
  }

  Future<void> saveInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final invoiceList = invoices.map((invoice) => invoice.toJson()).toList();
    await prefs.setStringList('invoices', invoiceList.map((invoice) => jsonEncode(invoice)).toList());
  }

  void onSave(Invoice invoice) {
    setState(() {
      invoices.add(invoice);
    });
    saveInvoices();
  }

  void editInvoice(int index, Invoice updatedInvoice) {
    setState(() {
      invoices[index] = updatedInvoice;
    });
    saveInvoices();
  }

  void removeInvoice(int index) {
    setState(() {
      invoices.removeAt(index);
    });
    saveInvoices();
  }

  @override
  Widget build(BuildContext context) {
    final formDataProvider2 = Provider.of<FormDataProvider2>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
    double sumAll = 0.0;
    sumAll += sumOfHomeBills;
    sumAll += sumOfInternet;
    sumAll += sumOfPhone;
    setSumAll(sumAll);
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
                      Navigator.pushNamed(context, 'abonelikler');
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.black), // Replace with the desired left icon
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    },
                    icon: Icon(Icons.clear, color: Colors.black), // Replace with the desired right icon
                  ),
                ],
              ),
              Text(
                "Gider Ekle",
                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 28, fontWeight: FontWeight.normal),
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
                      child: Text('Sonraki', style: GoogleFonts.montserrat(fontSize: 18),),
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
              color: Color(0xfff0f0f1),
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    child: ListView(
                      controller: ScrollController(initialScrollOffset: (screenWidth - 60) / 3 + 10),
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
                                Align(child: Text("Gelir", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 15)), alignment: Alignment.center),
                                SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                      height: 8,
                                      width: (screenWidth-60) / 3,
                                      color: Color(
                                          0xff1ab738)
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
                                Align(child: Text("Abonelikler", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 15)), alignment: Alignment.center),
                                SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 8,
                                    width: (screenWidth-60) / 3,
                                    color: Color(0xff1ab738),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          splashColor: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 50,
                            width: (screenWidth-60) / 3,
                            child: Column(
                              children: [
                                Align(child: Text("Faturalar", style: GoogleFonts.montserrat(color: Color(0xff1ab738), fontWeight: FontWeight.bold, fontSize: 15)), alignment: Alignment.center),
                                SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 8,
                                    width: (screenWidth-60) / 3,
                                    color: Color(0xff1ab738),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          splashColor: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 50,
                            width: ((screenWidth-60) / 3) + 10,
                            child: Column(
                              children: [
                                Align(
                                    child: Text(
                                        "Diğer Giderler",
                                        style: GoogleFonts.montserrat(
                                            color: Color(0xffc6c6c7),
                                            fontSize: 15)
                                    ),
                                    alignment: Alignment.center
                                ),
                                SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 8,
                                    width: ((screenWidth-60) / 3) + 10,
                                    color: Color(
                                        0xffc6c6c7),
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
                        children: [Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: hasHomeSelected ? Colors.black : Colors.black.withOpacity(0.5),
                                        width: hasHomeSelected ? 4 : 2,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if(isAddButtonActive==false){
                                          handleHomeBillsContainer();
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
                                              child: Text("Ev Faturaları",style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),)
                                          ),
                                          if (homeBillsTitleList.isNotEmpty && homeBillsPriceList.isNotEmpty)
                                            Container(
                                              child:
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: homeBillsTitleList.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  double sum2 = double.parse(homeBillsPriceList[i]);
                                                  String convertSumo = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum2);
                                                  return Container(
                                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            homeBillsTitleList[i],
                                                            style: GoogleFonts.montserrat(fontSize: 20),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            textAlign: TextAlign.right,
                                                            convertSumo,
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
                                                            _showEditDialog(context, i, 1); // Show the edit dialog
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          if (isTextFormFieldVisible && hasHomeSelected)
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              child: Column(
                                                children: [
                                                  Row(
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
                                                              final invoice = Invoice(
                                                                category: "Ev Faturaları",
                                                                name: text,
                                                                periodDate: _selectedBillingDay!,
                                                                dueDate: _selectedDueDay != null
                                                                    ? _selectedDueDay
                                                                    : null,
                                                              );
                                                              onSave(invoice);
                                                              if (text.isNotEmpty && priceText.isNotEmpty) {
                                                                double dprice = double.tryParse(priceText) ?? 0.0;
                                                                String price = dprice.toStringAsFixed(2);
                                                                setState(() {
                                                                  homeBillsTitleList.add(text);
                                                                  homeBillsPriceList.add(price);
                                                                  formDataProvider2.setHomeTitleValue(text, homeBillsTitleList);
                                                                  formDataProvider2.setHomePriceValue(price, homeBillsPriceList);
                                                                  formDataProvider2.calculateSumOfHome(homeBillsPriceList);
                                                                  isEditingList = false; // Add a corresponding entry for the new item
                                                                  textController.clear();
                                                                  platformPriceController.clear();
                                                                  isTextFormFieldVisible = false;
                                                                  isAddButtonActive = false;
                                                                  _load();
                                                                });
                                                              }
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
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: DropdownButtonFormField<int>(
                                                          value: _selectedBillingDay,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              _selectedBillingDay = value;
                                                            });
                                                          },
                                                          decoration: InputDecoration(labelText: 'Billing Day'),
                                                          items: daysList.map((day) {
                                                            return DropdownMenuItem<int>(
                                                              value: day,
                                                              child: Text(day.toString()),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: DropdownButtonFormField<int>(
                                                          value: _selectedDueDay,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              _selectedDueDay = value;
                                                            });
                                                          },
                                                          decoration: InputDecoration(labelText: 'Due Day (optional)'),
                                                          items: daysList.map((day) {
                                                            return DropdownMenuItem<int>(
                                                              value: day,
                                                              child: Text(day.toString()),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
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
                                                        hasHomeSelected = true;
                                                        hasInternetSelected = false;
                                                        hasPhoneSelected = false;
                                                        isAddButtonActive = true;
                                                        isTextFormFieldVisible = true;
                                                        isTextFormFieldVisibleND =false;
                                                        isTextFormFieldVisibleRD = false;
                                                        platformPriceController.clear();
                                                        if (homeBillsTitleList.isEmpty){
                                                          print("homeBillsTitleList is empty!");
                                                        }
                                                        homeBillsTitleList.forEach((element) {
                                                          print('itemList: $element');
                                                        });
                                                        homeBillsPriceList.forEach((element) {
                                                          print('pricesList: $element');
                                                        });
                                                        //print("isEditingList: $isEditingList");
                                                        //print("isEditingListND: $isEditingList");
                                                        //print("isEditingListRD: $isEditingList");
                                                        //print("isTextFormFieldVisible: $isTextFormFieldVisible");
                                                        //print("isTextFormFieldVisibleND: $isTextFormFieldVisibleND");
                                                        //print("isTextFormFieldVisibleRD: $isTextFormFieldVisibleRD");
                                                      });
                                                    },
                                                    child: Icon(Icons.add_circle, size: 26),
                                                  ),
                                                  if (convertSum != "0,00")
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 43),
                                                      child: Text("Toplam: $convertSum", style: GoogleFonts.montserrat(fontSize: 20),),
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
                                        color: hasInternetSelected ? Colors.black : Colors.black.withOpacity(0.5),
                                        width: hasInternetSelected ? 4 : 2,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if(isAddButtonActive==false){
                                          handleInternetContainerTouch();
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
                                              child: Text("İnternet",style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),)
                                          ),
                                          if (internetTitleList.isNotEmpty && internetPriceList.isNotEmpty)
                                            Container(
                                              child:
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: internetTitleList.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  return Container(
                                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            internetTitleList[i],
                                                            style: GoogleFonts.montserrat(fontSize: 20),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            textAlign: TextAlign.right,
                                                            internetPriceList[i].toString(),
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
                                                            _showEditDialog(context, i, 2); // Show the edit dialog
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          if (isTextFormFieldVisibleND && hasInternetSelected)
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
                                                              internetTitleList.add(text);
                                                              internetPriceList.add(price);
                                                              formDataProvider2.setInternetTitleValue(text, internetTitleList);
                                                              formDataProvider2.setInternetPriceValue(price, internetPriceList);
                                                              formDataProvider2.calculateSumOfInternet(internetPriceList);
                                                              isEditingListND = false; // Add a corresponding entry for the new item
                                                              NDtextController.clear();
                                                              NDplatformPriceController.clear();
                                                              isTextFormFieldVisibleND = false;
                                                              isAddButtonActiveND = false;
                                                              _load();
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
                                                        hasHomeSelected = false;
                                                        hasInternetSelected = true;
                                                        hasPhoneSelected = false;
                                                        isAddButtonActiveND = true;
                                                        isTextFormFieldVisible = false;
                                                        isTextFormFieldVisibleND =true;
                                                        isTextFormFieldVisibleRD = false;
                                                        NDplatformPriceController.clear();
                                                      });
                                                    },
                                                    child: Icon(Icons.add_circle, size: 26),
                                                  ),
                                                  if (convertSum2 != "0,00")
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 43),
                                                      child: Text("Toplam: $convertSum2", style: GoogleFonts.montserrat(fontSize: 20),),
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
                                        color: hasPhoneSelected ? Colors.black : Colors.black.withOpacity(0.5),
                                        width: hasPhoneSelected ? 4 : 2,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if(isAddButtonActive==false){
                                          handlePhoneContainerTouch();
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
                                              child: Text("Telefon",style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),)
                                          ),
                                          if (phoneTitleList.isNotEmpty && phonePriceList.isNotEmpty)
                                            Container(
                                              child:
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: phoneTitleList.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  return Container(
                                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            phoneTitleList[i],
                                                            style: GoogleFonts.montserrat(fontSize: 20),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            textAlign: TextAlign.right,
                                                            phonePriceList[i].toString(),
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
                                                            _showEditDialog(context, i, 3); // Show the edit dialog
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          if (isTextFormFieldVisibleRD && hasPhoneSelected)
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
                                                              phoneTitleList.add(text);
                                                              phonePriceList.add(price);
                                                              formDataProvider2.setPhoneTitleValue(text, phoneTitleList);
                                                              formDataProvider2.setPhonePriceValue(price, phonePriceList);
                                                              formDataProvider2.calculateSumOfPhone(phonePriceList);
                                                              isEditingListRD = false; // Add a corresponding entry for the new item
                                                              RDtextController.clear();
                                                              RDplatformPriceController.clear();
                                                              isTextFormFieldVisibleRD = false;
                                                              isAddButtonActiveRD = false;
                                                              _load();
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
                                                        hasHomeSelected = false;
                                                        hasInternetSelected = false;
                                                        hasPhoneSelected = true;
                                                        isAddButtonActiveRD = true;
                                                        isTextFormFieldVisible = false;
                                                        isTextFormFieldVisibleND =false;
                                                        isTextFormFieldVisibleRD = true;
                                                        RDplatformPriceController.clear();
                                                        if (phoneTitleList.isEmpty){
                                                          print("homeBillsTitleList is empty!");
                                                        }
                                                        phoneTitleList.forEach((element) {
                                                          print('itemList: $element');
                                                        });
                                                        phonePriceList.forEach((element) {
                                                          print('pricesList: $element');
                                                        });
                                                        //print("isEditingList: $isEditingList");
                                                        //print("isEditingListND: $isEditingList");
                                                        //print("isEditingListRD: $isEditingList");
                                                        //print("isTextFormFieldVisible: $isTextFormFieldVisible");
                                                        //print("isTextFormFieldVisibleND: $isTextFormFieldVisibleND");
                                                        //print("isTextFormFieldVisibleRD: $isTextFormFieldVisibleRD");
                                                      });
                                                    },
                                                    child: Icon(Icons.add_circle, size: 26),
                                                  ),
                                                  if (convertSum3 != "0,00")
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 43),
                                                      child: Text("Toplam: $convertSum3", style: GoogleFonts.montserrat(fontSize: 20),),
                                                    ),
                                                ],
                                              ),
                                            ),
                                        ],
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
