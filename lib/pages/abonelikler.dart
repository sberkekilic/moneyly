import 'package:flutter/material.dart';
import 'package:moneyly/pages/gelir-ekle.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({Key? key}) : super(key: key);
  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}
class _SubscriptionsState extends State<Subscriptions> {
  List<String> itemList = [];
  List<String> pricesList = [];
  List<String> NDitemList = [];
  List<String> NDpricesList = [];
  List<String> RDitemList = [];
  List<String> RDpricesList = [];

  List<TextEditingController> editTextControllers = [];
  List<TextEditingController> NDeditTextControllers = [];
  List<TextEditingController> RDeditTextControllers = [];

  TextEditingController textController = TextEditingController();
  TextEditingController NDtextController = TextEditingController();
  TextEditingController RDtextController = TextEditingController();

  TextEditingController platformPriceController = TextEditingController();
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
    });
  }
  void handleOyunContainerTouch() {
    setState(() {
      isTVContainerTouched = false;
      isOyunContainerTouched = true;
      isMuzikContainerTouched = false;
    });
  }
  void handleMuzikContainerTouch() {
    setState(() {
      isTVContainerTouched = false;
      isOyunContainerTouched = false;
      isMuzikContainerTouched = true;
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

  void goToPreviousPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddIncome()),
    );
  }
  void goToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddIncome()),
    );
  }

  @override
  void initState() {
    super.initState();
    pricesList = [];
    editTextControllers = itemList.map((item) => TextEditingController(text: item)).toList();
    NDeditTextControllers = NDitemList.map((item) => TextEditingController(text: item)).toList();
    RDeditTextControllers = RDitemList.map((item) => TextEditingController(text: item)).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gider Ekle",
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        leadingWidth: 30,
      ),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                icon: Icon(Icons.navigate_before),
                onPressed: goToPreviousPage,
              ),
            ),
            Text("Adım: 2"),
            Expanded(
              child: IconButton(
                icon: Icon(Icons.navigate_next),
                onPressed: goToNextPage,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left:20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Abonelikler", style: TextStyle(fontSize: 17),),
            Padding(
              padding: const EdgeInsets.only(top: 10),
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
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              itemList[i],
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            Text(
                                              pricesList[i].toString(),
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            if(!isAddButtonActive)
                                              IconButton(
                                                  splashRadius: 0.0001,
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(minWidth: 24, maxWidth: 24),
                                                  onPressed: () {
                                                    setState(() {
                                                      isEditingList = !isEditingList;
                                                      if (isEditingList) {
                                                        editController.text = itemList[i];
                                                        platformPriceController.text = pricesList[i].toString(); // Set the correct value
                                                      }
                                                    });
                                                  },
                                                  icon: Icon(Icons.edit))
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
                                                  mainAxisAlignment: MainAxisAlignment.end,
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
                            if (isTextFormFieldVisible)
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
                                      isAddButtonActive = true;
                                      isTextFormFieldVisible = true;
                                      platformPriceController.clear();
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
                            if (isTextFormFieldVisibleND)
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
                                      isAddButtonActiveND = true;
                                      isTextFormFieldVisibleND = true;
                                      NDplatformPriceController.clear();
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
                            if (isTextFormFieldVisibleRD)
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
                                      isAddButtonActiveRD = true;
                                      isTextFormFieldVisibleRD = true;
                                      RDplatformPriceController.clear();
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
    );
  }
}

