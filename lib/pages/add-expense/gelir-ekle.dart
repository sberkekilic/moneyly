import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyly/routes/routes.dart';
import 'package:number_text_input_formatter/number_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
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
  int? selectedDay;

  TextEditingController textController = TextEditingController();

  Map<String, List<Map<String, dynamic>>> incomeMap = {};

  Future<void> goToNextPage(BuildContext context, IncomeSelectionsBloc selections, SelectedOption selectedOption) async {
    final prefs = await SharedPreferences.getInstance();
    if (!incomeMap.containsKey(newSelectedTitle)) {
      incomeMap[newSelectedTitle] = []; // Initialize the list if it doesn't exist
    }

    // Add income value along with the day of the month
    incomeMap[newSelectedTitle]!.add({
      "amount": incomeController.text, // Convert input to double
      "day": selectedDay
    });

    await prefs.setString('incomeMap', jsonEncode(incomeMap));

    // Navigate to the next page
    context.go('/subs');
  }

  void handleButtonPress(String value) {
    print("VALUE: $value");
    setState(() {
      String currentText = incomeController.text;
      int cursorPosition = incomeController.selection.baseOffset;
      int commaIndex = currentText.indexOf(',');
      String integerPart = currentText.substring(0, commaIndex); // Integer part before the comma
      String decimalPart = currentText.substring(commaIndex + 1); // Decimal part after the comma
      print("currentText is $currentText and cursorPosition is $cursorPosition\nintegerPart is $integerPart and decimalPart is $decimalPart");

      // Handle comma for decimal separator
      if (value == ',') {
        // Insert comma at the correct position, either before or after the integer part
        currentText = currentText.substring(0, commaIndex) + ',' + currentText.substring(commaIndex + 1);
        cursorPosition = commaIndex+1;
      }
      // Clear button press (C)
      else if (value == 'C') {
        currentText = "0,00"; // Reset to "0,00"
        cursorPosition = 1; // Reset cursor position
      }
      // Handle backspace button (←)
      else if (value == '←') {
        if (decimalPart != "00"){
          // Delete from the decimal part
          if (decimalPart[1] != '0') {
            decimalPart = decimalPart[0] + '0'; // Replace last digit with '0'
            currentText = "$integerPart,$decimalPart";
            cursorPosition--;
          } else {
            decimalPart = '0' + '0';
            currentText = "$integerPart,$decimalPart";
            cursorPosition--;
          }
        } else {
          // If integer part is empty, set it to '0'
          if (integerPart.isEmpty) {
            print("integerPart.isEmpty");
            integerPart = '0';
            currentText = "$integerPart,$decimalPart";
          }
          // If there's only one digit left in the integer part, set it to '0'
          if (integerPart.length == 1) {
            print("integerPart.length == 1");
            integerPart = '0';
            currentText = "$integerPart,$decimalPart";
          }
          // Delete from the integer part
          if (integerPart.length > 1) {
            print("integerPart.length > 1");
            integerPart = integerPart.substring(0, integerPart.length - 1);
            integerPart = _formatIntegerPart(integerPart);
            currentText = "$integerPart,$decimalPart";
          }
        }
      }
      // Handle digit buttons (0-9)
      else {
        // If the currentText is "0,00" or empty, initialize it with the first number
        if (currentText == "0,00" || currentText.isEmpty) {
          currentText = "$value,00"; // Start with the pressed value and "00"
        } else {
          // Add the digit based on the cursor position
          if (integerPart.length > 0 && cursorPosition <= commaIndex) {
            // Insert the digit in the integer part
            integerPart += value;
            integerPart = _formatIntegerPart(integerPart);
          }
          if (cursorPosition == commaIndex+2){
            decimalPart = decimalPart.substring(0,1) + value;
            cursorPosition++;
          }
          if (cursorPosition == commaIndex+1){
            decimalPart = value + decimalPart.substring(1);
            cursorPosition++;
          }
          // Combine the integer and decimal parts
          currentText = "$integerPart,$decimalPart";
        }
      }

      // Ensure the cursor position is within bounds
      cursorPosition = cursorPosition.clamp(0, currentText.length);
      // Update the controller with the new value and set the cursor position
      incomeController.text = currentText;
      if (currentText == "0,00"){
      cursorPosition = 1;
      }
      incomeController.selection = TextSelection.collapsed(offset: cursorPosition);
    });
  }
  String _formatIntegerPart(String integerPart) {
    if (integerPart.isEmpty || integerPart == "0") return "0";

    // Remove any existing dots to start with a clean number
    integerPart = integerPart.replaceAll('.', '');

    // Format the integer part with dots for thousands
    StringBuffer buffer = StringBuffer();
    int count = 0;

    for (int i = integerPart.length - 1; i >= 0; i--) {
      buffer.write(integerPart[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.'); // Add dot every 3 digits from the right
      }
    }

    // Reverse the result to get the correct order
    return buffer.toString().split('').reversed.join('');
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
  Widget selectableContainer(SelectedOption option, String label, IconData iconData) {
    return BlocBuilder<IncomeSelectionsBloc, IncomeSelectionsState>(
      builder: (context, state) {
        final selectedOption = (state is IncomeSelectionsLoaded)
            ? state.selectedOption
            : SelectedOption.None;
        bool isSelected = selectedOption == option;

        // Directly compute selectedTitle based on the current state
        String selectedTitle = labelForOption(selectedOption);

        return GestureDetector(
          onTap: () {
            context.read<IncomeSelectionsBloc>().add(SetOptionAndValue(option, 'New Value'));
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

  @override
  void initState() {
    super.initState();
    _loadSelectedOption();
  }

  Future<void> _loadSelectedOption() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('selected_option') ?? SelectedOption.None.index;
    final loadedIncomeData = prefs.getString('incomeMap') ?? '';

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
    if (loadedIncomeData!.isNotEmpty) {
      Map<String, dynamic> decodedData = json.decode(loadedIncomeData);
      if (decodedData.containsKey(newSelectedTitle)) {
        List<dynamic> incomeList = decodedData[newSelectedTitle];
        if (incomeList.isNotEmpty){
          Map<String, dynamic> firstIncomeItem = incomeList[0];
          String amount = firstIncomeItem['amount'];
          incomeController.text = amount;
          if (firstIncomeItem.containsKey('day')) {
            selectedDay = firstIncomeItem['day'];
          }
        } else {
          incomeController.text = "0,00";
        }
      } else {
        incomeController.text = "0,00";
      }
    } else{
      incomeController.text = "0,00";
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
                                        "Ayın hangi günü?",
                                        style: TextStyle(
                                          fontFamily: 'Keep Calm',
                                          fontSize: 16.sp,
                                        )
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  PullDownButton(
                                    itemBuilder: (context) {
                                      return List.generate(31, (index) {
                                        int day = index + 1;
                                        return PullDownMenuItem(
                                          title: 'Day $day',
                                          onTap: () {
                                            setState(() {
                                              selectedDay = day;
                                            });
                                          },
                                        );
                                      });
                                    },
                                    buttonBuilder: (context, showMenu) => TextButton(
                                      onPressed: showMenu,
                                      child: Text(
                                        selectedDay != null ? "Selected Day: $selectedDay" : "Select a Day",
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        state is IncomeSelectionsLoaded ? state.selectedTitle : '',
                                        style: TextStyle(
                                          fontFamily: 'Keep Calm',
                                          fontSize: 16.sp,
                                        )
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                  IntrinsicHeight(
                                    child: TextFormField(
                                      readOnly: true,
                                      controller: incomeController,
                                      textAlign: TextAlign.right,
                                      style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.bold),
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
                                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                                        suffixIcon:  Container(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(width: 10),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  minimumSize: Size((screenWidth - 60) / 3, 50),
                                                  backgroundColor: Colors.black,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                child: Icon(Icons.clear),
                                                onPressed: () {
                                                  setState(() {
                                                    handleButtonPress('C');
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 50,
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
        onPressed: () => handleButtonPress('←'),
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
