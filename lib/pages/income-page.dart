import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/pages/selection.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({Key? key}) : super(key: key);

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  Map<String, List<String>> incomeMap = {};
  String selectedTitle = '';
  String selectedKey = "";
  String newSelectedOption = "";
  double incomeValue = 0.0;
  String formattedIncomeValue = "";
  String formattedSavingsValue = "";
  String formattedWishesValue = "";
  String formattedNeedsValue = "";
  int? segmentControlGroupValue = 0;

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
    final ab4 = prefs.getDouble('totalInvestValue') ?? 0.0;
    setState(() {
      selectedTitle = labelForOption(SelectedOption.values[ab1]);
      sumInvestValue = ab3;
      totalInvestValue = ab4;
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
                incomeValue = NumberFormat.decimalPattern('tr_TR').parse(
                    valueToParse) as double;
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
                        newValue = NumberFormat.currency(
                            locale: 'tr_TR', symbol: '', decimalDigits: 2)
                            .format(NumberFormat.decimalPattern('tr_TR').parse(
                            newValue) as double);
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
                                  Navigator.of(context).pop(
                                      false); // Don't delete
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(
                                      true); // Confirm deletion
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        // Remove the old value at the specified index
                        incomeMap[key]!.removeAt(index);
                        if (incomeMap[key]!.isEmpty) {
                          incomeMap.remove(key);
                        }
                        setState(() {
                          // Save the modified incomeMap to SharedPreferences
                          prefs.setString('incomeMap', jsonEncode(incomeMap));
                        });
                        Navigator.of(context).pop(); // Close the dialog
                        _load();
                      }
                    },
                    child: Text('Delete'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
    int totalValues = incomeMap.values.fold<int>(
      0,
          (count, list) => count + list.length,
    );
    sumOfSavingValue = sumInvestValue.isNaN ? 0.0 : sumInvestValue;
    savingsValue = totalInvestValue.isNaN ? 0.0 : totalInvestValue;
    result = (savingsValue == 0.0) ? 0.0 : sumOfSavingValue / savingsValue;
    formattedsavingsValue =
        NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2)
            .format(savingsValue);
    formattedSumOfSavingValue =
        NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2)
            .format(sumOfSavingValue);
    savingsValue = incomeValue * 0.2;
    formattedIncomeValue =
        NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2)
            .format(incomeValue);
    formattedSavingsValue =
        NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2)
            .format(savingsValue);
    nameController.text = formattedIncomeValue;
    String firstKey = "";
    List<double> valuesOfFirstKey = [];
    double sumOfFirstKey = 0.0;
    String formattedValueOfFirstKey = "";
    if (incomeMap.keys.isNotEmpty) {
      firstKey = incomeMap.keys.first;
      valuesOfFirstKey =
          incomeMap[firstKey]!.map((value) => NumberFormat.decimalPattern(
              'tr_TR').parse(value) as double).toList();
      sumOfFirstKey =
          valuesOfFirstKey.reduce((value, accumulator) => value + accumulator);
      formattedValueOfFirstKey =
          NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2)
              .format(sumOfFirstKey);
    }
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
                  icon: Icon(Icons.settings, color: Colors
                      .black), // Replace with the desired left icon
                ),
                IconButton(
                  onPressed: () {

                  },
                  icon: Icon(Icons.person, color: Colors
                      .black), // Replace with the desired right icon
                ),
              ],
            ),
            Text(
              "Eylül 2023",
              style: GoogleFonts.montserrat(color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Gelirler Detayı", style: GoogleFonts.montserrat(
                  fontSize: 22, fontWeight: FontWeight.bold)),
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
                  child: (incomeMap[selectedTitle] != null &&
                      totalValues == 1) ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("$selectedTitle Geliri",
                          style: GoogleFonts.montserrat(
                              fontSize: 21, fontWeight: FontWeight.bold)),
                      Text("$incomeMap"),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            setState(() {
                              isEditing = !isEditing;
                            });
                          });
                          nameController.selection = TextSelection.fromPosition(
                            TextPosition(offset: nameController.text.length),
                          );
                          focusNode.requestFocus();
                          SystemChannels.textInput.invokeMethod(
                              'TextInput.show');
                        },
                        child: SizedBox(
                          width: double.maxFinite,
                          child: isEditing
                              ? EditableText(
                            controller: nameController,
                            focusNode: focusNode,
                            style: GoogleFonts.montserrat(fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            cursorColor: Colors.black,
                            backgroundCursorColor: Colors.black,
                            keyboardType: TextInputType.text,
                            onChanged: (newName) {
                              // You can update the name in real-time if needed
                            },
                            onEditingComplete: () async {
                              final prefs = await SharedPreferences
                                  .getInstance();
                              setState(() {
                                String newName = nameController.text;
                                if (incomeValue != newName) {
                                  prefs.setString('income_value', newName);
                                }
                                isEditing = false;
                                _load();
                              });
                            },
                          )
                              : Text(formattedIncomeValue, style: GoogleFonts
                              .montserrat(
                              fontSize: 25, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      SizedBox(
                        child: LinearPercentIndicator(
                          padding: EdgeInsets.only(right: 10),
                          backgroundColor: Color(0xffc6c6c7),
                          animation: true,
                          lineHeight: 10,
                          animationDuration: 1000,
                          percent: 1,
                          trailing: Text("%100", style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                          barRadius: Radius.circular(10),
                          progressColor: Colors.lightBlue,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text("Başka geliriniz bulunmamaktadır.",
                          style: GoogleFonts.montserrat(
                              fontSize: 16, fontWeight: FontWeight.normal)),
                      Divider(
                          color: Color(0xffc6c6c7), thickness: 2, height: 30),
                      if(!isIncomeAdding)
                        SizedBox(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text("Gelir Ekle",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  IconButton(
                                      onPressed: () async {
                                        setState(() {
                                          isIncomeAdding = true;
                                        });
                                      },
                                      icon: Icon(Icons.add_circle)
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      if(isIncomeAdding)
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Gelir Türü", style: GoogleFonts.montserrat(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: CupertinoSlidingSegmentedControl<int>(
                                      groupValue: segmentControlGroupValue,
                                      children: {
                                        0: buildSegment('İş'),
                                        1: buildSegment('Burs'),
                                        2: buildSegment('Emekli'),
                                      },
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
                                  style: GoogleFonts.montserrat(fontSize: 18,
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
                                            offset: incomeController.text
                                                .length),
                                      );
                                  focusNode.requestFocus();
                                  SystemChannels.textInput.invokeMethod(
                                      'TextInput.show');
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 3.0,
                                    ),
                                  ),
                                  child: EditableText(
                                    controller: incomeController,
                                    focusNode: focusNode,
                                    style: GoogleFonts.montserrat(fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    cursorColor: Colors.black,
                                    backgroundCursorColor: Colors.black,
                                    keyboardType: TextInputType.text,
                                    onChanged: (newName) {
                                      // You can update the name in real-time if needed
                                    },
                                    onEditingComplete: () async {
                                      final prefs = await SharedPreferences
                                          .getInstance();
                                      setState(() {
                                        String newName = incomeController.text;
                                        if (!incomeMap.containsKey(
                                            newSelectedOption)) {
                                          incomeMap[newSelectedOption] = [
                                          ]; // Initialize the list if it doesn't exist
                                        }
                                        incomeMap[newSelectedOption]!.add(
                                            newName);
                                        prefs.setString(
                                            'incomeMap', jsonEncode(incomeMap));
                                        isIncomeAdding = false;
                                        _load();
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                    ],
                  ) : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tüm Gelir", style: GoogleFonts.montserrat(
                          fontSize: 19, fontWeight: FontWeight.bold)),
                      Text("$incomeMap"),
                      SizedBox(height: 10),
                      Text(formattedIncomeValue, style: GoogleFonts.montserrat(
                          fontSize: 25, fontWeight: FontWeight.bold)),
                      Divider(
                          color: Color(0xffc6c6c7), thickness: 2, height: 30),
                      if(!isIncomeAdding)
                        SizedBox(
                          child: Column(
                            children: [
                              ListView(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                // Prevent scrolling of the inner ListView
                                children: incomeMap.keys.expand((key) {
                                  final values = incomeMap[key];
                                  List<Widget> valueWidgets = [];
                                  for (int i = 0; i < values!.length; i++) {
                                    double doubledValue = NumberFormat
                                        .decimalPattern('tr_TR').parse(
                                        values[i]) as double;
                                    String formattedValue = NumberFormat
                                        .currency(locale: 'tr_TR',
                                        symbol: '',
                                        decimalDigits: 2).format(doubledValue);
                                    valueWidgets.add(
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              CircularPercentIndicator(
                                                radius: 30,
                                                lineWidth: 7.0,
                                                percent: doubledValue /
                                                    incomeValue,
                                                center: Text(
                                                    "%${((doubledValue /
                                                        incomeValue) * 100)
                                                        .toStringAsFixed(0)}",
                                                    style: GoogleFonts
                                                        .montserrat(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight
                                                            .w600)),
                                                progressColor: Colors.blue,
                                              ),
                                              const SizedBox(width: 10),
                                              Flexible(
                                                flex: 2,
                                                fit: FlexFit.tight,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    Text(key, style: GoogleFonts
                                                        .montserrat(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight
                                                            .w600)),
                                                    Text(
                                                        "$formattedValue / $formattedIncomeValue",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                            color: Colors.black,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight
                                                                .w600))
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
                                                        editIncome(key,
                                                            formattedValue, i);
                                                      });
                                                    },
                                                    icon: Icon(Icons.edit)
                                                ),
                                              )
                                            ],
                                          ),
                                          const Divider(
                                              color: Color(0xffc6c6c7),
                                              thickness: 2,
                                              height: 30),
                                        ],
                                      ),
                                    );
                                  }

                                  return valueWidgets;
                                }).toList(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text("Gelir Ekle",
                                      style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  IconButton(
                                      onPressed: () async {
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        setState(() {
                                          isIncomeAdding = true;
                                        });
                                      },
                                      icon: Icon(Icons.add_circle)
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      if(isIncomeAdding)
                        SizedBox(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly,
                                children: [
                                  Container(
                                    child: TextButton(
                                      child: Text("İş"),
                                      onPressed: () {
                                        setState(() {
                                          newSelectedOption = "İş";
                                        });
                                      },
                                    ),
                                  ),
                                  Container(
                                    child: TextButton(
                                      child: Text("Burs"),
                                      onPressed: () {
                                        setState(() {
                                          newSelectedOption = "Burs";
                                        });
                                      },
                                    ),
                                  ),
                                  Container(
                                    child: TextButton(
                                      child: Text("Emekli"),
                                      onPressed: () {
                                        setState(() {
                                          newSelectedOption = "Emekli";
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    setState(() {});
                                  });
                                  incomeController.selection =
                                      TextSelection.fromPosition(
                                        TextPosition(
                                            offset: incomeController.text
                                                .length),
                                      );
                                  focusNode.requestFocus();
                                  SystemChannels.textInput.invokeMethod(
                                      'TextInput.show');
                                },
                                child: EditableText(
                                  controller: incomeController,
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
                                  onEditingComplete: () async {
                                    final prefs = await SharedPreferences
                                        .getInstance();
                                    setState(() {
                                      String newName = incomeController.text;
                                      if (!incomeMap.containsKey(
                                          newSelectedOption)) {
                                        incomeMap[newSelectedOption] = [
                                        ]; // Initialize the list if it doesn't exist
                                      }
                                      incomeMap[newSelectedOption]!.add(
                                          newName);
                                      prefs.setString(
                                          'incomeMap', jsonEncode(incomeMap));
                                      isIncomeAdding = false;
                                      _load();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                    ],
                  )
              ),
              SizedBox(height: 20),
              Text("Birikim", style: GoogleFonts.montserrat(
                  fontSize: 22, fontWeight: FontWeight.bold)),
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
                    Text("Birikim Hedefi", style: GoogleFonts.montserrat(
                        fontSize: 19, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("$formattedSumOfSavingValue / $formattedsavingsValue",
                        style: GoogleFonts.montserrat(
                            fontSize: 19, fontWeight: FontWeight.bold)),
                    SizedBox(
                      child: LinearPercentIndicator(
                        padding: EdgeInsets.only(right: 10),
                        backgroundColor: Color(0xffc6c6c7),
                        animation: true,
                        lineHeight: 10,
                        animationDuration: 1000,
                        percent: result,
                        trailing: Text("%${((result) * 100).toStringAsFixed(
                            0)}", style: GoogleFonts.montserrat(color: Colors
                            .black, fontSize: 16, fontWeight: FontWeight.w600)),
                        barRadius: Radius.circular(10),
                        progressColor: Colors.lightBlue,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text("Birikimlerinizi buraya ekleyin.",
                        style: GoogleFonts.montserrat(
                            fontSize: 14, fontWeight: FontWeight.normal)),
                    Divider(color: Color(0xffc6c6c7), thickness: 2, height: 30),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, 'investment-page');
                      },
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Yatırım Sayfasına Git", style: GoogleFonts
                                .montserrat(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
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
              currentIndex: 1,
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
                  icon: Padding(
                    padding: EdgeInsets.only(left: 5,right: 5),
                    child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100, // Background color
                          borderRadius: BorderRadius.circular(20), // Rounded corners
                        ),
                        child: Icon(Icons.attach_money_sharp, size: 30)
                    ),
                  ),
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
                    padding: const EdgeInsets.only(top: 5,bottom: 5),
                    child: Icon(FontAwesome.bank, size: 20),
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

  Widget buildSegment(String text) => Container(
        padding: EdgeInsets.all(10),
        child: Text(
            text,
            style: GoogleFonts.montserrat(
                fontSize: 18, fontWeight: FontWeight.bold)
        ),
      );
}