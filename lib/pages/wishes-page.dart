import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

class BankData {
  int id;
  String bankName;
  String selectedTab;
  String selectedSymbol;
  double percent;
  double sum;
  bool isEditing;
  bool isAddButtonActive = false;

  BankData({
    required this.id,
    required this.bankName,
    required this.selectedTab,
    required this.selectedSymbol,
    required this.percent,
    required this.sum,
    this.isEditing = false,
    this.isAddButtonActive = false,
  });
}

class BankTypeProvider extends ChangeNotifier {
  List<BankData> bankDataList = [];
  List<TextEditingController> assetControllers = [];
  Map<int, Map<String, List<double>>> sumMap = {};
  int _nextId = 1;


  void addBankData(String bankName, double percent, double sum, String currency, String selectedSymbol) {
    BankData bankData = BankData(id: _nextId++, bankName: bankName, percent: percent, sum: sum, selectedTab: currency, selectedSymbol: selectedSymbol);
    bankDataList.add(bankData);
    final sumMap = <int, Map<String, List<double>>>{
      bankData.id: {
        currency: [],
      },
    };
    final sumValues = sumMap[bankData.id]?[currency];
    if (sumValues != null) {
      print("KOD 1");
      sumValues.add(sum);
    } else {
      print("KOD 2");
      sumMap[bankData.id]?[currency] = [sum];
    }

    notifyListeners();
    print("SUMMAP add: ${sumMap}");
    print("addBankData : ${bankData.id} ${bankData.bankName} ${bankData.sum}");
  }


  void updateBankData(int id, String bankName, double percent, double sum, String currency, String selectedSymbol) {
    final index = bankDataList.indexWhere((bank) => bank.id == id);
    if (!sumMap.containsKey(id)) {
      sumMap[id] = {currency: []};
    }
    final sumValues = sumMap[id]?[currency] ?? [];
    if (index != -1) {
      if (bankDataList[index].bankName != bankName){
        double totalSum = sum;
        BankData bankData = BankData(id: id, bankName: bankName, percent: percent, sum: totalSum, selectedTab: currency, selectedSymbol: selectedSymbol);
        bankDataList[index] = bankData;
        notifyListeners();
      } else {
        sumValues.add(sum);
        print("KOD 4 SUMVALUES $sumValues");
        sumMap[id]?[currency] = sumValues;
        double totalSum = calculateSum(id);
        print("KOD 4 totalSum $totalSum");
        BankData bankData = BankData(id: id, bankName: bankName, percent: percent, sum: totalSum, selectedTab: currency, selectedSymbol: selectedSymbol);
        bankDataList[index] = bankData;
        notifyListeners();
      }
      print("SUMMAP: ${sumMap}");
      print("bankDataList[index] sum: ${bankDataList[index].id} ${bankDataList[index].bankName} ${bankDataList[index].sum}");
    }
  }

  double calculateSum(int id) {
    if (sumMap.containsKey(id)) {
      double totalSum = 0.0;

      sumMap[id]?.forEach((currency, values) {
        for (var value in values) {
          totalSum += value;
        }
      });

      return totalSum;
    } else {
      return 0.0; // Handle the case when the sumMap entry does not exist
    }
  }

  double calculateSumForCurrency(int id, String currency) {
    if (sumMap.containsKey(id)) {
      double totalSum = 0.0;

      sumMap[id]?.forEach((key, values) {
        if (key == currency) {
          for (var value in values) {
            totalSum += value;
          }
        }
      });

      return totalSum;
    } else {
      return 0.0; // Handle the case when the sumMap entry does not exist
    }
  }

  double calculateTotalSumForCurrency(String currency) {
    double totalSum = 0.0;

    sumMap.forEach((id, currencyMap) {
      if (currencyMap.containsKey(currency)) {
        final values = currencyMap[currency]!;
        for (var value in values) {
          totalSum += value;
        }
      }
    });

    return totalSum;
  }

  void deleteBankData(Map<int, Map<String, List<double>>> sumMap, int id) {
    final values = sumMap[id];
    if (values != null) {
      values.clear();
    }
    bankDataList.removeWhere((bank) => bank.id == id);
    _nextId = bankDataList.isNotEmpty ? bankDataList.map((bank) => bank.id).reduce(max) + 1 : 1;
    notifyListeners();
    print("deleteBankData : ${bankDataList}");
  }

