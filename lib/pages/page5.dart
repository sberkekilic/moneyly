import 'package:flutter/material.dart';
import 'package:moneyly/form-data-provider.dart';
import 'package:moneyly/pages/selection.dart';
import 'package:provider/provider.dart';

class Page5 extends StatefulWidget {
  const Page5({Key? key}) : super(key: key);

  @override
  State<Page5> createState() => _Page5State();
}

class _Page5State extends State<Page5> {
  @override
  Widget build(BuildContext context) {
    final page1 = Provider.of<IncomeSelections>(context, listen: false);
    final page2 = Provider.of<FormDataProvider>(context, listen: false);
    String itemListText = "";
    for (int i = 0; i<page2.itemList.length; i++){
      itemListText += "${page2.itemList[i]}, ${page2.pricesList[i]}";

    if (i < page2.itemList.length - 1){
      itemListText += "\n";
    }
    }
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(onPressed: () {
            Navigator.pushNamed(context, 'abonelikler');
          }, child: Text("Abonelikler")),
          Text("PAGE 1: GELİR TÜRÜ: ${page1.selectedOption}"),
          Text("PAGE 1: GELİR MİKTARI: ${page1.incomeValue}"),
          Text("PAGE 2: FİLM,DİZİ VE TV: \n$itemListText")
        ],
      ),
    );
  }
}
