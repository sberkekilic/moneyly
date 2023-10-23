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
    double sumOfTV = NumberFormat.decimalPattern('tr_TR').parse(page2.sumOfTV) as double;
    double sumOfGaming = NumberFormat.decimalPattern('tr_TR').parse(page2.sumOfGaming) as double;
    double sumOfMusic = NumberFormat.decimalPattern('tr_TR').parse(page2.sumOfMusic) as double;
    double sumOfHomeBills = NumberFormat.decimalPattern('tr_TR').parse(page2.sumOfHomeBills) as double;
    double sumOfInternet = NumberFormat.decimalPattern('tr_TR').parse(page2.sumOfInternet) as double;
    double sumOfPhone = NumberFormat.decimalPattern('tr_TR').parse(page2.sumOfPhone) as double;
    double sumOfRent = NumberFormat.decimalPattern('tr_TR').parse(page2.sumOfRent) as double;
    double sumOfKitchen = NumberFormat.decimalPattern('tr_TR').parse(page2.sumOfKitchen) as double;
    double sumOfCatering = NumberFormat.decimalPattern('tr_TR').parse(page2.sumOfCatering) as double;
    double sumOfEnt= NumberFormat.decimalPattern('tr_TR').parse(page2.sumOfEntertainment) as double;
    double sumOfOther = NumberFormat.decimalPattern('tr_TR').parse(page2.sumOfOther) as double;
    double sumOfSubs = sumOfTV+sumOfGaming+sumOfMusic;
    double sumOfBills = sumOfHomeBills+sumOfInternet+sumOfPhone;
    double sumOfOthers = sumOfRent+sumOfKitchen+sumOfCatering+sumOfEnt+sumOfOther;
    double subsPercent = (sumOfSubs/ incomeValue) * 100;
    double billsPercent = (sumOfBills/ incomeValue) * 100;
    double othersPercent = (sumOfOthers/ incomeValue) * 100;
    double outcomeValue = sumOfSubs+sumOfBills+sumOfOthers;
    double netProfit = incomeValue - outcomeValue;
    double savingsValue = incomeValue * 0.2;
    double wantsNeedsValue = incomeValue * 0.3;
    double alimentValue = incomeValue * 0.5;
    String formattedSavingsValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(savingsValue);
    String formattedWantsNeedsValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(wantsNeedsValue);
    String formattedAlimentValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(alimentValue);
    String formattedIncomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(incomeValue);
    String formattedOutcomeValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(outcomeValue);
    String formattedProfitValue = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(netProfit);
    String formattedSumOfSubs = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfSubs);
    String formattedSumOfBills = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfBills);
    String formattedSumOfOthers = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfOthers);


    String itemListText = "";
    String oyunListe = "";
    String muzikListe = "";
    String itemListTextHomeBills = "";
    for (int i = 0; i<page2.tvTitleList.length; i++){
      itemListText += "${page2.tvTitleList[i]}, ${page2.tvPriceList[i]}";

    if (i < page2.tvTitleList.length - 1){
      itemListText += "\n";
    }
    }
    for (int i = 0; i<page2.gamingTitleList.length; i++){
      oyunListe += "${page2.gamingTitleList[i]}, ${page2.gamingPriceList[i]}";

      if (i < page2.gamingTitleList.length - 1){
        oyunListe += "\n";
      }
    }
    for (int i = 0; i<page2.musicTitleList.length; i++){
      muzikListe += "${page2.musicTitleList[i]}, ${page2.musicPriceList[i]}";

      if (i < page2.musicTitleList.length - 1){
        muzikListe += "\n";
      }
    }
    for (int i = 0; i<page2.homeBillsTitleList.length; i++){
      itemListTextHomeBills += "${page2.homeBillsTitleList[i]}, ${page2.homeBillsPriceList[i]}";

      if (i < page2.homeBillsTitleList.length - 1){
        itemListTextHomeBills += "\n";
      }

    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 50, left: 20, right: 20),
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
                  Text("${formattedIncomeValue}",style: TextStyle(fontSize: 25)),
                  SizedBox(height: 10),
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
                                formattedIncomeValue,
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
                  SizedBox(height: 5),
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
                  SizedBox(height: 5),
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
                  SizedBox(height: 5),
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
            SizedBox(height: 50),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Gider", style: TextStyle(fontSize: 31)),
                  Text("${formattedOutcomeValue}",style: TextStyle(fontSize: 25)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("Abonelikler",style: TextStyle(fontSize: 16),)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("${formattedSumOfSubs}",style: TextStyle(fontSize: 16), textAlign: TextAlign.right,)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("%${subsPercent.toStringAsFixed(2)}",style: TextStyle(fontSize: 16),textAlign: TextAlign.right)),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("Faturalar",style: TextStyle(fontSize: 16),)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text(formattedSumOfBills,style: TextStyle(fontSize: 16), textAlign: TextAlign.right,)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("%${billsPercent.toStringAsFixed(2)}",style: TextStyle(fontSize: 16),textAlign: TextAlign.right)),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("Diğer Giderler",style: TextStyle(fontSize: 16),)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text(formattedSumOfOthers,style: TextStyle(fontSize: 16), textAlign: TextAlign.right,)),
                      Flexible(
                          flex: 3,
                          fit: FlexFit.tight,
                          child: Text("%${othersPercent.toStringAsFixed(2)}",style: TextStyle(fontSize: 16),textAlign: TextAlign.right)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Net Kazanç", style: TextStyle(fontSize: 31)),
                  Text(formattedProfitValue,style: TextStyle(fontSize: 25)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
