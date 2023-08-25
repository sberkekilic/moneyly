import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'abonelikler.dart';
import 'faturalar.dart';
import 'gelir-ekle.dart';

class OtherExpenses extends StatefulWidget {
  const OtherExpenses({Key? key}) : super(key: key);

  @override
  State<OtherExpenses> createState() => _OtherExpensesState();
}

class _OtherExpensesState extends State<OtherExpenses> {
  List<String> itemList = [];
  List<String> pricesList = [];
  List<String> NDitemList = [];
  List<String> NDpricesList = [];
  List<String> RDitemList = [];
  List<String> RDpricesList = [];
  List<String> THitemList = [];
  List<String> THpricesList = [];
  List<String> otherItemList = [];
  List<String> otherPricesList = [];

  List<TextEditingController> editTextControllers = [];
  List<TextEditingController> NDeditTextControllers = [];
  List<TextEditingController> RDeditTextControllers = [];
  List<TextEditingController> THeditTextControllers = [];
  List<TextEditingController> otherEditTextControllers = [];

  TextEditingController textController = TextEditingController();
  TextEditingController NDtextController = TextEditingController();
  TextEditingController RDtextController = TextEditingController();
  TextEditingController THtextController = TextEditingController();
  TextEditingController otherTextController = TextEditingController();

  TextEditingController platformPriceController = TextEditingController();
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

  bool isTVContainerTouched = false;
  bool isOyunContainerTouched = false;
  bool isMuzikContainerTouched = false;
  bool isEntContainerTouched = false;
  bool isOtherContainerTouched = false;

  void handleTVContainerTouch() {
    setState(() {
      isTVContainerTouched = true;
      isOyunContainerTouched = false;
      isMuzikContainerTouched = false;
      isEntContainerTouched = false;
      isOtherContainerTouched = false;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isTextFormFieldVisibleTH = false;
      isTextFormFieldVisibleOther = false;
      isEditingList = false;
      print("isEditingList: $isEditingList");
      print("isEditingListND: $isEditingList");
      print("isEditingListRD: $isEditingList");
      print("isTextFormFieldVisible: $isTextFormFieldVisible");
      print("isTextFormFieldVisibleND: $isTextFormFieldVisibleND");
      print("isTextFormFieldVisibleRD: $isTextFormFieldVisibleRD");
    });
  }
  void handleOyunContainerTouch() {
    setState(() {
      isTVContainerTouched = false;
      isOyunContainerTouched = true;
      isMuzikContainerTouched = false;
      isEntContainerTouched = false;
      isOtherContainerTouched = false;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isTextFormFieldVisibleTH = false;
      isTextFormFieldVisibleOther = false;
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
      isEntContainerTouched = false;
      isOtherContainerTouched = false;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isTextFormFieldVisibleTH = false;
      isTextFormFieldVisibleOther = false;
      isEditingListRD = false;
      print("isEditingList: $isEditingList");
      print("isEditingListND: $isEditingList");
      print("isEditingListRD: $isEditingList");
      print("isTextFormFieldVisible: $isTextFormFieldVisible");
      print("isTextFormFieldVisibleND: $isTextFormFieldVisibleND");
      print("isTextFormFieldVisibleRD: $isTextFormFieldVisibleRD");
    });
  }
  void handleEntContainerTouch() {
    setState(() {
      isTVContainerTouched = false;
      isOyunContainerTouched = false;
      isMuzikContainerTouched = false;
      isEntContainerTouched = true;
      isOtherContainerTouched = false;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isTextFormFieldVisibleTH = true;
      isTextFormFieldVisibleOther = false;
      isEditingListTH = false;
      print("isEditingList: $isEditingList");
      print("isEditingListND: $isEditingList");
      print("isEditingListRD: $isEditingList");
      print("isTextFormFieldVisible: $isTextFormFieldVisible");
      print("isTextFormFieldVisibleND: $isTextFormFieldVisibleND");
      print("isTextFormFieldVisibleRD: $isTextFormFieldVisibleRD");
    });
  }
  void handleOtherContainerTouch() {
    setState(() {
      isTVContainerTouched = false;
      isOyunContainerTouched = false;
      isMuzikContainerTouched = false;
      isEntContainerTouched = false;
      isOtherContainerTouched = true;
      isTextFormFieldVisible = false;
      isTextFormFieldVisibleND =false;
      isTextFormFieldVisibleRD = false;
      isTextFormFieldVisibleTH = false;
      isTextFormFieldVisibleOther = true;
      isEditingListOther = false;
      print("isEditingList: $isEditingList");
      print("isEditingListND: $isEditingList");
      print("isEditingListRD: $isEditingList");
      print("isTextFormFieldVisible: $isTextFormFieldVisible");
      print("isTextFormFieldVisibleND: $isTextFormFieldVisibleND");
      print("isTextFormFieldVisibleRD: $isTextFormFieldVisibleRD");
    });
  }

