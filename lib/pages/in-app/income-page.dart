import 'dart:convert';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../blocs/income-selections.dart';
import '../../blocs/settings/selected-index-cubit.dart';
import '../../models/transaction.dart';

class IncomePage extends StatefulWidget {
  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  List<Map<String, dynamic>> bankAccounts = [];
  Map<String, dynamic>? selectedAccount;
  bool isLoading = true; // Flag to indicate loading state

  Map<String, List<Map<String, dynamic>>> incomeMap = {};
  Map<String, List<Map<String, dynamic>>> summedIncomeMap = {};
  String selectedTitle = 'Toplam';
  String selectedKey = "";
  int? selectedDay;
  String newSelectedOption = "İş";
  double incomeValue = 0.0;
  String formattedIncomeValue = "";
  String formattedWorkValue = "";
  String formattedScholarshipValue = "";
  String formattedPensionValue = "";
  String formattedSavingsValue = "";
  String formattedWishesValue = "";
  String formattedNeedsValue = "";
  int? segmentControlGroupValue = 0;
  int totalValues = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String labelForOption(SelectedOption option) {
    switch (option) {
      case SelectedOption.Is:
        return 'İş';
      case SelectedOption.Burs:
        return 'Burs';
      case SelectedOption.Emekli:
        return 'Emekli';
      default:
        return '';
    }
  }

  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ab1 = prefs.getInt('selected_option') ?? SelectedOption.None.index;
    final ab2 = prefs.getString('incomeMap') ?? "0";
    final ab3 = prefs.getDouble('sumInvestValue') ?? 0.0;
    String? accountDataListJson = prefs.getString('accountDataList');
    String? accountData = prefs.getString('selectedAccount');

