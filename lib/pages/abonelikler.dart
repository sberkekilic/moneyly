import 'package:flutter/material.dart';
import 'package:moneyly/pages/gelir-ekle.dart';

class Platform {
  final String name;
  final double price;
  Platform({required this.name, required this.price});
}

class Subscriptions extends StatefulWidget {
  const Subscriptions({Key? key}) : super(key: key);

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {
  List<Platform> platforms = [];
  List<String> itemList = [];
  TextEditingController _textEditingController = TextEditingController();
  TextEditingController textController = TextEditingController();
  TextEditingController platformNameController = TextEditingController();
  TextEditingController platformPriceController = TextEditingController();

  bool isTextFormFieldVisible = false;

  void addPlatform(String name, double price) {
    setState(() {
      platforms.add(Platform(name: name, price: price));
    });
  }

  void _addItem(String item) {
    setState(() {
      itemList.add(item);
    });
  }

  void addItem() {
    String text = textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        itemList.add(text);
        textController.clear();
        isTextFormFieldVisible = false; // Hide the TextFormField after adding the text
      });
    }
  }

  void goToPreviousPage() {
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddIncome()),
      );
    });
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yeni Metin Ekle'),
          content: TextFormField(
            controller: _textEditingController,
            decoration: InputDecoration(
              hintText: 'Metin giriniz',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String newItem = _textEditingController.text.trim();
                if (newItem.isNotEmpty) {
                  setState(() {
                    itemList.add(newItem);
                  });
                }
                _textEditingController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Ekle'),
            ),
            TextButton(
              onPressed: () {
                _textEditingController.clear();
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  void goToNextPage() {
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddIncome()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gider Ekle",
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.normal,
          ),
        ),
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
            Text("Adım: 2"),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Abonelikler"),
          Center(
            child: Container(
              width: 300,
              padding: EdgeInsets.all(8), // Adjust the outer padding of the container
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 5,
                ),
              ),
              child: Column(
                children: [
                  Text("Başlık"),
                  for (var item in itemList)
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 0), // Adjust the vertical spacing between items
                      child: Text(item, style: TextStyle(fontSize: 20),),
                    ),
                  if (isTextFormFieldVisible)
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 0),
                      child: ListTile(
                        title: TextFormField(
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: 'Metin giriniz',
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: addItem,
                          child: Text("Ekle"),
                        ),
                      ),
                    ),
                  if (!isTextFormFieldVisible)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isTextFormFieldVisible = true;
                        });
                      },
                      child: Text("Ekle"),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),

    );
  }
}
