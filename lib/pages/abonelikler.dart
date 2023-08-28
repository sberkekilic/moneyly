import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import '../form-data-provider.dart';
import 'faturalar.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({Key? key}) : super(key: key);
  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}
class _SubscriptionsState extends State<Subscriptions> {
  int editableIndex = -1;

  List<String> NDitemList = [];
  List<String> NDpricesList = [];
  List<String> RDitemList = [];
  List<String> RDpricesList = [];

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
      //print("isEditingList: $isEditingList");
      //print("isEditingListND: $isEditingList");
      //print("isEditingListRD: $isEditingList");
      //print("isTextFormFieldVisible: $isTextFormFieldVisible");
      //print("isTextFormFieldVisibleND: $isTextFormFieldVisibleND");
      //print("isTextFormFieldVisibleRD: $isTextFormFieldVisibleRD");
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
      print("isEditingList: $isEditingList");
      print("isEditingListND: $isEditingList");
      print("isEditingListRD: $isEditingList");
      print("isTextFormFieldVisible: $isTextFormFieldVisible");
      print("isTextFormFieldVisibleND: $isTextFormFieldVisibleND");
      print("isTextFormFieldVisibleRD: $isTextFormFieldVisibleRD");
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
      print("isEditingList: $isEditingList");
      print("isEditingListND: $isEditingList");
      print("isEditingListRD: $isEditingList");
      print("isTextFormFieldVisible: $isTextFormFieldVisible");
      print("isTextFormFieldVisibleND: $isTextFormFieldVisibleND");
      print("isTextFormFieldVisibleRD: $isTextFormFieldVisibleRD");
    });
  }

  void addItem() {

  }
  void addItemND() {
    String text = NDtextController.text.trim();
    String priceText = NDplatformPriceController.text.trim();
    if (text.isNotEmpty && priceText.isNotEmpty) {
      double dprice = double.tryParse(priceText) ?? 0.0;
      String price = dprice.toStringAsFixed(2);
      setState(() {
        NDpricesList.add(price);
        NDitemList.add(text);
        isEditingListND = false; // Add a corresponding entry for the new item
        NDtextController.clear();
        NDplatformPriceController.clear();
        isTextFormFieldVisibleND = false;
        isAddButtonActiveND = false;
        //***********************//
        NDitemList.forEach((item) {
          print("add item: $item");
        });
        //***********************//
      });
    }
  }
  void addItemRD() {
    String text = RDtextController.text.trim();
    String priceText = RDplatformPriceController.text.trim();
    if (text.isNotEmpty && priceText.isNotEmpty) {
      double dprice = double.tryParse(priceText) ?? 0.0;
      String price = dprice.toStringAsFixed(2);
      setState(() {
        RDpricesList.add(price);
        RDitemList.add(text);
        isEditingListRD = false; // Add a corresponding entry for the new item
        RDtextController.clear();
        RDplatformPriceController.clear();
        isTextFormFieldVisibleRD = false;
        isAddButtonActiveRD = false;
        //***********************//
        RDitemList.forEach((item) {
          print("add item: $item");
        });
        //***********************//
      });
    }
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

  @override
  void initState() {
    super.initState();
    print("SAYFA YÜKLENDİ");
    if(Provider.of<FormDataProvider>(context, listen: false).itemList.isNotEmpty){
      isTVContainerTouched = true;
    }
  }



  @override
  Widget build(BuildContext context) {
    final formDataProvider = Provider.of<FormDataProvider>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
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
                        backgroundColor: Colors.black,
                      ),
                      clipBehavior: Clip.hardEdge,
                      onPressed: () {
                        Navigator.pushNamed(context, 'faturalar');
                      },
                      child: const Text('Next', style: TextStyle(fontSize: 18),),
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
                            Navigator.of(context).pop();
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
                                Align(child: Text("Abonelikler", style: TextStyle(color: Color(
                                    0xff1ab738), fontWeight: FontWeight.bold, fontSize: 15)), alignment: Alignment.center),
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
                                Align(child: Text("Faturalar", style: TextStyle(color: Color(
                                    0xffc6c6c7), fontSize: 15)), alignment: Alignment.center),
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
                            width: (screenWidth-60) / 3,
                            child: Column(
                              children: [
                                Align(child: Text("Diğer Giderler", style: TextStyle(color: Color(
                                    0xffc6c6c7), fontSize: 15)), alignment: Alignment.center),
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
                                      onTap: handleTVContainerTouch,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text("Film, Dizi ve TV",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                                          ),
                                          if (formDataProvider.itemList.isNotEmpty && formDataProvider.pricesList.isNotEmpty)
                                            Container(
                                              child:
                                              ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: formDataProvider.itemList.length,
                                                  itemBuilder: (BuildContext context, int i){

                                                    TextEditingController editController = TextEditingController(text: formDataProvider.itemList[i]);
                                                    TextEditingController platformPriceController = TextEditingController(text: formDataProvider.pricesList[i].toString());

                                                    TextFormField nan1Field = TextFormField(
                                                      controller: editController,
                                                      style: TextStyle(fontSize: 20),
                                                      decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        hintText: 'NAN1',
                                                      ),
                                                    );

                                                    TextFormField dob1Field = TextFormField(
                                                      controller: platformPriceController,
                                                      keyboardType: TextInputType.number,
                                                      style: TextStyle(fontSize: 20),
                                                      decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        hintText: 'DOB1',
                                                      ),
                                                    );
                                                    return Padding(
                                                      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                      child: Row(
                                                        children: [
                                                          Flexible(
                                                            fit: FlexFit.tight,
                                                            child: GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  editableIndex = (editableIndex == i) ? -1 : i;
                                                                });
                                                              },
                                                              child: (editableIndex != i)
                                                                  ? Text(
                                                                  formDataProvider.itemList[i],
                                                                  style: TextStyle(fontSize: 20),
                                                                  overflow: TextOverflow.ellipsis
                                                              )
                                                                  : nan1Field,
                                                            )
                                                          ),
                                                          SizedBox(width: 25),
                                                          Flexible(
                                                            fit: FlexFit.tight,
                                                              child: (editableIndex != i)
                                                                  ? Text(
                                                                  textAlign: TextAlign.right,
                                                                  formDataProvider.pricesList[i].toString(),
                                                                  style: TextStyle(fontSize: 20),
                                                                  overflow: TextOverflow.ellipsis
                                                              )
                                                                  : dob1Field,
                                                          ),
                                                          SizedBox(width: 25),
                                                          if (editableIndex == -1 || editableIndex == i)
                                                            Container(
                                                              width: 21,
                                                              height: 21,
                                                              child: IconButton(
                                                                padding: EdgeInsets.zero,
                                                                onPressed: () {
                                                                  setState(() {
                                                                    if (editableIndex == -1) {
                                                                      editableIndex = i;
                                                                    } else {
                                                                      editableIndex = -1;
                                                                    }
                                                                    isEditingList = !isEditingList;
                                                                    if (isEditingList) {
                                                                      editController.text = formDataProvider.itemList[i];
                                                                      platformPriceController.text = formDataProvider.pricesList[i].toString();
                                                                    }
                                                                  });
                                                                },
                                                                icon: Icon((editableIndex == i) ? null : Icons.edit, size: 21),
                                                              ),
                                                            ),
                                                          if (editableIndex == i)
                                                          Container(
                                                            height:23,
                                                            width: 23,
                                                            child: IconButton(
                                                              iconSize: 23,
                                                              splashRadius: 0.0001,
                                                              padding: EdgeInsets.zero,
                                                              constraints: BoxConstraints(minWidth: 21, maxWidth: 21),
                                                              onPressed: () {
                                                                setState(() {
                                                                  editableIndex = -1;
                                                                  isEditingList = false;
                                                                  isAddButtonActive = false;
                                                                  // Reset the text to the original item text when cancel is clicked
                                                                  editController.text = formDataProvider.itemList[i];
                                                                  platformPriceController.text = formDataProvider.pricesList[i].toString();
                                                                  platformPriceController.clear();
                                                                });
                                                              },
                                                              icon: Icon(Icons.cancel),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          if (editableIndex == i)
                                                          Container(
                                                            height:23,
                                                            width: 23,
                                                            child: IconButton(
                                                              iconSize: 23,
                                                              splashRadius: 0.0001,
                                                              padding: EdgeInsets.zero,
                                                              constraints: BoxConstraints(minWidth: 21, maxWidth: 21),
                                                              onPressed: () {
                                                                setState(() {
                                                                  editableIndex = -1;
                                                                  isEditingList = false;
                                                                  formDataProvider.itemList[i] = editController.text.trim();
                                                                  double dPrice = double.tryParse(platformPriceController.text) ?? 0.0;
                                                                  String editedPrice = dPrice.toStringAsFixed(2);
                                                                  formDataProvider.pricesList[i] = editedPrice;
                                                                  platformPriceController.text = editedPrice.toString(); // Update the controller value
                                                                  platformPriceController.clear();
                                                                });
                                                              },
                                                              icon: Icon(Icons.save),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          if (editableIndex == i)
                                                          Container(
                                                            height:23,
                                                            width: 23,
                                                            child: IconButton(
                                                              iconSize: 23,
                                                              splashRadius: 0.0001,
                                                              padding: EdgeInsets.zero,
                                                              constraints: BoxConstraints(minWidth: 21, maxWidth: 21),
                                                              onPressed: () {
                                                                setState(() {
                                                                  // Remove the item from the list
                                                                  isEditingList = false;
                                                                  isAddButtonActive = false;
                                                                  formDataProvider.itemList.removeAt(i);
                                                                  formDataProvider.pricesList.removeAt(i);
                                                                  platformPriceController.clear();
                                                                  editableIndex = -1;
                                                                });
                                                              },
                                                              icon: Icon(Icons.delete),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    );
                                                  }
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
                                                              formDataProvider.updateTextValue(text, 2);
                                                              formDataProvider.updateNumberValue(price, 2);
                                                              isEditingList = false; // Add a corresponding entry for the new item
                                                              textController.clear();
                                                              formDataProvider.notifyListeners();
                                                              platformPriceController.clear();
                                                              formDataProvider.notifyListeners();
                                                              isTextFormFieldVisible = false;
                                                              isAddButtonActive = false;
                                                              //***********************//
                                                              formDataProvider.itemList.forEach((item) {
                                                                print("ekle ikonu item: $item");
                                                              });
                                                              //***********************//
                                                              //***********************//
                                                              formDataProvider.pricesList.forEach((item) {
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
                                              child: InkWell(
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
                                                    formDataProvider.itemList.forEach((element) {
                                                      print('itemList: $element');
                                                    });
                                                    formDataProvider.pricesList.forEach((element) {
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
                                      onTap: handleOyunContainerTouch,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text("Oyun",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                                          ),
                                          for (int i = 0; i < NDitemList.length; i++)
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10, right: 10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: isEditingListND
                                                        ? Column(
                                                      children: [
                                                        TextFormField(
                                                          controller: NDeditController,
                                                          style: TextStyle(fontSize: 18),
                                                          decoration: InputDecoration(
                                                            border: InputBorder.none,
                                                            hintText: 'NAN',
                                                          ),
                                                        ),
                                                        SizedBox(height:34)
                                                      ],
                                                    )
                                                        : Container(
                                                      padding: EdgeInsets.symmetric(vertical: 2),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            NDitemList[i],
                                                            style: TextStyle(fontSize: 18),
                                                          ),
                                                          Text(
                                                            NDpricesList[i].toString(),
                                                            style: TextStyle(fontSize: 18),
                                                          ),
                                                          if(!isAddButtonActiveND)
                                                            IconButton(
                                                                splashRadius: 0.0001,
                                                                padding: EdgeInsets.zero,
                                                                constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    isEditingListND = !isEditingListND;
                                                                    if (isEditingListND) {
                                                                      NDeditController.text = NDitemList[i];
                                                                      NDplatformPriceController.text = NDpricesList[i].toString(); // Set the correct value
                                                                    }
                                                                  });
                                                                },
                                                                icon: Icon(Icons.edit))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (isEditingListND)
                                                    Expanded(
                                                      child: Column(
                                                        children: [
                                                          TextFormField(
                                                            controller: NDplatformPriceController,
                                                            keyboardType: TextInputType.number, // Show numeric keyboard
                                                            style: TextStyle(fontSize: 18),
                                                            decoration: InputDecoration(
                                                              border: InputBorder.none,
                                                              hintText: 'DOB',
                                                            ),
                                                          ),
                                                          Column(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  IconButton(
                                                                    splashRadius: 0.0001,
                                                                    padding: EdgeInsets.zero,
                                                                    constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                    onPressed: () {
                                                                      setState(() {
                                                                        isEditingListND = false;
                                                                        NDitemList[i] = NDeditController.text.trim();
                                                                        double dPrice = double.tryParse(NDplatformPriceController.text) ?? 0.0;
                                                                        String editedPrice = dPrice.toStringAsFixed(2);
                                                                        NDpricesList[i] = editedPrice;
                                                                        NDplatformPriceController.text = editedPrice.toString(); // Update the controller value
                                                                        NDplatformPriceController.clear();
                                                                      });
                                                                    },
                                                                    icon: Icon(
                                                                        Icons.save
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 10,),
                                                                  if (isEditingListND)
                                                                    IconButton(
                                                                      splashRadius: 0.0001,
                                                                      padding: EdgeInsets.zero,
                                                                      constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                      onPressed: () {
                                                                        setState(() {
                                                                          isEditingListND = false;
                                                                          isAddButtonActiveND = false;
                                                                          // Reset the text to the original item text when cancel is clicked
                                                                          NDeditController.text = NDitemList[i];
                                                                          NDplatformPriceController.text = NDpricesList[i].toString();
                                                                          NDplatformPriceController.clear();
                                                                        });
                                                                      },
                                                                      icon: Icon(Icons.cancel),
                                                                    ),
                                                                  SizedBox(width: 10,),
                                                                  if (isEditingListND)
                                                                    IconButton(
                                                                      splashRadius: 0.0001,
                                                                      padding: EdgeInsets.zero,
                                                                      constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                      onPressed: () {
                                                                        setState(() {
                                                                          // Remove the item from the list
                                                                          isEditingListND = false;
                                                                          isAddButtonActiveND = false;
                                                                          NDitemList.removeAt(i);
                                                                          NDpricesList.removeAt(i);
                                                                          NDplatformPriceController.clear();
                                                                        });
                                                                      },
                                                                      icon: Icon(Icons.delete),
                                                                    ),
                                                                ],
                                                              ),
                                                              SizedBox(height: 10)
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
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
                                                        onPressed: addItemND,
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
                                              child: InkWell(
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
                                                    print("isEditingList: $isEditingList");
                                                    print("isEditingListND: $isEditingList");
                                                    print("isEditingListRD: $isEditingList");
                                                    print("isTextFormFieldVisible: $isTextFormFieldVisible");
                                                    print("isTextFormFieldVisibleND: $isTextFormFieldVisibleND");
                                                    print("isTextFormFieldVisibleRD: $isTextFormFieldVisibleRD");
                                                  });
                                                },
                                                child: Icon(Icons.add_circle, size: 26),
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
                                      onTap: handleMuzikContainerTouch,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text("Müzik",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                                          ),
                                          for (int i = 0; i < RDitemList.length; i++)
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10, right: 10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: isEditingListRD
                                                        ? Column(
                                                      children: [
                                                        TextFormField(
                                                          controller: RDeditController,
                                                          style: TextStyle(fontSize: 18),
                                                          decoration: InputDecoration(
                                                            border: InputBorder.none,
                                                            hintText: 'NAN',
                                                          ),
                                                        ),
                                                        SizedBox(height:34)
                                                      ],
                                                    )
                                                        : Container(
                                                      padding: EdgeInsets.symmetric(vertical: 2),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            RDitemList[i],
                                                            style: TextStyle(fontSize: 18),
                                                          ),
                                                          Text(
                                                            RDpricesList[i].toString(),
                                                            style: TextStyle(fontSize: 18),
                                                          ),
                                                          if(!isAddButtonActiveRD)
                                                            IconButton(
                                                                splashRadius: 0.0001,
                                                                padding: EdgeInsets.zero,
                                                                constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    isEditingListRD = !isEditingListRD;
                                                                    if (isEditingListRD) {
                                                                      RDeditController.text = RDitemList[i];
                                                                      RDplatformPriceController.text = RDpricesList[i].toString(); // Set the correct value
                                                                    }
                                                                  });
                                                                },
                                                                icon: Icon(Icons.edit))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (isEditingListRD)
                                                    Expanded(
                                                      child: Column(
                                                        children: [
                                                          TextFormField(
                                                            controller: RDplatformPriceController,
                                                            keyboardType: TextInputType.number, // Show numeric keyboard
                                                            style: TextStyle(fontSize: 18),
                                                            decoration: InputDecoration(
                                                              border: InputBorder.none,
                                                              hintText: 'DOB',
                                                            ),
                                                          ),
                                                          Column(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  IconButton(
                                                                    splashRadius: 0.0001,
                                                                    padding: EdgeInsets.zero,
                                                                    constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                    onPressed: () {
                                                                      setState(() {
                                                                        isEditingListRD = false;
                                                                        RDitemList[i] = RDeditController.text.trim();
                                                                        double dPrice = double.tryParse(RDplatformPriceController.text) ?? 0.0;
                                                                        String editedPrice = dPrice.toStringAsFixed(2);
                                                                        RDpricesList[i] = editedPrice;
                                                                        RDplatformPriceController.text = editedPrice.toString(); // Update the controller value
                                                                        RDplatformPriceController.clear();
                                                                      });
                                                                    },
                                                                    icon: Icon(
                                                                        Icons.save
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 10,),
                                                                  if (isEditingListRD)
                                                                    IconButton(
                                                                      splashRadius: 0.0001,
                                                                      padding: EdgeInsets.zero,
                                                                      constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                      onPressed: () {
                                                                        setState(() {
                                                                          isEditingListRD = false;
                                                                          isAddButtonActiveRD = false;
                                                                          // Reset the text to the original item text when cancel is clicked
                                                                          RDeditController.text = RDitemList[i];
                                                                          RDplatformPriceController.text = RDpricesList[i].toString();
                                                                          RDplatformPriceController.clear();
                                                                        });
                                                                      },
                                                                      icon: Icon(Icons.cancel),
                                                                    ),
                                                                  SizedBox(width: 10,),
                                                                  if (isEditingListRD)
                                                                    IconButton(
                                                                      splashRadius: 0.0001,
                                                                      padding: EdgeInsets.zero,
                                                                      constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                      onPressed: () {
                                                                        setState(() {
                                                                          // Remove the item from the list
                                                                          isEditingListRD = false;
                                                                          isAddButtonActiveRD = false;
                                                                          RDitemList.removeAt(i);
                                                                          RDpricesList.removeAt(i);
                                                                          RDplatformPriceController.clear();
                                                                        });
                                                                      },
                                                                      icon: Icon(Icons.delete),
                                                                    ),
                                                                ],
                                                              ),
                                                              SizedBox(height: 10)
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
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
                                                        onPressed: addItemRD,
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
                                              child: InkWell(
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
                                                    print("isEditingList: $isEditingList");
                                                    print("isEditingListND: $isEditingList");
                                                    print("isEditingListRD: $isEditingList");
                                                    print("isTextFormFieldVisible: $isTextFormFieldVisible");
                                                    print("isTextFormFieldVisibleND: $isTextFormFieldVisibleND");
                                                    print("isTextFormFieldVisibleRD: $isTextFormFieldVisibleRD");
                                                  });
                                                },
                                                child: Icon(Icons.add_circle, size: 26),
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

