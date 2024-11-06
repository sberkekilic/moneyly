import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/pages/add-expense/gelir-ekle.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pull_down_button/pull_down_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../blocs/form-bloc.dart';
import 'faturalar.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({Key? key}) : super(key: key);
  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}
class _SubscriptionsState extends State<Subscriptions> {
  FocusNode platformPriceFocusNode = FocusNode();
  FocusNode textFocusNode = FocusNode();

  List<String> sharedPreferencesData = [];
  List<String> desiredKeys = [
    'invoices',
    'incomeMap',
    'selected_option'
  ];
  List<Invoice> invoices = [];

  bool hasTVSelected = false;
  bool hasGameSelected = false;
  bool hasMusicSelected = false;

  List<String> tvTitleList = [];
  List<String> gameTitleList = [];
  List<String> musicTitleList = [];
  List<String> tvPriceList = [];
  List<String> gamePriceList = [];
  List<String> musicPriceList = [];

  double sumOfTV = 0.0;
  double sumOfGame = 0.0;
  double sumOfMusic = 0.0;

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

  int? _selectedBillingDay;
  int? _selectedBillingMonth;
  int? _selectedDueDay;
  String faturaDonemi = "";
  String? sonOdeme;
  bool isPromptOK = true;
  final ScrollController _scrollController = ScrollController();

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

