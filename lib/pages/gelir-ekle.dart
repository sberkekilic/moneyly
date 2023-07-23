import 'package:flutter/material.dart';
import 'package:moneyly/main.dart';
import 'package:moneyly/pages/abonelikler.dart';

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
  int? inputValue;
  SelectedOption selectedOption = SelectedOption.None;
  String selectedTitle = '';

  void goToPreviousPage() {
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    });
  }

  void goToNextPage() {
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Subscriptions()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gelir Ekle", style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.normal,)),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        leadingWidth: 30,
      ),
        bottomNavigationBar: BottomAppBar(
          height: 60,
          child: Row(
            children: [
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.navigate_before),
                  onPressed: goToPreviousPage,
                ),
              ),
              Text("Adım: 1"),
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.navigate_next),
                  onPressed: goToNextPage,
                ),
              ),
            ],
          ),
        ),
      body: Column(
        children: [
          Row(
            children: [
              Text("Aylık maaş seçin"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              selectableContainer(
                SelectedOption.Is,
                'İş',
                  Icons.check_circle_outline
              ),
              selectableContainer(
                SelectedOption.Burs,
                'Burs',
                Icons.check_circle_outline
              ),
              selectableContainer(
                SelectedOption.Emekli,
                'Emekli',
                  Icons.check_circle_outline
              ),
            ],
          ),
          Visibility(
            visible: selectedOption != SelectedOption.None,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(selectedTitle),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: Expanded(
                        child: Container(
                          width: 200,
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black,
                                  width: 2.0
                              )
                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: "...",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(10)
                            ),
                            onChanged: (value) {
                              inputValue = int.tryParse(value);
                            },
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      child: Text('Save'),
                      onPressed: () {
                        // Use the inputValue as needed
                        print('Input value: $inputValue');
                      },
                    ),
                  ],
                ),
              ],
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
        width: 125,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: isSelected ? 4.0 : 2.0,
          ),
          borderRadius: BorderRadius.circular(15.0),
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
}
