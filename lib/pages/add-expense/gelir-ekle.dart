import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyly/routes/routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../blocs/income-selections.dart';

class AddIncome extends StatefulWidget {
  const AddIncome({Key? key}) : super(key: key);

  @override
  State<AddIncome> createState() => _AddIncomeState();
}

class _AddIncomeState extends State<AddIncome> {
  TextEditingController incomeController = TextEditingController();
  SelectedOption selectedOption = SelectedOption.None;
  IncomeSelectionsBloc selections = IncomeSelectionsBloc();
  bool isDecimal = false;
  double inputValue = 0.0;
  String selectedTitle = '';
  String newSelectedTitle = '';
  List<List<String>> numericButtons = [
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['1', '2', '3'],
    ['0', ',', 'OK'],
  ];

  int digitCount = 0;

  TextEditingController textController = TextEditingController();

  Map<String, List<String>> incomeMap = {};

  Future<void> goToNextPage(BuildContext context, IncomeSelectionsBloc selections, SelectedOption selectedOption) async {
    final prefs = await SharedPreferences.getInstance();
    if (!incomeMap.containsKey(newSelectedTitle)) {
      incomeMap[newSelectedTitle] = []; // Initialize the list if it doesn't exist
    }
    incomeMap[newSelectedTitle]!.add(incomeController.text);
    prefs.setString('incomeMap', jsonEncode(incomeMap));

    // Navigate to the next page
    context.go('/subs');
  }
  void handleButtonPress(String value) {
    setState(() {
      if (value == ',') {
        if (!isDecimal) {
          incomeController.text += ',';
          isDecimal = true;
        }
      } else if (value == 'C') {
        incomeController.clear();
        isDecimal = false;
      } else if (value == '←' || value == '') { // Compare with empty string for backspace
        if (incomeController.text.isNotEmpty) {
          final currentText = incomeController.text;
          final textWithoutDots = currentText.replaceAll('.', '');

          if (textWithoutDots.isEmpty) {
            incomeController.clear();
            isDecimal = false;
          } else if (incomeController.text.contains(',')) {
            final newText = currentText.substring(0, currentText.length - 1);
            incomeController.text = formatNumber(newText);
          } else {
            final newText = textWithoutDots.substring(0, textWithoutDots.length - 1);
            incomeController.text = formatNumber(newText);
          }

          if (incomeController.text.endsWith(',')) {
            isDecimal = false;
          }
        }
      } else {
        final currentText = incomeController.text;
        final parts = currentText.split(',');
        final wholePart = parts[0];
        int wholePartLength = wholePart.replaceAll('.', '').length;
        final decimalPart = parts.length > 1 ? parts[1] : '';

        if (isDecimal && decimalPart.length <= 9 - wholePartLength && (wholePartLength + decimalPart.length + value.length) <= 9) {
          incomeController.text = formatNumber('$wholePart,$decimalPart$value');
          print(parts);
          print("${decimalPart.length} decimal");
          print("${wholePartLength} whole");
          print("${(wholePart + decimalPart).length} sum");
          print(isDecimal);
        } else {
          print(parts);
          print(isDecimal);
          final textWithoutDots = incomeController.text.replaceAll('.', '');

          if (textWithoutDots.isEmpty || textWithoutDots == '0') {
            incomeController.clear();
          }

          if (textWithoutDots.length < 9) {
            incomeController.text = formatNumber(textWithoutDots + value);
          }
        }
      }
    });
  }
  String formatNumber(String value) {
    final numericValue = int.tryParse(value);
    if (numericValue == null) {
      return value;
    }

    final formattedValue = numericValue.toString();
    final length = formattedValue.length;
    final segments = <String>[];

    for (var i = length; i > 0; i -= 3) {
      final startIndex = i - 3 > 0 ? i - 3 : 0;
      segments.insert(0, formattedValue.substring(startIndex, i));
    }

    return segments.join('.');
  }
  String labelForOption(SelectedOption option) {
    switch (option) {
      case SelectedOption.Is:
        newSelectedTitle = "İş";
        return 'İş gelirinizi yazın';
      case SelectedOption.Burs:
        newSelectedTitle = "Burs";
        return 'Burs gelirinizi yazın';
      case SelectedOption.Emekli:
        newSelectedTitle = "Emekli";
        return 'Emekli gelirinizi yazın';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedOption();
  }

  Future<void> _loadSelectedOption() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('selected_option') ?? SelectedOption.None.index;
    final loadedIncomeData = prefs.getString('incomeMap') ?? "{}";

    final bloc = context.read<IncomeSelectionsBloc>();
    bloc.add(LoadSelectedOption(SelectedOption.values[index]));

    // Wait for the IncomeSelectionsLoaded state
    await for (final state in bloc.stream) {
      if (state is IncomeSelectionsLoaded) {
        selectedOption = state.selectedOption;
        break; // Exit the loop when the correct state is found
      }
    }

    // Set the title based on the selected option
    selectedTitle = labelForOption(selectedOption);
    if (loadedIncomeData.isNotEmpty) {
      Map<String, dynamic> decodedData = json.decode(loadedIncomeData);
      if (decodedData.containsKey(newSelectedTitle)) {
        incomeController.text = decodedData[newSelectedTitle].join(', ');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff0f0f1),
        elevation: 0,
        toolbarHeight: 60.h,
        automaticallyImplyLeading: false,
        leadingWidth: 30.w,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                "Gelir Ekle",
                style: TextStyle(
                    fontFamily: 'Keep Calm',
                    color: Colors.black,
                    fontSize: 28.sp
                )
            ),
            Text(
                "1/4",
                style: TextStyle(
                    fontFamily: 'Keep Calm',
                    color: Colors.black,
                    fontSize: 24.sp
                )
            ),
          ],
        ),
      ),
      body: Container(
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                              "Aylık gelir seçin",
                              style: TextStyle(
                                fontFamily: 'Keep Calm',
                                fontSize: 16.sp,
                              )
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: selectableContainer(
                                SelectedOption.Is,
                                'İş',
                                Icons.check_circle_outline,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: selectableContainer(
                                SelectedOption.Burs,
                                'Burs',
                                Icons.check_circle_outline,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: selectableContainer(
                                SelectedOption.Emekli,
                                'Emekli',
                                Icons.check_circle_outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      BlocBuilder<IncomeSelectionsBloc,IncomeSelectionsState>(
                          builder: (context, state) {
                            return Visibility(
                              visible: state is IncomeSelectionsLoaded && state.selectedOption != SelectedOption.None,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        selectedTitle,
                                        style: TextStyle(
                                          fontFamily: 'Keep Calm',
                                          fontSize: 16.sp,
                                        )
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: incomeController,
                                          textAlign: TextAlign.right,
                                          readOnly: true,
                                          style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(color: Colors.black, width: 4, style: BorderStyle.solid),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(color: Colors.black, width: 3, style: BorderStyle.solid),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(color: Colors.black, width: 3, style: BorderStyle.solid),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                                            suffixIcon: Container(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(width: 20),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      minimumSize: Size((screenWidth - 60) / 3, 45),
                                                      backgroundColor: Colors.black,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                    child: Icon(Icons.clear),
                                                    onPressed: () {
                                                      setState(() {
                                                        incomeController.clear();
                                                        isDecimal = false;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildNumberButton('1'),
                                      buildNumberButton('2'),
                                      buildNumberButton('3'),
                                    ],
                                  ),
                                  SizedBox(height: 7),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildNumberButton('4'),
                                      buildNumberButton('5'),
                                      buildNumberButton('6'),
                                    ],
                                  ),
                                  SizedBox(height: 7),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildNumberButton('7'),
                                      buildNumberButton('8'),
                                      buildNumberButton('9'),
                                    ],
                                  ),
                                  SizedBox(height: 7),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildNumberComa(','),
                                      buildNumberButton('0'),
                                      buildNumberIcon(Icon(Icons.backspace), textColor: Colors.blue),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    color: Colors.white,
                    child: BlocBuilder<IncomeSelectionsBloc, IncomeSelectionsState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: state is IncomeSelectionsLoaded && state.selectedOption != SelectedOption.None && incomeController.text.isNotEmpty ? Colors.black : Colors.grey ,
                          ),
                          clipBehavior: Clip.hardEdge,
                          onPressed: (state is IncomeSelectionsLoaded && state.selectedOption != SelectedOption.None && incomeController.text.isNotEmpty)
                              ? () async {
                            goToNextPage(context, selections, selectedOption);
                          }
                              : null,
                          child: Text(
                              'Sonraki',
                              style: TextStyle(
                                  fontFamily: 'Keep Calm',
                                  fontSize: 18.sp
                              )
                          ),
                        );
                      },

                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget selectableContainer(SelectedOption option, String label, IconData iconData) {
    return BlocBuilder<IncomeSelectionsBloc, IncomeSelectionsState>(
      builder: (context, state) {
        final selectedOption = (state is IncomeSelectionsLoaded)
            ? state.selectedOption
            : SelectedOption.None;
        bool isSelected = selectedOption == option;
        selectedTitle = labelForOption(selectedOption);
        print('newSelectedTitle: $newSelectedTitle');
        return GestureDetector(
          onTap: () {
            context.read<IncomeSelectionsBloc>().add(SetSelectedOption(option));
            context.read<IncomeSelectionsBloc>().add(SetIncomeValue('New Value'));
          },
          child: Container(
            height: 140.0, // Adjust according to your needs
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.white,
              border: Border.all(
                color: Colors.black,
                width: isSelected ? 4.0 : 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Keep Calm',
                      fontSize: isSelected ? 18.0 : 15.0, // Adjust according to your needs
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget buildNumberButton(String value, {Color textColor = Colors.black}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 50,
      child: ElevatedButton(
        onPressed: () => handleButtonPress(value),
        style: ElevatedButton.styleFrom(
            minimumSize: Size((screenWidth - 60) / 3, 45),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.black, width: 3)
            )
        ),
        child: Text(
            value,
            style: TextStyle(
                fontFamily: 'Keep Calm',
                fontSize: 15.sp,
                color: textColor
            )
        ),
      ),
    );
  }
  Widget buildNumberComa(String value, {Color textColor = Colors.white}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 50,
      child: ElevatedButton(
        onPressed: () => handleButtonPress(value),
        style: ElevatedButton.styleFrom(
            minimumSize: Size((screenWidth - 60) / 3, 45),
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.black, width: 3)
            )
        ),
        child: Text(
            value,
            style: TextStyle(
                fontFamily: 'Keep Calm',
                fontSize: 15.sp,
                color: textColor
            )
        ),
      ),
    );
  }
  Widget buildNumberIcon(Widget icon, {Color textColor = Colors.black}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 50,
      child: ElevatedButton(
        onPressed: () => handleButtonPress(icon == Icon(Icons.backspace) ? '←' : ''),
        style: ElevatedButton.styleFrom(
            minimumSize: Size((screenWidth - 60) / 3, 45),
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
            )
        ),
        child: icon,
      ),
    );
  }
}
