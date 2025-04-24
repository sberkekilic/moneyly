// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'dart:convert';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  List<String> currencyList = [
    'Türk Lirası',
    'Dolar',
    'Euro',
    'Altın',
    'Hisse',
    'Diğer'
  ];
  final Map<String, String> currencySymbols = {
    'Türk Lirası': '₺',
    'Dolar': '\$',
    'Euro': '€',
    'Altın': 'g',
    'Hisse': '📈',
    'Diğer': '?',
  };
  String selectedTab = "Türk Lirası";
  String selectedSymbol = "";
  String totalSymbol = "";
  int idForBuild = 0;
  int selectedTabIndex = 0;
  List<Map<String, dynamic>> bankDataList = [];
  List<TextEditingController> assetControllers = [];
  List<String> selectedTabList = [];
  Map<int, Map<String, List<double>>> sumMap = {};
  int _nextId = 1;
  double totalCurrencySum = 0.0;
  int selectedCurrencyIndex = 0;

  Future<void> addBankData(String bankName, String currency, String selectedSymbol, bool isDebit, double creditLimit, int cutoffDate) async {
    final prefs = await SharedPreferences.getInstance();
    print("AAAAAA 1 : $_nextId");
    final bankData = {
      'id': _nextId++,
      'bankName': bankName,
      'selectedTab': currency,
      'selectedSymbol': selectedSymbol,
      'isEditing': false,
      'isAddButtonActive': false,
      'isDebit' : isDebit,
      'creditLimit': creditLimit,
      'cutoffDate': cutoffDate,
    };
    print("AAAAAA 2 : $_nextId");
    bankDataList.add(bankData);
    selectedTabList.add(currency);
    setState(() {
      prefs.setInt('nextId', _nextId);
      String bankDataListJson = jsonEncode(bankDataList);
      prefs.setString('bankDataList', bankDataListJson);
      prefs.setStringList('selectedTabList', selectedTabList);
    });
  }
  void _showAddBankDialog() {
    TextEditingController bankNameController = TextEditingController();
    TextEditingController creditLimitController = TextEditingController();
    String selectedCurrency = dropDownValue;
    bool isDebit = false; //Varsayılan banka hesabı
    int selectedCutoffDate = 1; //Varsayılan hesap kesim günü

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Add Bank"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: bankNameController,
                      decoration: InputDecoration(labelText: "Bank Name"),
                    ),
                    DropdownButton<String>(
                      value: selectedCurrency,
                      items: ["USD", "EUR", "Türk Lirası"] // Modify based on available currencies
                          .map((String currency) => DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      ))
                          .toList(),
                      onChanged: (value) {
                        selectedCurrency = value!;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isDebit ? "Debit Account" : "Credit Account"),
                        Switch(
                          value: isDebit, // False = Debit, True = Credit
                          onChanged: (value) {
                            setState(() {
                              isDebit = value;
                            });
                          },
                        ),
                      ],
                    ),
                    if (!isDebit) ...[ // Show only for credit accounts
                      TextField(
                        controller: creditLimitController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Credit Limit"),
                      ),
                      DropdownButton<int>(
                        value: selectedCutoffDate,
                        items: List.generate(28, (index) => index + 1)
                            .map((day) => DropdownMenuItem(
                          value: day,
                          child: Text("Cutoff Date: $day"),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCutoffDate = value!;
                          });
                        },
                      ),
                    ]
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      String bankName = bankNameController.text.trim();
                      double creditLimit = isDebit ? 0.0 : (double.tryParse(creditLimitController.text) ?? 0.0);

                      if (bankName.isNotEmpty) {
                        addBankData(bankName, selectedCurrency, "", isDebit, creditLimit, selectedCutoffDate);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text("Add"),
                  ),
                ],
              );
            },
        );
      },
    );
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
  Future<void> updateBankData(int bankId, String currency, double amount) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> bankData = bankDataList.firstWhere((bank) => bank['id'] == bankId, orElse: () => <String, dynamic>{});

    if (bankData != null){
      Map<String, double> goalMap = (bankData['goal'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, (value is num) ? value.toDouble() : 0.0));

      goalMap[currency] = amount;
      bankData['goal'] = goalMap;
    }
    // Save the updated bankDataList to preferences
    String bankDataListJson = jsonEncode(bankDataList);
    await prefs.setString('bankDataList', bankDataListJson);
  }
  Future<void> _saveBankDataList() async {
    final prefs = await SharedPreferences.getInstance();
    String bankDataListJson = jsonEncode(bankDataList);
    await prefs.setString('bankDataList', bankDataListJson);
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
    double totalGoal = 0.0;

    for (var bankData in bankDataList){
      Map<String, dynamic>? goalMap = bankData['goal'] as Map<String, dynamic>?;

      if (goalMap != null && goalMap.containsKey(currency)){
        double value = (goalMap[currency] is num) ? (goalMap[currency] as num).toDouble() : 0.0;
        totalGoal += value;
      }
    }

    return totalGoal;
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
  String getInitials(String title) {
    List<String> words = title.split(" ");
    String initials = words.length > 1
        ? "${words[0][0]}${words[1][0]}"
        : words[0][0];
    return initials.toUpperCase();
  }
  Widget buildMonogram(String title) {
    return Container(
      width: 70.r,
      height: 70.r,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey
      ),
      child: Center(
        child: Text(
          getInitials(title),
          style: TextStyle(
            color: Colors.white, // Text color
            fontSize: 20.0, // Font size
            fontWeight: FontWeight.bold, // Font weight
          ),
        ),
      ),
    );
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

      totalCurrencySum = calculateTotalSumForCurrency("Türk Lirası");
    });
  }
  Widget buildBankCategories(BuildContext context, Map<String, dynamic> bankData) {
    String newSelectedTab = "Türk Lirası"; // Default customsliding option
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
    Map<String, double> goalMap = (bankData['goal'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value is num) ? value.toDouble() : 0.0), // Ensure value is a double
    ) ?? {};

    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
              color: Color(0xFFD5E1F5)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bank Info Container
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFF70B8FF),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      buildMonogram(bankData['bankName']),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  bankData['isEditing'] = !bankData['isEditing'];
                                });
                                nameController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: nameController.text.length),
                                );
                                focusNode.requestFocus();
                                SystemChannels.textInput.invokeMethod('TextInput.show');
                              },
                              child: bankData['isEditing']
                                  ? EditableText(
                                controller: nameController,
                                focusNode: focusNode,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.normal,
                                ),
                                cursorColor: Colors.black,
                                backgroundCursorColor: Colors.black,
                                keyboardType: TextInputType.text,
                                onChanged: (newName) {
                                  bankData['bankName'] = newName;
                                },
                                onEditingComplete: () {
                                  setState(() {
                                    bankData['isEditing'] = false;
                                  });
                                  _saveBankDataList();
                                },
                              )
                                  : Text(
                                bankData['bankName'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(goalMap[selectedTabList[bankData['id'] - 1]] ?? 0.0) + selectedSymbol,
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontSize: 19,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Currency Selector
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Colors.transparent, // Disable splash effect
                        highlightColor: Colors.transparent, // Disable highlight effect
                        hoverColor: Colors.transparent, // Disable hover effect
                      ),
                      child: CustomSlidingSegmentedControl<int>(
                        initialValue: currencyList.indexOf(selectedTabList[bankData['id'] - 1]),
                        isStretch: false,
                        children: {
                          for (int i = 0; i < currencyList.length; i++)
                            i: Container(
                              width: 100,
                              alignment: Alignment.center,
                              child: Text(
                                currencyList[i],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        },
                        innerPadding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0xFF86CDEA),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [],
                        ),
                        thumbDecoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Color(0x7D0065a3)  // Dark mode color
                              : Colors.white, // Light mode color
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [],
                        ),
                        onValueChanged: (value) {
                          setState(() {
                            String selectedCurrency = currencyList[value]; // Get the selected currency string
                            selectedTabList[bankData['id'] - 1] = selectedCurrency; // Update the selectedTabList for this specific bank
                            bankData['selectedSymbol'] = getSelectedSymbol(selectedCurrency); // Update the symbol for the bank
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    flex: 32,
                    child: ActionButton(
                      label: "Düzenle",
                      onTap: () {
                        setState(() {
                          bankData['isAddButtonActive'] = true;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 32,
                    child: ActionButton(
                      label: "Kaldır",
                      onTap: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: Text("Are you sure?"),
                              content: Text("Do you want to delete this item?"),
                              actions: [
                                CupertinoDialogAction(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancel"),
                                ),
                                CupertinoDialogAction(
                                  onPressed: () {
                                    setState(() {
                                      deleteBankData(bankData['id']);
                                      Navigator.of(context).pop();
                                    });
                                  },
                                  child: Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Add Asset Field
              if (bankData['isAddButtonActive'] && assetController != null) ...[
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: assetController,
                        keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          hintText: 'Asset',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                          ),
                          prefixIcon: Icon(Icons.attach_money, color: Colors.blueAccent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ConfirmButton(
                      onPressed: () {
                        String inputText = assetController?.text.trim() ?? '';
                        double? price = double.tryParse(inputText);
                        setState(() {
                          if (price != null && price >= 0) {
                            updateBankData(
                              bankData['id'],
                              newSelectedTab,
                              price
                            );
                            assetController?.clear();
                            bankData['isAddButtonActive'] = false;
                          } else {
                            bankData['isAddButtonActive'] = false;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ],
          )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String selectedCurrency = currencyList[selectedCurrencyIndex];
    String currencySymbol = currencySymbols[selectedCurrency] ?? '';

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bankalarım",
                  style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0x7D67C5FF) // Dark mode color
                      : Color(0xFFD5E1F5),// Light mode color
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xFF87CEEB),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xFF70B8FF),
                            ),
                            child: Text("Toplam Varlığım",
                                style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontSize: 19,
                                    fontWeight: FontWeight.normal)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("$selectedCurrency Varlığım",
                                    style: GoogleFonts.montserrat(
                                        color: Colors.black,
                                        fontSize: 19,
                                        fontWeight: FontWeight.normal)),
                                Text(
                                    NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(totalCurrencySum) + currencySymbol,
                                    style: GoogleFonts.montserrat(
                                        color: Colors.black,
                                        fontSize: 19,
                                        fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              splashColor: Colors.transparent, // Disable splash effect
                              highlightColor: Colors.transparent, // Disable highlight effect
                              hoverColor: Colors.transparent, // Disable hover effect
                            ),
                            child: CustomSlidingSegmentedControl<int>(
                              initialValue: 0,
                              isStretch: false,
                              children: {
                                for (int i = 0; i < currencyList.length; i++)
                                  i: Container(
                                    width: 100,
                                    alignment: Alignment.center,
                                    child: Text(
                                      currencyList[i],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              },
                              innerPadding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Color(0xFF86CDEA),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [],
                              ),
                              thumbDecoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Color(0x7D0065a3)  // Dark mode color
                                    : Colors.white, // Light mode color
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [],
                              ),
                              onValueChanged: (value) {
                                setState(() {
                                  selectedCurrencyIndex = value; // Update selected currency index
                                  totalCurrencySum = calculateTotalSumForCurrency(currencyList[selectedCurrencyIndex]);
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF70B7FE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _showAddBankDialog();
                            });
                          },
                          child: SizedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Banka Ekle",
                                      style: GoogleFonts.montserrat(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal)),
                                  Icon(Icons.add_circle),
                                ],
                              ),
                            ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                sumMap.entries.map((outer) =>
                "Key: ${outer.key}\n" + outer.value.entries.map((inner) =>
                "  ${inner.key}: ${inner.value.join(", ")}"
                ).join("\n")
                ).join("\n\n"),
                style: TextStyle(fontSize: 16),
              ),
              Text(
                bankDataList.map((bankData) =>
                    bankData.entries.map((entry) =>
                    "${entry.key}: ${entry.value}"
                    ).join(", ")
                ).join("\n\n"),
                style: TextStyle(fontSize: 16),
              ),
              ListView(
                padding: EdgeInsets.zero,
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

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFF70B7FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ConfirmButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ConfirmButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(Icons.check_circle, color: Colors.white, size: 28),
      ),
    );
  }
}