  void addItem() {
    String text = textController.text.trim();
    String priceText = platformPriceController.text.trim();
    if (text.isNotEmpty && priceText.isNotEmpty) {
      double dprice = double.tryParse(priceText) ?? 0.0;
      String price = dprice.toStringAsFixed(2);
      setState(() {
        pricesList.add(price);
        itemList.add(text);
        isEditingList = false; // Add a corresponding entry for the new item
        textController.clear();
        platformPriceController.clear();
        isTextFormFieldVisible = false;
        isAddButtonActive = false;
        //***********************//
        itemList.forEach((item) {
          print("add item: $item");
        });
        //***********************//
      });
    }
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
  void addItemTH() {
    String text = THtextController.text.trim();
    String priceText = THplatformPriceController.text.trim();
    if (text.isNotEmpty && priceText.isNotEmpty) {
      double dprice = double.tryParse(priceText) ?? 0.0;
      String price = dprice.toStringAsFixed(2);
      setState(() {
        THpricesList.add(price);
        THitemList.add(text);
        isEditingListTH = false; // Add a corresponding entry for the new item
        THtextController.clear();
        THplatformPriceController.clear();
        isTextFormFieldVisibleTH = false;
        isAddButtonActiveTH = false;
        //***********************//
        THitemList.forEach((item) {
          print("add item: $item");
        });
        //***********************//
      });
    }
  }
  void addItemOther() {
    String text = otherTextController.text.trim();
    String priceText = otherPlatformPriceController.text.trim();
    if (text.isNotEmpty && priceText.isNotEmpty) {
      double dprice = double.tryParse(priceText) ?? 0.0;
      String price = dprice.toStringAsFixed(2);
      setState(() {
        otherPricesList.add(price);
        otherItemList.add(text);
        isEditingListOther = false; // Add a corresponding entry for the new item
        otherTextController.clear();
        otherPlatformPriceController.clear();
        isTextFormFieldVisibleOther = false;
        isAddButtonActiveOther = false;
        //***********************//
        otherItemList.forEach((item) {
          print("add item: $item");
        });
        //***********************//
      });
    }
  }

  void goToPreviousPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Bills()),
    );
  }
  void goToNextPage() {

  }

  @override
  void initState() {
    super.initState();
    pricesList = [];
    editTextControllers = itemList.map((item) => TextEditingController(text: item)).toList();
    NDeditTextControllers = NDitemList.map((item) => TextEditingController(text: item)).toList();
    RDeditTextControllers = RDitemList.map((item) => TextEditingController(text: item)).toList();
    THeditTextControllers = THitemList.map((item) => TextEditingController(text: item)).toList();
    otherEditTextControllers = otherItemList.map((item) => TextEditingController(text: item)).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                      GoRouter.of(context).replace("/faturalar");
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.black), // Replace with the desired left icon
                  ),
                  IconButton(
                    onPressed: () {
                      GoRouter.of(context).replace("/");
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
                      onPressed: () async {
                        GoRouter.of(context).replace("/diger-giderler");
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
                          onTap: () {
                            Navigator.of(context).pop();
                            try {
                              Navigator.of(context).pushReplacementNamed("/gelir-ekle");
                            } catch (error) {
                              // Handle the error or leave this block empty to suppress the error
                            }
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
                            GoRouter.of(context).replace("/abonelikler");
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
                            GoRouter.of(context).replace("/faturalar");
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
                            GoRouter.of(context).replace("/diger-giderler");
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
                                              child: Text("Kira",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                                          ),
                                          for (int i = 0; i < itemList.length; i++)
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10, right: 10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: isEditingList
                                                        ? Column(
                                                      children: [
                                                        TextFormField(
                                                          controller: editController,
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
                                                        children: [
                                                          Flexible(
                                                            fit: FlexFit.tight,
                                                            child: Text(
                                                                itemList[i],
                                                                style: TextStyle(fontSize: 18),
                                                                overflow: TextOverflow.ellipsis
                                                            ),
                                                          ),
                                                          SizedBox(width: 25),
                                                          Flexible(
                                                            fit: FlexFit.tight,
                                                            child: Text(
                                                                pricesList[i].toString(),
                                                                style: TextStyle(fontSize: 18),
                                                                overflow: TextOverflow.ellipsis
                                                            ),
                                                          ),
                                                          if (!isAddButtonActive)
                                                            Container(
                                                              width: 21,
                                                              height: 21,
                                                              child: IconButton(
                                                                padding: EdgeInsets.zero,
                                                                onPressed: () {
                                                                  setState(() {
                                                                    isEditingList = !isEditingList;
                                                                    if (isEditingList) {
                                                                      editController.text = itemList[i];
                                                                      platformPriceController.text = pricesList[i].toString();
                                                                      // Set the correct value
                                                                    }
                                                                  });
                                                                },
                                                                icon: Icon(Icons.edit, size: 21),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (isEditingList)
                                                    Expanded(
                                                      child: Column(
                                                        children: [
                                                          TextFormField(
                                                            controller: platformPriceController,
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
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  IconButton(
                                                                    splashRadius: 0.0001,
                                                                    padding: EdgeInsets.zero,
                                                                    constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                    onPressed: () {
                                                                      setState(() {
                                                                        isEditingList = false;
                                                                        itemList[i] = editController.text.trim();
                                                                        double dPrice = double.tryParse(platformPriceController.text) ?? 0.0;
                                                                        String editedPrice = dPrice.toStringAsFixed(2);
                                                                        pricesList[i] = editedPrice;
                                                                        platformPriceController.text = editedPrice.toString(); // Update the controller value
                                                                        platformPriceController.clear();
                                                                      });
                                                                    },
                                                                    icon: Icon(
                                                                        Icons.save
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 10,),
                                                                  if (isEditingList)
                                                                    IconButton(
                                                                      splashRadius: 0.0001,
                                                                      padding: EdgeInsets.zero,
                                                                      constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                      onPressed: () {
                                                                        setState(() {
                                                                          isEditingList = false;
                                                                          isAddButtonActive = false;
                                                                          // Reset the text to the original item text when cancel is clicked
                                                                          editController.text = itemList[i];
                                                                          platformPriceController.text = pricesList[i].toString();
                                                                          platformPriceController.clear();
                                                                        });
                                                                      },
                                                                      icon: Icon(Icons.cancel),
                                                                    ),
                                                                  SizedBox(width: 10,),
                                                                  if (isEditingList)
                                                                    IconButton(
                                                                      splashRadius: 0.0001,
                                                                      padding: EdgeInsets.zero,
                                                                      constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                      onPressed: () {
                                                                        setState(() {
                                                                          // Remove the item from the list
                                                                          isEditingList = false;
                                                                          isAddButtonActive = false;
                                                                          itemList.removeAt(i);
                                                                          pricesList.removeAt(i);
                                                                          platformPriceController.clear();
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
                                                        onPressed: addItem,
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
                                              child: Text("Mutfak",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
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
                                              child: Text("Yeme-İçme",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
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
                                  SizedBox(height: 20),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isEntContainerTouched ? Colors.black : Colors.black.withOpacity(0.5),
                                        width: isEntContainerTouched ? 4 : 2,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: handleEntContainerTouch,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text("Eğlence",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                                          ),
                                          for (int i = 0; i < THitemList.length; i++)
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10, right: 10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: isEditingListTH
                                                        ? Column(
                                                      children: [
                                                        TextFormField(
                                                          controller: THeditController,
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
                                                            THitemList[i],
                                                            style: TextStyle(fontSize: 18),
                                                          ),
                                                          Text(
                                                            THpricesList[i].toString(),
                                                            style: TextStyle(fontSize: 18),
                                                          ),
                                                          if(!isAddButtonActiveTH)
                                                            IconButton(
                                                                splashRadius: 0.0001,
                                                                padding: EdgeInsets.zero,
                                                                constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    isEditingListTH = !isEditingListTH;
                                                                    if (isEditingListTH) {
                                                                      THeditController.text = THitemList[i];
                                                                      THplatformPriceController.text = THpricesList[i].toString(); // Set the correct value
                                                                    }
                                                                  });
                                                                },
                                                                icon: Icon(Icons.edit))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (isEditingListTH)
                                                    Expanded(
                                                      child: Column(
                                                        children: [
                                                          TextFormField(
                                                            controller: THplatformPriceController,
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
                                                                        isEditingListTH = false;
                                                                        THitemList[i] = THeditController.text.trim();
                                                                        double dPrice = double.tryParse(THplatformPriceController.text) ?? 0.0;
                                                                        String editedPrice = dPrice.toStringAsFixed(2);
                                                                        THpricesList[i] = editedPrice;
                                                                        THplatformPriceController.text = editedPrice.toString(); // Update the controller value
                                                                        THplatformPriceController.clear();
                                                                      });
                                                                    },
                                                                    icon: Icon(
                                                                        Icons.save
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 10,),
                                                                  if (isEditingListTH)
                                                                    IconButton(
                                                                      splashRadius: 0.0001,
                                                                      padding: EdgeInsets.zero,
                                                                      constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                      onPressed: () {
                                                                        setState(() {
                                                                          isEditingListTH = false;
                                                                          isAddButtonActiveTH = false;
                                                                          // Reset the text to the original item text when cancel is clicked
                                                                          THeditController.text = THitemList[i];
                                                                          THplatformPriceController.text = THpricesList[i].toString();
                                                                          THplatformPriceController.clear();
                                                                        });
                                                                      },
                                                                      icon: Icon(Icons.cancel),
                                                                    ),
                                                                  SizedBox(width: 10,),
                                                                  if (isEditingListTH)
                                                                    IconButton(
                                                                      splashRadius: 0.0001,
                                                                      padding: EdgeInsets.zero,
                                                                      constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                      onPressed: () {
                                                                        setState(() {
                                                                          // Remove the item from the list
                                                                          isEditingListTH = false;
                                                                          isAddButtonActiveTH = false;
                                                                          THitemList.removeAt(i);
                                                                          THpricesList.removeAt(i);
                                                                          THplatformPriceController.clear();
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
                                          if (isTextFormFieldVisibleTH && isEntContainerTouched)
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
                                                        onPressed: addItemND,
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
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    isTVContainerTouched = false;
                                                    isOyunContainerTouched = false;
                                                    isMuzikContainerTouched = false;
                                                    isEntContainerTouched = true;
                                                    isOtherContainerTouched = false;
                                                    isAddButtonActiveTH = true;
                                                    isTextFormFieldVisible = false;
                                                    isTextFormFieldVisibleND =false;
                                                    isTextFormFieldVisibleRD = false;
                                                    isTextFormFieldVisibleTH = true;
                                                    isTextFormFieldVisibleOther = false;
                                                    THplatformPriceController.clear();
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
                                  DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: Radius.circular(10),
                                    color: isOtherContainerTouched ? Colors.black : Colors.black.withOpacity(0.5),
                                    strokeWidth: isOtherContainerTouched ? 4 : 2,
                                    dashPattern: [6,3],
                                    child: Container(
                                      width: double.infinity,
                                      child: InkWell(
                                        onTap: handleOtherContainerTouch,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Text("Diğer",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                                            ),
                                            for (int i = 0; i < otherItemList.length; i++)
                                              Padding(
                                                padding: const EdgeInsets.only(left: 10, right: 10),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: isEditingListOther
                                                          ? Column(
                                                        children: [
                                                          TextFormField(
                                                            controller: otherEditController,
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
                                                              otherItemList[i],
                                                              style: TextStyle(fontSize: 18),
                                                            ),
                                                            Text(
                                                              otherPricesList[i].toString(),
                                                              style: TextStyle(fontSize: 18),
                                                            ),
                                                            if(!isAddButtonActiveOther)
                                                              IconButton(
                                                                  splashRadius: 0.0001,
                                                                  padding: EdgeInsets.zero,
                                                                  constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                  onPressed: () {
                                                                    setState(() {
                                                                      isEditingListOther = !isEditingListOther;
                                                                      if (isEditingListOther) {
                                                                        otherEditController.text = otherItemList[i];
                                                                        otherPlatformPriceController.text = otherPricesList[i].toString(); // Set the correct value
                                                                      }
                                                                    });
                                                                  },
                                                                  icon: Icon(Icons.edit))
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    if (isEditingListOther)
                                                      Expanded(
                                                        child: Column(
                                                          children: [
                                                            TextFormField(
                                                              controller: otherPlatformPriceController,
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
                                                                          isEditingListOther = false;
                                                                          otherItemList[i] = otherEditController.text.trim();
                                                                          double dPrice = double.tryParse(otherPlatformPriceController.text) ?? 0.0;
                                                                          String editedPrice = dPrice.toStringAsFixed(2);
                                                                          otherPricesList[i] = editedPrice;
                                                                          otherPlatformPriceController.text = editedPrice.toString(); // Update the controller value
                                                                          otherPlatformPriceController.clear();
                                                                        });
                                                                      },
                                                                      icon: Icon(
                                                                          Icons.save
                                                                      ),
                                                                    ),
                                                                    SizedBox(width: 10,),
                                                                    if (isEditingListOther)
                                                                      IconButton(
                                                                        splashRadius: 0.0001,
                                                                        padding: EdgeInsets.zero,
                                                                        constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                        onPressed: () {
                                                                          setState(() {
                                                                            isEditingListOther = false;
                                                                            isAddButtonActiveOther = false;
                                                                            // Reset the text to the original item text when cancel is clicked
                                                                            otherEditController.text = otherItemList[i];
                                                                            otherPlatformPriceController.text = otherPricesList[i].toString();
                                                                            otherPlatformPriceController.clear();
                                                                          });
                                                                        },
                                                                        icon: Icon(Icons.cancel),
                                                                      ),
                                                                    SizedBox(width: 10,),
                                                                    if (isEditingListOther)
                                                                      IconButton(
                                                                        splashRadius: 0.0001,
                                                                        padding: EdgeInsets.zero,
                                                                        constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                                        onPressed: () {
                                                                          setState(() {
                                                                            // Remove the item from the list
                                                                            isEditingListOther = false;
                                                                            isAddButtonActiveOther = false;
                                                                            otherItemList.removeAt(i);
                                                                            otherPricesList.removeAt(i);
                                                                            otherPlatformPriceController.clear();
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
                                            if (isTextFormFieldVisibleOther && isOtherContainerTouched)
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
                                                          onPressed: addItemRD,
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
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isTVContainerTouched = false;
                                                      isOyunContainerTouched = false;
                                                      isMuzikContainerTouched = false;
                                                      isEntContainerTouched = false;
                                                      isOtherContainerTouched = true;
                                                      isAddButtonActiveOther = true;
                                                      isTextFormFieldVisible = false;
                                                      isTextFormFieldVisibleND =false;
                                                      isTextFormFieldVisibleRD = false;
                                                      isTextFormFieldVisibleTH = false;
                                                      isTextFormFieldVisibleOther = true;
                                                      otherPlatformPriceController.clear();
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