    setState(() {
      sumInvestValue = ab3;

      if (ab2.isNotEmpty) {
        final decodedData = json.decode(ab2);
        if (decodedData is Map<String, dynamic>) {
          decodedData.forEach((key, value) {
            if (value is List<dynamic>) {
              // We need to check if each list item is a Map
              incomeMap[key] = value
                  .where((item) => item is Map<String, dynamic>)
                  .cast<Map<String, dynamic>>()
                  .toList();
            }
            if (incomeMap.containsKey(key) && incomeMap[key]!.isNotEmpty) {
              String valueToParse = '';
              if (incomeMap.containsKey(selectedKey.isNotEmpty ? selectedKey : key) &&
                  incomeMap[selectedKey.isNotEmpty ? selectedKey : key]!.isNotEmpty) {

                valueToParse = incomeMap[selectedKey.isNotEmpty ? selectedKey : key]![0]["amount"];
                selectedDay = incomeMap[selectedKey.isNotEmpty ? selectedKey : key]![0]["day"];
                try {
                  final parsed = NumberFormat.decimalPattern('tr_TR').parse(valueToParse);
                  incomeValue = parsed.toDouble();
                } catch (e) {
                  print("Parsing error: $e, value: $valueToParse");
                  incomeValue = 0.0; // ya da null yapacaksan double? incomeValue kullan
                }
              } // Take the first (and only) string from the list
              selectedKey = key;
              double sum = 0.0;
              incomeMap.values.forEach((values) {
                values.forEach((value) {
                  if (value is Map<String, dynamic>) {
                    // Ensure we are accessing "amount" correctly from the map
                    double parsedValue = 0.0;

                    try {
                      final parsed = NumberFormat.decimalPattern('tr_TR').parse(value["amount"].toString());
                      parsedValue = parsed.toDouble();
                    } catch (e) {
                      print("Amount parse error: $e, value: ${value["amount"]}");
                      parsedValue = 0.0; // veya null atanacaksa double? parsedValue
                    }
                    sum += parsedValue;
                  }
                });
              });
              incomeValue = sum;
            } else {
              incomeValue =
                  0.0; // Default value if the key or value is not found
            }
          });
        }
      }

      // Handle account data list
      if (accountDataListJson != null) {
        try {
          List<Map<String, dynamic>> decodedData = List<Map<String, dynamic>>.from(jsonDecode(accountDataListJson));
          print('Tüm Hesaplar: $decodedData');
          // Remove duplicates by id
          bankAccounts = decodedData.toSet().toList();

          // If the account data is set (selectedAccount) and is not part of the list, reset it
          if (accountData != null) {
            final Map<String, dynamic> accountFromPrefs = Map<String, dynamic>.from(jsonDecode(accountData));
            // Find the matching account in bankAccounts by id
            try {
              selectedAccount = bankAccounts.firstWhere(
                      (account) => account['id'] == accountFromPrefs['id']
              );
            } catch (e) {
              selectedAccount = null;
            }
          }
          setState(() {
            isLoading = false;
          });
        } catch (e) {
          print('Error decoding account data: $e');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('No account data found');
        setState(() {
          isLoading = false;
        });
      }

      print('Seçili hesap: $accountData');
      print('Selected account1: $selectedAccount');

      if (accountData != null && selectedAccount == null) {
        setState(() {
          selectedAccount = Map<String, dynamic>.from(jsonDecode(accountData));
          print('Selected account2: $selectedAccount');
        });
      }

      // Calculate the total number of values in incomeMap
      totalValues = incomeMap.values.fold<int>(
        0,
            (count, list) => count + list.length,
      );

      // Calculate the sum for each key in incomeMap
      for (var key in incomeMap.keys) {
        double sum = 0.0;

        // Iterate over each value list for the current key
        for (var value in incomeMap[key]!) {
          double parseAmount(String amountStr) {
            try {
              // Eğer Türkçe formatta ("1.234,56") ise bu çalışır
              return NumberFormat.decimalPattern('tr_TR').parse(amountStr).toDouble();
            } catch (e1) {
              try {
                // İngilizce format gelirse: "1,234.56" → "1234.56"
                final cleaned = amountStr.replaceAll('.', '').replaceAll(',', '.');
                return double.parse(cleaned);
              } catch (e2) {
                print("Parse failed for: $amountStr\nError: $e2");
                return 0.0;
              }
            }
          }

          if (value is Map<String, dynamic>) {
            // Extract the "amount" value from the map
            String amountStr = value["amount"].toString(); // Ensure the amount is a String
            double parsedValue = parseAmount(amountStr);

            sum += parsedValue; // Add the parsed value to the sum
          }
        }

        // Store the sum as a string in the new map
        summedIncomeMap[key] = [
          {
            "amount": NumberFormat.decimalPattern('tr_TR').format(sum),
          }
        ];
      }
    });
  }

