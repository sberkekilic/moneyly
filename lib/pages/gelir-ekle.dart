import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'abonelikler.dart';
import 'selection.dart';

class AddIncome extends StatefulWidget {
  const AddIncome({Key? key}) : super(key: key);

  @override
  State<AddIncome> createState() => _AddIncomeState();
}

enum SelectedOption {
  None,
  Is,
  Burs,
  Emekli,
}

class _AddIncomeState extends State<AddIncome> {
  TextEditingController incomeController = TextEditingController();
  bool isDecimal = false;
  double inputValue = 0.0;
  SelectedOption selectedOption = SelectedOption.None;
  String selectedTitle = '';
  List<List<String>> numericButtons = [
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['1', '2', '3'],
    ['0', ',', 'OK'],
  ];

  int digitCount = 0;

  TextEditingController textController = TextEditingController();

  void goToPreviousPage() {
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage()),
      );
    });
  }

  void goToNextPage() {
    final selections = Provider.of<IncomeSelections>(context, listen: false);
    selections.setIncomeValue(incomeController.text);
    selections.setSelectedOption(selectedOption);
    GoRouter.of(context).push("/abonelikler");
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
                      GoRouter.of(context).replace("/");
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.black), // Replace with the desired left icon
                  ),
                  IconButton(
                    onPressed: () {
                      GoRouter.of(context).replace("/");
                    },
                    icon: Icon(Icons.clear, color: Colors.black), // Replace with the desired right icon
                  ),
                ],
              ),
              Text(
                "Gelir Ekle",
                style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.normal),
              ),
            ],
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: selectedOption != SelectedOption.None && incomeController.text.isNotEmpty ? Colors.black : Colors.grey ,
                      ),
                      clipBehavior: Clip.hardEdge,
                      onPressed: (selectedOption != SelectedOption.None && incomeController.text.isNotEmpty)
                          ? () async {
                        goToNextPage();
                      }
                          : null,
                      child: const Text(
                        'Next',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  color: Color(0xfff0f0f1),
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            InkWell(
                              onTap: (){
                                GoRouter.of(context).replace("/gelir-ekle");
                              },
                              splashColor: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 50,
                                width: (screenWidth-60) / 3,
                                child: Column(
                                  children: [
                                    Align(child: Text("Gelir", style: TextStyle(color: Color(0xff1ab738), fontSize: 15, fontWeight: FontWeight.bold)), alignment: Alignment.center),
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
                              splashColor: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 50,
                                width: (screenWidth-60) / 3,
                                child: Column(
                                  children: [
                                    Align(child: Text("Abonelikler", style: TextStyle(color: Color(0xffc6c6c7), fontSize: 15)), alignment: Alignment.center),
                                    SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        height: 8,
                                        width: (screenWidth-60) / 3,
                                        color: Color(0xffc6c6c7)
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            InkWell(
                              splashColor: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 50,
                                width: (screenWidth-60) / 3,
                                child: Column(
                                  children: [
                                    Align(child: Text("Faturalar", style: TextStyle(color: Color(0xffc6c6c7), fontSize: 15)), alignment: Alignment.center),
                                    SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        height: 8,
                                        width: (screenWidth-60) / 3,
                                        color: Color(
                                            0xffc6c6c7),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            InkWell(
                              splashColor: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 50,
                                width: (screenWidth-60) / 3,
                                child: Column(
                                  children: [
                                    Align(child: Text("Diğer Giderler", style: TextStyle(color: Color(
                                        0xffc6c6c7), fontSize: 15)), alignment: Alignment.center),
                                    SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        height: 8,
                                        width: (screenWidth-60) / 3,
                                        color: Color(
                                            0xffc6c6c7),
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
              ],
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
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text("Aylık gelir seçin", style: TextStyle(fontSize: 18),)
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 10),
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
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: selectableContainer(
                                      SelectedOption.Burs,
                                      'Burs',
                                      Icons.check_circle_outline,
                                    ),
                                  ),
                                  SizedBox(width: 10),
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
                            Visibility(
                              visible: selectedOption != SelectedOption.None,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      selectedTitle,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: incomeController,
                                          textAlign: TextAlign.right,
                                          readOnly: true,
                                          style: TextStyle(fontSize: 20),
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
                                                      incomeController.clear();
                                                      isDecimal = false;
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
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget selectableContainer(SelectedOption option, String label, IconData iconData) {
    bool isSelected = selectedOption == option;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = option;
          selectedTitle = "$label gelirinizi yazın";
        });
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: isSelected ? 4.0 : 2.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    iconData,
                    color: Colors.black,
                    size: 30,
                  )
              ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
          ]
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
          style: TextStyle(color: textColor, fontSize: 20),
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
          style: TextStyle(color: textColor, fontSize: 20),
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
