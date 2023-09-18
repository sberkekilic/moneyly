import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class BankData {
  int id;
  String bankName;
  double percent;
  double sum;

  BankData({required this.id, required this.bankName, required this.percent, required this.sum});
}

class BankTypeProvider extends ChangeNotifier {
  List<BankData> bankDataList = [];
  Map<int, List<double>> sumMap = {};
  int _nextId = 1;

  void addBankData(String bankName, double percent, double sum) {
    BankData bankData = BankData(id: _nextId++, bankName: bankName, percent: percent, sum: sum);
    bankDataList.add(bankData);

    // Check if the bank ID already exists in the sumMap variable.
    final sumValues = sumMap[bankData.id];
    if (sumValues != null) {
      // Add the new sum to the existing list of doubles.
      sumValues.add(sum);
    } else {
      // Create a new list of doubles and add the new sum to it.
      sumMap[bankData.id] = [sum];
    }

    notifyListeners();
    print("addBankData : ${bankData.id} ${bankData.bankName} ${bankData.sum}");
  }


  void updateBankData(int id, String bankName, double percent, double sum) {
    final index = bankDataList.indexWhere((bank) => bank.id == id);
    final sumValues = sumMap[id] ?? [];
    if (index != -1) {
      if (bankDataList[index].bankName != bankName){

      } else {
        sumValues.add(sum);
        sumMap[id] = sumValues;
        Iterable<MapEntry<int, List<double>>> entries = sumMap.entries;
        for (final entry in entries) {
          print('(${entry.key}, ${entry.value})');
        }
      }

      if (bankDataList[index].bankName != bankName){
        double totalSum = sum;
        BankData bankData = BankData(id: id, bankName: bankName, percent: percent, sum: totalSum);
        bankDataList[index] = bankData;
        notifyListeners();
      } else {
        double totalSum = calculateSum(id);
        BankData bankData = BankData(id: id, bankName: bankName, percent: percent, sum: totalSum);
        bankDataList[index] = bankData;
        notifyListeners();
      }
      print("bankDataList[index] sum: ${bankDataList[index].id} ${bankDataList[index].bankName} ${bankDataList[index].sum}");
    }
  }

  void deleteBankData(Map<int, List<double>> sumMap, int id) {
    final values = sumMap[id];
    if (values != null) {
      values.clear();
    }
    bankDataList.removeWhere((bank) => bank.id == id);
    _nextId = bankDataList.isNotEmpty ? bankDataList.map((bank) => bank.id).reduce(max) + 1 : 1;
    notifyListeners();
    print("deleteBankData : ${bankDataList}");
  }

  double calculateSum(int id){
    double totalSum = 0.0;
    final sumValues = sumMap[id] ?? [];

    for (var value in sumValues) {
      totalSum += value;
    }

    return totalSum;
  }

  List<double> getSumList(int id) {
    // Get the list of doubles for the bank with the given ID.
    final sumValues = sumMap[id] ?? [];

    return sumValues;
  }

  // This new method returns a copy of the sumMap variable.
  Map<int, List<double>> getSumMap() {
    return Map<int, List<double>>.from(sumMap);
  }

  void deleteValueById(Map<int, List<double>> sumMap, int id, int index, String bankName, double percent) {
    final idPosition = bankDataList.indexWhere((bank) => bank.id == id);
    final values = sumMap[id] ?? [];
    if (values != null && index < values.length) {
      values.removeAt(index);
      double totalSum = 0.0;
      for (double value in values) {
        totalSum += value;
      }
      sumMap[id] = values;
      BankData bankData = BankData(id: id, bankName: bankName, percent: percent, sum: totalSum);
      bankDataList[idPosition] = bankData;
      notifyListeners();
    }
    Iterable<MapEntry<int, List<double>>> entries = sumMap.entries;
    for (final entry in entries) {
      print('(${entry.key}, ${entry.value})');
    }
  }

}


class WishesPage extends StatefulWidget {
  const WishesPage({Key? key}) : super(key: key);

  @override
  State<WishesPage> createState() => _WishesPageState();
}

class _WishesPageState extends State<WishesPage> {
  
  final TextEditingController assetController = TextEditingController();
  bool isAddButtonActive = false;

  TextEditingController nameController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool isEditing = false; // Track whether editing mode is active