  List<double> getSumList(int id, String currency) {
    // Get the list of doubles for the bank with the given ID.
    final sumValues = sumMap[id]?[currency] ?? [];

    return sumValues;
  }

  // This new method returns a copy of the sumMap variable.
  Map<int, Map<String, List<double>>> getSumMap() {
    return Map<int, Map<String, List<double>>>.from(sumMap);
  }

  void deleteValueById(Map<int, Map<String, List<double>>> sumMap, int id, int index, String bankName, double percent, String currency, String selectedSymbol) {
    final idPosition = bankDataList.indexWhere((bank) => bank.id == id);
    final values = sumMap[id]?[currency] ?? [];
    if (values != null && index < values.length) {
      values.removeAt(index);
      if (values.isEmpty){
        sumMap[id]?.remove(currency);
      } else {
        double totalSum = 0.0;
        for (double value in values) {
          totalSum += value;
        }
        sumMap[id]?[currency] = values;
        BankData bankData = BankData(id: id, bankName: bankName, percent: percent, sum: totalSum, selectedTab: currency, selectedSymbol: selectedSymbol);
        bankDataList[idPosition] = bankData;
      }
      notifyListeners();
    }
    Iterable<MapEntry<int, Map<String, List<double>>>> entries = sumMap.entries;
    for (final entry in entries) {
      print('(${entry.key}, ${entry.value[currency]})');
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
  FocusNode focusNode = FocusNode();

  String dropDownValue = "Türk Lirası";
  var currencyList = [
    'Türk Lirası',
    'Dolar',
    'Euro',
    'Altın',
    'Hisse',
    'Diğer'
  ];
  String selectedTab = "Türk Lirası";
  String selectedSymbol = "";


  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  Widget buildBankCategories(BuildContext context, BankData bankData) {
    final bankDataProvider = Provider.of<BankTypeProvider>(context, listen: false);
    final TextEditingController nameController = TextEditingController();
    final sumForCurrency = bankDataProvider.calculateSumForCurrency(bankData.id, selectedTab) ;
    double totalCurrencySum = bankDataProvider.calculateTotalSumForCurrency(selectedTab);
    final division = (totalCurrencySum != 0.0 && !totalCurrencySum.isNaN) ? (sumForCurrency / totalCurrencySum) : 0.0;
    TextEditingController? assetController;
    if (bankData.id < bankDataProvider.assetControllers.length) {
      assetController = bankDataProvider.assetControllers[bankData.id];
    } else {
      assetController = TextEditingController();
      bankDataProvider.assetControllers.add(assetController);
    }
    if(bankData.selectedTab == currencyList[0]){
      selectedSymbol = "₺";
    } else if (bankData.selectedTab == currencyList[1]){
      selectedSymbol = '\$';
    } else if (bankData.selectedTab == currencyList[2]){
      selectedSymbol = "€";
    } else if (bankData.selectedTab == currencyList[3]){
      selectedSymbol = "g";
    } else if (bankData.selectedTab == currencyList[4]){
      selectedSymbol = "₺";
    } else if (bankData.selectedTab == currencyList[5]){
      selectedSymbol = "?";
    }
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
                    setState(() {
                      bankData.isEditing = !bankData.isEditing;
                    });
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
                  child: bankData.isEditing
                      ? EditableText(
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
                      if(bankData.bankName != newName){
                        bankDataProvider.updateBankData(bankData.id, newName, bankData.percent, bankData.sum, dropDownValue, bankData.selectedSymbol);
                      }
                      setState(() {
                        bankData.isEditing = false; // Exit editing mode
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
                "${sumForCurrency.toString()}$selectedSymbol",
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
                  percent: division,
                  trailing: Text(
                    "%${((division)*100).toStringAsFixed(0)}",
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
              DefaultTabController(
                length: currencyList.length,
                initialIndex: currencyList.indexOf(bankData.selectedTab),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: TabBar(
                        isScrollable: true, // Set this to true if you have many currencies
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xffc6c6c7),
                        ),
                        labelColor: Colors.blue, // Color for the selected tab text
                        unselectedLabelColor: Colors.grey, // Color for unselected tab text
                        tabs: currencyList.map((currency) {
                          return Tab(
                            child: Container(
                              padding: EdgeInsets.all(8.0), // Adjust padding as needed
                              decoration: BoxDecoration(
                                shape: BoxShape.circle, // Circular background for each tab
                              ),
                              child: Text(
                                currency,
                                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        }).toList(),
                        onTap: (value) {
                          setState(() {
                            bankData.selectedTab = currencyList[value]; // Set dropDownValue to the selected currency
                            bankData.selectedSymbol = getSelectedSymbol(bankData.selectedTab);
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        if(bankDataProvider.sumMap[bankData.id]?[bankData.selectedTab] != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bankData.selectedTab, style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                              Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: bankDataProvider.sumMap[bankData.id]?[bankData.selectedTab]?.length ?? 0 + 1,
                                itemBuilder: (context, index) {
                                  if (index < bankDataProvider.sumMap[bankData.id]![bankData.selectedTab]!.length && bankDataProvider.sumMap[bankData.id]![bankData.selectedTab]![index] != 0.0) {
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
                                                bankDataProvider.sumMap[bankData.id]![bankData.selectedTab]![index].toString(),
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
                                                  bankDataProvider.deleteValueById(bankDataProvider.sumMap, bankData.id, index, bankData.bankName, bankData.percent, dropDownValue, bankData.selectedSymbol);
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
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if(!bankData.isAddButtonActive)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        bankData.isAddButtonActive = true;
                      });
                    },
                    child: Text(
                      "Varlık Ekle",
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Text("Are you sure?"),
                            content: Text("Do you want to delete this item?"),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () {
                                  // Close the dialog
                                  Navigator.of(context).pop();
                                },
                                child: Text("Cancel"),
                              ),
                              CupertinoDialogAction(
                                onPressed: () {
                                  // Delete the item and close the dialog
                                  Provider.of<BankTypeProvider>(context, listen: false)
                                      .deleteBankData(bankDataProvider.sumMap, bankData.id);
                                  Navigator.of(context).pop();
                                },
                                child: Text("Delete"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Icon(CupertinoIcons.delete),
                  ),
                ],
              ),
              if(bankData.isAddButtonActive)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        child:DropdownButton(
                          value: dropDownValue,
                          icon:Icon(Icons.keyboard_arrow_down),
                          items: currencyList.map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(items),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropDownValue = newValue!;
                            });
                          },
                        )
                    ),
                  ],
                ),
              if(bankData.isAddButtonActive && assetController != null)
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
                                double price = double.tryParse(assetController?.text.trim() ?? '0.3') ?? 0.3;
                                String newName = nameController.text;
                                setState(() {
                                  final text = assetController?.text.trim() ?? '';
                                  if (text.isNotEmpty && text != "0") {
                                    BankData updatedBankData = bankDataProvider.bankDataList.firstWhere((bank) => bank.id == bankData.id);
                                    bankDataProvider.notifyListeners();
                                    bankDataProvider.updateBankData(bankData.id, newName, bankData.percent, price, dropDownValue , bankData.selectedSymbol);
                                    bankDataProvider.notifyListeners();
                                    assetController?.clear();
                                    bankData.isAddButtonActive = false;
                                    print("updatedBankData.sum:${updatedBankData.sum}");
                                  } else {
                                    assetController?.clear();
                                    bankData.isAddButtonActive = false;
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
        final bankDataProvider = Provider.of<BankTypeProvider>(context, listen: false);
        double totalCurrencySum = bankDataProvider.calculateTotalSumForCurrency(selectedTab);
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
                        Text("${totalCurrencySum.toString()}$selectedSymbol",
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
                                  provider.addBankData(bankName, initialPercent, 0.0, dropDownValue, "");
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

  String getSelectedSymbol(String currency) {
    switch (currency) {
      case 'Türk Lirası':
        return '₺';
      case 'Dolar':
        return '\$';
      case 'Euro':
        return '€';
      case 'Altın':
        return 'g';
      case 'Hisse':
        return '₺'; // Change this to the desired symbol for Hisse
      case 'Diğer':
        return '?';
      default:
        return ''; // Handle other cases as needed
    }
  }

}