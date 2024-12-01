import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/blocs/form-bloc.dart';
import 'package:moneyly/pages/add-expense/abonelikler.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'faturalar.dart';

class OtherExpenses extends StatefulWidget {
  const OtherExpenses({Key? key}) : super(key: key);

  @override
  State<OtherExpenses> createState() => _OtherExpensesState();
}

class _OtherExpensesState extends State<OtherExpenses> {
  FocusNode platformPriceFocusNode = FocusNode();
  FocusNode textFocusNode = FocusNode();
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
  List<String> monthNames = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

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
    context.go('/page6');
  }

  void _showEditDialog(BuildContext context, int index, int orderIndex, int id) {
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
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              title: Text('Edit Item id:$id',style: GoogleFonts.montserrat(fontSize: 20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          "Item",
                          style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black)
                      )
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: selectedEditController,
                    decoration: InputDecoration(
                      hintText: "e.g., Subscription",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(width: 2, color: Colors.black),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: GoogleFonts.montserrat(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerLeft, child: Text("Price",style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black))),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: selectedPriceController,
                    decoration: InputDecoration(
                      hintText: "e.g., 10.00",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(width: 2, color: Colors.black),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: GoogleFonts.montserrat(fontSize: 20),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      NumberTextInputFormatter(
                        allowNegative: false,
                        overrideDecimalPoint: true,
                        insertDecimalPoint: false,
                        insertDecimalDigits: true,
                        decimalDigits: 2,
                        groupDigits: 3,
                        decimalSeparator: ',',
                        groupSeparator: '.',
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerLeft, child: Text("Period Date",style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: PullDownButton(
                            itemBuilder: (context) => daysList
                                .map(
                                  (day) => PullDownMenuItem(
                                  onTap: () {
                                    FocusScope.of(context).unfocus(); // Unfocus the TextFormField
                                    setState(() {
                                      _selectedBillingDay = day;
                                    });
                                  },
                                  title: day.toString()
                              ),
                            ).toList(),
                            buttonBuilder: (context, showMenu) => ElevatedButton(
                              onPressed: showMenu,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      _selectedBillingDay == null
                                          ? "Gün"
                                          : _selectedBillingDay.toString(),
                                      style: TextStyle(
                                          color: Colors.black
                                      )
                                  ),
                                  Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.black
                                  )
                                ],
                              ),
                            ),
                          )
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                          child: PullDownButton(
                            itemBuilder: (context) => monthsList
                                .map(
                                  (month) => PullDownMenuItem(
                                  onTap: () {
                                    FocusScope.of(context).unfocus(); // Unfocus the TextFormField
                                    setState(() {
                                      _selectedBillingMonth = month;
                                      _updateDaysListForSelectedMonth();
                                    });
                                  },
                                  title: monthNames[month - 1]
                              ),
                            ).toList(),
                            buttonBuilder: (context, showMenu) => ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: showMenu,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedBillingMonth == null
                                          ? "Ay"
                                          : monthNames[_selectedBillingMonth! - 1],
                                      style: TextStyle(color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down, color: Colors.black)
                                ],
                              ),
                            ),
                          )
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerLeft, child: Text("Due Date",style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black))),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PullDownButton(
                      itemBuilder: (context) => [
                        PullDownMenuItem(
                          onTap: () {
                            FocusScope.of(context).unfocus(); // Unfocus the TextFormField
                            setState(() {
                              _selectedDueDay = null; // Set selected day to null
                            });
                          },
                          title: 'None', // Label for the null option
                        ),
                        ...daysList.map(
                              (day) => PullDownMenuItem(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                _selectedDueDay = day;
                              });
                            },
                            title: day.toString(),
                          ),
                        ),
                      ],
                      buttonBuilder: (context, showMenu) => ElevatedButton(
                        onPressed: showMenu,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                _selectedDueDay == null
                                    ? "Gün"
                                    : _selectedDueDay.toString(),
                                style: TextStyle(
                                    color: Colors.black
                                )
                            ),
                            Icon(Icons.arrow_drop_down, color: Colors.black)
                          ],
                        ),
                      ),
                    ),
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
                          break;
                        case 3:
                          final priceText = selectedPriceController.text.trim();
                          double dprice = double.tryParse(priceText) ?? 0.0;
                          String price = dprice.toStringAsFixed(2);
                          cateringTitleList[index] = selectedEditController.text;
                          cateringPriceList[index] = price;
                          break;
                        case 4:
                          final priceText = selectedPriceController.text.trim();
                          double dprice = double.tryParse(priceText) ?? 0.0;
                          String price = dprice.toStringAsFixed(2);
                          entertainmentTitleList[index] = selectedEditController.text;
                          entertainmentPriceList[index] = price;
                          break;
                        case 5:
                          final priceText = selectedPriceController.text.trim();
                          double dprice = double.tryParse(priceText) ?? 0.0;
                          String price = dprice.toStringAsFixed(2);
                          otherTitleList[index] = selectedEditController.text;
                          otherPriceList[index] = price;
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
                            isEditingList = false;
                            isAddButtonActive = false;
                            removeInvoice(id);
                            break;
                          case 2:
                            isEditingListND = false;
                            isAddButtonActiveND = false;
                            break;
                          case 3:
                            isEditingListRD = false;
                            isAddButtonActiveRD = false;
                            break;
                          case 4:
                            isEditingListTH = false;
                            isAddButtonActiveTH = false;
                            break;
                          case 5:
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
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Function to get the correct number of days for a given month in the current year
  int _daysInMonth(int month) {
    int year = DateTime.now().year;
    return DateTime(year, month + 1, 0).day;
  }

