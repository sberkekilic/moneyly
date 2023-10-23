import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../deneme.dart';
import 'faturalar.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({Key? key}) : super(key: key);
  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}
class _SubscriptionsState extends State<Subscriptions> {
  List<String> sharedPreferencesData = [];
  List<String> desiredKeys = ['tvTitleList2', 'tvPriceList2', 'hasTVSelected2', 'sumOfTV2', 'gameTitleList2', 'gamePriceList2', 'hasGameSelected2', 'sumOfGame2', 'musicTitleList2', 'musicPriceList2', 'hasMusicSelected2', 'sumOfMusic2'];
  final List<Invoice> invoices = [];
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
  int? _selectedDueDay;

  List<int> daysList = List.generate(31, (index) => index + 1);

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
      _load();
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
      _load();
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
      _load();
    });
  }

  void goToPreviousPage() {
    Navigator.pop(context);
  }
  Future<void> goToNextPage() async {
    exportSharedPreferencesDataToTxt();
    Navigator.pushNamed(context, 'faturalar');
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

    // Define the file path where you want to save the text file
    final filePath = '/data/user/0/com.example.moneyly/app_flutter/preferences.txt';

    // Write the data to the file
    final file = File(filePath);
    await file.writeAsString(buffer.toString());

    // Optionally, display a message indicating the export is complete
  }
  void _showEditDialog(BuildContext context, int index, int orderIndex) {
    final formDataProvider2 = Provider.of<FormDataProvider2>(context, listen: false);

    TextEditingController selectedEditController = TextEditingController();
    TextEditingController selectedPriceController = TextEditingController();

    switch (orderIndex) {
      case 1:
        TextEditingController editController =
        TextEditingController(text: tvTitleList[index]);
        TextEditingController priceController =
        TextEditingController(text: tvPriceList[index]);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          title: Text('Edit Item',style: GoogleFonts.montserrat(fontSize: 20)),
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
                      tvTitleList[index] = selectedEditController.text;
                      tvPriceList[index] = price;
                      formDataProvider2.setTVTitleValue(selectedEditController.text, tvTitleList);
                      formDataProvider2.setTVPriceValue(price, tvPriceList);
                      formDataProvider2.calculateSumOfTV(tvPriceList);
                      break;
                    case 2:
                      final priceText = selectedPriceController.text.trim();
                      double dprice = double.tryParse(priceText) ?? 0.0;
                      String price = dprice.toStringAsFixed(2);
                      gameTitleList[index] = selectedEditController.text;
                      gamePriceList[index] = price;
                      formDataProvider2.setGameTitleValue(selectedEditController.text, gameTitleList);
                      formDataProvider2.setGamePriceValue(price, gamePriceList);
                      formDataProvider2.calculateSumOfGame(gamePriceList);
                      break;
                    case 3:
                      final priceText = selectedPriceController.text.trim();
                      double dprice = double.tryParse(priceText) ?? 0.0;
                      String price = dprice.toStringAsFixed(2);
                      musicTitleList[index] = selectedEditController.text;
                      musicPriceList[index] = price;
                      formDataProvider2.setMusicTitleValue(selectedEditController.text, musicTitleList);
                      formDataProvider2.setMusicPriceValue(price, musicPriceList);
                      formDataProvider2.calculateSumOfMusic(musicPriceList);
                      break;
                  }
                });
                _load();
                Navigator.of(context).pop();
              },

              child: const Text('Save'),
            ),
            TextButton(
                onPressed: () {
                  setState(() {
                    switch (orderIndex){
                      case 1:
                        tvTitleList.removeAt(index);
                        tvPriceList.removeAt(index);
                        formDataProvider2.removeTVTitleValue(tvTitleList);
                        formDataProvider2.removeTVPriceValue(tvPriceList);
                        formDataProvider2.calculateSumOfTV(tvPriceList);
                        isEditingList = false;
                        isAddButtonActive = false;
                        break;
                      case 2:
                        gameTitleList.removeAt(index);
                        gamePriceList.removeAt(index);
                        formDataProvider2.removeGameTitleValue(gameTitleList);
                        formDataProvider2.removeGamePriceValue(gamePriceList);
                        formDataProvider2.calculateSumOfGame(gamePriceList);
                        isEditingListND = false;
                        isAddButtonActiveND = false;
                        break;
                      case 3:
                        musicTitleList.removeAt(index);
                        musicPriceList.removeAt(index);
                        formDataProvider2.removeMusicTitleValue(musicTitleList);
                        formDataProvider2.removeMusicPriceValue(musicPriceList);
                        formDataProvider2.calculateSumOfMusic(musicPriceList);
                        isEditingListRD = false;
                        isAddButtonActiveRD = false;
                        break;
                    }
                    _load();
                    Navigator.of(context).pop();
                  });
                },
                child: const Text("Remove"))
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
    final ab1 = prefs.getBool('hasTVSelected2') ?? false;
    final ab2 = prefs.getBool('hasGameSelected2') ?? false;
    final ab3 = prefs.getBool('hasMusicSelected2') ?? false;
    final bb1 = prefs.getStringList('tvTitleList2') ?? [];
    final bb2 = prefs.getStringList('gameTitleList2') ?? [];
    final bb3 = prefs.getStringList('musicTitleList2') ?? [];
    final cb1 = prefs.getStringList('tvPriceList2') ?? [];
    final cb2 = prefs.getStringList('gamePriceList2') ?? [];
    final cb3 = prefs.getStringList('musicPriceList2') ?? [];
    final db1 = prefs.getDouble('sumOfTV2') ?? 0.0;
    final db2 = prefs.getDouble('sumOfGame2') ?? 0.0;
    final db3 = prefs.getDouble('sumOfMusic2') ?? 0.0;
    setState(() {
      hasTVSelected = ab1;
      hasGameSelected = ab2;
      hasMusicSelected = ab3;
      tvTitleList = bb1;
      gameTitleList = bb2;
      musicTitleList = bb3;
      tvPriceList = cb1;
      gamePriceList = cb2;
      musicPriceList = cb3;
      sumOfTV = db1;
      sumOfGame = db2;
      sumOfMusic = db3;
      loadSharedPreferencesData(desiredKeys);
    });
    convertSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfTV);
    convertSum2 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfGame);
    convertSum3 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfMusic);
  }
  Future<void> setSumAll(double value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('sumOfSubs2', value);
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
    sumAll += sumOfTV;
    sumAll += sumOfGame;
    sumAll += sumOfMusic;
    setSumAll(sumAll);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff0f0f1),
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
                    Navigator.pushNamed(context, 'gelir-ekle');
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.black), // Replace with the desired left icon
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
                  },
                  icon: const Icon(Icons.clear, color: Colors.black), // Replace with the desired right icon
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
                const SizedBox(width: 20),
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
                      onPressed: sumAll!= 0.0 ? () {
                        goToNextPage();
                      } : null,
                      child: Text('Sonraki', style: GoogleFonts.montserrat(fontSize: 18)),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
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
              color: const Color(0xfff0f0f1),
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.pushNamed(context, 'gelir-ekle');
                          },
                          splashColor: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 50,
                            width: (screenWidth-60) / 3,
                            child: Column(
                              children: [
                                Align(alignment: Alignment.center, child: Text("Gelir", style: GoogleFonts.montserrat(color: Colors.black, fontSize: 15))),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 8,
                                      width: (screenWidth-60) / 3,
                                    color: const Color(0xff1ab738)
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: (){
                            Navigator.pushNamed(context, 'abonelikler');
                          },
                          splashColor: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 50,
                            width: (screenWidth-60) / 3,
                            child: Column(
                              children: [
                                Align(alignment: Alignment.center, child: Text("Abonelikler", style: GoogleFonts.montserrat(color: const Color(0xff1ab738), fontWeight: FontWeight.bold, fontSize: 15))),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 8,
                                    width: (screenWidth-60) / 3,
                                    color: const Color(
                                        0xff1ab738),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          splashColor: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 50,
                            width: (screenWidth-60) / 3,
                            child: Column(
                              children: [
                                Align(alignment: Alignment.center, child: Text("Faturalar", style: GoogleFonts.montserrat(color: const Color(0xffc6c6c7), fontSize: 15))),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 8,
                                    width: (screenWidth-60) / 3,
                                    color: const Color(
                                        0xffc6c6c7),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          splashColor: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 50,
                            width: ((screenWidth-60) / 3) + 10,
                            child: Column(
                              children: [
                                Align(alignment: Alignment.center, child: Text("Diğer Giderler", style: GoogleFonts.montserrat(color: const Color(
                                    0xffc6c6c7), fontSize: 15))),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 8,
                                    width: ((screenWidth-60) / 3) + 10,
                                    color: const Color(
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
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: hasTVSelected ? Colors.black : Colors.black.withOpacity(0.5),
                                        width: hasTVSelected ? 4 : 2,
                                      ),
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
                                              padding: const EdgeInsets.all(10),
                                              child: Text("Film, Dizi ve TV",style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold),)
                                          ),
                                          if (tvTitleList.isNotEmpty && tvPriceList.isNotEmpty)
                                            ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: tvTitleList.length,
                                              itemBuilder: (BuildContext context, int i) {
                                                double sum2 = double.parse(tvPriceList[i]);
                                                String convertSumo = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum2);
                                                return Container(
                                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            tvTitleList[i],
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
                                                                _showEditDialog(context, i, 1); // Show the edit dialog
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
                                              child: Column(
                                                children: [
                                                  Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Expanded(
                                                            child: TextFormField(
                                                              controller: textController,
                                                              decoration: const InputDecoration(
                                                                border: InputBorder.none,
                                                                hintText: 'ABA',
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 10),
                                                          Expanded(
                                                            child: TextFormField(
                                                              controller: platformPriceController,
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
                                                                  final text = textController.text.trim();
                                                                  final priceText = platformPriceController.text.trim();
                                                                  final invoice = Invoice(
                                                                    category: "Abonelikler",
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
                                                                      tvTitleList.add(text);
                                                                      tvPriceList.add(price);
                                                                      formDataProvider2.setTVTitleValue(text, tvTitleList);
                                                                      formDataProvider2.setTVPriceValue(price, tvPriceList);
                                                                      formDataProvider2.calculateSumOfTV(tvPriceList);
                                                                      isEditingList = false; // Add a corresponding entry for the new item
                                                                      textController.clear();
                                                                      platformPriceController.clear();
                                                                      isTextFormFieldVisible = false;
                                                                      isAddButtonActive = false;
                                                                      _load();
                                                                    });
                                                                  }
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
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                                            // Add Horizontal padding using menuItemStyleData.padding so it matches
                                                            // the menu padding when button's width is not specified.
                                                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                          ),
                                                          hint: const Text(
                                                            'Fatura Dönemi',
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
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: DropdownButtonFormField2<int>(
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
                                                    child: const Icon(Icons.add_circle, size: 26),
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
                                                          _showEditDialog(context, i, 2); // Show the edit dialog
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
                                                              formDataProvider2.setGameTitleValue(text, gameTitleList);
                                                              formDataProvider2.setGamePriceValue(price, gamePriceList);
                                                              formDataProvider2.calculateSumOfGame(gamePriceList);
                                                              isEditingListND = false; // Add a corresponding entry for the new item
                                                              NDtextController.clear();
                                                              NDplatformPriceController.clear();
                                                              isTextFormFieldVisibleND = false;
                                                              isAddButtonActiveND = false;
                                                              _load();
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
                                                          _showEditDialog(context, i, 3); // Show the edit dialog
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
                                                              formDataProvider2.setMusicTitleValue(text, musicTitleList);
                                                              formDataProvider2.setMusicPriceValue(price, musicPriceList);
                                                              formDataProvider2.calculateSumOfMusic(musicPriceList);
                                                              isEditingListRD = false; // Add a corresponding entry for the new item
                                                              RDtextController.clear();
                                                              RDplatformPriceController.clear();
                                                              isTextFormFieldVisibleRD = false;
                                                              isAddButtonActiveRD = false;
                                                              _load();
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
          ),
        ],
      )
    );
  }
}

