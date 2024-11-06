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

class IncomePage extends StatefulWidget {
  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  Map<String, List<String>> incomeMap = {};
  Map<String, List<String>> summedIncomeMap = {};
  String selectedTitle = 'Toplam';
  String selectedKey = "";
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
    setState(() {
      sumInvestValue = ab3;
      if (ab2.isNotEmpty) {
        final decodedData = json.decode(ab2);
        if (decodedData is Map<String, dynamic>) {
          decodedData.forEach((key, value) {
            if (value is List<dynamic>) {
              incomeMap[key] = value.cast<String>();
            }
            if (incomeMap.containsKey(key) && incomeMap[key]!.isNotEmpty) {
              String valueToParse = '';
              if (incomeMap.containsKey(
                      selectedKey.isNotEmpty ? selectedKey : key) &&
                  incomeMap[selectedKey.isNotEmpty ? selectedKey : key]!
                      .isNotEmpty) {
                valueToParse =
                    incomeMap[selectedKey.isNotEmpty ? selectedKey : key]![0];
                incomeValue = NumberFormat.decimalPattern('tr_TR')
                    .parse(valueToParse) as double;
              } // Take the first (and only) string from the list
              selectedKey = key;
              double sum = 0.0;
              incomeMap.values.forEach((values) {
                values.forEach((value) {
                  double parsedValue = NumberFormat.decimalPattern('tr_TR')
                      .parse(value) as double;
                  sum += parsedValue;
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

      totalValues = incomeMap.values.fold<int>(
        0,
            (count, list) => count + list.length,
      );

      for (var key in incomeMap.keys) {
        double sum = 0.0;

        // Iterate over each value list for the current key
        for (var value in incomeMap[key]!) {
          double parsedValue = NumberFormat.decimalPattern('tr_TR').parse(value) as double;
          sum += parsedValue; // Sum the parsed values
        }

        // Store the sum as a string in the new map
        summedIncomeMap[key] = [NumberFormat.decimalPattern('tr_TR').format(sum)];
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
                        newValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(NumberFormat.decimalPattern('tr_TR')
                                .parse(newValue) as double);
                        incomeMap[key]![index] = newValue;

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

  bool isEditing = false;
  bool isIncomeAdding = false;
  final TextEditingController nameController = TextEditingController();
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
    List<String> workValue = incomeMap['İş'] ?? ['0'];
    List<String> scholarshipValue = incomeMap['Burs'] ?? ['0'];
    List<String> pensionValue = incomeMap['Emekli'] ?? ['0'];
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
          .map((value) =>
              NumberFormat.decimalPattern('tr_TR').parse(value) as double)
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
                  color: Colors.black,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
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
                            Container(
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
                                            fontWeight: FontWeight.bold)),
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
                                                        incomeMap[
                                                            newSelectedOption] = [
                                                          newName
                                                        ];
                                                      } else {
                                                        incomeMap[
                                                            newSelectedOption] = [
                                                          newName
                                                        ];
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
                                                      fontWeight:
                                                          FontWeight.bold)),
                                        ),
                                        SizedBox(width: 20.w),
                                        GestureDetector(
                                            onTap: isEditing
                                                ? () async {
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
                                                        incomeMap[
                                                            newSelectedOption] = [
                                                          newName
                                                        ];
                                                      } else {
                                                        incomeMap[
                                                            newSelectedOption] = [
                                                          newName
                                                        ];
                                                      }
                                                      prefs.setString(
                                                          'incomeMap',
                                                          jsonEncode(
                                                              incomeMap));
                                                      nameController.clear();
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
                                                ? Icon(Icons.done_rounded)
                                                : Icon(Icons.edit_rounded)),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    SizedBox(
                                      child: LinearPercentIndicator(
                                        padding: EdgeInsets.only(right: 10),
                                        backgroundColor: Color(0xffc6c6c7),
                                        animation: true,
                                        lineHeight: 10,
                                        animationDuration: 1000,
                                        percent: 1,
                                        trailing: Text("%100",
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
                                                        percent: (NumberFormat.decimalPattern('tr_TR').parse(entry.value[i]) as double) / incomeValue,
                                                        center: Text(
                                                          "%${(((NumberFormat.decimalPattern('tr_TR').parse(entry.value[i]) as double) / incomeValue) * 100).toStringAsFixed(0)}",
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
                                                              NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(parseTurkishDouble(entry.value[i])), // The specific income value, e.g., "25.000" or "200"
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
                                                              editIncome(entry.key, entry.value[i], i);
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
                                      padding: EdgeInsets.all(15),
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
                                        color:
                                        Color.fromARGB(120, 152, 255, 170),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Gelir Türü",
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 18,
                                                      fontWeight:
                                                      FontWeight.bold)),
                                              GestureDetector(
                                                child: Icon(Icons.cancel,
                                                    size: 26),
                                                onTap: () {
                                                  setState(() {
                                                    isIncomeAdding =
                                                    !isIncomeAdding;
                                                  });
                                                },
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child:
                                                CustomSlidingSegmentedControl<int>(
                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.red),
                                                  thumbDecoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.amber),
                                                  children: {
                                                    0: buildSegment('İş'),
                                                    1: buildSegment('Burs'),
                                                    2: buildSegment('Emekli'),
                                                  },
                                                  isStretch: true,
                                                  onValueChanged:
                                                      (segmentControlGroupValue) {
                                                    setState(() {
                                                      this.segmentControlGroupValue =
                                                          segmentControlGroupValue;
                                                      switch (
                                                      segmentControlGroupValue) {
                                                        case 0:
                                                          newSelectedOption =
                                                          "İş";
                                                          break;
                                                        case 1:
                                                          newSelectedOption =
                                                          "Burs";
                                                          break;
                                                        case 2:
                                                          newSelectedOption =
                                                          "Emekli";
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
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 10),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                setState(() {});
                                              });
                                              incomeController.selection =
                                                  TextSelection.fromPosition(
                                                    TextPosition(
                                                        offset: incomeController
                                                            .text.length),
                                                  );
                                              focusNode.requestFocus();
                                              SystemChannels.textInput
                                                  .invokeMethod(
                                                  'TextInput.show');
                                            },
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    maxLines: 1,
                                                    controller:
                                                    incomeController,
                                                    decoration: InputDecoration(
                                                        filled: true,
                                                        isDense: true,
                                                        fillColor: Colors.white,
                                                        contentPadding:
                                                        EdgeInsets.fromLTRB(
                                                            10, 20, 20, 0),
                                                        enabledBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(20),
                                                          borderSide:
                                                          BorderSide(
                                                              color: Colors
                                                                  .amber,
                                                              width: 3),
                                                        ),
                                                        focusedBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(20),
                                                          borderSide:
                                                          BorderSide(
                                                              color: Colors
                                                                  .black,
                                                              width: 3),
                                                        ),
                                                        border:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(20),
                                                        ),
                                                        hintText: 'GAG',
                                                        hintStyle: TextStyle(
                                                            color:
                                                            Colors.black)),
                                                    keyboardType:
                                                    TextInputType.number,
                                                  ),
                                                ),
                                                SizedBox(width: 20.w),
                                                ElevatedButton(
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    final prefs = await SharedPreferences.getInstance();
                                                    setState(() {
                                                      String newName = incomeController.text;
                                                      if (!incomeMap.containsKey(newSelectedOption)) {
                                                        incomeMap[newSelectedOption] = []; // Initialize the list if it doesn't exist
                                                      }
                                                      if (newName.isNotEmpty){
                                                        incomeMap[newSelectedOption]!.add(newName);
                                                        prefs.setString('incomeMap', jsonEncode(incomeMap));
                                                        isIncomeAdding = false;
                                                        incomeController.clear();
                                                        _load();
                                                      }
                                                    });
                                                  },
                                                  child: Icon(
                                                      Icons.check_circle,
                                                      size: 26,
                                                      color: Colors.black),
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

double parseTurkishDouble(String numberString) {
  // Create a NumberFormat instance for the Turkish locale
  final NumberFormat format = NumberFormat.decimalPattern('tr_TR');

  // Replace the comma with a dot for the decimal part
  String normalizedString = numberString.replaceAll('.', '').replaceAll(',', '.');

  // Parse the normalized string to a double
  return format.parse(normalizedString).toDouble();
}
