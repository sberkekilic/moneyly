import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/form-data-provider.dart';
import 'package:moneyly/pages/selection.dart';
import 'package:provider/provider.dart';

import 'gelir-ekle.dart';

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

    double incomeValue = NumberFormat.decimalPattern('tr_TR').parse(page1.incomeValue) as double;
    double subsValue = NumberFormat.decimalPattern('tr_TR').parse(page2.sumOfPrices) as double;
    double subsPercent = (subsValue / incomeValue) * 100;
    double savingsValue = incomeValue * 0.2;
    double wantsNeedsValue = incomeValue * 0.3;
    double alimentValue = incomeValue * 0.5;
    String formattedSavingsValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(savingsValue);
    String formattedWantsNeedsValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(wantsNeedsValue);
    String formattedAlimentValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(alimentValue);
    String notCalculatedValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(incomeValue);


    String itemListText = "";
    String itemListTextHomeBills = "";
    for (int i = 0; i<page2.itemList.length; i++){
      itemListText += "${page2.itemList[i]}, ${page2.pricesList[i]}";

    if (i < page2.itemList.length - 1){
      itemListText += "\n";
    }
    }
    for (int i = 0; i<page2.itemListHomeBills.length; i++){
      itemListTextHomeBills += "${page2.itemListHomeBills[i]}, ${page2.pricesListHomeBills[i]}";

      if (i < page2.itemListHomeBills.length - 1){
        itemListTextHomeBills += "\n";
      }

    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 50, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Aylık Rapor", style: TextStyle(fontSize: 36),),
            SizedBox(height: 50),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Gelir", style: TextStyle(fontSize: 31)),
                  Text("${notCalculatedValue}",style: TextStyle(fontSize: 25)),
                  if (page1.selectedOption == SelectedOption.Is)
                    Row(
                      children: [
                        Text("İş geliri",style: TextStyle(fontSize: 16)),
                        SizedBox(width: 50),
                        Text("${page1.incomeValue}",style: TextStyle(fontSize: 16)),
                        SizedBox(width: 50),
                        Text("%100",style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  if (page1.selectedOption == SelectedOption.Burs)
                    Row(
                      children: [
                        Text("Burs geliri",style: TextStyle(fontSize: 16)),
                        SizedBox(width: 50),
                        Text("${page1.incomeValue}",style: TextStyle(fontSize: 16)),
                        SizedBox(width: 50),
                        Text("%100",style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  if (page1.selectedOption == SelectedOption.Emekli)
                    Row(
                      children: [
                        Flexible(
                            flex: 3,
                            fit: FlexFit.tight,
                            child: Text(
                                "Emekli geliri",
                                style: TextStyle(fontSize: 16))
                        ),
                        Flexible(
                            flex: 3,
                            fit: FlexFit.tight,
                            child: Text(
                                notCalculatedValue,
                                style: TextStyle(fontSize: 16), textAlign: TextAlign.right)
                        ),
                        Flexible(
                            flex: 3,
                            fit: FlexFit.tight,
                            child: Text(
                                "%100.00",
                                style: TextStyle(
                                    fontSize: 16), textAlign: TextAlign.right)
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("Birikim",style: TextStyle(fontSize: 16),)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text(formattedSavingsValue,style: TextStyle(fontSize: 16), textAlign: TextAlign.right,)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("%20.00",style: TextStyle(fontSize: 16),textAlign: TextAlign.right)),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("İstekler",style: TextStyle(fontSize: 16),)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text(formattedWantsNeedsValue,style: TextStyle(fontSize: 16), textAlign: TextAlign.right,)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("%30.00",style: TextStyle(fontSize: 16),textAlign: TextAlign.right)),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("İhtiyaçlar",style: TextStyle(fontSize: 16),)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text(formattedAlimentValue,style: TextStyle(fontSize: 16), textAlign: TextAlign.right,)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("%50.00",style: TextStyle(fontSize: 16),textAlign: TextAlign.right)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Gider", style: TextStyle(fontSize: 31)),
                  Text("${notCalculatedValue}",style: TextStyle(fontSize: 25)),
                  Row(
                    children: [
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("Abonelikler",style: TextStyle(fontSize: 16),)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text(page2.sumOfPrices,style: TextStyle(fontSize: 16), textAlign: TextAlign.right,)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("%${subsPercent.toStringAsFixed(2)}",style: TextStyle(fontSize: 16),textAlign: TextAlign.right)),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("İstekler",style: TextStyle(fontSize: 16),)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text(formattedWantsNeedsValue,style: TextStyle(fontSize: 16), textAlign: TextAlign.right,)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("%30.00",style: TextStyle(fontSize: 16),textAlign: TextAlign.right)),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("İhtiyaçlar",style: TextStyle(fontSize: 16),)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text(formattedAlimentValue,style: TextStyle(fontSize: 16), textAlign: TextAlign.right,)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("%50.00",style: TextStyle(fontSize: 16),textAlign: TextAlign.right)),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(onPressed: () {
              Navigator.pushNamed(context, 'abonelikler');
            }, child: Text("Abonelikler")),
            Text("PAGE 1: GELİR TÜRÜ: ${page1.selectedOption}"),
            Text("PAGE 1: GELİR MİKTARI: ${page1.incomeValue}"),
            Text("PAGE 2: FİLM,DİZİ VE TV: \n$itemListText"),
            Text("PAGE 2: FİLM,DİZİ VE TV TOPLAM TUTARU: \n${page2.sumOfPrices}"),
            Text("PAGE 3: EV FATURALARI, : \n$itemListTextHomeBills"),
          ],
        ),
      ),
    );
  }
}
