import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/form-data-provider.dart';
import 'package:provider/provider.dart';
import 'faturalar.dart';

class OtherExpenses extends StatefulWidget {
  const OtherExpenses({Key? key}) : super(key: key);

  @override
  State<OtherExpenses> createState() => _OtherExpensesState();
}

class _OtherExpensesState extends State<OtherExpenses> {

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

  bool isRentContainerTouched = false;
  bool isKitchenContainerTouched = false;
  bool isCateringContainerTouched = false;
  bool isEntContainerTouched = false;
  bool isOtherContainerTouched = false;

  void handleRentContainerTouch() {
    setState(() {
      isRentContainerTouched = true;
      isKitchenContainerTouched = false;
      isCateringContainerTouched = false;
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
  void handleKitchenContainerTouch() {
    setState(() {
      isRentContainerTouched = false;
      isKitchenContainerTouched = true;
      isCateringContainerTouched = false;
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
  void handleCateringContainerTouch() {
    setState(() {
      isRentContainerTouched = false;
      isKitchenContainerTouched = false;
      isCateringContainerTouched = true;
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
      isRentContainerTouched = false;
      isKitchenContainerTouched = false;
      isCateringContainerTouched = false;
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
      isRentContainerTouched = false;
      isKitchenContainerTouched = false;
      isCateringContainerTouched = false;
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

  void goToPreviousPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Bills()),
    );
  }
  void goToNextPage() {
  }

  void _showEditDialog(BuildContext context, int index, int orderIndex) {
    final formDataProvider = Provider.of<FormDataProvider>(context, listen: false);

    TextEditingController selectedEditController = TextEditingController();
    TextEditingController selectedPriceController = TextEditingController();

    switch (orderIndex) {
      case 1:
        TextEditingController editController =
        TextEditingController(text: formDataProvider.rentTitleList[index]);
        TextEditingController priceController =
        TextEditingController(text: formDataProvider.rentPriceList[index]);
        selectedEditController = editController;
        selectedPriceController = priceController;
        break;
      case 2:
        TextEditingController NDeditController =
        TextEditingController(text: formDataProvider.kitchenTitleList[index]);
        TextEditingController NDpriceController =
        TextEditingController(text: formDataProvider.kitchenPriceList[index]);
        selectedEditController = NDeditController;
        selectedPriceController = NDpriceController;
        break;
      case 3:
        TextEditingController RDeditController =
        TextEditingController(text: formDataProvider.cateringTitleList[index]);
        TextEditingController RDpriceController =
        TextEditingController(text: formDataProvider.cateringPriceList[index]);
        selectedEditController = RDeditController;
        selectedPriceController = RDpriceController;
        break;
      case 4:
        TextEditingController THeditController =
        TextEditingController(text: formDataProvider.entertainmentTitleList[index]);
        TextEditingController THpriceController =
        TextEditingController(text: formDataProvider.entertainmentPriceList[index]);
        selectedEditController = THeditController;
        selectedPriceController = THpriceController;
        break;
      case 5:
        TextEditingController otherEditController =
        TextEditingController(text: formDataProvider.otherTitleList[index]);
        TextEditingController otherPriceController =
        TextEditingController(text: formDataProvider.otherPriceList[index]);
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
          title: Text('Edit Item',style: TextStyle(fontSize: 20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(child: Text("Item", style: TextStyle(fontSize: 18),), alignment: Alignment.centerLeft,),
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
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Align(child: Text("Price",style: TextStyle(fontSize: 18)), alignment: Alignment.centerLeft),
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
                style: TextStyle(fontSize: 20),
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
                      formDataProvider.rentTitleList[index] = selectedEditController.text;
                      formDataProvider.rentPriceList[index] = selectedPriceController.text;
                      break;
                    case 2:
                      formDataProvider.kitchenTitleList[index] = selectedEditController.text;
                      formDataProvider.kitchenPriceList[index] = selectedPriceController.text;
                      break;
                    case 3:
                      formDataProvider.cateringTitleList[index] = selectedEditController.text;
                      formDataProvider.cateringPriceList[index] = selectedPriceController.text;
                      break;
                    case 4:
                      formDataProvider.entertainmentTitleList[index] = selectedEditController.text;
                      formDataProvider.entertainmentPriceList[index] = selectedPriceController.text;
                      break;
                    case 5:
                      formDataProvider.otherTitleList[index] = selectedEditController.text;
                      formDataProvider.otherPriceList[index] = selectedPriceController.text;
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
                        TextEditingController(text: formDataProvider.rentPriceList[index]);
                        formDataProvider.rentTitleList.removeAt(index);
                        formDataProvider.rentPriceList.removeAt(index);
                        priceController.clear();
                        isEditingList = false;
                        isAddButtonActive = false;
                        break;
                      case 2:
                        TextEditingController NDpriceController =
                        TextEditingController(text: formDataProvider.kitchenPriceList[index]);
                        formDataProvider.kitchenTitleList.removeAt(index);
                        formDataProvider.kitchenPriceList.removeAt(index);
                        NDpriceController.clear();
                        isEditingListND = false;
                        isAddButtonActiveND = false;
                        break;
                      case 3:
                        TextEditingController RDpriceController =
                        TextEditingController(text: formDataProvider.cateringPriceList[index]);
                        formDataProvider.cateringTitleList.removeAt(index);
                        formDataProvider.cateringPriceList.removeAt(index);
                        RDpriceController.clear();
                        isEditingListRD = false;
                        isAddButtonActiveRD = false;
                        break;
                      case 4:
                        TextEditingController THpriceController =
                        TextEditingController(text: formDataProvider.entertainmentPriceList[index]);
                        formDataProvider.entertainmentTitleList.removeAt(index);
                        formDataProvider.entertainmentPriceList.removeAt(index);
                        THpriceController.clear();
                        isEditingListTH = false;
                        isAddButtonActiveTH = false;
                        break;
                      case 5:
                        TextEditingController otherPriceController =
                        TextEditingController(text: formDataProvider.otherPriceList[index]);
                        formDataProvider.otherTitleList.removeAt(index);
                        formDataProvider.otherPriceList.removeAt(index);
                        otherPriceController.clear();
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
    if(Provider.of<FormDataProvider>(context, listen: false).rentTitleList.isNotEmpty){
       isRentContainerTouched = true;
    }
    if(Provider.of<FormDataProvider>(context, listen: false).kitchenTitleList.isNotEmpty){
    isKitchenContainerTouched = true;
    }
    if(Provider.of<FormDataProvider>(context, listen: false).cateringTitleList.isNotEmpty){
    isCateringContainerTouched = true;
    }
    if(Provider.of<FormDataProvider>(context, listen: false).entertainmentTitleList.isNotEmpty){
    isEntContainerTouched = true;
    }
    if(Provider.of<FormDataProvider>(context, listen: false).otherTitleList.isNotEmpty){
    isOtherContainerTouched = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formDataProvider = Provider.of<FormDataProvider>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
    double sum = 0.0;
    for(String price in formDataProvider.rentPriceList){
      sum += double.parse(price);
    }
    double sumkitchen = 0.0;
    for(String price in formDataProvider.kitchenPriceList){
      sumkitchen += double.parse(price);
    }
    double sumcatering = 0.0;
    for(String price in formDataProvider.cateringPriceList){
      sumcatering += double.parse(price);
    }
    double sument = 0.0;
    for(String price in formDataProvider.entertainmentPriceList){
      sument += double.parse(price);
    }
    double sumother = 0.0;
    for(String price in formDataProvider.otherPriceList){
      sumother += double.parse(price);
    }
    String convertSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum);
    formDataProvider.sumOfRent = convertSum;
    String convertSum2 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumkitchen);
    formDataProvider.sumOfKitchen = convertSum2;
    String convertSum3 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumcatering);
    formDataProvider.sumOfCatering = convertSum3;
    String convertSum4 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sument);
    formDataProvider.sumOfEntertainment = convertSum4;
    String convertSum5 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumother);
    formDataProvider.sumOfOther = convertSum5;
    double sumAll = 0.0;
    sumAll += sum;
    sumAll += sumkitchen;
    sumAll += sumcatering;
    sumAll += sument;
    sumAll += sumother;
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
                        backgroundColor: sumAll!=0.0 ? Colors.black : Colors.grey,
                      ),
                      clipBehavior: Clip.hardEdge,
                      onPressed: () async {
                        Navigator.pushNamed(context, 'ana-sayfa');
                      },
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
                                        color: isRentContainerTouched ? Colors.black : Colors.black.withOpacity(0.5),
                                        width: isRentContainerTouched ? 4 : 2,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: isAddButtonActive ? null : handleRentContainerTouch,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text("Kira",style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),)
                                          ),
                                          if (formDataProvider.rentTitleList.isNotEmpty && formDataProvider.rentPriceList.isNotEmpty)
                                            Container(
                                              child:
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: formDataProvider.rentTitleList.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  double sum2 = double.parse(formDataProvider.rentPriceList[i]);
                                                  String convertSumo = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum2);
                                                  return Container(
                                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            formDataProvider.rentTitleList[i],
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
                                                            _showEditDialog(context, i, 1); // Show the edit dialog
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          if (isTextFormFieldVisible && isRentContainerTouched)
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
                                                              formDataProvider.updateTextValue(text, 4, 1);
                                                              formDataProvider.updateNumberValue(price, 4, 1);
                                                              isEditingList = false; // Add a corresponding entry for the new item
                                                              textController.clear();
                                                              formDataProvider.notifyListeners();
                                                              platformPriceController.clear();
                                                              formDataProvider.notifyListeners();
                                                              isTextFormFieldVisible = false;
                                                              isAddButtonActive = false;
                                                              //***********************//
                                                              formDataProvider.rentTitleList.forEach((item) {
                                                                print("ekle ikonu item: $item");
                                                              });
                                                              //***********************//
                                                              //***********************//
                                                              formDataProvider.rentPriceList.forEach((item) {
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
                                                        isRentContainerTouched = true;
                                                        isKitchenContainerTouched = false;
                                                        isCateringContainerTouched = false;
                                                        isEntContainerTouched = false;
                                                        isOtherContainerTouched = false;
                                                        isAddButtonActive = true;
                                                        isTextFormFieldVisible = true;
                                                        isTextFormFieldVisibleND =false;
                                                        isTextFormFieldVisibleRD = false;
                                                        isTextFormFieldVisibleTH = false;
                                                        isTextFormFieldVisibleOther = false;
                                                        platformPriceController.clear();
                                                        formDataProvider.rentTitleList.forEach((element) {
                                                          print('itemList: $element');
                                                        });
                                                        formDataProvider.rentPriceList.forEach((element) {
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
                                                      child: Text("Toplam: ${convertSum}", style: TextStyle(fontSize: 20),),
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
                                        color: isKitchenContainerTouched ? Colors.black : Colors.black.withOpacity(0.5),
                                        width: isKitchenContainerTouched ? 4 : 2,
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
                                          if (formDataProvider.kitchenTitleList.isNotEmpty && formDataProvider.kitchenPriceList.isNotEmpty)
                                            Container(
                                              child:
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: formDataProvider.kitchenTitleList.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  double sum2 = double.parse(formDataProvider.kitchenPriceList[i]);
                                                  String convertSumo = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum2);
                                                  return Container(
                                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            formDataProvider.kitchenTitleList[i],
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
                                                            _showEditDialog(context, i, 2); // Show the edit dialog
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          if (isTextFormFieldVisibleND && isKitchenContainerTouched)
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
                                                              formDataProvider.updateTextValue(text, 4, 2);
                                                              formDataProvider.updateNumberValue(price, 4, 2);
                                                              isEditingListND = false; // Add a corresponding entry for the new item
                                                              NDtextController.clear();
                                                              formDataProvider.notifyListeners();
                                                              NDplatformPriceController.clear();
                                                              formDataProvider.notifyListeners();
                                                              isTextFormFieldVisibleND = false;
                                                              isAddButtonActiveND = false;
                                                              //***********************//
                                                              formDataProvider.kitchenTitleList.forEach((item) {
                                                                print("ekle ikonu item: $item");
                                                              });
                                                              //***********************//
                                                              //***********************//
                                                              formDataProvider.kitchenPriceList.forEach((item) {
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
                                                        isRentContainerTouched = false;
                                                        isKitchenContainerTouched = true;
                                                        isCateringContainerTouched = false;
                                                        isEntContainerTouched = false;
                                                        isOtherContainerTouched = false;
                                                        isAddButtonActiveND = true;
                                                        isTextFormFieldVisible = false;
                                                        isTextFormFieldVisibleND =true;
                                                        isTextFormFieldVisibleRD = false;
                                                        isTextFormFieldVisibleTH = false;
                                                        isTextFormFieldVisibleOther = false;
                                                        NDplatformPriceController.clear();
                                                        formDataProvider.kitchenTitleList.forEach((element) {
                                                          print('itemList: $element');
                                                        });
                                                        formDataProvider.kitchenPriceList.forEach((element) {
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
                                        color: isCateringContainerTouched ? Colors.black : Colors.black.withOpacity(0.5),
                                        width: isCateringContainerTouched ? 4 : 2,
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
                                          if (formDataProvider.cateringTitleList.isNotEmpty && formDataProvider.cateringPriceList.isNotEmpty)
                                            Container(
                                              child:
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: formDataProvider.cateringTitleList.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  double sum2 = double.parse(formDataProvider.cateringPriceList[i]);
                                                  String convertSumo = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum2);
                                                  return Container(
                                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            formDataProvider.cateringTitleList[i],
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
                                                            _showEditDialog(context, i, 3); // Show the edit dialog
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          if (isTextFormFieldVisibleRD && isCateringContainerTouched)
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
                                                              formDataProvider.updateTextValue(text, 4, 3);
                                                              formDataProvider.updateNumberValue(price, 4, 3);
                                                              isEditingListRD = false; // Add a corresponding entry for the new item
                                                              RDtextController.clear();
                                                              formDataProvider.notifyListeners();
                                                              RDplatformPriceController.clear();
                                                              formDataProvider.notifyListeners();
                                                              isTextFormFieldVisibleRD = false;
                                                              isAddButtonActiveRD = false;
                                                              //***********************//
                                                              formDataProvider.cateringTitleList.forEach((item) {
                                                                print("ekle ikonu item: $item");
                                                              });
                                                              //***********************//
                                                              //***********************//
                                                              formDataProvider.cateringPriceList.forEach((item) {
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
                                                        isRentContainerTouched = false;
                                                        isKitchenContainerTouched = false;
                                                        isCateringContainerTouched = true;
                                                        isEntContainerTouched = false;
                                                        isOtherContainerTouched = false;
                                                        isAddButtonActiveRD = true;
                                                        isTextFormFieldVisible = false;
                                                        isTextFormFieldVisibleND =false;
                                                        isTextFormFieldVisibleRD = true;
                                                        isTextFormFieldVisibleTH = false;
                                                        isTextFormFieldVisibleOther = false;
                                                        RDplatformPriceController.clear();
                                                        formDataProvider.cateringTitleList.forEach((element) {
                                                          print('itemList: $element');
                                                        });
                                                        formDataProvider.cateringPriceList.forEach((element) {
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
                                        color: isEntContainerTouched ? Colors.black : Colors.black.withOpacity(0.5),
                                        width: isEntContainerTouched ? 4 : 2,
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
                                          if (formDataProvider.entertainmentTitleList.isNotEmpty && formDataProvider.entertainmentPriceList.isNotEmpty)
                                            Container(
                                              child:
                                              ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: formDataProvider.entertainmentTitleList.length,
                                                itemBuilder: (BuildContext context, int i) {
                                                  double sum2 = double.parse(formDataProvider.entertainmentPriceList[i]);
                                                  String convertSumo = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum2);
                                                  return Container(
                                                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 2,
                                                          fit: FlexFit.tight,
                                                          child: Text(
                                                            formDataProvider.entertainmentTitleList[i],
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
                                                            _showEditDialog(context, i, 4); // Show the edit dialog
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
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
                                                        onPressed: () {
                                                          final text = THtextController.text.trim();
                                                          final priceText = THplatformPriceController.text.trim();
                                                          if (text.isNotEmpty && priceText.isNotEmpty) {
                                                            double dprice = double.tryParse(priceText) ?? 0.0;
                                                            String price = dprice.toStringAsFixed(2);
                                                            setState(() {
                                                              formDataProvider.updateTextValue(text, 4, 4);
                                                              formDataProvider.updateNumberValue(price, 4, 4);
                                                              isEditingListTH = false; // Add a corresponding entry for the new item
                                                              THtextController.clear();
                                                              formDataProvider.notifyListeners();
                                                              THplatformPriceController.clear();
                                                              formDataProvider.notifyListeners();
                                                              isTextFormFieldVisibleTH = false;
                                                              isAddButtonActiveTH = false;
                                                              //***********************//
                                                              formDataProvider.entertainmentTitleList.forEach((item) {
                                                                print("ekle ikonu item: $item");
                                                              });
                                                              //***********************//
                                                              //***********************//
                                                              formDataProvider.entertainmentPriceList.forEach((item) {
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
                                                        isRentContainerTouched = false;
                                                        isKitchenContainerTouched = false;
                                                        isCateringContainerTouched = false;
                                                        isEntContainerTouched = true;
                                                        isOtherContainerTouched = false;
                                                        isAddButtonActiveTH = true;
                                                        isTextFormFieldVisible = false;
                                                        isTextFormFieldVisibleND =false;
                                                        isTextFormFieldVisibleRD = false;
                                                        isTextFormFieldVisibleTH = true;
                                                        isTextFormFieldVisibleOther = false;
                                                        THplatformPriceController.clear();
                                                        formDataProvider.entertainmentTitleList.forEach((element) {
                                                          print('itemList: $element');
                                                        });
                                                        formDataProvider.entertainmentPriceList.forEach((element) {
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
                                    color: isOtherContainerTouched ? Colors.black : Colors.black.withOpacity(0.5),
                                    strokeWidth: isOtherContainerTouched ? 4 : 2,
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
                                            if (formDataProvider.otherTitleList.isNotEmpty && formDataProvider.otherPriceList.isNotEmpty)
                                              Container(
                                                child:
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: formDataProvider.otherTitleList.length,
                                                  itemBuilder: (BuildContext context, int i) {
                                                    double sum2 = double.parse(formDataProvider.otherPriceList[i]);
                                                    String convertSumo = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sum2);
                                                    return Container(
                                                      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                      child: Row(
                                                        children: [
                                                          Flexible(
                                                            flex: 2,
                                                            fit: FlexFit.tight,
                                                            child: Text(
                                                              formDataProvider.otherTitleList[i],
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
                                                              _showEditDialog(context, i, 5); // Show the edit dialog
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
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
                                                          onPressed: () {
                                                            final text = otherTextController.text.trim();
                                                            final priceText = otherPlatformPriceController.text.trim();
                                                            if (text.isNotEmpty && priceText.isNotEmpty) {
                                                              double dprice = double.tryParse(priceText) ?? 0.0;
                                                              String price = dprice.toStringAsFixed(2);
                                                              setState(() {
                                                                formDataProvider.updateTextValue(text, 4, 5);
                                                                formDataProvider.updateNumberValue(price, 4, 5);
                                                                isEditingListOther = false; // Add a corresponding entry for the new item
                                                                otherTextController.clear();
                                                                formDataProvider.notifyListeners();
                                                                otherPlatformPriceController.clear();
                                                                formDataProvider.notifyListeners();
                                                                isTextFormFieldVisibleOther = false;
                                                                isAddButtonActiveOther = false;
                                                                //***********************//
                                                                formDataProvider.otherTitleList.forEach((item) {
                                                                  print("ekle ikonu item: $item");
                                                                });
                                                                //***********************//
                                                                //***********************//
                                                                formDataProvider.otherPriceList.forEach((item) {
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
                                                          isRentContainerTouched = false;
                                                          isKitchenContainerTouched = false;
                                                          isCateringContainerTouched = false;
                                                          isEntContainerTouched = false;
                                                          isOtherContainerTouched = true;
                                                          isAddButtonActiveOther = true;
                                                          isTextFormFieldVisible = false;
                                                          isTextFormFieldVisibleND =false;
                                                          isTextFormFieldVisibleRD = false;
                                                          isTextFormFieldVisibleTH = false;
                                                          isTextFormFieldVisibleOther = true;
                                                          otherPlatformPriceController.clear();
                                                          formDataProvider.otherTitleList.forEach((element) {
                                                            print('itemList: $element');
                                                          });
                                                          formDataProvider.otherPriceList.forEach((element) {
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