  Future<void> handleTVContainerTouch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasTVSelected2', true);
    await prefs.setBool('hasGameSelected2', false);
    await prefs.setBool('hasMusicSelected2', false);
    setState(() {
      hasTVSelected = true;
      hasGameSelected = false;
      hasMusicSelected = false;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isEditingList = false;
    });
  }
  Future<void> handleOyunContainerTouch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasTVSelected2', false);
    await prefs.setBool('hasGameSelected2', true);
    await prefs.setBool('hasMusicSelected2', false);
    setState(() {
      hasTVSelected = false;
      hasGameSelected = true;
      hasMusicSelected = false;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isEditingListND = false;
    });
  }
  Future<void> handleMuzikContainerTouch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasTVSelected2', false);
    await prefs.setBool('hasGameSelected2', false);
    await prefs.setBool('hasMusicSelected2', true);
    setState(() {
      hasTVSelected = false;
      hasGameSelected = false;
      hasMusicSelected = true;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isEditingListRD = false;
    });
  }

  void goToPreviousPage() {
    Navigator.pop(context);
  }
  Future<void> goToNextPage() async {
    exportSharedPreferencesDataToTxt();
    context.go('/bills');
  }

  Future<void> exportSharedPreferencesDataToTxt() async {
    final prefs = await SharedPreferences.getInstance();

    // Create a StringBuffer to store the data
    final buffer = StringBuffer();

    // Iterate through your SharedPreferences keys and add them to the buffer
    for (var key in prefs.getKeys()) {
      final value = prefs.get(key);
      buffer.write('$key: $value\n');
    }

    // Get the directory for the application's documents
    final directory = await getApplicationDocumentsDirectory();

    // Define the file path where you want to save the text file
    final filePath = '${directory.path}/preferences.txt';

    // Write the data to the file
    final file = File(filePath);
    await file.writeAsString(buffer.toString());

    // Optionally, display a message indicating the export is complete
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
        TextEditingController(text: gameTitleList[index]);
        TextEditingController NDpriceController =
        TextEditingController(text: gamePriceList[index]);
        selectedEditController = NDeditController;
        selectedPriceController = NDpriceController;
        break;
      case 3:
        TextEditingController RDeditController =
        TextEditingController(text: musicTitleList[index]);
        TextEditingController RDpriceController =
        TextEditingController(text: musicPriceList[index]);
        selectedEditController = RDeditController;
        selectedPriceController = RDpriceController;
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
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
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.white, width: 3),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: 'ABA',
                    hintStyle: TextStyle(color: Colors.black)
                ),
                style: GoogleFonts.montserrat(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: Text("Price",style: GoogleFonts.montserrat(fontSize: 18))),
              const SizedBox(height: 10),
              TextFormField(
                controller: selectedPriceController,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: EdgeInsets.fromLTRB(10, 20, 20, 0),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.white, width: 3),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: 'GAG',
                    hintStyle: TextStyle(color: Colors.black)
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
                      child: PullDownButton(
                        scrollController: _scrollController,
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
                  Expanded(
                      child: PullDownButton(
                        scrollController: _scrollController,
                        itemBuilder: (context) => monthsList
                            .map(
                              (month) => PullDownMenuItem(
                              onTap: () {
                                FocusScope.of(context).unfocus(); // Unfocus the TextFormField
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
                              borderRadius: BorderRadius.circular(15),
                            ),
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
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: Text("Due Date",style: GoogleFonts.montserrat(fontSize: 18))),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: PullDownButton(
                  scrollController: _scrollController,
                  itemBuilder: (context) => daysList
                      .map(
                        (day) => PullDownMenuItem(
                        onTap: () {
                          FocusScope.of(context).unfocus(); // Unfocus the TextFormField
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
              child: const Text('Cancel'),
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
                    case 3:
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
                  }
                });
                Navigator.of(context).pop();
              },

              child: const Text('Save'),
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
                        gameTitleList.removeAt(index);
                        gamePriceList.removeAt(index);
                        isEditingListND = false;
                        isAddButtonActiveND = false;
                        break;
                      case 3:
                        musicTitleList.removeAt(index);
                        musicPriceList.removeAt(index);
                        isEditingListRD = false;
                        isAddButtonActiveRD = false;
                        break;
                    }
                    Navigator.of(context).pop();
                  });
                },
                child: const Text("Remove"))
          ],
        );
      },
    );
  }

  void _showBillPaidPrompt() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Fatura Ödendi mi?'),
          content: Text('Bu ay fatura ödendi mi?'),
          actions: <Widget>[
            TextButton(
              child: Text('Hayır'),
              onPressed: () {
                setState(() {
                  isPromptOK = false;
                });
                print("1F: isPromptOK:${isPromptOK}");
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Evet'),
              onPressed: () {
                setState(() {
                  isPromptOK = true;
                });
                Navigator.of(context).pop();
              },
            ),
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

  @override
  void dispose() {
    platformPriceFocusNode.dispose();
    textFocusNode.dispose();
    super.dispose();
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
    final bb1 = prefs.getStringList('tvTitleList2') ?? [];
    final bb2 = prefs.getStringList('gameTitleList2') ?? [];
    final bb3 = prefs.getStringList('musicTitleList2') ?? [];
    final cb1 = prefs.getStringList('tvPriceList2') ?? [];
    final cb2 = prefs.getStringList('gamePriceList2') ?? [];
    final cb3 = prefs.getStringList('musicPriceList2') ?? [];
    final db1 = prefs.getDouble('sumOfTV2') ?? 0.0;
    final db2 = prefs.getDouble('sumOfGame2') ?? 0.0;
    final db3 = prefs.getDouble('sumOfMusic2') ?? 0.0;
    final eb1 = prefs.getStringList('invoices') ?? [];
    setState(() {
      tvTitleList = bb1;
      gameTitleList = bb2;
      musicTitleList = bb3;
      tvPriceList = cb1;
      gamePriceList = cb2;
      musicPriceList = cb3;
      sumOfTV = db1;
      sumOfGame = db2;
      sumOfMusic = db3;
      for (final invoiceString in eb1) {
        final Map<String, dynamic> invoiceJson = jsonDecode(invoiceString);
        final Invoice invoice = Invoice.fromJson(invoiceJson);
        invoices.add(invoice);
      }
      loadSharedPreferencesData(desiredKeys);
    });
    //await prefs.setStringList('invoices', []);
    //await prefs.setStringList('tvTitleList2', []);
    //await prefs.setStringList('tvPriceList2', []);
    //await prefs.setDouble('sumOfTV2', 0.0);
    convertSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfTV);
    convertSum2 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfGame);
    convertSum3 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfMusic);
  }

  Future<void> setSumAll(double value) async {
    final prefs = await SharedPreferences.getInstance();
    print("value is $value");
    prefs.setDouble('sumOfTV2', value);
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
        invoice.difference = (DateTime.parse(sonOdeme!).difference(currentDate).inDays + 1).toString();;
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
    double tvSum = calculateSubcategorySum(invoices, 'TV');
    String formattedTvSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(tvSum);
    double sumAll = 0.0;
    sumAll += tvSum;
    sumAll += sumOfGame;
    sumAll += sumOfMusic;
    setSumAll(tvSum);
    List<int> idsWithTVTargetCategory = [];
    for (Invoice invoice in invoices) {
      if (invoice.subCategory == "TV") {
        idsWithTVTargetCategory.add(invoice.id);
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
                        "Abonelikler",
                        style: TextStyle(
                            fontFamily: 'Keep Calm',
                            color: Colors.black,
                            fontSize: 28.sp
                        )
                    ),
                    Text(
                        "2/4",
                        style: TextStyle(
                            fontFamily: 'Keep Calm',
                            color: Colors.black,
                            fontSize: 24.sp
                        )
                    ),
                  ],
                ),
              ),
              body: Container(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 4)
                      )
                    ]
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                  child:  Container(
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
                                          color: hasTVSelected ? Colors.black : Colors.black.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          if(isAddButtonActive==false){
                                            handleTVContainerTouch();
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
                                                padding: const EdgeInsets.all(20),
                                                child: Text(
                                                    "Film, Dizi ve TV",
                                                    style: GoogleFonts.montserrat(
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.bold,
                                                        color: hasTVSelected ? Colors.white : Colors.black
                                                    )
                                                )
                                            ),
                                            ListView.builder(
                                              physics: NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: invoices.length,
                                              itemBuilder: (context, index) {
                                                Invoice invoice = invoices[index];
                                                String invoiceText = invoice.toDisplayString();
                                                return Text(invoiceText, style: TextStyle(color: hasTVSelected ? Colors.white : Colors.black));
                                              },
                                            ),
                                            if (invoices.isNotEmpty && invoices.isNotEmpty)
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: idsWithTVTargetCategory.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  int id = idsWithTVTargetCategory[i];
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
                                                          icon: Icon(Icons.edit, size: 21, color: hasTVSelected ? Colors.white : Colors.black),
                                                          onPressed: () {
                                                            _showEditDialog(context, i, 1, id); // Show the edit dialog
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            if (isTextFormFieldVisible && hasTVSelected)
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          "Fatura Adı",
                                                          style: GoogleFonts.montserrat(
                                                              fontSize: 15.sp,
                                                              color: hasTVSelected ? Colors.white : Colors.black
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
                                                              borderRadius: BorderRadius.circular(15),
                                                              borderSide: BorderSide(color: Colors.white, width: 3),
                                                            ),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(15),
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
                                                              color: hasTVSelected ? Colors.white : Colors.black
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
                                                              borderRadius: BorderRadius.circular(15),
                                                              borderSide: BorderSide(color: Colors.white, width: 3),
                                                            ),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(15),
                                                            ),
                                                            hintText: 'GAG',
                                                            hintStyle: TextStyle(color: Colors.black)
                                                        ),
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
                                                                        color: hasTVSelected ? Colors.white : Colors.black
                                                                    )
                                                                ),
                                                                SizedBox(height: 5.h),
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                        child: PullDownButton(
                                                                          scrollController: _scrollController,
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
                                                                                borderRadius: BorderRadius.circular(15),
                                                                              ),
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
                                                                        color: hasTVSelected ? Colors.white : Colors.black
                                                                    )
                                                                ),
                                                                SizedBox(height: 5.h),
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                      flex:1,
                                                                      child: PullDownButton(
                                                                        scrollController: _scrollController,
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
                                                                                double dprice = double.tryParse(priceText) ?? 0.0;
                                                                                String price = dprice.toStringAsFixed(2);
                                                                                final invoice = Invoice(
                                                                                  id: newId,
                                                                                  price: price,
                                                                                  subCategory: 'TV',
                                                                                  category: "Abonelikler",
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
                                                                            icon: const Icon(Icons.check_circle, size: 26, color: Colors.white),
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
                                                                            icon: const Icon(Icons.cancel, size: 26, color: Colors.white),
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
                                            if (!isEditingList && !isTextFormFieldVisible)
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          hasTVSelected = true;
                                                          hasGameSelected = false;
                                                          hasMusicSelected = false;
                                                          isAddButtonActive = true;
                                                          isTextFormFieldVisible = true;
                                                          isTextFormFieldVisibleND =false;
                                                          isTextFormFieldVisibleRD = false;
                                                          platformPriceController.clear();
                                                        });
                                                      },
                                                      child: Icon(Icons.add_circle, size: 26, color: hasTVSelected ? Colors.white : Colors.black),
                                                    ),
                                                    if (formattedTvSum != "0,00")
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 43),
                                                        child: Text("Toplam: $formattedTvSum", style: GoogleFonts.montserrat(fontSize: 20),),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: hasGameSelected ? Colors.black : Colors.black.withOpacity(0.5),
                                          width: hasGameSelected ? 4 : 2,
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          if(isAddButtonActiveND==false){
                                            handleOyunContainerTouch();
                                            isAddButtonActive = false;
                                            isAddButtonActiveRD = false;
                                          } else {
                                            isAddButtonActive = false;
                                            isAddButtonActiveRD = false;
                                          }
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.all(10),
                                                child: Text("Oyun",style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),)
                                            ),
                                            if (gameTitleList.isNotEmpty && gamePriceList.isNotEmpty)
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: gameTitleList.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  double sum3 = double.parse(gamePriceList[i]);
                                                  String convertSuma = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum3);
                                                  return Container(
                                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            gameTitleList[i],
                                                            style: GoogleFonts.montserrat(fontSize: 20),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            textAlign: TextAlign.right,
                                                            convertSuma,
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
                                                            _showEditDialog(context, i, 2, 0); // Show the edit dialog
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            if (isTextFormFieldVisibleND && hasGameSelected)
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: NDtextController,
                                                        decoration: const InputDecoration(
                                                          border: InputBorder.none,
                                                          hintText: 'ABA',
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: NDplatformPriceController,
                                                        keyboardType: TextInputType.number, // Show numeric keyboard
                                                        decoration: const InputDecoration(
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
                                                                gameTitleList.add(text);
                                                                gamePriceList.add(price);
                                                                context.read<FormBloc>().add(AddGameTitle(text));
                                                                context.read<FormBloc>().add(AddGamePrice(price));
                                                                context.read<FormBloc>().add(CalculateGameSum(gamePriceList));
                                                                isEditingListND = false; // Add a corresponding entry for the new item
                                                                NDtextController.clear();
                                                                NDplatformPriceController.clear();
                                                                isTextFormFieldVisibleND = false;
                                                                isAddButtonActiveND = false;
                                                              });
                                                            }
                                                          },
                                                          icon: const Icon(Icons.check_circle, size: 26),
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
                                                          icon: const Icon(Icons.cancel, size: 26),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (!isEditingListND && !isTextFormFieldVisibleND)
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          hasTVSelected = false;
                                                          hasGameSelected = true;
                                                          hasMusicSelected = false;
                                                          isAddButtonActiveND = true;
                                                          isTextFormFieldVisible = false;
                                                          isTextFormFieldVisibleND =true;
                                                          isTextFormFieldVisibleRD = false;
                                                          NDplatformPriceController.clear();
                                                        });
                                                      },
                                                      child: const Icon(Icons.add_circle, size: 26),
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
                                    const SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: hasMusicSelected ? Colors.black : Colors.black.withOpacity(0.5),
                                          width: hasMusicSelected ? 4 : 2,
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          if(isAddButtonActiveRD==false){
                                            handleMuzikContainerTouch();
                                            isAddButtonActive = false;
                                            isAddButtonActiveND = false;
                                          } else {
                                            isAddButtonActive = false;
                                            isAddButtonActiveND = false;
                                          }
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.all(10),
                                                child: Text("Müzik",style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold),)
                                            ),
                                            if (musicTitleList.isNotEmpty && musicPriceList.isNotEmpty)
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: musicTitleList.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  double sum2 = double.parse(musicPriceList[i]);
                                                  String convertSumo = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum2);
                                                  return Container(
                                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            musicTitleList[i],
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
                                                        const SizedBox(width: 20),
                                                        IconButton(
                                                          splashRadius: 0.0001,
                                                          padding: EdgeInsets.zero,
                                                          constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                                          icon: const Icon(Icons.edit, size: 21),
                                                          onPressed: () {
                                                            _showEditDialog(context, i, 3, 0); // Show the edit dialog
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            if (isTextFormFieldVisibleRD && hasMusicSelected)
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: RDtextController,
                                                        decoration: const InputDecoration(
                                                          border: InputBorder.none,
                                                          hintText: 'ABA',
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: RDplatformPriceController,
                                                        keyboardType: TextInputType.number, // Show numeric keyboard
                                                        decoration: const InputDecoration(
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
                                                                musicTitleList.add(text);
                                                                musicPriceList.add(price);
                                                                context.read<FormBloc>().add(AddMusicTitle(text));
                                                                context.read<FormBloc>().add(AddMusicPrice(price));
                                                                context.read<FormBloc>().add(CalculateMusicSum(musicPriceList));
                                                                isEditingListRD = false; // Add a corresponding entry for the new item
                                                                RDtextController.clear();
                                                                RDplatformPriceController.clear();
                                                                isTextFormFieldVisibleRD = false;
                                                                isAddButtonActiveRD = false;
                                                              });
                                                            }
                                                          },
                                                          icon: const Icon(Icons.check_circle, size: 26),
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
                                                          icon: const Icon(Icons.cancel, size: 26),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (!isEditingListRD && !isTextFormFieldVisibleRD)
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          hasTVSelected = false;
                                                          hasGameSelected = false;
                                                          hasMusicSelected = true;
                                                          isAddButtonActiveRD = true;
                                                          isTextFormFieldVisible = false;
                                                          isTextFormFieldVisibleND =false;
                                                          isTextFormFieldVisibleRD = true;
                                                          RDplatformPriceController.clear();
                                                        });
                                                      },
                                                      child: const Icon(Icons.add_circle, size: 26),
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
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
                        height: 42.h,
                        width: 42.h,
                        color: Colors.white,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              backgroundColor: sumAll != 0.0 ? Colors.black : Colors.grey,
                            ),
                            clipBehavior: Clip.hardEdge,
                            onPressed: () {
                              context.go('/');
                            },
                            child: Icon(Icons.arrow_back, color: sumAll != 0.0 ? Colors.white : Colors.black, size: 20.sp,)
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: Container(
                          height: 42.h,
                          color: Colors.white,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              backgroundColor: sumAll != 0.0 ? Colors.black : Colors.grey,
                            ),
                            clipBehavior: Clip.hardEdge,
                            onPressed: sumAll != 0.0 ? () {
                              goToNextPage();
                            } : null,
                            child: Text('Sonraki', style: GoogleFonts.montserrat(fontSize: 18)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
      )
    );
  }
}
