import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/pages/add-expense/gelir-ekle.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';
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
    _selectedBillingMonth = invoice.getPeriodMonth();
    _selectedDueDay = invoice.getDueDay();
    invoice.periodDate = formatPeriodDate(_selectedBillingDay ?? 0);
    if (_selectedDueDay != null) {
      invoice.dueDate = formatDueDate(_selectedDueDay, invoice.periodDate);
    }

    switch (orderIndex) {
      case 1:
        TextEditingController editController =
        TextEditingController(text: invoice.name);
        TextEditingController priceController =
        TextEditingController(text: NumberFormat('#,##0.00', 'tr_TR').format(double.parse(invoice.price)));
        selectedEditController = editController;
        selectedPriceController = priceController;
        break;
      case 2:
        TextEditingController NDeditController =
        TextEditingController(text: invoice.name);
        TextEditingController NDpriceController =
        TextEditingController(text: NumberFormat('#,##0.00', 'tr_TR').format(double.parse(invoice.price)));
        selectedEditController = NDeditController;
        selectedPriceController = NDpriceController;
        break;
      case 3:
        TextEditingController RDeditController =
        TextEditingController(text: invoice.name);
        TextEditingController RDpriceController =
        TextEditingController(text: NumberFormat('#,##0.00', 'tr_TR').format(double.parse(invoice.price)));
        selectedEditController = RDeditController;
        selectedPriceController = RDpriceController;
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( //TO UPDATE DAYS LIST
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
              ),
              title: Text(
                  'Edit Item id:$id',
                  style: GoogleFonts.montserrat(fontSize: 20, color: Colors.black)
              ),
              content: SingleChildScrollView(
                child: Column(
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
                      final priceText = selectedPriceController.text.trim();
                      num parsedPrice = NumberFormat.decimalPattern('tr_TR').parse(priceText) ?? 0;
                      double dprice = parsedPrice is double
                          ? parsedPrice
                          : parsedPrice.toDouble();
                      String price = dprice.toStringAsFixed(2);
                      String name = selectedEditController.text;
                      invoice.name = name;
                      invoice.price = price;
                      if (_selectedDueDay != null) {
                        editInvoice(
                          id,
                          formatPeriodDate(_selectedBillingDay!),
                          formatDueDate(_selectedDueDay, formatPeriodDate(_selectedBillingDay!)),
                        );
                      } else {
                        editInvoice(
                          id,
                          formatPeriodDate(_selectedBillingDay!),
                          null, // or provide any default value you want for dueDate when _selectedDueDay is null
                        );
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
                            isEditingListND = false;
                            isAddButtonActiveND = false;
                            removeInvoice(id);
                            break;
                          case 3:
                            isEditingListND = false;
                            isAddButtonActiveRD = false;
                            removeInvoice(id);
                            break;
                        }
                        Navigator.of(context).pop();
                      });
                    },
                    child: const Text("Remove"))
              ],
            );
          }
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

  String formatPeriodDate(int day) {
    final currentDate = DateTime.now();
    int year = currentDate.year;
    int month = currentDate.month;

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
    double gameSum = calculateSubcategorySum(invoices, 'Oyun');
    double musicSum = calculateSubcategorySum(invoices, 'Müzik');
    String formattedTvSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(tvSum);
    String formattedGameSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(gameSum);
    String formattedMusicSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(musicSum);
    double sumAll = 0.0;
    sumAll += tvSum;
    sumAll += gameSum;
    sumAll += musicSum;
    setSumAll(tvSum);
    setSumAll(gameSum);
    setSumAll(musicSum);
    List<int> idsWithTVTargetCategory = [];
    List<int> idsWithGameTargetCategory = [];
    List<int> idsWithMusicTargetCategory = [];
    for (Invoice invoice in invoices) {
      if (invoice.subCategory == "TV") {
        idsWithTVTargetCategory.add(invoice.id);
      } else if (invoice.subCategory == "Oyun") {
        idsWithGameTargetCategory.add(invoice.id);
      } else if (invoice.subCategory == "Müzik") {
        idsWithMusicTargetCategory.add(invoice.id);
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
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: hasTVSelected ? Colors.black : Colors.black.withOpacity(0.5),
                                            width: hasTVSelected ? 4 : 2
                                          )
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
                                            Text(
                                                "Film, Dizi ve TV",
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                )
                                            ),
                                            SizedBox(height: 10),
                                            /*ListView.builder(
                                              physics: NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: invoices.length,
                                              itemBuilder: (context, index) {
                                                Invoice invoice = invoices[index];
                                                String invoiceText = invoice.toDisplayString();
                                                return Text(invoiceText, style: TextStyle(color: hasTVSelected ? Colors.white : Colors.black));
                                              },
                                            ),*/
                                            if (invoices.isNotEmpty && idsWithTVTargetCategory.isNotEmpty && !isTextFormFieldVisible)
                                              Column(
                                                children: idsWithTVTargetCategory.asMap().entries.map((entry) {
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
                                                      if (i < idsWithTVTargetCategory.length - 1)
                                                        SizedBox(height: 10),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                            if (formattedTvSum != "0,00" && !isTextFormFieldVisible)
                                              SizedBox(height: 10),
                                            if (formattedTvSum != "0,00" && !isTextFormFieldVisible)
                                              Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Color.fromARGB(120, 152, 255, 170),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    padding: EdgeInsets.all(10),
                                                    child: SizedBox(
                                                      child: Text("Toplam: $formattedTvSum", style: GoogleFonts.montserrat(fontSize: 20),),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10)
                                                ],
                                              ),
                                            if (isTextFormFieldVisible && hasTVSelected)
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
                                                                Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: Text(
                                                                            "Başlangıç Tarihi",
                                                                            style: GoogleFonts.montserrat(
                                                                              fontSize: 15.sp,
                                                                            )
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child: Text(
                                                                            "Son Ödeme Tarihi",
                                                                            style: GoogleFonts.montserrat(
                                                                              fontSize: 15.sp,
                                                                            )
                                                                        ),
                                                                      ),
                                                                    ],
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
                                                                  ],
                                                                ),
                                                                Row(
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
                                                                            subCategory: 'TV',
                                                                            category: "Abonelikler",
                                                                            name: text,
                                                                            periodDate: formatPeriodDate(_selectedBillingDay!),
                                                                            dueDate: _selectedDueDay != null && _selectedBillingDay != null && _selectedBillingMonth != null
                                                                                ? formatDueDate(
                                                                                _selectedDueDay!,
                                                                                formatPeriodDate(_selectedBillingDay!)
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
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            if (formattedTvSum == "0,00" && !isTextFormFieldVisible)
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
                                    const SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
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
                                            Text(
                                                "Oyun",
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                )
                                            ),
                                            SizedBox(height: 10),
                                            if (invoices.isNotEmpty && idsWithGameTargetCategory.isNotEmpty && !isTextFormFieldVisibleND)
                                              Column(
                                                children: idsWithGameTargetCategory.asMap().entries.map((entry) {
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
                                                      if (i < idsWithGameTargetCategory.length - 1)
                                                        SizedBox(height: 10),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                            if (formattedGameSum != "0,00" && !isTextFormFieldVisibleND)
                                              SizedBox(height: 10),
                                            if (formattedGameSum != "0,00" && !isTextFormFieldVisibleND)
                                              Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Color.fromARGB(120, 152, 255, 170),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    padding: EdgeInsets.all(10),
                                                    child: SizedBox(
                                                      child: Text("Toplam: $formattedGameSum", style: GoogleFonts.montserrat(fontSize: 20),),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10)
                                                ],
                                              ),
                                            if (isTextFormFieldVisibleND && hasGameSelected)
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
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Text(
                                                                          "Başlangıç Tarihi",
                                                                          style: GoogleFonts.montserrat(
                                                                            fontSize: 15.sp,
                                                                          )
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: Text(
                                                                          "Son Ödeme Tarihi",
                                                                          style: GoogleFonts.montserrat(
                                                                            fontSize: 15.sp,
                                                                          )
                                                                      ),
                                                                    ),
                                                                  ],
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
                                                                  ],
                                                                ),
                                                                Row(
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
                                                                            subCategory: 'Oyun',
                                                                            category: "Abonelikler",
                                                                            name: text,
                                                                            periodDate: formatPeriodDate(_selectedBillingDay!),
                                                                            dueDate: _selectedDueDay != null && _selectedBillingDay != null && _selectedBillingMonth != null
                                                                                ? formatDueDate(
                                                                                _selectedDueDay!,
                                                                                formatPeriodDate(_selectedBillingDay!)
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
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            if (formattedGameSum == "0,00" && !isTextFormFieldVisibleND)
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
                                                            hasTVSelected = false;
                                                            hasGameSelected = true;
                                                            hasMusicSelected = false;
                                                            isAddButtonActiveND = true;
                                                            isTextFormFieldVisible = false;
                                                            isTextFormFieldVisibleND =true;
                                                            isTextFormFieldVisibleRD = false;
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
                                    const SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
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
                                            Text(
                                                "Müzik",
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                )
                                            ),
                                            SizedBox(height: 10),
                                            if (invoices.isNotEmpty && idsWithMusicTargetCategory.isNotEmpty && !isTextFormFieldVisibleRD)
                                              Column(
                                                children: idsWithMusicTargetCategory.asMap().entries.map((entry) {
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
                                                      if (i < idsWithMusicTargetCategory.length - 1)
                                                        SizedBox(height: 10),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                            if (formattedMusicSum != "0,00" && !isTextFormFieldVisibleRD)
                                              SizedBox(height: 10),
                                            if (formattedMusicSum != "0,00" && !isTextFormFieldVisibleRD)
                                              Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Color.fromARGB(120, 152, 255, 170),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    padding: EdgeInsets.all(10),
                                                    child: SizedBox(
                                                      child: Text("Toplam: $formattedMusicSum", style: GoogleFonts.montserrat(fontSize: 20),),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10)
                                                ],
                                              ),
                                            if (isTextFormFieldVisibleRD && hasMusicSelected)
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
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Text(
                                                                          "Başlangıç Tarihi",
                                                                          style: GoogleFonts.montserrat(
                                                                            fontSize: 15.sp,
                                                                          )
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: Text(
                                                                          "Son Ödeme Tarihi",
                                                                          style: GoogleFonts.montserrat(
                                                                            fontSize: 15.sp,
                                                                          )
                                                                      ),
                                                                    ),
                                                                  ],
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
                                                                  ],
                                                                ),
                                                                Row(
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
                                                                            subCategory: 'Müzik',
                                                                            category: "Abonelikler",
                                                                            name: text,
                                                                            periodDate: formatPeriodDate(_selectedBillingDay!),
                                                                            dueDate: _selectedDueDay != null && _selectedBillingDay != null && _selectedBillingMonth != null
                                                                                ? formatDueDate(
                                                                                _selectedDueDay!,
                                                                                formatPeriodDate(_selectedBillingDay!)
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
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            if (formattedMusicSum == "0,00" && !isTextFormFieldVisibleRD)
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
                                                            hasTVSelected = false;
                                                            hasGameSelected = false;
                                                            hasMusicSelected = true;
                                                            isAddButtonActiveRD = true;
                                                            isTextFormFieldVisible = false;
                                                            isTextFormFieldVisibleND =false;
                                                            isTextFormFieldVisibleRD = true;
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
                              context.go('/');
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
      )
    );
  }
}