  @override
  void dispose() {
    nameController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  BankData? selectedBankData;
  Widget buildBankCategories(BuildContext context, BankData bankData) {
    final bankDataProvider = Provider.of<BankTypeProvider>(context, listen: false);
    final TextEditingController nameController = TextEditingController();
    nameController.text = bankData.bankName;

    return Column(
      children: [
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    // Toggle editing mode
                    isEditing = !isEditing;
                    selectedBankData = bankData;
                  });
                  // Set the cursor position to the end of the text
                  nameController.selection = TextSelection.fromPosition(
                    TextPosition(offset: nameController.text.length),
                  );
                  focusNode.requestFocus();
                  SystemChannels.textInput.invokeMethod('TextInput.show');
                },
                child: Container(
                  width: double.maxFinite, // Set a fixed width to match the Text widget
                  child: isEditing
                      ? EditableText(
                    readOnly: selectedBankData != bankData,
                    controller: nameController,
                    focusNode: focusNode,
                    style: TextStyle(
                      // Maintain text style
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.normal,
                    ),
                    cursorColor: Colors.black,
                    backgroundCursorColor: Colors.black,
                    keyboardType: TextInputType.text,
                    onChanged: (newName) {
                      // You can update the name in real-time if needed
                    },
                    onEditingComplete: () {
                      // Save changes when editing is complete
                      String newName = nameController.text;
                      bankDataProvider.updateBankData(bankData.id, newName, bankData.percent, bankData.sum);
                      setState(() {
                        isEditing = false; // Exit editing mode
                        selectedBankData = null;
                      });
                    },
                  )
                      : Text(
                    bankData.bankName,
                    style: TextStyle(
                      // Maintain text style
                      color: Colors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                bankData.sum.toString(),
                style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(
                child: LinearPercentIndicator(
                  padding: EdgeInsets.only(right: 10),
                  backgroundColor: Color(0xffc6c6c7),
                  animation: true,
                  lineHeight: 10,
                  animationDuration: 1000,
                  percent: bankData.percent / 100, // Use the bank's percent value
                  trailing: Text(
                    "${bankData.percent}%", // Show the bank's percent value
                    style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.normal),
                  ),
                  barRadius: Radius.circular(10),
                  progressColor: Colors.lightBlue,
                ),
              ),
              SizedBox(height: 5),
              ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  if(bankDataProvider.sumMap[bankData.id] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: bankDataProvider.sumMap[bankData.id]?.length ?? 0 + 1,
                          itemBuilder: (context, index) {
                            if (index < bankDataProvider.sumMap[bankData.id]!.length && bankDataProvider.sumMap[bankData.id]![index] != 0.0) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        fit: FlexFit.tight,
                                        child: Text(
                                          bankDataProvider.sumMap[bankData.id]![index].toString(),
                                          style: GoogleFonts.montserrat(fontSize: 20),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      IconButton(
                                        splashRadius: 0.0001,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                        icon: Icon(Icons.delete, size: 21),
                                        onPressed: () {
                                          setState(() {
                                            bankDataProvider.notifyListeners();
                                            bankDataProvider.deleteValueById(bankDataProvider.sumMap, bankData.id, index, bankData.bankName, bankData.percent);
                                            bankDataProvider.notifyListeners();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                ],
                              );
                            }
                            return SizedBox.shrink();
                          },
                        )

                      ],
                    )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isAddButtonActive = true;
                      });
                    },
                    child: Text(
                      "Varlık Ekle",
                      style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // When delete button is clicked, delete the bank
                      Provider.of<BankTypeProvider>(context, listen: false)
                          .deleteBankData(bankDataProvider.sumMap,bankData.id);
                    },
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
              if(isAddButtonActive)
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: assetController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Asset',
                          ),
                        ),
                      ),
                      Wrap(
                        children: [
                          IconButton(
                              onPressed: () {
                                double price = double.tryParse(assetController.text.trim()) ?? 0.3;
                                String newName = nameController.text;
                                setState(() {
                                  final text = assetController.text.trim();
                                  if (text.isNotEmpty) {
                                    BankData updatedBankData = bankDataProvider.bankDataList.firstWhere((bank) => bank.id == bankData.id);
                                    bankDataProvider.notifyListeners();
                                    bankDataProvider.updateBankData(bankData.id, newName, bankData.percent, price);
                                    bankDataProvider.notifyListeners();
                                    assetController.clear();
                                    isAddButtonActive = false;
                                    print("updatedBankData.sum:${updatedBankData.sum}");
                                  }
                                });

                              },
                              icon: Icon(Icons.check_circle, size: 26),
                          )
                        ],
                      )
                    ],
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BankTypeProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xfff0f0f1),
            elevation: 0,
            toolbarHeight: 70,
            automaticallyImplyLeading: false,
            leadingWidth: 30,
            title: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {

                      },
                      icon: Icon(Icons.settings, color: Colors.black), // Replace with the desired left icon
                    ),
                    IconButton(
                      onPressed: () {

                      },
                      icon: Icon(Icons.person, color: Colors.black), // Replace with the desired right icon
                    ),
                  ],
                ),
                Text(
                  "Eylül 2023",
                  style: GoogleFonts.montserrat(color: Colors.black, fontSize: 28, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Bankalarım",
                      style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.normal)),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tüm Varlığım",
                            style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontSize: 19,
                                fontWeight: FontWeight.normal)),
                        SizedBox(height: 10),
                        Text("---",
                            style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontSize: 19,
                                fontWeight: FontWeight.normal)),
                        SizedBox(height: 5),
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Banka Ekle",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal)),
                              IconButton(
                                onPressed: () {
                                  // Add a new bank directly with default name and 0 percent
                                  final bankName = "Bank Name ${provider.bankDataList.length + 1}";
                                  const initialPercent = 0.0;
                                  print("TEK ADDBANKDATA ÇALIŞTI");
                                  provider.addBankData(bankName, initialPercent, 0.0);
                                },
                                icon: Icon(Icons.add_circle),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      for (var bankData
                      in Provider.of<BankTypeProvider>(context)
                          .bankDataList)
                        buildBankCategories(context, bankData),
                    ],
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), // Adjust as needed
                topRight: Radius.circular(10), // Adjust as needed
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), // Adjust as needed
                topRight: Radius.circular(10), // Adjust as needed
              ),
              child: BottomNavigationBar(
                currentIndex: 4,
                onTap: (int index) {
                  switch (index) {
                    case 0:
                      Navigator.pushNamed(context, 'ana-sayfa');
                      break;
                    case 1:
                      Navigator.pushNamed(context, 'income-page');
                      break;
                    case 2:
                      Navigator.pushNamed(context, 'outcome-page');
                      break;
                    case 3:
                      Navigator.pushNamed(context, 'investment-page');
                      break;
                    case 4:
                      Navigator.pushNamed(context, 'wishes-page');
                      break;
                  }
                },
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home, size: 30),
                    label: 'Ana Sayfa',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.attach_money, size: 30),
                    label: 'Gelir',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.money_off, size: 30),
                    label: 'Gider',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.trending_up, size: 30),
                    label: 'Yatırım',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(FontAwesome.bank, size: 30),
                    label: 'Bankalar',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}