  // Define TextEditingControllers for the editable fields
  TextEditingController keyController = TextEditingController();
  TextEditingController valueController = TextEditingController();

// Function to handle editing
  void editIncome(String key, String value, int index) async {
    keyController.text = key;
    valueController.text = value;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Income'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: keyController,
                decoration: InputDecoration(labelText: 'Key'),
                readOnly: true,
                enabled: false,
              ),
              TextField(
                controller: valueController,
                decoration: InputDecoration(labelText: 'Value'),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final newKey = keyController.text;
                      String newValue = valueController.text;
                      setState(() {

                        // Only update the value at the specified index
                        newValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2)
                            .format(NumberFormat.decimalPattern('tr_TR').parse(newValue) as double);

                        incomeMap[key]![index]["amount"] = newValue;
                        // Save the modified incomeMap to SharedPreferences
                        prefs.setString('incomeMap', jsonEncode(incomeMap));
                      });
                      _load();
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final confirm = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Deletion'),
                            content: Text(
                                'Are you sure you want to delete this entry?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false); // Don't delete
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true); // Confirm deletion
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        if (totalValues == 1){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Cannot delete the last income entry."),
                            ),
                          );
                        } else {
                          setState(() {
                            incomeMap.remove(key);
                            summedIncomeMap.remove(key);
                            // Save the modified incomeMap to SharedPreferences
                            prefs.setString('incomeMap', jsonEncode(incomeMap));
                          });
                        }
                        Navigator.of(context).pop(); // Close the dialog
                        _load();
                      }
                    },
                    child: Text('Delete'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accountDataList', jsonEncode(bankAccounts));
  }

  Future<void> _addTransactionToAccount(int accountId, Transaction transaction) async {
    try {
      setState(() {
        final accountIndex = bankAccounts.indexWhere((acc) => acc['id'] == accountId);
        if (accountIndex != -1) {
          bankAccounts[accountIndex]['transactions'] ??= [];
          bankAccounts[accountIndex]['transactions'].add(transaction.toJson());
        }
      });
      await _saveAccounts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add transaction: $e")),
      );
    }
  }

  bool isEditing = false;
  bool isIncomeAdding = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController incomeController = TextEditingController();
  FocusNode focusNode = FocusNode();

  double sumOfSavingValue = 0.0;
  double savingsValue = 0.0;
  double totalInvestValue = 0.0;
  double sumInvestValue = 0.0;
  double result = 0.0;
  String formattedsavingsValue = "";
  String formattedSumOfSavingValue = "";
  String formattedSumOfIncomeValue = "";

  @override
  Widget build(BuildContext context) {

    sumOfSavingValue = sumInvestValue.isNaN ? 0.0 : sumInvestValue;
    formattedIncomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(incomeValue);
    nameController.text = formattedIncomeValue;
    String firstKey = "";
    List<double> valuesOfFirstKey = [];
    List<String> workValue = incomeMap['İş']?.map((e) => e["amount"].toString()).toList() ?? ['0'];
    List<String> scholarshipValue = incomeMap['Burs']?.map((e) => e["amount"].toString()).toList() ?? ['0'];
    List<String> pensionValue = incomeMap['Emekli']?.map((e) => e["amount"].toString()).toList() ?? ['0'];
    double workDoubleValue;
    if (workValue.isNotEmpty && workValue[0].isNotEmpty){
      try{
        workDoubleValue = NumberFormat.decimalPattern('tr_TR').parse(workValue[0]) as double;
      } catch (e) {
        workDoubleValue = 0.0;
        print("Error parsing pension value: $e");
      }
    } else {
      workDoubleValue = 0.0;
    }
    double scholarshipDoubleValue;
    if (scholarshipValue.isNotEmpty && scholarshipValue[0].isNotEmpty){
      try{
        scholarshipDoubleValue = NumberFormat.decimalPattern('tr_TR').parse(scholarshipValue[0]) as double;
      } catch (e) {
        scholarshipDoubleValue = 0.0;
        print("Error parsing pension value: $e");
      }
    } else {
      scholarshipDoubleValue = 0.0;
    }
    double pensionDoubleValue;
    if (pensionValue.isNotEmpty && pensionValue[0].isNotEmpty){
      try{
        pensionDoubleValue = NumberFormat.decimalPattern('tr_TR').parse(pensionValue[0]) as double;
      } catch (e) {
        pensionDoubleValue = 0.0;
        print("Error parsing pension value: $e");
      }
    } else {
      pensionDoubleValue = 0.0;
    }
    formattedWorkValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(workDoubleValue);
    formattedScholarshipValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(scholarshipDoubleValue);
    formattedPensionValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(pensionDoubleValue);
    int workPercent = (incomeValue != 0)
        ? ((workDoubleValue / incomeValue) * 100).round()
        : 0;
    int scholarshipPercent = (incomeValue != 0)
        ? ((scholarshipDoubleValue / incomeValue) * 100).round()
        : 0;
    int pensionPercent = (incomeValue != 0)
        ? ((pensionDoubleValue / incomeValue) * 100).round()
        : 0;
    List<double> percentages = [
      workPercent.isNaN ? 0.0 : (workPercent.toDouble() / 100),
      scholarshipPercent.isNaN ? 0.0 : (scholarshipPercent.toDouble() / 100),
      pensionPercent.isNaN ? 0.0 : (pensionPercent.toDouble() / 100),
    ];
    print("İLK percentages:$percentages");
    Map<String, double> variableMap = {
      'workPercent': workPercent.toDouble(),
      'scholarshipPercent': scholarshipPercent.toDouble(),
      'pensionPercent': pensionPercent.toDouble(),
    };
    percentages.sort();
    List<String> variableNames = variableMap.keys.toList()
      ..sort(
          (a, b) => (variableMap[a] ?? 0.0).compareTo(variableMap[b] ?? 0.0));
    String smallestVariable = variableNames[0];
    String mediumVariable = variableNames[1];
    String largestVariable = variableNames[2];
    percentages.sort(
      (a, b) => b.compareTo(a),
    );
    percentages[0] = 1.0;
    print(
        "son percentages:$percentages, smallestVariable:$smallestVariable, mediumVariable:$mediumVariable, largestVariable:$largestVariable");
    double sumOfFirstKey = 0.0;
    String formattedValueOfFirstKey = "";
    if (incomeMap.keys.isNotEmpty) {
      firstKey = incomeMap.keys.first;
      valuesOfFirstKey = incomeMap[firstKey]!
          .map((value) => parseAmount(value["amount"]))
          .toList();
      sumOfFirstKey =
          valuesOfFirstKey.reduce((value, accumulator) => value + accumulator);
      formattedValueOfFirstKey =
          NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2)
              .format(sumOfFirstKey);
    }
    if (incomeMap.length == 1){
      selectedTitle = incomeMap.keys.first;
    } else {
      selectedTitle = "Toplam";
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Gelirler Detayı",
                style: TextStyle(
                  fontFamily: 'Keep Calm',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850] // Dark mode color
                        : Colors.white, // Light mode color
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.5) // Dark mode shadow color
                            : Colors.grey.withOpacity(0.5), // Light mode shadow color
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            incomeMap.isEmpty
                                ? Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.redAccent.withOpacity(0.1),
                              ),
                              child: Center(
                                child: Text(
                                  "Lütfen önce gelir ekleyin.",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            )
                                : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Color(0xFFF0EAD6)),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("$selectedTitle Geliri",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.grey[850] // Dark mode color
                                              : Colors.black, // Light mode color
                                        )
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 200,
                                          child: isEditing
                                              ? EditableText(
                                                  controller: nameController,
                                                  focusNode: focusNode,
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 28,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                  cursorColor: Colors.black,
                                                  backgroundCursorColor:
                                                      Colors.black,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  onEditingComplete: () async {
                                                    final prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    setState(() {
                                                      String newName =
                                                          nameController.text;
                                                      if (newSelectedOption
                                                          .isEmpty) {
                                                        // Get the first key from the incomeMap if newSelectedOption is empty
                                                        newSelectedOption =
                                                            incomeMap
                                                                .keys.first;
                                                      }
                                                      if (incomeMap.containsKey(
                                                          newSelectedOption)) {
                                                        // Update the existing value
                                                        incomeMap[newSelectedOption] = [{"amount": newName}];
                                                      } else {
                                                        incomeMap[newSelectedOption] = [{"amount": newName}];
                                                      }
                                                      prefs.setString(
                                                          'incomeMap',
                                                          jsonEncode(
                                                              incomeMap));
                                                      nameController.clear();
                                                      isEditing = false;
                                                      _load();
                                                    });
                                                  },
                                                )
                                              : Text(formattedIncomeValue,
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 25,
                                                      fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).brightness == Brightness.dark
                                                        ? Colors.grey[850] // Dark mode color
                                                        : Colors.black, // Light mode color
                                                  )
                                          ),
                                        ),
                                        SizedBox(width: 20.w),
                                        GestureDetector(
                                            onTap: isEditing
                                                ? () async {
                                              final prefs = await SharedPreferences.getInstance();
                                              setState(() {
                                                String newAmount = nameController.text; // Changed from newName to newAmount
                                                int day = int.tryParse(dayController.text) ?? 1; // Get day value, default to 1

                                                if (newSelectedOption.isEmpty) {
                                                  newSelectedOption = incomeMap.keys.first;
                                                }

                                                if (incomeMap.containsKey(newSelectedOption)) {
                                                  // Update the existing value with both amount and day
                                                  incomeMap[newSelectedOption] = [{
                                                    "amount": newAmount,
                                                    "day": day, // Use the parsed day value
                                                    // Keep existing account info if needed
                                                    if (incomeMap[newSelectedOption]!.isNotEmpty)
                                                      "account": incomeMap[newSelectedOption]![0]["account"],
                                                    if (incomeMap[newSelectedOption]!.isNotEmpty)
                                                      "accountID": incomeMap[newSelectedOption]![0]["accountID"],
                                                  }];
                                                } else {
                                                  // Create new entry with both amount and day
                                                  incomeMap[newSelectedOption] = [{
                                                    "amount": newAmount,
                                                    "day": day,
                                                    "account": selectedAccount?['bankName'] ?? "Unknown",
                                                    "accountID": selectedAccount?['id'] ?? "",
                                                  }];
                                                }

                                                prefs.setString('incomeMap', jsonEncode(incomeMap));
                                                nameController.clear();
                                                dayController.clear(); // Clear day field too
                                                isEditing = false;
                                                focusNode.unfocus();
                                                _load();
                                              });
                                                  }
                                                : () {
                                                    setState(() {
                                                      isEditing = true;
                                                      focusNode.requestFocus();
                                                    });
                                                  },
                                            child: isEditing
                                                ? Icon(
                                                Icons.done_rounded,
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.grey[850] // Dark mode color
                                                  : Colors.black, // Light mode color
                                            )
                                                : Icon(
                                                Icons.edit_rounded,
                                              color: Theme.of(context).brightness == Brightness.dark
                                                  ? Colors.grey[850] // Dark mode color
                                                  : Colors.black, // Light mode color
                                            )),
                                      ],
                                    ),
                                    TextField(
                                      controller: dayController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(labelText: "Day of Month (1-31)"),
                                    ),
                                    SizedBox(height: 10),
                                    SizedBox(
                                      child: LinearPercentIndicator(
                                        padding: EdgeInsets.only(right: 10),
                                        backgroundColor: Color(0xffc6c6c7),
                                        animation: true,
                                        lineHeight: 10,
                                        animationDuration: 1000,
                                        percent: 0,
                                        trailing: Text("%??",
                                            style: GoogleFonts.montserrat(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                        barRadius: Radius.circular(10),
                                        progressColor: Colors.lightBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                              ),
                              child:  Column(
                                children: [
                                  if (summedIncomeMap.length > 1) ...[
                                    for (var entry in summedIncomeMap.entries)
                                      for (int i = 0; i < entry.value.length; i++)
                                        Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(20),
                                                color: Color(0x7D67C5FF),
                                              ),
                                              padding: const EdgeInsets.all(15),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      CircularPercentIndicator(
                                                        radius: 30,
                                                        lineWidth: 7.0,
                                                        percent: (NumberFormat.decimalPattern('tr_TR').parse(entry.value[i]["amount"] ?? '0') as double) / incomeValue,
                                                        center: Text(
                                                          "%${(((NumberFormat.decimalPattern('tr_TR').parse(entry.value[i]["amount"] ?? '0') as double) / incomeValue) * 100).toStringAsFixed(0)}",
                                                          style: GoogleFonts.montserrat(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        progressColor: Colors.blue,
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Flexible(
                                                        flex: 2,
                                                        fit: FlexFit.tight,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              entry.key,  // The key, e.g., "İş"
                                                              style: GoogleFonts.montserrat(
                                                                color: Colors.black,
                                                                fontSize: 18.sp,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                            Text(
                                                              NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(parseTurkishDouble(entry.value[i]["amount"] ?? '0')), // The specific income value, e.g., "25.000" or "200"
                                                              style: GoogleFonts.montserrat(
                                                                color: Colors.black,
                                                                fontSize: 18.sp,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Flexible(
                                                        flex: 1,
                                                        fit: FlexFit.tight,
                                                        child: IconButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              editIncome(entry.key, entry.value[i]["amount"] ?? '0', i);
                                                            });
                                                          },
                                                          icon: Icon(Icons.edit),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (summedIncomeMap.length > 1) // Add a gap if not the last index
                                              SizedBox(height: 10),
                                          ],
                                        ),
                                  ],
                                  if (!isIncomeAdding)
                                    Container(
                                      decoration: BoxDecoration(
                                        color:
                                        Color.fromARGB(120, 152, 255, 170),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.only(left: 20,right: 20),
                                      child: SizedBox(
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Gelir Ekle",
                                                style: GoogleFonts.montserrat(
                                                    fontSize: 16,
                                                    fontWeight:
                                                    FontWeight.w600)),
                                            IconButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    isIncomeAdding = true;
                                                  });
                                                },
                                                icon: Icon(Icons.add_circle))
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (isIncomeAdding)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(120, 152, 255, 170),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Gelir Türü",
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 18, fontWeight: FontWeight.bold)),
                                              GestureDetector(
                                                child: Icon(Icons.cancel, size: 26),
                                                onTap: () {
                                                  setState(() {
                                                    isIncomeAdding = !isIncomeAdding;
                                                  });
                                                },
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 10),

                                          // BANKA HESABI SEÇİMİ
                                          if (bankAccounts.isEmpty)
                                          Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              color: Colors.redAccent.withOpacity(0.1),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Lütfen önce hesap ekleyin.",
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (bankAccounts.isNotEmpty)
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Banka Hesabı",
                                                    style: GoogleFonts.montserrat(
                                                        fontSize: 18, fontWeight: FontWeight.bold)),
                                                SizedBox(height: 10),
                                                DropdownButtonFormField<Map<String, dynamic>>(
                                                  value: selectedAccount,
                                                  decoration: InputDecoration(
                                                    labelText: "Hesap seç",
                                                    isDense: true,
                                                    contentPadding:
                                                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  items: bankAccounts.map((account) {
                                                    return DropdownMenuItem<Map<String, dynamic>>(
                                                      value: account,
                                                      child: Text(account['bankName']),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedAccount = value;
                                                    });
                                                  },
                                                ),
                                                SizedBox(height: 10),
                                              ],
                                            ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: CustomSlidingSegmentedControl<int>(
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20), color: Colors.red),
                                                  thumbDecoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20),
                                                      color: Colors.amber),
                                                  children: {
                                                    0: buildSegment('İş'),
                                                    1: buildSegment('Burs'),
                                                    2: buildSegment('Emekli'),
                                                  },
                                                  isStretch: true,
                                                  onValueChanged: (segmentControlGroupValue) {
                                                    setState(() {
                                                      this.segmentControlGroupValue = segmentControlGroupValue;
                                                      switch (segmentControlGroupValue) {
                                                        case 0:
                                                          newSelectedOption = "İş";
                                                          break;
                                                        case 1:
                                                          newSelectedOption = "Burs";
                                                          break;
                                                        case 2:
                                                          newSelectedOption = "Emekli";
                                                          break;
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Text("Gelir Miktarı",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 18, fontWeight: FontWeight.bold)),
                                          SizedBox(height: 10),
                                          GestureDetector(
                                            onTap: () {
                                              incomeController.selection = TextSelection.fromPosition(
                                                TextPosition(offset: incomeController.text.length),
                                              );
                                              focusNode.requestFocus();
                                              SystemChannels.textInput.invokeMethod('TextInput.show');
                                            },
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    maxLines: 1,
                                                    controller: incomeController,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      isDense: true,
                                                      fillColor: Colors.white,
                                                      contentPadding:
                                                      EdgeInsets.fromLTRB(10, 20, 20, 0),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                        borderSide:
                                                        BorderSide(color: Colors.amber, width: 3),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                        borderSide:
                                                        BorderSide(color: Colors.black, width: 3),
                                                      ),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      hintText: 'GAG',
                                                      hintStyle: TextStyle(color: Colors.black),
                                                    ),
                                                    keyboardType: TextInputType.number,
                                                  ),
                                                ),
                                                SizedBox(width: 20),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    final amount = double.tryParse(incomeController.text);

                                                    if (amount != null && amount > 0 && selectedAccount != null) {
                                                      // 1. Create a transaction record (like in your reference code)
                                                      final transaction = Transaction(
                                                        transactionId: DateTime.now().millisecondsSinceEpoch,
                                                        date: DateTime.now(), // or use a selected date if available
                                                        amount: amount,
                                                        installment: null,
                                                        currency: selectedAccount!['currency'] ?? 'USD', // or get from account
                                                        subcategory: newSelectedOption,
                                                        category: 'Income', // Explicitly set as income
                                                        title: 'Income', // or get from a title field if available
                                                        description: '',
                                                        isSurplus: true,
                                                        isFromInvoice: false,
                                                        initialInstallmentDate: null,
                                                      );

                                                      // 2. Add transaction to the account (will handle balance update)
                                                      await _addTransactionToAccount(selectedAccount!['id'], transaction);

                                                      // 3. Update incomeMap (if still needed for other purposes)
                                                      final prefs = await SharedPreferences.getInstance();
                                                      setState(() {
                                                        if (!incomeMap.containsKey(newSelectedOption)) {
                                                          incomeMap[newSelectedOption] = [];
                                                        }

                                                        incomeMap[newSelectedOption]!.add({
                                                          "amount": amount.toString(),
                                                          "account": selectedAccount!['bankName'],
                                                          "accountID": selectedAccount!['id'],
                                                          "transactionID": transaction.transactionId.toString(),
                                                          "day": DateTime.now().day,
                                                        });

                                                        prefs.setString('incomeMap', jsonEncode(incomeMap));
                                                        isIncomeAdding = false;
                                                        incomeController.clear();
                                                        _load(); // Refresh the UI
                                                      });
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text('Please enter a valid positive amount')),
                                                      );
                                                    }
                                                  },
                                                  child: Icon(Icons.check_circle, size: 26, color: Colors.black),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              )
                            )
                          ],
                        )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSegment(String text) => Padding(
        padding: EdgeInsets.all(5),
        child: Text(text,
            style: GoogleFonts.montserrat(
                fontSize: 14, fontWeight: FontWeight.bold)),
      );
}

double parseAmount(dynamic amount) {
  try {
    if (amount == null) return 0.0;

    String amountStr = amount.toString();

    // İlk olarak Türkçe formatta parse etmeye çalış
    return NumberFormat.decimalPattern('tr_TR').parse(amountStr).toDouble();
  } catch (e1) {
    try {
      // Olmazsa manuel düzeltme yap ve parse et
      final cleaned = amount.toString().replaceAll('.', '').replaceAll(',', '.');
      return double.parse(cleaned);
    } catch (e2) {
      print("Parse error: $e2 → value: $amount");
      return 0.0;
    }
  }
}


double parseTurkishDouble(String numberString) {
  // Create a NumberFormat instance for the Turkish locale
  final NumberFormat format = NumberFormat.decimalPattern('tr_TR');

  // Replace the comma with a dot for the decimal part
  String normalizedString = numberString.replaceAll('.', '').replaceAll(',', '.');

  // Parse the normalized string to a double
  return format.parse(normalizedString).toDouble();
}
