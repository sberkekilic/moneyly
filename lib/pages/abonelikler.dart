import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import '../form-data-provider.dart';
import 'faturalar.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({Key? key}) : super(key: key);
  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}
class _SubscriptionsState extends State<Subscriptions> {

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

  bool isTVContainerTouched = false;
  bool isOyunContainerTouched = false;
  bool isMuzikContainerTouched = false;

  void handleTVContainerTouch() {
    setState(() {
      isTVContainerTouched = true;
      isOyunContainerTouched = false;
      isMuzikContainerTouched = false;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isEditingList = false;
    });
  }
  void handleOyunContainerTouch() {
    setState(() {
      isTVContainerTouched = false;
      isOyunContainerTouched = true;
      isMuzikContainerTouched = false;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isEditingListND = false;
    });
  }
  void handleMuzikContainerTouch() {
    setState(() {
      isTVContainerTouched = false;
      isOyunContainerTouched = false;
      isMuzikContainerTouched = true;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isEditingListRD = false;
    });
  }

  void goToPreviousPage() {
    Navigator.pop(context);
  }
  void goToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Bills(),
      ),
    );
  }

  void _showEditDialog(BuildContext context, int index, int orderIndex) {
    final formDataProvider = Provider.of<FormDataProvider>(context, listen: false);

    TextEditingController selectedEditController = TextEditingController();
    TextEditingController selectedPriceController = TextEditingController();

    switch (orderIndex) {
      case 1:
        TextEditingController editController =
        TextEditingController(text: formDataProvider.tvTitleList[index]);
        TextEditingController priceController =
        TextEditingController(text: formDataProvider.tvPriceList[index]);
        selectedEditController = editController;
        selectedPriceController = priceController;
        break;
      case 2:
        TextEditingController NDeditController =
        TextEditingController(text: formDataProvider.gamingTitleList[index]);
        TextEditingController NDpriceController =
        TextEditingController(text: formDataProvider.gamingPriceList[index]);
        selectedEditController = NDeditController;
        selectedPriceController = NDpriceController;
        break;
      case 3:
        TextEditingController RDeditController =
        TextEditingController(text: formDataProvider.musicTitleList[index]);
        TextEditingController RDpriceController =
        TextEditingController(text: formDataProvider.musicPriceList[index]);
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
                      formDataProvider.tvTitleList[index] = selectedEditController.text;
                      formDataProvider.tvPriceList[index] = selectedPriceController.text;
                      break;
                    case 2:
                      formDataProvider.gamingTitleList[index] = selectedEditController.text;
                      formDataProvider.gamingPriceList[index] = selectedPriceController.text;
                      break;
                    case 3:
                      formDataProvider.musicTitleList[index] = selectedEditController.text;
                      formDataProvider.musicPriceList[index] = selectedPriceController.text;
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
                        TextEditingController priceController =
                        TextEditingController(text: formDataProvider.tvPriceList[index]);
                        formDataProvider.tvTitleList.removeAt(index);
                        formDataProvider.tvPriceList.removeAt(index);
                        priceController.clear();
                        isEditingList = false;
                        isAddButtonActive = false;
                        break;
                      case 2:
                        TextEditingController NDpriceController =
                        TextEditingController(text: formDataProvider.gamingPriceList[index]);
                        formDataProvider.gamingTitleList.removeAt(index);
                        formDataProvider.gamingPriceList.removeAt(index);
                        NDpriceController.clear();
                        isEditingListND = false;
                        isAddButtonActiveND = false;
                        break;
                      case 3:
                        TextEditingController RDpriceController =
                        TextEditingController(text: formDataProvider.musicPriceList[index]);
                        formDataProvider.musicTitleList.removeAt(index);
                        formDataProvider.musicPriceList.removeAt(index);
                        RDpriceController.clear();
                        isEditingListRD = false;
                        isAddButtonActiveRD = false;
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
    if(Provider.of<FormDataProvider>(context, listen: false).tvTitleList.isNotEmpty){
      isTVContainerTouched = true;
    }
    if(Provider.of<FormDataProvider>(context, listen: false).gamingTitleList.isNotEmpty){
      isOyunContainerTouched = true;
    }
    if(Provider.of<FormDataProvider>(context, listen: false).tvTitleList.isNotEmpty){
      isMuzikContainerTouched = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formDataProvider = Provider.of<FormDataProvider>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
    double sum = 0.0;
    for(String price in formDataProvider.tvPriceList){
      sum += double.parse(price);
    }
    double sumoyun = 0.0;
    for(String price in formDataProvider.gamingPriceList){
      sumoyun += double.parse(price);
    }
    double summuzik = 0.0;
    for(String price in formDataProvider.musicPriceList){
      summuzik += double.parse(price);
    }
    String convertSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum);
    formDataProvider.sumOfTV = convertSum;
    String convertSum2 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumoyun);
    formDataProvider.sumOfGaming = convertSum2;
    String convertSum3 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(summuzik);
    formDataProvider.sumOfMusic = convertSum3;
    double sumAll = 0.0;
    sumAll += sum;
    sumAll += sumoyun;
    sumAll += summuzik;

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
                    Navigator.pushNamed(context, 'gelir-ekle');
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
                      onPressed: () {
                        Navigator.pushNamed(context, 'faturalar');
                      },
                      child: Text('Sonraki', style: GoogleFonts.montserrat(fontSize: 18)),
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
                                Align(child: Text("Abonelikler", style: GoogleFonts.montserrat(color: Color(0xff1ab738), fontWeight: FontWeight.bold, fontSize: 15)), alignment: Alignment.center),
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
                          splashColor: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 50,
                            width: (screenWidth-60) / 3,
                            child: Column(
                              children: [
                                Align(child: Text("Faturalar", style: GoogleFonts.montserrat(color: Color(0xffc6c6c7), fontSize: 15)), alignment: Alignment.center),
                                SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 8,
                                    width: (screenWidth-60) / 3,
                                    color: Color(
                                        0xffc6c6c7),
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
                                Align(child: Text("Diğer Giderler", style: GoogleFonts.montserrat(color: Color(
                                    0xffc6c6c7), fontSize: 15)), alignment: Alignment.center),
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
                                        color: isTVContainerTouched ? Colors.black : Colors.black.withOpacity(0.5),
                                        width: isTVContainerTouched ? 4 : 2,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if(isAddButtonActive==false){
                                          print("if 1");
                                          handleTVContainerTouch();
                                          isAddButtonActiveND = false;
                                          isAddButtonActiveRD = false;
                                        } else {
                                          print("else 1");
                                          isAddButtonActiveND = false;
                                          isAddButtonActiveRD = false;
                                        }
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text("Film, Dizi ve TV",style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold),)
                                          ),
                                          if (formDataProvider.tvTitleList.isNotEmpty && formDataProvider.tvPriceList.isNotEmpty)
                                            Container(
                                              child:
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: formDataProvider.tvTitleList.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  double sum2 = double.parse(formDataProvider.tvPriceList[i]);
                                                  String convertSumo = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum2);
                                                  return Container(
                                                      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                      child: Row(
                                                        children: [
                                                          Flexible(
                                                            flex: 2,
                                                            fit: FlexFit.tight,
                                                            child: Text(
                                                              formDataProvider.tvTitleList[i],
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
                                          if (isTextFormFieldVisible && isTVContainerTouched)
                                            Container(
                                              padding: EdgeInsets.all(10),
                                              child: Row(
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
                                                          if (text.isNotEmpty && priceText.isNotEmpty) {
                                                            double dprice = double.tryParse(priceText) ?? 0.0;
                                                            String price = dprice.toStringAsFixed(2);
                                                            setState(() {
                                                              formDataProvider.updateTextValue(text, 2, 1);
                                                              formDataProvider.updateNumberValue(price, 2, 1);
                                                              isEditingList = false; // Add a corresponding entry for the new item
                                                              textController.clear();
                                                              formDataProvider.notifyListeners();
                                                              platformPriceController.clear();
                                                              formDataProvider.notifyListeners();
                                                              isTextFormFieldVisible = false;
                                                              isAddButtonActive = false;
                                                              //***********************//
                                                              formDataProvider.tvTitleList.forEach((item) {
                                                                print("ekle ikonu item: $item");
                                                              });
                                                              //***********************//
                                                              //***********************//
                                                              formDataProvider.tvPriceList.forEach((item) {
                                                                print("ekle ikonu price: $item");
                                                              });
                                                              //***********************//
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
                                                        isTVContainerTouched = true;
                                                        isOyunContainerTouched = false;
                                                        isMuzikContainerTouched = false;
                                                        isAddButtonActive = true;
                                                        isTextFormFieldVisible = true;
                                                        isTextFormFieldVisibleND =false;
                                                        isTextFormFieldVisibleRD = false;
                                                        platformPriceController.clear();
                                                      });
                                                    },
                                                    child: Icon(Icons.add_circle, size: 26),
                                                  ),
                                                  if (convertSum != "0,00")
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 43),
                                                    child: Text("Toplam: ${convertSum}", style: GoogleFonts.montserrat(fontSize: 20),),
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
                                        color: isOyunContainerTouched ? Colors.black : Colors.black.withOpacity(0.5),
                                        width: isOyunContainerTouched ? 4 : 2,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if(isAddButtonActiveND==false){
                                          print("if 2");
                                          handleOyunContainerTouch();
                                          isAddButtonActive = false;
                                          isAddButtonActiveRD = false;
                                        } else {
                                          print("else 2");
                                          isAddButtonActive = false;
                                          isAddButtonActiveRD = false;
                                        }
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text("Oyun",style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),)
                                          ),
                                          if (formDataProvider.gamingTitleList.isNotEmpty && formDataProvider.gamingPriceList.isNotEmpty)
                                            Container(
                                              child:
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: formDataProvider.gamingTitleList.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  double sum3 = double.parse(formDataProvider.gamingPriceList[i]);
                                                  String convertSuma = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum3);
                                                  return Container(
                                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            formDataProvider.gamingTitleList[i],
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
                                          if (isTextFormFieldVisibleND && isOyunContainerTouched)
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
                                                              formDataProvider.updateTextValue(text, 2, 2);
                                                              formDataProvider.updateNumberValue(price, 2, 2);
                                                              isEditingListND = false; // Add a corresponding entry for the new item
                                                              NDtextController.clear();
                                                              formDataProvider.notifyListeners();
                                                              NDplatformPriceController.clear();
                                                              formDataProvider.notifyListeners();
                                                              isTextFormFieldVisibleND = false;
                                                              isAddButtonActiveND = false;
                                                              //***********************//
                                                              formDataProvider.gamingTitleList.forEach((item) {
                                                                print("ekle ikonu item: $item");
                                                              });
                                                              //***********************//
                                                              //***********************//
                                                              formDataProvider.tvPriceList.forEach((item) {
                                                                print("ekle ikonu price: $item");
                                                              });
                                                              //***********************//
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
                                                        isTVContainerTouched = false;
                                                        isOyunContainerTouched = true;
                                                        isMuzikContainerTouched = false;
                                                        isAddButtonActiveND = true;
                                                        isTextFormFieldVisible = false;
                                                        isTextFormFieldVisibleND =true;
                                                        isTextFormFieldVisibleRD = false;
                                                        NDplatformPriceController.clear();
                                                        formDataProvider.gamingTitleList.forEach((element) {
                                                          print('itemList: $element');
                                                        });
                                                        formDataProvider.gamingPriceList.forEach((element) {
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
                                                  if (convertSum2 != "0,00")
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 43),
                                                      child: Text("Toplam: ${convertSum2}", style: GoogleFonts.montserrat(fontSize: 20),),
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
                                        color: isMuzikContainerTouched ? Colors.black : Colors.black.withOpacity(0.5),
                                        width: isMuzikContainerTouched ? 4 : 2,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if(isAddButtonActiveRD==false){
                                          print("if 3");
                                          handleMuzikContainerTouch();
                                          isAddButtonActive = false;
                                          isAddButtonActiveND = false;
                                        } else {
                                          print("else 3");
                                          isAddButtonActive = false;
                                          isAddButtonActiveND = false;
                                        }
                                      },
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text("Müzik",style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold),)
                                          ),
                                          if (formDataProvider.musicTitleList.isNotEmpty && formDataProvider.musicPriceList.isNotEmpty)
                                            Container(
                                              child:
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: formDataProvider.musicTitleList.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  double sum2 = double.parse(formDataProvider.musicPriceList[i]);
                                                  String convertSumo = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum2);
                                                  return Container(
                                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            formDataProvider.musicTitleList[i],
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
                                                            _showEditDialog(context, i, 3); // Show the edit dialog
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          if (isTextFormFieldVisibleRD && isMuzikContainerTouched)
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
                                                              formDataProvider.updateTextValue(text, 2, 3);
                                                              formDataProvider.updateNumberValue(price, 2, 3);
                                                              isEditingListRD = false; // Add a corresponding entry for the new item
                                                              RDtextController.clear();
                                                              formDataProvider.notifyListeners();
                                                              RDplatformPriceController.clear();
                                                              formDataProvider.notifyListeners();
                                                              isTextFormFieldVisibleRD = false;
                                                              isAddButtonActiveRD = false;
                                                              //***********************//
                                                              formDataProvider.tvTitleList.forEach((item) {
                                                                print("ekle ikonu item: $item");
                                                              });
                                                              //***********************//
                                                              //***********************//
                                                              formDataProvider.tvPriceList.forEach((item) {
                                                                print("ekle ikonu price: $item");
                                                              });
                                                              //***********************//
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
                                                        isTVContainerTouched = false;
                                                        isOyunContainerTouched = false;
                                                        isMuzikContainerTouched = true;
                                                        isAddButtonActiveRD = true;
                                                        isTextFormFieldVisible = false;
                                                        isTextFormFieldVisibleND =false;
                                                        isTextFormFieldVisibleRD = true;
                                                        RDplatformPriceController.clear();
                                                        formDataProvider.musicTitleList.forEach((element) {
                                                          print('itemList: $element');
                                                        });
                                                        formDataProvider.musicPriceList.forEach((element) {
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
                                                      child: Text("Toplam: ${convertSum3}", style: GoogleFonts.montserrat(fontSize: 20),),
                                                    ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
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

