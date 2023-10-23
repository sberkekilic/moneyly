// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int idForBuild = 0;
  List<Map<String, dynamic>> bankDataList = [];
  List<TextEditingController> assetControllers = [];
  List<String> selectedTabList = [];
  Map<int, Map<String, List<double>>> sumMap = {};
  int _nextId = 1;

  Future<void> addBankData(String bankName, double percent, double sum, String currency, String selectedSymbol) async {
    final prefs = await SharedPreferences.getInstance();
    print("AAAAAA 1 : $_nextId");
    final bankData = {
      'id': _nextId++,
      'bankName': bankName,
      'percent': percent,
      'sum': sum,
      'selectedTab': currency,
      'selectedSymbol': selectedSymbol,
      'isEditing': false,
      'isAddButtonActive': false,
    };
    print("AAAAAA 2 : $_nextId");
    bankDataList.add(bankData);
    selectedTabList.add(currency);
    final sumMap = <int, Map<String, List<double>>>{
      bankData['id'] as int: {
        currency: [],
      },
    };
    final sumValues = sumMap[(bankData['id'] as int)]?[currency];
    if (sumValues != null) {
      print("KOD 1");
      sumValues.add(sum);
    } else {
      print("KOD 2");
      sumMap[(bankData['id'] as int)]?[currency] = [sum];
    }
    setState(() {
      prefs.setInt('nextId', _nextId);
      String bankDataListJson = jsonEncode(bankDataList);
      prefs.setString('bankDataList', bankDataListJson);
      prefs.setStringList('selectedTabList', selectedTabList);
    });
  }
  Future<void> deleteBankData(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> serializableSumMap = {};
    final values = sumMap[id];
    if (values != null) {
      values.clear();
    }
    bankDataList.removeWhere((bank) => bank['id'] == id);
    reorganizeKeys(sumMap, id);
    updateBankDataList(bankDataList, id);
    selectedTabList.removeAt(selectedTabList.length-1);
    _nextId--;
    setState(() {
      prefs.setInt('nextId', _nextId);
      String bankDataListJson = jsonEncode(bankDataList);
      prefs.setString('bankDataList', bankDataListJson);
      prefs.setStringList('selectedTabList', selectedTabList);
      sumMap.forEach((key, value) {
        final innerMap = <String, List<double>>{};
        value.forEach((innerKey, innerValue) {
          innerMap[innerKey] = innerValue;
        });
        serializableSumMap[key.toString()] = innerMap;
      });
      final sumMapJson = jsonEncode(serializableSumMap);
      prefs.setString('sumMap', sumMapJson);
    });
  }
  Future<void> updateBankData(int id, String bankName, double percent, double sum, String currency, String selectedSymbol, bool addButton) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> serializableSumMap = {};
    final index = bankDataList.indexWhere((bank) => bank['id'] == id);
    if (!sumMap.containsKey(id)) {
      sumMap[id] = {currency: []};
    }
    final sumValues = sumMap[id]?[currency] ?? [];
    if (index != -1) {
      if (bankDataList[index]['bankName'] != bankName){
        double totalSum = sum;
        final bankData = {
          'id': id,
          'bankName': bankName,
          'percent': percent,
          'sum': totalSum,
          'selectedTab': currency,
          'selectedSymbol': selectedSymbol,
          'isEditing': false,
          'isAddButtonActive' : addButton
        };
        bankDataList[index] = bankData;
        setState(() {});
      } else {
        sumValues.add(sum);
        sumMap[id]?[currency] = sumValues;
        double totalSum = calculateSum(id);
        final bankData = {
          'id': id,
          'bankName': bankName,
          'selectedTab': currency,
          'selectedSymbol': selectedSymbol,
          'percent': percent,
          'sum': totalSum,
          'isEditing': false,
          'isAddButtonActive' : addButton
        };
        bankDataList[index] = bankData;
      }
    }
    setState(() {
      String bankDataListJson = jsonEncode(bankDataList);
      prefs.setString('bankDataList', bankDataListJson);
      sumMap.forEach((key, value) {
        final innerMap = <String, List<double>>{};
        value.forEach((innerKey, innerValue) {
          innerMap[innerKey] = innerValue;
        });
        serializableSumMap[key.toString()] = innerMap;
      });
      final sumMapJson = jsonEncode(serializableSumMap);
      prefs.setString('sumMap', sumMapJson);
    });
  }
  Future<void> deleteValueById(int id, int index, String bankName, double percent, String currency, String selectedSymbol, bool addButton) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> serializableSumMap = {};
    final idPosition = bankDataList.indexWhere((bank) => bank['id'] == id);
    final values = sumMap[id]?[currency] ?? [];
    if (values != null && index < values.length) {
      values.removeAt(index);
      if (values.isEmpty) {
        sumMap[id]?.remove(currency);
      } else {
        double totalSum = 0.0;
        for (double value in values) {
          totalSum += value;
        }
        sumMap[id]?[currency] = values;
        final bankData = {
          'id': id,
          'bankName': bankName,
          'percent': percent,
          'sum': totalSum,
          'selectedTab': currency,
          'selectedSymbol': selectedSymbol,
          'isEditing': false,
          'isAddButtonActive' : addButton
        };
        bankDataList[idPosition] = bankData;
      }
      Iterable<MapEntry<int, Map<String, List<double>>>> entries = sumMap.entries;
      for (final entry in entries) {
        print('(${entry.key}, ${entry.value[currency]})');
      }
    }
    setState(() {
      String bankDataListJson = jsonEncode(bankDataList);
      prefs.setString('bankDataList', bankDataListJson);
      sumMap.forEach((key, value) {
        final innerMap = <String, List<double>>{};
        value.forEach((innerKey, innerValue) {
          innerMap[innerKey] = innerValue;
        });
        serializableSumMap[key.toString()] = innerMap;
      });
      final sumMapJson = jsonEncode(serializableSumMap);
      prefs.setString('sumMap', sumMapJson);
    });
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
  void updateBankDataList(List<Map<String, dynamic>> bankDataList, int deletedId) {
    final updatedBankDataList = <Map<String, dynamic>>[];
    int newId = 1;

    // Iterate through the bankDataList and update the IDs
    for (final bankData in bankDataList) {
      final id = bankData['id'];

      if (id != deletedId) {
        bankData['id'] = newId;

        if (id != newId) {
          final name = bankData['bankName'];
          final nameMatch = RegExp(r'^Bank Name \d+$').hasMatch(name);

          if (nameMatch) {
            bankData['bankName'] = 'Bank Name $newId';
          }
        }

        updatedBankDataList.add(bankData);
        newId++;
      }
    }

    // Update the original bankDataList with the updated list
    bankDataList.clear();
    bankDataList.addAll(updatedBankDataList);
  }
  void reorganizeKeys(Map<int, Map<String, List<double>>> map, int deletedKey) {
    final keysToRemove = <int>{};
    final newKeyOrder = <int>[];

    // Identify keys to remove and the new key order
    map.forEach((key, value) {
      if (key == deletedKey) {
        keysToRemove.add(key);
      } else {
        newKeyOrder.add(key);
      }
    });

    // Remove keys
    for (final key in keysToRemove) {
      map.remove(key);
    }

    // Reassign keys in order
    final newMap = <int, Map<String, List<double>>>{};
    for (int i = 0; i < newKeyOrder.length; i++) {
      final oldKey = newKeyOrder[i];
      final newValue = map[oldKey]!;
      newMap[i + 1] = newValue;
    }

    // Update the original map
    map.clear();
    map.addAll(newMap);
  }
  List<double> getSumList(int id, String currency) {
    // Get the list of doubles for the bank with the given ID.
    final sumValues = sumMap[id]?[currency] ?? [];
    return sumValues;
  }
  Map<int, Map<String, List<double>>> getSumMap() {
    return Map<int, Map<String, List<double>>>.from(sumMap);
  }
  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _load();
  }
  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ab1 = prefs.getInt('nextId') ?? 1;
    final ab2 = prefs.getStringList('selectedTabList') ?? [];
    final ab3 = prefs.getString('bankDataList');
    final ab4 = prefs.getString('sumMap');

    setState(() {
      print("ab1 : $ab1");
      print("ab2 : $ab2");
      print("ab3 type: $ab3");
      _nextId = ab1;
      selectedTabList = ab2;

      try {
        if (ab3 != null && ab3.isNotEmpty) {
          bankDataList = (jsonDecode(ab3) as List<dynamic>).cast<Map<String, dynamic>>();
        } else {
          // Handle the case where 'bankDataList' is null or empty.
          bankDataList = [];
        }
      } catch (e) {
        // Handle any exceptions that may occur during decoding.
        print("Error decoding bankDataList: $e");
        bankDataList = [];
      }

      try {
        if (ab4 != null && ab4.isNotEmpty) {
          final decodedSumMap = jsonDecode(ab4) as Map<String, dynamic>;
          sumMap = <int, Map<String, List<double>>>{};
          decodedSumMap.forEach((key, value) {
            final intKey = int.tryParse(key);
            if (intKey != null && value is Map<String, dynamic>) {
              final innerMap = <String, List<double>>{};
              value.forEach((innerKey, innerValue) {
                if (innerValue is List<dynamic>) {
                  innerMap[innerKey] = innerValue.map((item) => (item is double) ? item : 0.0).toList();
                }
              });
              sumMap[intKey] = innerMap;
            }
          });
        } else {
          sumMap = {};
        }
      } catch (e) {
        sumMap = {};
      }

      // Assign the final sumMap to your instance variable if needed
      // this.sumMap = sumMap;
    });
  }

  Widget buildBankCategories(BuildContext context, Map<String, dynamic> bankData) {
    final String newSelectedTab;
    if (selectedTabList.isEmpty){
      newSelectedTab = "Türk Lirası";
    } else {
      newSelectedTab = selectedTabList[(selectedTabList.length)-(selectedTabList.length-((bankData['id'] as int)-1))];
      print("bankData['id'] : ${bankData['id']}");
      print("Type of bankData['id'] : ${bankData['id'].runtimeType}");
      print("bankDataProvider.selectedTabList : $selectedTabList");
      print("newSelectedTab : $newSelectedTab");
    }
    final TextEditingController nameController = TextEditingController();
    final sumForCurrency = calculateSumForCurrency(bankData['id'], newSelectedTab) ;
    double totalCurrencySum = calculateTotalSumForCurrency(newSelectedTab);
    final division = (totalCurrencySum != 0.0 && !totalCurrencySum.isNaN) ? (sumForCurrency / totalCurrencySum) : 0.0;
    TextEditingController? assetController;
    if (bankData['id'] < assetControllers.length) {
      assetController = assetControllers[bankData['id']];
    } else {
      assetController = TextEditingController();
      assetControllers.add(assetController);
    }
    if(newSelectedTab == currencyList[0]){
      selectedSymbol = "₺";
    } else if (newSelectedTab == currencyList[1]){
      selectedSymbol = '\$';
    } else if (newSelectedTab == currencyList[2]){
      selectedSymbol = "€";
    } else if (newSelectedTab == currencyList[3]){
      selectedSymbol = "g";
    } else if (newSelectedTab == currencyList[4]){
      selectedSymbol = "₺";
    } else if (newSelectedTab == currencyList[5]){
      selectedSymbol = "?";
    }
    nameController.text = bankData['bankName'];

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
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
                      bankData['isEditing'] = !bankData['isEditing'];
                    });
                  });
                  // Set the cursor position to the end of the text
                  nameController.selection = TextSelection.fromPosition(
                    TextPosition(offset: nameController.text.length),
                  );
                  focusNode.requestFocus();
                  SystemChannels.textInput.invokeMethod('TextInput.show');
                },
                child: SizedBox(
                  width: double.maxFinite, // Set a fixed width to match the Text widget
                  child: bankData['isEditing']
                      ? EditableText(
                    controller: nameController,
                    focusNode: focusNode,
                    style: const TextStyle(
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
                      if(bankData['bankName'] != newName){
                        updateBankData(bankData['id'], newName, bankData['percent'], bankData['sum'], dropDownValue, bankData['selectedSymbol'], false);
                      }
                      setState(() {
                        bankData['isEditing'] = false; // Exit editing mode
                      });
                    },
                  )
                      : Text(
                    bankData['bankName'],
                    style: const TextStyle(
                      // Maintain text style
                      color: Colors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "${sumForCurrency.toString()}$selectedSymbol",
                style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(
                child: LinearPercentIndicator(
                  padding: const EdgeInsets.only(right: 10),
                  backgroundColor: const Color(0xffc6c6c7),
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
                  barRadius: const Radius.circular(10),
                  progressColor: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 5),
              DefaultTabController(
                length: currencyList.length,
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
                          color: const Color(0xffc6c6c7),
                        ),
                        labelColor: Colors.blue, // Color for the selected tab text
                        unselectedLabelColor: Colors.grey, // Color for unselected tab text
                        tabs: currencyList.map((currency) {
                          return Tab(
                            child: Container(
                              padding: const EdgeInsets.all(8.0), // Adjust padding as needed
                              decoration: const BoxDecoration(
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
                            selectedTabList[selectedTabList.length - (selectedTabList.length - ((bankData['id'] as int) - 1))] = currencyList[value];
                            bankData['selectedSymbol'] = getSelectedSymbol(selectedTab);
                            print("selectedTabList : $selectedTabList");
                            print("sumMap for onChange : $sumMap");
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        if (sumMap[bankData['id']]?[selectedTabList[selectedTabList.length - (selectedTabList.length - ((bankData['id'] as int) - 1))]] != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(selectedTabList[selectedTabList.length - (selectedTabList.length - ((bankData['id'] as int) - 1))], style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                              const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: sumMap[bankData['id']]?[selectedTabList[selectedTabList.length - (selectedTabList.length - ((bankData['id'] as int) - 1))]]?.length ?? 0 + 1,
                                itemBuilder: (context, index) {
                                  if (index < sumMap[bankData['id']]![selectedTabList[selectedTabList.length - (selectedTabList.length - ((bankData['id'] as int) - 1))]]!.length && sumMap[bankData['id']]![selectedTabList[selectedTabList.length - (selectedTabList.length - ((bankData['id'] as int) - 1))]]![index] != 0.0) {
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
                                                sumMap[bankData['id']]![selectedTabList[selectedTabList.length - (selectedTabList.length - ((bankData['id'] as int) - 1))]]![index].toString(),
                                                style: GoogleFonts.montserrat(fontSize: 20),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            IconButton(
                                              splashRadius: 0.0001,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(minWidth: 23, maxWidth: 23),
                                              icon: const Icon(Icons.delete, size: 21),
                                              onPressed: () {
                                                setState(() {
                                                  deleteValueById(bankData['id'], index, bankData['bankName'], bankData['percent'], selectedTabList[selectedTabList.length - (selectedTabList.length - ((bankData['id'] as int) - 1))], bankData['selectedSymbol'], false);
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        const Divider(color: Color(0xffc6c6c7), thickness: 2, height: 20),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              )
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if(bankData['isAddButtonActive'] == false)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          bankData['isAddButtonActive'] = true;
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
                              title: const Text("Are you sure?"),
                              content: const Text("Do you want to delete this item?"),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () {
                                    // Close the dialog
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Cancel"),
                                ),
                                CupertinoDialogAction(
                                  onPressed: () {
                                    setState(() {
                                      deleteBankData(bankData['id']);
                                      Navigator.of(context).pop();
                                    });
                                  },
                                  child: const Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Icon(CupertinoIcons.delete),
                    ),
                  ],
                ),
              if(bankData['isAddButtonActive'] == true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton(
                      value: dropDownValue,
                      icon:const Icon(Icons.keyboard_arrow_down),
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
                    ),
                  ],
                ),
              if(bankData['isAddButtonActive'] == true && assetController != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: assetController,
                        keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                        decoration: const InputDecoration(
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
                                updateBankData(bankData['id'], newName, bankData['percent'], price, dropDownValue , bankData['selectedSymbol'], false);
                                assetController?.clear();
                              } else {
                                assetController?.clear();
                              }
                            });
                          },
                          icon: const Icon(Icons.check_circle, size: 26),
                        )
                      ],
                    )
                  ],
                )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalCurrencySum = calculateTotalSumForCurrency("Türk Lirası");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff0f0f1),
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
                  icon: const Icon(Icons.settings, color: Colors.black), // Replace with the desired left icon
                ),
                IconButton(
                  onPressed: () {

                  },
                  icon: const Icon(Icons.person, color: Colors.black), // Replace with the desired right icon
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bankalarım",
                  style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
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
                    const SizedBox(height: 10),
                    Text("${totalCurrencySum.toString()}₺",
                        style: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontSize: 19,
                            fontWeight: FontWeight.normal)),
                    const SizedBox(height: 5),
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
                              final bankName = "Bank Name ${bankDataList.length + 1}";
                              const initialPercent = 0.0;
                              print("TEK ADDBANKDATA ÇALIŞTI");
                              addBankData(bankName, initialPercent, 0.0, dropDownValue, "");
                            },
                            icon: const Icon(Icons.add_circle),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  for (var bankData
                  in bankDataList)
                    buildBankCategories(context, bankData),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 90,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), // Adjust as needed
              topRight: Radius.circular(10), // Adjust as needed
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
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
              selectedLabelStyle: GoogleFonts.montserrat(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.montserrat(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w600),
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
                  icon: Padding(
                    padding: EdgeInsets.only(left: 5,right: 5),
                    child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100, // Background color
                          borderRadius: BorderRadius.circular(20), // Rounded corners
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5,bottom: 5),
                          child: Icon(FontAwesome.bank, size: 20),
                        )
                    ),
                  ),
                  label: 'İstekler',
                )
              ],
            ),
          ),
        ),
      ),
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