// Function to update the days list based on the selected month
  void _updateDaysListForSelectedMonth() {
    daysList = List.generate(_daysInMonth(_selectedBillingMonth!), (index) => index + 1);

    // Ensure selected day is within the updated range
    if (_selectedBillingDay != null && (_selectedBillingDay! > daysList.length)) {
      setState(() {
        _selectedBillingDay = daysList.last;
      });
    } else if (_selectedDueDay != null && (_selectedDueDay! > daysList.length)) {
      setState(() {
        _selectedDueDay = daysList.last;
      });
    }
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
    double screenWidth = MediaQuery.of(context).size.width;
    double rentSum = calculateSubcategorySum(invoices, 'Kira');
    double kitchenSum = calculateSubcategorySum(invoices, 'Mutfak');
    double cateringSum = calculateSubcategorySum(invoices, 'Yeme İçme');
    double entSum = calculateSubcategorySum(invoices, 'Eğlence');
    double otherSum = calculateSubcategorySum(invoices, 'Diğer');
    String formattedRentSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(rentSum);
    String formattedKitchenSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(kitchenSum);
    String formattedCateringSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(cateringSum);
    String formattedEntSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(entSum);
    String formattedOtherSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(otherSum);
    double sumAll = 0.0;
    sumAll += rentSum;
    sumAll += kitchenSum;
    sumAll += cateringSum;
    sumAll += entSum;
    sumAll += otherSum;
    setSumAll(sumAll);
    List<int> idsWithRentTargetCategory = [];
    List<int> idsWithKitchenTargetCategory = [];
    List<int> idsWithCateringTargetCategory = [];
    List<int> idsWithEntTargetCategory = [];
    List<int> idsWithOtherTargetCategory = [];
    for (Invoice invoice in invoices) {
      if (invoice.subCategory == "Kira") {
        idsWithRentTargetCategory.add(invoice.id);
      } else if (invoice.subCategory == "Mutfak") {
        idsWithKitchenTargetCategory.add(invoice.id);
      } else if (invoice.subCategory == "Yeme İçme") {
        idsWithCateringTargetCategory.add(invoice.id);
      } else if (invoice.subCategory == "Eğlence") {
        idsWithEntTargetCategory.add(invoice.id);
      } else if (invoice.subCategory == "Diğer") {
        idsWithOtherTargetCategory.add(invoice.id);
      }
    }

    return BlocProvider<FormBloc>(
        create: (context) => FormBloc(),
        child: BlocBuilder<FormBloc, FormStateCustom>(
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color(0xfff0f0f1),
                  elevation: 0,
                  toolbarHeight: 60.h,
                  automaticallyImplyLeading: false,
                  leadingWidth: 30.w,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Diğer Giderler",
                          style: TextStyle(
                              fontFamily: 'Keep Calm',
                              color: Colors.black,
                              fontSize: 28.sp
                          )
                      ),
                      Text(
                          "4/4",
                          style: TextStyle(
                              fontFamily: 'Keep Calm',
                              color: Colors.black,
                              fontSize: 24.sp
                          )
                      ),
                    ],
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
                      Container(
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
                                              padding: const EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
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
                                                    Text(
                                                        "Kira",
                                                        style: GoogleFonts.montserrat(
                                                          fontSize: 22,
                                                          fontWeight: FontWeight.bold,
                                                        )
                                                    ),
                                                    SizedBox(height: 10),
                                                    if (invoices.isNotEmpty && idsWithRentTargetCategory.isNotEmpty && !isTextFormFieldVisible)
                                                      Column(
                                                        children: idsWithRentTargetCategory.asMap().entries.map((entry) {
                                                          int i = entry.key; // The index
                                                          int id = entry.value; // The id at this index
                                                          Invoice invoice = invoices.firstWhere((invoice) => invoice.id == id);

                                                          // Background color for each container
                                                          Color backgroundColor = Colors.grey;

                                                          return Column(
                                                            children: [
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  color: backgroundColor,
                                                                  borderRadius: BorderRadius.circular(12), // Rounded corners
                                                                  border: Border.all(color: Colors.grey.shade400, width: 0.5),
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    // Label and Value for Name
                                                                    Row(
                                                                      children: [
                                                                        Flexible(
                                                                          flex:2,
                                                                          child: ListTile(
                                                                            dense: true,
                                                                            title: Text("Name", style: TextStyle(color: Colors.black)),
                                                                            subtitle: Text(
                                                                              invoice.name,
                                                                              style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Flexible(
                                                                          flex:2,
                                                                          child: ListTile(
                                                                            dense: true,
                                                                            title: Text("Price", style: TextStyle(color: Colors.black)),
                                                                            subtitle: Text(
                                                                              NumberFormat('#,##0.00', 'tr_TR').format(double.parse(invoice.price)),
                                                                              style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Flexible(
                                                                          flex:2,
                                                                          child: ListTile(
                                                                            dense: true,
                                                                            title: Text("Period Date", style: TextStyle(color: Colors.black)),
                                                                            subtitle: Text(
                                                                              invoice.periodDate,
                                                                              style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Flexible(
                                                                          flex:2,
                                                                          child: ListTile(
                                                                            dense: true,
                                                                            title: Text("Due Date", style: TextStyle(color: Colors.black)),
                                                                            subtitle: Text(
                                                                              invoice.dueDate ?? "N/A",
                                                                              style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    Container(
                                                                      decoration: BoxDecoration(
                                                                        color: Color.fromARGB(200, 255, 200, 0),
                                                                        borderRadius: BorderRadius.circular(12),
                                                                      ),
                                                                      padding: EdgeInsets.only(left: 20,right: 20),
                                                                      child: SizedBox(
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text("Düzenle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                                                            IconButton(
                                                                              splashRadius: 0.0001,
                                                                              padding: EdgeInsets.zero,
                                                                              constraints: BoxConstraints(minWidth: 23, maxWidth: 23),
                                                                              icon: Icon(Icons.edit, size: 21),
                                                                              onPressed: () {
                                                                                _showEditDialog(context, i, 1, id); // Pass the index and id
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),

                                                                  ],
                                                                ),
                                                              ),
                                                              if (i < idsWithRentTargetCategory.length - 1)
                                                                SizedBox(height: 10),
                                                            ],
                                                          );
                                                        }).toList(),
                                                      ),
                                                    if (formattedRentSum != "0,00" && !isTextFormFieldVisible)
                                                      SizedBox(height: 10),
                                                    if (formattedRentSum != "0,00" && !isTextFormFieldVisible)
                                                      Column(
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              color: Color.fromARGB(120, 152, 255, 170),
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                            padding: EdgeInsets.all(10),
                                                            child: SizedBox(
                                                              child: Text("Toplam: $formattedRentSum", style: GoogleFonts.montserrat(fontSize: 20),),
                                                            ),
                                                          ),
                                                          SizedBox(height: 10)
                                                        ],
                                                      ),
                                                    if (isTextFormFieldVisible && hasRentSelected)
                                                      Container(
                                                        child: SingleChildScrollView(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                  "Fatura Adı",
                                                                  style: GoogleFonts.montserrat(
                                                                    fontSize: 15.sp,
                                                                  )
                                                              ),
                                                              SizedBox(height: 10.h),
                                                              TextFormField(
                                                                focusNode: textFocusNode,
                                                                controller: textController,
                                                                decoration: InputDecoration(
                                                                    filled: true,
                                                                    fillColor: Colors.white,
                                                                    isDense: true,
                                                                    contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                                                                    focusedBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(20),
                                                                      borderSide: BorderSide(width: 3),
                                                                    ),
                                                                    enabledBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(20),
                                                                      borderSide: BorderSide(width: 2),
                                                                    ),
                                                                    border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(20),
                                                                    ),
                                                                    hintText: 'ABA',
                                                                    hintStyle: TextStyle(color: Colors.black)
                                                                ),
                                                              ),
                                                              SizedBox(height: 15.h),
                                                              Text(
                                                                  "Tutar",
                                                                  style: GoogleFonts.montserrat(
                                                                    fontSize: 15.sp,
                                                                  )
                                                              ),
                                                              SizedBox(height: 10.h),
                                                              TextFormField(
                                                                focusNode: platformPriceFocusNode,
                                                                controller: platformPriceController,
                                                                keyboardType: TextInputType.number, // Show numeric keyboard
                                                                textInputAction: TextInputAction.done, //IOS add done button
                                                                decoration: InputDecoration(
                                                                    filled: true,
                                                                    fillColor: Colors.white,
                                                                    isDense: true,
                                                                    contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                                                                    focusedBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(20),
                                                                      borderSide: BorderSide(width: 3),
                                                                    ),
                                                                    enabledBorder: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(20),
                                                                      borderSide: BorderSide(width: 2),
                                                                    ),
                                                                    border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(20),
                                                                    ),
                                                                    hintText: 'GAG',
                                                                    hintStyle: TextStyle(color: Colors.black)
                                                                ),
                                                                inputFormatters: [
                                                                  NumberTextInputFormatter(
                                                                    allowNegative: false,
                                                                    overrideDecimalPoint: true,
                                                                    insertDecimalPoint: false,
                                                                    insertDecimalDigits: true,
                                                                    decimalDigits: 2,
                                                                    groupDigits: 3,
                                                                    decimalSeparator: ',',
                                                                    groupSeparator: '.',
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(height: 15.h),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                            "Başlangıç Tarihi",
                                                                            style: GoogleFonts.montserrat(
                                                                              fontSize: 15.sp,
                                                                            )
                                                                        ),
                                                                        SizedBox(height: 5.h),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                                child: PullDownButton(
                                                                                  itemBuilder: (context) => daysList
                                                                                      .map(
                                                                                        (day) => PullDownMenuItem(
                                                                                        onTap: () {
                                                                                          platformPriceFocusNode.unfocus();
                                                                                          textFocusNode.unfocus();
                                                                                          setState(() {
                                                                                            _selectedBillingDay = day;
                                                                                          });
                                                                                        },
                                                                                        title: day.toString()
                                                                                    ),
                                                                                  ).toList(),
                                                                                  buttonBuilder: (context, showMenu) => ElevatedButton(
                                                                                    onPressed: showMenu,
                                                                                    style: ElevatedButton.styleFrom(
                                                                                      backgroundColor: Colors.white,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(20),
                                                                                      ),
                                                                                      side: BorderSide(width: 2),
                                                                                    ),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Text(
                                                                                            _selectedBillingDay == null
                                                                                                ? "Gün"
                                                                                                : _selectedBillingDay.toString(),
                                                                                            style: TextStyle(
                                                                                                color: Colors.black
                                                                                            )
                                                                                        ),
                                                                                        Icon(
                                                                                            Icons.arrow_drop_down,
                                                                                            color: Colors.black
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                            ),
                                                                            SizedBox(width: 20.w),
                                                                            Expanded(
                                                                                child: PullDownButton(
                                                                                  itemBuilder: (context) => monthsList
                                                                                      .map(
                                                                                        (month) => PullDownMenuItem(
                                                                                        onTap: () {
                                                                                          platformPriceFocusNode.unfocus();
                                                                                          textFocusNode.unfocus();
                                                                                          setState(() {
                                                                                            _selectedBillingMonth = month;
                                                                                          });
                                                                                        },
                                                                                        title: monthNames[month - 1]
                                                                                    ),
                                                                                  ).toList(),
                                                                                  buttonBuilder: (context, showMenu) => ElevatedButton(
                                                                                    style: ElevatedButton.styleFrom(
                                                                                      backgroundColor: Colors.white,
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(20),
                                                                                      ),
                                                                                      side: BorderSide(width: 2),
                                                                                    ),
                                                                                    onPressed: showMenu,
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Text(
                                                                                            _selectedBillingMonth == null
                                                                                                ? "Ay"
                                                                                                : monthNames[_selectedBillingMonth! - 1],
                                                                                            style: TextStyle(
                                                                                                color: Colors.black
                                                                                            )
                                                                                        ),
                                                                                        Icon(Icons.arrow_drop_down, color: Colors.black)
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SizedBox(height: 10.h),
                                                                        Text(
                                                                            "Son Ödeme Tarihi",
                                                                            style: GoogleFonts.montserrat(
                                                                              fontSize: 15.sp,
                                                                            )
                                                                        ),
                                                                        SizedBox(height: 5.h),
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Expanded(
                                                                              flex:1,
                                                                              child: PullDownButton(
                                                                                itemBuilder: (context) => daysList
                                                                                    .map(
                                                                                      (day) => PullDownMenuItem(
                                                                                      onTap: () {
                                                                                        platformPriceFocusNode.unfocus();
                                                                                        textFocusNode.unfocus();
                                                                                        setState(() {
                                                                                          _selectedDueDay = day;
                                                                                        });
                                                                                      },
                                                                                      title: day.toString()
                                                                                  ),
                                                                                ).toList(),
                                                                                buttonBuilder: (context, showMenu) => ElevatedButton(
                                                                                  onPressed: showMenu,
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.white,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(20),
                                                                                    ),
                                                                                    side: BorderSide(width: 2),
                                                                                  ),
                                                                                  child: Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Text(
                                                                                          _selectedDueDay == null
                                                                                              ? "Gün"
                                                                                              : _selectedDueDay.toString(),
                                                                                          style: TextStyle(
                                                                                              color: Colors.black
                                                                                          )
                                                                                      ),
                                                                                      Icon(Icons.arrow_drop_down, color: Colors.black)
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(width: 20.w),
                                                                            Expanded(
                                                                              flex:1,
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.end,
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
                                                                                        num parsedPrice = NumberFormat.decimalPattern('tr_TR').parse(priceText) ?? 0;
                                                                                        double dprice = parsedPrice is double
                                                                                            ? parsedPrice
                                                                                            : parsedPrice.toDouble();
                                                                                        String price = dprice.toStringAsFixed(2);
                                                                                        final invoice = Invoice(
                                                                                          id: newId,
                                                                                          price: price,
                                                                                          subCategory: 'Kira',
                                                                                          category: "Diğer Giderler",
                                                                                          name: text,
                                                                                          periodDate: formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!),
                                                                                          dueDate: _selectedDueDay != null && _selectedBillingDay != null && _selectedBillingMonth != null
                                                                                              ? formatDueDate(
                                                                                              _selectedDueDay!,
                                                                                              formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!)
                                                                                          )
                                                                                              : null,
                                                                                          difference: "abo2",
                                                                                        );
                                                                                        onSave(invoice);
                                                                                        if (text.isNotEmpty && priceText.isNotEmpty) {
                                                                                          setState(() {
                                                                                            isEditingList = false; // Add a corresponding entry for the new item
                                                                                            textController.clear();
                                                                                            platformPriceController.clear();
                                                                                            isTextFormFieldVisible = false;
                                                                                            isAddButtonActive = false;
                                                                                          });
                                                                                        }
                                                                                      });
                                                                                    },
                                                                                    icon: const Icon(Icons.check_circle, size: 26),
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
                                                                                    icon: const Icon(Icons.cancel, size: 26),
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
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    if (formattedRentSum == "0,00" && !isTextFormFieldVisible)
                                                      SizedBox(height: 10),
                                                    if (!isEditingList && !isTextFormFieldVisible)
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: Color.fromARGB(120, 133, 133, 133),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        padding: EdgeInsets.only(left: 20,right: 20),
                                                        child: SizedBox(
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text("Abonelik Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
                                                              IconButton(
                                                                onPressed: () {
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
                                                                icon: Icon(Icons.add_circle, size: 26),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: hasKitchenSelected ? Colors.black : Colors.black.withOpacity(0.5),
                                                  width: hasKitchenSelected ? 4 : 2,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      "Mutfak",
                                                      style: GoogleFonts.montserrat(
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.bold,
                                                      )
                                                  ),
                                                  SizedBox(height: 10),
                                                  if (invoices.isNotEmpty && idsWithKitchenTargetCategory.isNotEmpty && !isTextFormFieldVisibleND)
                                                    Column(
                                                      children: idsWithKitchenTargetCategory.asMap().entries.map((entry) {
                                                        int i = entry.key; // The index
                                                        int id = entry.value; // The id at this index
                                                        Invoice invoice = invoices.firstWhere((invoice) => invoice.id == id);

                                                        // Background color for each container
                                                        Color backgroundColor = Colors.grey;

                                                        return Column(
                                                          children: [
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: backgroundColor,
                                                                borderRadius: BorderRadius.circular(12), // Rounded corners
                                                                border: Border.all(color: Colors.grey.shade400, width: 0.5),
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  // Label and Value for Name
                                                                  Row(
                                                                    children: [
                                                                      Flexible(
                                                                        flex:2,
                                                                        child: ListTile(
                                                                          dense: true,
                                                                          title: Text("Name", style: TextStyle(color: Colors.black)),
                                                                          subtitle: Text(
                                                                            invoice.name,
                                                                            style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Flexible(
                                                                        flex:2,
                                                                        child: ListTile(
                                                                          dense: true,
                                                                          title: Text("Price", style: TextStyle(color: Colors.black)),
                                                                          subtitle: Text(
                                                                            NumberFormat('#,##0.00', 'tr_TR').format(double.parse(invoice.price)),
                                                                            style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Flexible(
                                                                        flex:2,
                                                                        child: ListTile(
                                                                          dense: true,
                                                                          title: Text("Period Date", style: TextStyle(color: Colors.black)),
                                                                          subtitle: Text(
                                                                            invoice.periodDate,
                                                                            style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Flexible(
                                                                        flex:2,
                                                                        child: ListTile(
                                                                          dense: true,
                                                                          title: Text("Due Date", style: TextStyle(color: Colors.black)),
                                                                          subtitle: Text(
                                                                            invoice.dueDate ?? "N/A",
                                                                            style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                      color: Color.fromARGB(200, 255, 200, 0),
                                                                      borderRadius: BorderRadius.circular(12),
                                                                    ),
                                                                    padding: EdgeInsets.only(left: 20,right: 20),
                                                                    child: SizedBox(
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text("Düzenle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                                                          IconButton(
                                                                            splashRadius: 0.0001,
                                                                            padding: EdgeInsets.zero,
                                                                            constraints: BoxConstraints(minWidth: 23, maxWidth: 23),
                                                                            icon: Icon(Icons.edit, size: 21),
                                                                            onPressed: () {
                                                                              _showEditDialog(context, i, 2, id); // Pass the index and id
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),

                                                                ],
                                                              ),
                                                            ),
                                                            if (i < idsWithKitchenTargetCategory.length - 1)
                                                              SizedBox(height: 10),
                                                          ],
                                                        );
                                                      }).toList(),
                                                    ),
                                                  if (formattedKitchenSum != "0,00" && !isTextFormFieldVisibleND)
                                                    SizedBox(height: 10),
                                                  if (formattedKitchenSum != "0,00" && !isTextFormFieldVisibleND)
                                                    Column(
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color: Color.fromARGB(120, 152, 255, 170),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          padding: EdgeInsets.all(10),
                                                          child: SizedBox(
                                                            child: Text("Toplam: $formattedKitchenSum", style: GoogleFonts.montserrat(fontSize: 20),),
                                                          ),
                                                        ),
                                                        SizedBox(height: 10)
                                                      ],
                                                    ),
                                                  if (isTextFormFieldVisibleND && hasKitchenSelected)
                                                    Container(
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                                "Fatura Adı",
                                                                style: GoogleFonts.montserrat(
                                                                  fontSize: 15.sp,
                                                                )
                                                            ),
                                                            SizedBox(height: 10.h),
                                                            TextFormField(
                                                              focusNode: textFocusNode,
                                                              controller: textController,
                                                              decoration: InputDecoration(
                                                                  filled: true,
                                                                  fillColor: Colors.white,
                                                                  isDense: true,
                                                                  contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(width: 3),
                                                                  ),
                                                                  enabledBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(width: 2),
                                                                  ),
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                  ),
                                                                  hintText: 'ABA',
                                                                  hintStyle: TextStyle(color: Colors.black)
                                                              ),
                                                            ),
                                                            SizedBox(height: 15.h),
                                                            Text(
                                                                "Tutar",
                                                                style: GoogleFonts.montserrat(
                                                                  fontSize: 15.sp,
                                                                )
                                                            ),
                                                            SizedBox(height: 10.h),
                                                            TextFormField(
                                                              focusNode: platformPriceFocusNode,
                                                              controller: platformPriceController,
                                                              keyboardType: TextInputType.number, // Show numeric keyboard
                                                              textInputAction: TextInputAction.done, //IOS add done button
                                                              decoration: InputDecoration(
                                                                  filled: true,
                                                                  fillColor: Colors.white,
                                                                  isDense: true,
                                                                  contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(width: 3),
                                                                  ),
                                                                  enabledBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(width: 2),
                                                                  ),
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                  ),
                                                                  hintText: 'GAG',
                                                                  hintStyle: TextStyle(color: Colors.black)
                                                              ),
                                                              inputFormatters: [
                                                                NumberTextInputFormatter(
                                                                  allowNegative: false,
                                                                  overrideDecimalPoint: true,
                                                                  insertDecimalPoint: false,
                                                                  insertDecimalDigits: true,
                                                                  decimalDigits: 2,
                                                                  groupDigits: 3,
                                                                  decimalSeparator: ',',
                                                                  groupSeparator: '.',
                                                                )
                                                              ],
                                                            ),
                                                            SizedBox(height: 15.h),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                          "Başlangıç Tarihi",
                                                                          style: GoogleFonts.montserrat(
                                                                            fontSize: 15.sp,
                                                                          )
                                                                      ),
                                                                      SizedBox(height: 5.h),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                              child: PullDownButton(
                                                                                itemBuilder: (context) => daysList
                                                                                    .map(
                                                                                      (day) => PullDownMenuItem(
                                                                                      onTap: () {
                                                                                        platformPriceFocusNode.unfocus();
                                                                                        textFocusNode.unfocus();
                                                                                        setState(() {
                                                                                          _selectedBillingDay = day;
                                                                                        });
                                                                                      },
                                                                                      title: day.toString()
                                                                                  ),
                                                                                ).toList(),
                                                                                buttonBuilder: (context, showMenu) => ElevatedButton(
                                                                                  onPressed: showMenu,
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.white,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(20),
                                                                                    ),
                                                                                    side: BorderSide(width: 2),
                                                                                  ),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Text(
                                                                                          _selectedBillingDay == null
                                                                                              ? "Gün"
                                                                                              : _selectedBillingDay.toString(),
                                                                                          style: TextStyle(
                                                                                              color: Colors.black
                                                                                          )
                                                                                      ),
                                                                                      Icon(
                                                                                          Icons.arrow_drop_down,
                                                                                          color: Colors.black
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              )
                                                                          ),
                                                                          SizedBox(width: 20.w),
                                                                          Expanded(
                                                                              child: PullDownButton(
                                                                                itemBuilder: (context) => monthsList
                                                                                    .map(
                                                                                      (month) => PullDownMenuItem(
                                                                                      onTap: () {
                                                                                        platformPriceFocusNode.unfocus();
                                                                                        textFocusNode.unfocus();
                                                                                        setState(() {
                                                                                          _selectedBillingMonth = month;
                                                                                        });
                                                                                      },
                                                                                      title: monthNames[month - 1]
                                                                                  ),
                                                                                ).toList(),
                                                                                buttonBuilder: (context, showMenu) => ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.white,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(20),
                                                                                    ),
                                                                                    side: BorderSide(width: 2),
                                                                                  ),
                                                                                  onPressed: showMenu,
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Text(
                                                                                          _selectedBillingMonth == null
                                                                                              ? "Ay"
                                                                                              : monthNames[_selectedBillingMonth! - 1],
                                                                                          style: TextStyle(
                                                                                              color: Colors.black
                                                                                          )
                                                                                      ),
                                                                                      Icon(Icons.arrow_drop_down, color: Colors.black)
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              )
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: 10.h),
                                                                      Text(
                                                                          "Son Ödeme Tarihi",
                                                                          style: GoogleFonts.montserrat(
                                                                            fontSize: 15.sp,
                                                                          )
                                                                      ),
                                                                      SizedBox(height: 5.h),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Expanded(
                                                                            flex:1,
                                                                            child: PullDownButton(
                                                                              itemBuilder: (context) => daysList
                                                                                  .map(
                                                                                    (day) => PullDownMenuItem(
                                                                                    onTap: () {
                                                                                      platformPriceFocusNode.unfocus();
                                                                                      textFocusNode.unfocus();
                                                                                      setState(() {
                                                                                        _selectedDueDay = day;
                                                                                      });
                                                                                    },
                                                                                    title: day.toString()
                                                                                ),
                                                                              ).toList(),
                                                                              buttonBuilder: (context, showMenu) => ElevatedButton(
                                                                                onPressed: showMenu,
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: Colors.white,
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(20),
                                                                                  ),
                                                                                  side: BorderSide(width: 2),
                                                                                ),
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    Text(
                                                                                        _selectedDueDay == null
                                                                                            ? "Gün"
                                                                                            : _selectedDueDay.toString(),
                                                                                        style: TextStyle(
                                                                                            color: Colors.black
                                                                                        )
                                                                                    ),
                                                                                    Icon(Icons.arrow_drop_down, color: Colors.black)
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(width: 20.w),
                                                                          Expanded(
                                                                            flex:1,
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.end,
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
                                                                                      num parsedPrice = NumberFormat.decimalPattern('tr_TR').parse(priceText) ?? 0;
                                                                                      double dprice = parsedPrice is double
                                                                                          ? parsedPrice
                                                                                          : parsedPrice.toDouble();
                                                                                      String price = dprice.toStringAsFixed(2);
                                                                                      final invoice = Invoice(
                                                                                        id: newId,
                                                                                        price: price,
                                                                                        subCategory: 'Mutfak',
                                                                                        category: "Diğer Giderler",
                                                                                        name: text,
                                                                                        periodDate: formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!),
                                                                                        dueDate: _selectedDueDay != null && _selectedBillingDay != null && _selectedBillingMonth != null
                                                                                            ? formatDueDate(
                                                                                            _selectedDueDay!,
                                                                                            formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!)
                                                                                        )
                                                                                            : null,
                                                                                        difference: "abo2",
                                                                                      );
                                                                                      onSave(invoice);
                                                                                      if (text.isNotEmpty && priceText.isNotEmpty) {
                                                                                        setState(() {
                                                                                          isEditingListND = false; // Add a corresponding entry for the new item
                                                                                          textController.clear();
                                                                                          platformPriceController.clear();
                                                                                          isTextFormFieldVisibleND = false;
                                                                                          isAddButtonActiveND = false;
                                                                                        });
                                                                                      }
                                                                                    });
                                                                                  },
                                                                                  icon: const Icon(Icons.check_circle, size: 26),
                                                                                ),
                                                                                IconButton(
                                                                                  onPressed: () {
                                                                                    setState(() {
                                                                                      isTextFormFieldVisibleND = false;
                                                                                      isAddButtonActiveND = false;
                                                                                      textController.clear();
                                                                                      platformPriceController.clear();
                                                                                    });
                                                                                  },
                                                                                  icon: const Icon(Icons.cancel, size: 26),
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
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  if (formattedKitchenSum == "0,00" && !isTextFormFieldVisibleND)
                                                    SizedBox(height: 10),
                                                  if (!isEditingListND && !isTextFormFieldVisibleND)
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Color.fromARGB(120, 133, 133, 133),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      padding: EdgeInsets.only(left: 20,right: 20),
                                                      child: SizedBox(
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text("Abonelik Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
                                                            IconButton(
                                                              onPressed: () {
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
                                                                  platformPriceController.clear();
                                                                });
                                                              },
                                                              icon: Icon(Icons.add_circle, size: 26),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: hasCateringSelected ? Colors.black : Colors.black.withOpacity(0.5),
                                                  width: hasCateringSelected ? 4 : 2,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      "Yeme İçme",
                                                      style: GoogleFonts.montserrat(
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.bold,
                                                      )
                                                  ),
                                                  SizedBox(height: 10),
                                                  if (invoices.isNotEmpty && idsWithCateringTargetCategory.isNotEmpty && !isTextFormFieldVisibleRD)
                                                    Column(
                                                      children: idsWithCateringTargetCategory.asMap().entries.map((entry) {
                                                        int i = entry.key; // The index
                                                        int id = entry.value; // The id at this index
                                                        Invoice invoice = invoices.firstWhere((invoice) => invoice.id == id);

                                                        // Background color for each container
                                                        Color backgroundColor = Colors.grey;

                                                        return Column(
                                                          children: [
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: backgroundColor,
                                                                borderRadius: BorderRadius.circular(12), // Rounded corners
                                                                border: Border.all(color: Colors.grey.shade400, width: 0.5),
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  // Label and Value for Name
                                                                  Row(
                                                                    children: [
                                                                      Flexible(
                                                                        flex:2,
                                                                        child: ListTile(
                                                                          dense: true,
                                                                          title: Text("Name", style: TextStyle(color: Colors.black)),
                                                                          subtitle: Text(
                                                                            invoice.name,
                                                                            style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Flexible(
                                                                        flex:2,
                                                                        child: ListTile(
                                                                          dense: true,
                                                                          title: Text("Price", style: TextStyle(color: Colors.black)),
                                                                          subtitle: Text(
                                                                            NumberFormat('#,##0.00', 'tr_TR').format(double.parse(invoice.price)),
                                                                            style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Flexible(
                                                                        flex:2,
                                                                        child: ListTile(
                                                                          dense: true,
                                                                          title: Text("Period Date", style: TextStyle(color: Colors.black)),
                                                                          subtitle: Text(
                                                                            invoice.periodDate,
                                                                            style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Flexible(
                                                                        flex:2,
                                                                        child: ListTile(
                                                                          dense: true,
                                                                          title: Text("Due Date", style: TextStyle(color: Colors.black)),
                                                                          subtitle: Text(
                                                                            invoice.dueDate ?? "N/A",
                                                                            style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                      color: Color.fromARGB(200, 255, 200, 0),
                                                                      borderRadius: BorderRadius.circular(12),
                                                                    ),
                                                                    padding: EdgeInsets.only(left: 20,right: 20),
                                                                    child: SizedBox(
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text("Düzenle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                                                          IconButton(
                                                                            splashRadius: 0.0001,
                                                                            padding: EdgeInsets.zero,
                                                                            constraints: BoxConstraints(minWidth: 23, maxWidth: 23),
                                                                            icon: Icon(Icons.edit, size: 21),
                                                                            onPressed: () {
                                                                              _showEditDialog(context, i, 3, id); // Pass the index and id
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),

                                                                ],
                                                              ),
                                                            ),
                                                            if (i < idsWithCateringTargetCategory.length - 1)
                                                              SizedBox(height: 10),
                                                          ],
                                                        );
                                                      }).toList(),
                                                    ),
                                                  if (formattedCateringSum != "0,00" && !isTextFormFieldVisibleRD)
                                                    SizedBox(height: 10),
                                                  if (formattedCateringSum != "0,00" && !isTextFormFieldVisibleRD)
                                                    Column(
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color: Color.fromARGB(120, 152, 255, 170),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          padding: EdgeInsets.all(10),
                                                          child: SizedBox(
                                                            child: Text("Toplam: $formattedCateringSum", style: GoogleFonts.montserrat(fontSize: 20),),
                                                          ),
                                                        ),
                                                        SizedBox(height: 10)
                                                      ],
                                                    ),
                                                  if (isTextFormFieldVisibleRD && hasCateringSelected)
                                                    Container(
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                                "Fatura Adı",
                                                                style: GoogleFonts.montserrat(
                                                                  fontSize: 15.sp,
                                                                )
                                                            ),
                                                            SizedBox(height: 10.h),
                                                            TextFormField(
                                                              focusNode: textFocusNode,
                                                              controller: textController,
                                                              decoration: InputDecoration(
                                                                  filled: true,
                                                                  fillColor: Colors.white,
                                                                  isDense: true,
                                                                  contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(width: 3),
                                                                  ),
                                                                  enabledBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(width: 2),
                                                                  ),
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                  ),
                                                                  hintText: 'ABA',
                                                                  hintStyle: TextStyle(color: Colors.black)
                                                              ),
                                                            ),
                                                            SizedBox(height: 15.h),
                                                            Text(
                                                                "Tutar",
                                                                style: GoogleFonts.montserrat(
                                                                  fontSize: 15.sp,
                                                                )
                                                            ),
                                                            SizedBox(height: 10.h),
                                                            TextFormField(
                                                              focusNode: platformPriceFocusNode,
                                                              controller: platformPriceController,
                                                              keyboardType: TextInputType.number, // Show numeric keyboard
                                                              textInputAction: TextInputAction.done, //IOS add done button
                                                              decoration: InputDecoration(
                                                                  filled: true,
                                                                  fillColor: Colors.white,
                                                                  isDense: true,
                                                                  contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(width: 3),
                                                                  ),
                                                                  enabledBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(width: 2),
                                                                  ),
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                  ),
                                                                  hintText: 'GAG',
                                                                  hintStyle: TextStyle(color: Colors.black)
                                                              ),
                                                              inputFormatters: [
                                                                NumberTextInputFormatter(
                                                                  allowNegative: false,
                                                                  overrideDecimalPoint: true,
                                                                  insertDecimalPoint: false,
                                                                  insertDecimalDigits: true,
                                                                  decimalDigits: 2,
                                                                  groupDigits: 3,
                                                                  decimalSeparator: ',',
                                                                  groupSeparator: '.',
                                                                )
                                                              ],
                                                            ),
                                                            SizedBox(height: 15.h),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                          "Başlangıç Tarihi",
                                                                          style: GoogleFonts.montserrat(
                                                                            fontSize: 15.sp,
                                                                          )
                                                                      ),
                                                                      SizedBox(height: 5.h),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                              child: PullDownButton(
                                                                                itemBuilder: (context) => daysList
                                                                                    .map(
                                                                                      (day) => PullDownMenuItem(
                                                                                      onTap: () {
                                                                                        platformPriceFocusNode.unfocus();
                                                                                        textFocusNode.unfocus();
                                                                                        setState(() {
                                                                                          _selectedBillingDay = day;
                                                                                        });
                                                                                      },
                                                                                      title: day.toString()
                                                                                  ),
                                                                                ).toList(),
                                                                                buttonBuilder: (context, showMenu) => ElevatedButton(
                                                                                  onPressed: showMenu,
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.white,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(20),
                                                                                    ),
                                                                                    side: BorderSide(width: 2),
                                                                                  ),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Text(
                                                                                          _selectedBillingDay == null
                                                                                              ? "Gün"
                                                                                              : _selectedBillingDay.toString(),
                                                                                          style: TextStyle(
                                                                                              color: Colors.black
                                                                                          )
                                                                                      ),
                                                                                      Icon(
                                                                                          Icons.arrow_drop_down,
                                                                                          color: Colors.black
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              )
                                                                          ),
                                                                          SizedBox(width: 20.w),
                                                                          Expanded(
                                                                              child: PullDownButton(
                                                                                itemBuilder: (context) => monthsList
                                                                                    .map(
                                                                                      (month) => PullDownMenuItem(
                                                                                      onTap: () {
                                                                                        platformPriceFocusNode.unfocus();
                                                                                        textFocusNode.unfocus();
                                                                                        setState(() {
                                                                                          _selectedBillingMonth = month;
                                                                                        });
                                                                                      },
                                                                                      title: monthNames[month - 1]
                                                                                  ),
                                                                                ).toList(),
                                                                                buttonBuilder: (context, showMenu) => ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.white,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(20),
                                                                                    ),
                                                                                    side: BorderSide(width: 2),
                                                                                  ),
                                                                                  onPressed: showMenu,
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Text(
                                                                                          _selectedBillingMonth == null
                                                                                              ? "Ay"
                                                                                              : monthNames[_selectedBillingMonth! - 1],
                                                                                          style: TextStyle(
                                                                                              color: Colors.black
                                                                                          )
                                                                                      ),
                                                                                      Icon(Icons.arrow_drop_down, color: Colors.black)
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              )
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: 10.h),
                                                                      Text(
                                                                          "Son Ödeme Tarihi",
                                                                          style: GoogleFonts.montserrat(
                                                                            fontSize: 15.sp,
                                                                          )
                                                                      ),
                                                                      SizedBox(height: 5.h),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Expanded(
                                                                            flex:1,
                                                                            child: PullDownButton(
                                                                              itemBuilder: (context) => daysList
                                                                                  .map(
                                                                                    (day) => PullDownMenuItem(
                                                                                    onTap: () {
                                                                                      platformPriceFocusNode.unfocus();
                                                                                      textFocusNode.unfocus();
                                                                                      setState(() {
                                                                                        _selectedDueDay = day;
                                                                                      });
                                                                                    },
                                                                                    title: day.toString()
                                                                                ),
                                                                              ).toList(),
                                                                              buttonBuilder: (context, showMenu) => ElevatedButton(
                                                                                onPressed: showMenu,
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: Colors.white,
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(20),
                                                                                  ),
                                                                                  side: BorderSide(width: 2),
                                                                                ),
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    Text(
                                                                                        _selectedDueDay == null
                                                                                            ? "Gün"
                                                                                            : _selectedDueDay.toString(),
                                                                                        style: TextStyle(
                                                                                            color: Colors.black
                                                                                        )
                                                                                    ),
                                                                                    Icon(Icons.arrow_drop_down, color: Colors.black)
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(width: 20.w),
                                                                          Expanded(
                                                                            flex:1,
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.end,
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
                                                                                      num parsedPrice = NumberFormat.decimalPattern('tr_TR').parse(priceText) ?? 0;
                                                                                      double dprice = parsedPrice is double
                                                                                          ? parsedPrice
                                                                                          : parsedPrice.toDouble();
                                                                                      String price = dprice.toStringAsFixed(2);
                                                                                      final invoice = Invoice(
                                                                                        id: newId,
                                                                                        price: price,
                                                                                        subCategory: 'Yeme İçme',
                                                                                        category: "Diğer Giderler",
                                                                                        name: text,
                                                                                        periodDate: formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!),
                                                                                        dueDate: _selectedDueDay != null && _selectedBillingDay != null && _selectedBillingMonth != null
                                                                                            ? formatDueDate(
                                                                                            _selectedDueDay!,
                                                                                            formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!)
                                                                                        )
                                                                                            : null,
                                                                                        difference: "abo2",
                                                                                      );
                                                                                      onSave(invoice);
                                                                                      if (text.isNotEmpty && priceText.isNotEmpty) {
                                                                                        setState(() {
                                                                                          isEditingListRD = false; // Add a corresponding entry for the new item
                                                                                          textController.clear();
                                                                                          platformPriceController.clear();
                                                                                          isTextFormFieldVisibleRD = false;
                                                                                          isAddButtonActiveRD = false;
                                                                                        });
                                                                                      }
                                                                                    });
                                                                                  },
                                                                                  icon: const Icon(Icons.check_circle, size: 26),
                                                                                ),
                                                                                IconButton(
                                                                                  onPressed: () {
                                                                                    setState(() {
                                                                                      isTextFormFieldVisibleRD = false;
                                                                                      isAddButtonActiveRD = false;
                                                                                      textController.clear();
                                                                                      platformPriceController.clear();
                                                                                    });
                                                                                  },
                                                                                  icon: const Icon(Icons.cancel, size: 26),
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
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  if (formattedCateringSum == "0,00" && !isTextFormFieldVisibleRD)
                                                    SizedBox(height: 10),
                                                  if (!isEditingListRD && !isTextFormFieldVisibleRD)
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Color.fromARGB(120, 133, 133, 133),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      padding: EdgeInsets.only(left: 20,right: 20),
                                                      child: SizedBox(
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text("Abonelik Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
                                                            IconButton(
                                                              onPressed: () {
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
                                                                  platformPriceController.clear();
                                                                });
                                                              },
                                                              icon: Icon(Icons.add_circle, size: 26),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: hasEntertainmentSelected ? Colors.black : Colors.black.withOpacity(0.5),
                                                  width: hasEntertainmentSelected ? 4 : 2,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      "Eğlence",
                                                      style: GoogleFonts.montserrat(
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.bold,
                                                      )
                                                  ),
                                                  SizedBox(height: 10),
                                                  if (invoices.isNotEmpty && idsWithEntTargetCategory.isNotEmpty && !isTextFormFieldVisibleTH)
                                                    Column(
                                                      children: idsWithEntTargetCategory.asMap().entries.map((entry) {
                                                        int i = entry.key; // The index
                                                        int id = entry.value; // The id at this index
                                                        Invoice invoice = invoices.firstWhere((invoice) => invoice.id == id);

                                                        // Background color for each container
                                                        Color backgroundColor = Colors.grey;

                                                        return Column(
                                                          children: [
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: backgroundColor,
                                                                borderRadius: BorderRadius.circular(12), // Rounded corners
                                                                border: Border.all(color: Colors.grey.shade400, width: 0.5),
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  // Label and Value for Name
                                                                  Row(
                                                                    children: [
                                                                      Flexible(
                                                                        flex:2,
                                                                        child: ListTile(
                                                                          dense: true,
                                                                          title: Text("Name", style: TextStyle(color: Colors.black)),
                                                                          subtitle: Text(
                                                                            invoice.name,
                                                                            style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Flexible(
                                                                        flex:2,
                                                                        child: ListTile(
                                                                          dense: true,
                                                                          title: Text("Price", style: TextStyle(color: Colors.black)),
                                                                          subtitle: Text(
                                                                            NumberFormat('#,##0.00', 'tr_TR').format(double.parse(invoice.price)),
                                                                            style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Flexible(
                                                                        flex:2,
                                                                        child: ListTile(
                                                                          dense: true,
                                                                          title: Text("Period Date", style: TextStyle(color: Colors.black)),
                                                                          subtitle: Text(
                                                                            invoice.periodDate,
                                                                            style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Flexible(
                                                                        flex:2,
                                                                        child: ListTile(
                                                                          dense: true,
                                                                          title: Text("Due Date", style: TextStyle(color: Colors.black)),
                                                                          subtitle: Text(
                                                                            invoice.dueDate ?? "N/A",
                                                                            style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                      color: Color.fromARGB(200, 255, 200, 0),
                                                                      borderRadius: BorderRadius.circular(12),
                                                                    ),
                                                                    padding: EdgeInsets.only(left: 20,right: 20),
                                                                    child: SizedBox(
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text("Düzenle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                                                          IconButton(
                                                                            splashRadius: 0.0001,
                                                                            padding: EdgeInsets.zero,
                                                                            constraints: BoxConstraints(minWidth: 23, maxWidth: 23),
                                                                            icon: Icon(Icons.edit, size: 21),
                                                                            onPressed: () {
                                                                              _showEditDialog(context, i, 4, id); // Pass the index and id
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),

                                                                ],
                                                              ),
                                                            ),
                                                            if (i < idsWithEntTargetCategory.length - 1)
                                                              SizedBox(height: 10),
                                                          ],
                                                        );
                                                      }).toList(),
                                                    ),
                                                  if (formattedEntSum != "0,00" && !isTextFormFieldVisibleTH)
                                                    SizedBox(height: 10),
                                                  if (formattedEntSum != "0,00" && !isTextFormFieldVisibleTH)
                                                    Column(
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color: Color.fromARGB(120, 152, 255, 170),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          padding: EdgeInsets.all(10),
                                                          child: SizedBox(
                                                            child: Text("Toplam: $formattedEntSum", style: GoogleFonts.montserrat(fontSize: 20),),
                                                          ),
                                                        ),
                                                        SizedBox(height: 10)
                                                      ],
                                                    ),
                                                  if (isTextFormFieldVisibleTH && hasEntertainmentSelected)
                                                    Container(
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                                "Fatura Adı",
                                                                style: GoogleFonts.montserrat(
                                                                  fontSize: 15.sp,
                                                                )
                                                            ),
                                                            SizedBox(height: 10.h),
                                                            TextFormField(
                                                              focusNode: textFocusNode,
                                                              controller: textController,
                                                              decoration: InputDecoration(
                                                                  filled: true,
                                                                  fillColor: Colors.white,
                                                                  isDense: true,
                                                                  contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(width: 3),
                                                                  ),
                                                                  enabledBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(width: 2),
                                                                  ),
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                  ),
                                                                  hintText: 'ABA',
                                                                  hintStyle: TextStyle(color: Colors.black)
                                                              ),
                                                            ),
                                                            SizedBox(height: 15.h),
                                                            Text(
                                                                "Tutar",
                                                                style: GoogleFonts.montserrat(
                                                                  fontSize: 15.sp,
                                                                )
                                                            ),
                                                            SizedBox(height: 10.h),
                                                            TextFormField(
                                                              focusNode: platformPriceFocusNode,
                                                              controller: platformPriceController,
                                                              keyboardType: TextInputType.number, // Show numeric keyboard
                                                              textInputAction: TextInputAction.done, //IOS add done button
                                                              decoration: InputDecoration(
                                                                  filled: true,
                                                                  fillColor: Colors.white,
                                                                  isDense: true,
                                                                  contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(width: 3),
                                                                  ),
                                                                  enabledBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(width: 2),
                                                                  ),
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                  ),
                                                                  hintText: 'GAG',
                                                                  hintStyle: TextStyle(color: Colors.black)
                                                              ),
                                                              inputFormatters: [
                                                                NumberTextInputFormatter(
                                                                  allowNegative: false,
                                                                  overrideDecimalPoint: true,
                                                                  insertDecimalPoint: false,
                                                                  insertDecimalDigits: true,
                                                                  decimalDigits: 2,
                                                                  groupDigits: 3,
                                                                  decimalSeparator: ',',
                                                                  groupSeparator: '.',
                                                                )
                                                              ],
                                                            ),
                                                            SizedBox(height: 15.h),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                          "Başlangıç Tarihi",
                                                                          style: GoogleFonts.montserrat(
                                                                            fontSize: 15.sp,
                                                                          )
                                                                      ),
                                                                      SizedBox(height: 5.h),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                              child: PullDownButton(
                                                                                itemBuilder: (context) => daysList
                                                                                    .map(
                                                                                      (day) => PullDownMenuItem(
                                                                                      onTap: () {
                                                                                        platformPriceFocusNode.unfocus();
                                                                                        textFocusNode.unfocus();
                                                                                        setState(() {
                                                                                          _selectedBillingDay = day;
                                                                                        });
                                                                                      },
                                                                                      title: day.toString()
                                                                                  ),
                                                                                ).toList(),
                                                                                buttonBuilder: (context, showMenu) => ElevatedButton(
                                                                                  onPressed: showMenu,
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.white,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(20),
                                                                                    ),
                                                                                    side: BorderSide(width: 2),
                                                                                  ),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Text(
                                                                                          _selectedBillingDay == null
                                                                                              ? "Gün"
                                                                                              : _selectedBillingDay.toString(),
                                                                                          style: TextStyle(
                                                                                              color: Colors.black
                                                                                          )
                                                                                      ),
                                                                                      Icon(
                                                                                          Icons.arrow_drop_down,
                                                                                          color: Colors.black
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              )
                                                                          ),
                                                                          SizedBox(width: 20.w),
                                                                          Expanded(
                                                                              child: PullDownButton(
                                                                                itemBuilder: (context) => monthsList
                                                                                    .map(
                                                                                      (month) => PullDownMenuItem(
                                                                                      onTap: () {
                                                                                        platformPriceFocusNode.unfocus();
                                                                                        textFocusNode.unfocus();
                                                                                        setState(() {
                                                                                          _selectedBillingMonth = month;
                                                                                        });
                                                                                      },
                                                                                      title: monthNames[month - 1]
                                                                                  ),
                                                                                ).toList(),
                                                                                buttonBuilder: (context, showMenu) => ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.white,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(20),
                                                                                    ),
                                                                                    side: BorderSide(width: 2),
                                                                                  ),
                                                                                  onPressed: showMenu,
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Text(
                                                                                          _selectedBillingMonth == null
                                                                                              ? "Ay"
                                                                                              : monthNames[_selectedBillingMonth! - 1],
                                                                                          style: TextStyle(
                                                                                              color: Colors.black
                                                                                          )
                                                                                      ),
                                                                                      Icon(Icons.arrow_drop_down, color: Colors.black)
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              )
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: 10.h),
                                                                      Text(
                                                                          "Son Ödeme Tarihi",
                                                                          style: GoogleFonts.montserrat(
                                                                            fontSize: 15.sp,
                                                                          )
                                                                      ),
                                                                      SizedBox(height: 5.h),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Expanded(
                                                                            flex:1,
                                                                            child: PullDownButton(
                                                                              itemBuilder: (context) => daysList
                                                                                  .map(
                                                                                    (day) => PullDownMenuItem(
                                                                                    onTap: () {
                                                                                      platformPriceFocusNode.unfocus();
                                                                                      textFocusNode.unfocus();
                                                                                      setState(() {
                                                                                        _selectedDueDay = day;
                                                                                      });
                                                                                    },
                                                                                    title: day.toString()
                                                                                ),
                                                                              ).toList(),
                                                                              buttonBuilder: (context, showMenu) => ElevatedButton(
                                                                                onPressed: showMenu,
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: Colors.white,
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(20),
                                                                                  ),
                                                                                  side: BorderSide(width: 2),
                                                                                ),
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    Text(
                                                                                        _selectedDueDay == null
                                                                                            ? "Gün"
                                                                                            : _selectedDueDay.toString(),
                                                                                        style: TextStyle(
                                                                                            color: Colors.black
                                                                                        )
                                                                                    ),
                                                                                    Icon(Icons.arrow_drop_down, color: Colors.black)
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(width: 20.w),
                                                                          Expanded(
                                                                            flex:1,
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.end,
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
                                                                                      num parsedPrice = NumberFormat.decimalPattern('tr_TR').parse(priceText) ?? 0;
                                                                                      double dprice = parsedPrice is double
                                                                                          ? parsedPrice
                                                                                          : parsedPrice.toDouble();
                                                                                      String price = dprice.toStringAsFixed(2);
                                                                                      final invoice = Invoice(
                                                                                        id: newId,
                                                                                        price: price,
                                                                                        subCategory: 'Eğlence',
                                                                                        category: "Diğer Giderler",
                                                                                        name: text,
                                                                                        periodDate: formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!),
                                                                                        dueDate: _selectedDueDay != null && _selectedBillingDay != null && _selectedBillingMonth != null
                                                                                            ? formatDueDate(
                                                                                            _selectedDueDay!,
                                                                                            formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!)
                                                                                        )
                                                                                            : null,
                                                                                        difference: "abo2",
                                                                                      );
                                                                                      onSave(invoice);
                                                                                      if (text.isNotEmpty && priceText.isNotEmpty) {
                                                                                        setState(() {
                                                                                          isEditingListTH = false; // Add a corresponding entry for the new item
                                                                                          textController.clear();
                                                                                          platformPriceController.clear();
                                                                                          isTextFormFieldVisibleTH = false;
                                                                                          isAddButtonActiveTH = false;
                                                                                        });
                                                                                      }
                                                                                    });
                                                                                  },
                                                                                  icon: const Icon(Icons.check_circle, size: 26),
                                                                                ),
                                                                                IconButton(
                                                                                  onPressed: () {
                                                                                    setState(() {
                                                                                      isTextFormFieldVisibleTH = false;
                                                                                      isAddButtonActiveTH = false;
                                                                                      textController.clear();
                                                                                      platformPriceController.clear();
                                                                                    });
                                                                                  },
                                                                                  icon: const Icon(Icons.cancel, size: 26),
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
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  if (formattedEntSum == "0,00" && !isTextFormFieldVisibleTH)
                                                    SizedBox(height: 10),
                                                  if (!isEditingListTH && !isTextFormFieldVisibleTH)
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Color.fromARGB(120, 133, 133, 133),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      padding: EdgeInsets.only(left: 20,right: 20),
                                                      child: SizedBox(
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text("Abonelik Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
                                                            IconButton(
                                                              onPressed: () {
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
                                                                  platformPriceController.clear();
                                                                });
                                                              },
                                                              icon: Icon(Icons.add_circle, size: 26),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            DottedBorder(
                                              padding: const EdgeInsets.all(15),
                                              borderType: BorderType.RRect,
                                              radius: Radius.circular(20),
                                              color: hasOtherSelected ? Colors.black : Colors.black.withOpacity(0.5),
                                              strokeWidth: hasOtherSelected ? 4 : 2,
                                              dashPattern: [6,3],
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      "Diğer",
                                                      style: GoogleFonts.montserrat(
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.bold,
                                                      )
                                                  ),
                                                  SizedBox(height: 10),
                                                  if (invoices.isNotEmpty && idsWithOtherTargetCategory.isNotEmpty && !isTextFormFieldVisibleOther)
                                                    Column(
                                                      children: idsWithOtherTargetCategory.asMap().entries.map((entry) {
                                                        int i = entry.key; // The index
                                                        int id = entry.value; // The id at this index
                                                        Invoice invoice = invoices.firstWhere((invoice) => invoice.id == id);

                                                        // Background color for each container
                                                        Color backgroundColor = Colors.grey;

                                                        return Column(
                                                          children: [
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: backgroundColor,
                                                                borderRadius: BorderRadius.circular(12), // Rounded corners
                                                                border: Border.all(color: Colors.grey.shade400, width: 0.5),
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  // Label and Value for Name
                                                                  Row(
                                                                    children: [
                                                                      Flexible(
                                                                        flex:2,
                                                                        child: ListTile(
                                                                          dense: true,
                                                                          title: Text("Name", style: TextStyle(color: Colors.black)),
                                                                          subtitle: Text(
                                                                            invoice.name,
                                                                            style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Flexible(
                                                                        flex:2,
                                                                        child: ListTile(
                                                                          dense: true,
                                                                          title: Text("Price", style: TextStyle(color: Colors.black)),
                                                                          subtitle: Text(
                                                                            NumberFormat('#,##0.00', 'tr_TR').format(double.parse(invoice.price)),
                                                                            style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Flexible(
                                                                        flex:2,
                                                                        child: ListTile(
                                                                          dense: true,
                                                                          title: Text("Period Date", style: TextStyle(color: Colors.black)),
                                                                          subtitle: Text(
                                                                            invoice.periodDate,
                                                                            style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Flexible(
                                                                        flex:2,
                                                                        child: ListTile(
                                                                          dense: true,
                                                                          title: Text("Due Date", style: TextStyle(color: Colors.black)),
                                                                          subtitle: Text(
                                                                            invoice.dueDate ?? "N/A",
                                                                            style: GoogleFonts.montserrat(fontSize: 16.sp, color: Colors.black),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                      color: Color.fromARGB(200, 255, 200, 0),
                                                                      borderRadius: BorderRadius.circular(12),
                                                                    ),
                                                                    padding: EdgeInsets.only(left: 20,right: 20),
                                                                    child: SizedBox(
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text("Düzenle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                                                          IconButton(
                                                                            splashRadius: 0.0001,
                                                                            padding: EdgeInsets.zero,
                                                                            constraints: BoxConstraints(minWidth: 23, maxWidth: 23),
                                                                            icon: Icon(Icons.edit, size: 21),
                                                                            onPressed: () {
                                                                              _showEditDialog(context, i, 5, id); // Pass the index and id
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),

                                                                ],
                                                              ),
                                                            ),
                                                            if (i < idsWithOtherTargetCategory.length - 1)
                                                              SizedBox(height: 10),
                                                          ],
                                                        );
                                                      }).toList(),
                                                    ),
                                                  if (formattedOtherSum != "0,00" && !isTextFormFieldVisibleOther)
                                                    SizedBox(height: 10),
                                                  if (formattedOtherSum != "0,00" && !isTextFormFieldVisibleOther)
                                                    Column(
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color: Color.fromARGB(120, 152, 255, 170),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          padding: EdgeInsets.all(10),
                                                          child: SizedBox(
                                                            child: Text("Toplam: $formattedOtherSum", style: GoogleFonts.montserrat(fontSize: 20),),
                                                          ),
                                                        ),
                                                        SizedBox(height: 10)
                                                      ],
                                                    ),
                                                  if (isTextFormFieldVisibleOther && hasOtherSelected)
                                                    Container(
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                                "Fatura Adı",
                                                                style: GoogleFonts.montserrat(
                                                                  fontSize: 15.sp,
                                                                )
                                                            ),
                                                            SizedBox(height: 10.h),
                                                            TextFormField(
                                                              focusNode: textFocusNode,
                                                              controller: textController,
                                                              decoration: InputDecoration(
                                                                  filled: true,
                                                                  fillColor: Colors.white,
                                                                  isDense: true,
                                                                  contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(width: 3),
                                                                  ),
                                                                  enabledBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(width: 2),
                                                                  ),
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                  ),
                                                                  hintText: 'ABA',
                                                                  hintStyle: TextStyle(color: Colors.black)
                                                              ),
                                                            ),
                                                            SizedBox(height: 15.h),
                                                            Text(
                                                                "Tutar",
                                                                style: GoogleFonts.montserrat(
                                                                  fontSize: 15.sp,
                                                                )
                                                            ),
                                                            SizedBox(height: 10.h),
                                                            TextFormField(
                                                              focusNode: platformPriceFocusNode,
                                                              controller: platformPriceController,
                                                              keyboardType: TextInputType.number, // Show numeric keyboard
                                                              textInputAction: TextInputAction.done, //IOS add done button
                                                              decoration: InputDecoration(
                                                                  filled: true,
                                                                  fillColor: Colors.white,
                                                                  isDense: true,
                                                                  contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(width: 3),
                                                                  ),
                                                                  enabledBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    borderSide: BorderSide(width: 2),
                                                                  ),
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                  ),
                                                                  hintText: 'GAG',
                                                                  hintStyle: TextStyle(color: Colors.black)
                                                              ),
                                                              inputFormatters: [
                                                                NumberTextInputFormatter(
                                                                  allowNegative: false,
                                                                  overrideDecimalPoint: true,
                                                                  insertDecimalPoint: false,
                                                                  insertDecimalDigits: true,
                                                                  decimalDigits: 2,
                                                                  groupDigits: 3,
                                                                  decimalSeparator: ',',
                                                                  groupSeparator: '.',
                                                                )
                                                              ],
                                                            ),
                                                            SizedBox(height: 15.h),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                          "Başlangıç Tarihi",
                                                                          style: GoogleFonts.montserrat(
                                                                            fontSize: 15.sp,
                                                                          )
                                                                      ),
                                                                      SizedBox(height: 5.h),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                              child: PullDownButton(
                                                                                itemBuilder: (context) => daysList
                                                                                    .map(
                                                                                      (day) => PullDownMenuItem(
                                                                                      onTap: () {
                                                                                        platformPriceFocusNode.unfocus();
                                                                                        textFocusNode.unfocus();
                                                                                        setState(() {
                                                                                          _selectedBillingDay = day;
                                                                                        });
                                                                                      },
                                                                                      title: day.toString()
                                                                                  ),
                                                                                ).toList(),
                                                                                buttonBuilder: (context, showMenu) => ElevatedButton(
                                                                                  onPressed: showMenu,
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.white,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(20),
                                                                                    ),
                                                                                    side: BorderSide(width: 2),
                                                                                  ),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Text(
                                                                                          _selectedBillingDay == null
                                                                                              ? "Gün"
                                                                                              : _selectedBillingDay.toString(),
                                                                                          style: TextStyle(
                                                                                              color: Colors.black
                                                                                          )
                                                                                      ),
                                                                                      Icon(
                                                                                          Icons.arrow_drop_down,
                                                                                          color: Colors.black
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              )
                                                                          ),
                                                                          SizedBox(width: 20.w),
                                                                          Expanded(
                                                                              child: PullDownButton(
                                                                                itemBuilder: (context) => monthsList
                                                                                    .map(
                                                                                      (month) => PullDownMenuItem(
                                                                                      onTap: () {
                                                                                        platformPriceFocusNode.unfocus();
                                                                                        textFocusNode.unfocus();
                                                                                        setState(() {
                                                                                          _selectedBillingMonth = month;
                                                                                        });
                                                                                      },
                                                                                      title: monthNames[month - 1]
                                                                                  ),
                                                                                ).toList(),
                                                                                buttonBuilder: (context, showMenu) => ElevatedButton(
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Colors.white,
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(20),
                                                                                    ),
                                                                                    side: BorderSide(width: 2),
                                                                                  ),
                                                                                  onPressed: showMenu,
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Text(
                                                                                          _selectedBillingMonth == null
                                                                                              ? "Ay"
                                                                                              : monthNames[_selectedBillingMonth! - 1],
                                                                                          style: TextStyle(
                                                                                              color: Colors.black
                                                                                          )
                                                                                      ),
                                                                                      Icon(Icons.arrow_drop_down, color: Colors.black)
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              )
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(height: 10.h),
                                                                      Text(
                                                                          "Son Ödeme Tarihi",
                                                                          style: GoogleFonts.montserrat(
                                                                            fontSize: 15.sp,
                                                                          )
                                                                      ),
                                                                      SizedBox(height: 5.h),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Expanded(
                                                                            flex:1,
                                                                            child: PullDownButton(
                                                                              itemBuilder: (context) => daysList
                                                                                  .map(
                                                                                    (day) => PullDownMenuItem(
                                                                                    onTap: () {
                                                                                      platformPriceFocusNode.unfocus();
                                                                                      textFocusNode.unfocus();
                                                                                      setState(() {
                                                                                        _selectedDueDay = day;
                                                                                      });
                                                                                    },
                                                                                    title: day.toString()
                                                                                ),
                                                                              ).toList(),
                                                                              buttonBuilder: (context, showMenu) => ElevatedButton(
                                                                                onPressed: showMenu,
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: Colors.white,
                                                                                  shape: RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(20),
                                                                                  ),
                                                                                  side: BorderSide(width: 2),
                                                                                ),
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    Text(
                                                                                        _selectedDueDay == null
                                                                                            ? "Gün"
                                                                                            : _selectedDueDay.toString(),
                                                                                        style: TextStyle(
                                                                                            color: Colors.black
                                                                                        )
                                                                                    ),
                                                                                    Icon(Icons.arrow_drop_down, color: Colors.black)
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(width: 20.w),
                                                                          Expanded(
                                                                            flex:1,
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.end,
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
                                                                                      num parsedPrice = NumberFormat.decimalPattern('tr_TR').parse(priceText) ?? 0;
                                                                                      double dprice = parsedPrice is double
                                                                                          ? parsedPrice
                                                                                          : parsedPrice.toDouble();
                                                                                      String price = dprice.toStringAsFixed(2);
                                                                                      final invoice = Invoice(
                                                                                        id: newId,
                                                                                        price: price,
                                                                                        subCategory: 'Diğer',
                                                                                        category: "Diğer Giderler",
                                                                                        name: text,
                                                                                        periodDate: formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!),
                                                                                        dueDate: _selectedDueDay != null && _selectedBillingDay != null && _selectedBillingMonth != null
                                                                                            ? formatDueDate(
                                                                                            _selectedDueDay!,
                                                                                            formatPeriodDate(_selectedBillingDay!, _selectedBillingMonth!)
                                                                                        )
                                                                                            : null,
                                                                                        difference: "abo2",
                                                                                      );
                                                                                      onSave(invoice);
                                                                                      if (text.isNotEmpty && priceText.isNotEmpty) {
                                                                                        setState(() {
                                                                                          isEditingListOther = false; // Add a corresponding entry for the new item
                                                                                          textController.clear();
                                                                                          platformPriceController.clear();
                                                                                          isTextFormFieldVisibleOther = false;
                                                                                          isAddButtonActiveOther = false;
                                                                                        });
                                                                                      }
                                                                                    });
                                                                                  },
                                                                                  icon: const Icon(Icons.check_circle, size: 26),
                                                                                ),
                                                                                IconButton(
                                                                                  onPressed: () {
                                                                                    setState(() {
                                                                                      isTextFormFieldVisibleOther = false;
                                                                                      isAddButtonActiveOther = false;
                                                                                      textController.clear();
                                                                                      platformPriceController.clear();
                                                                                    });
                                                                                  },
                                                                                  icon: const Icon(Icons.cancel, size: 26),
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
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  if (formattedOtherSum == "0,00" && !isTextFormFieldVisibleOther)
                                                    SizedBox(height: 10),
                                                  if (!isEditingListOther && !isTextFormFieldVisibleOther)
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Color.fromARGB(120, 133, 133, 133),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      padding: EdgeInsets.only(left: 20,right: 20),
                                                      child: SizedBox(
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text("Abonelik Ekle", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
                                                            IconButton(
                                                              onPressed: () {
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
                                                                  platformPriceController.clear();
                                                                });
                                                              },
                                                              icon: Icon(Icons.add_circle, size: 26),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ],
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
                    ],
                  ),
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: BottomAppBar(
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          alignment: Alignment.center, // Center the button within the container
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: sumAll != 0.0 ? Colors.black : Colors.grey,
                                padding: EdgeInsets.zero, // Remove padding to center the icon
                              ),
                              clipBehavior: Clip.hardEdge,
                              onPressed: () {
                                context.go('/bills');
                              },
                              child: Icon(
                                Icons.arrow_back,
                                color: sumAll != 0.0 ? Colors.white : Colors.black,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Container(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                backgroundColor: sumAll != 0.0 ? Colors.black : Colors.grey,
                              ),
                              clipBehavior: Clip.hardEdge,
                              onPressed: sumAll != 0.0 ? () {
                                goToNextPage();
                              } : null,
                              child: Text(
                                'Sonraki',
                                style: GoogleFonts.montserrat(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
        ),
    );
  }
}
