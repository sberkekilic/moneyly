import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/blocs/settings/settings-page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/income-selections.dart';
import '../blocs/settings/selected-index-cubit.dart';
import '../blocs/settings/settings-cubit.dart';
import '../blocs/settings/settings-state.dart';
import 'add-expense/faturalar.dart';
import 'in-app/home-page.dart';
import 'in-app/income-page.dart';
import 'in-app/investment-page.dart';
import 'in-app/outcome-page.dart';
import 'in-app/wishes-page.dart';

class Page6 extends StatefulWidget {
  @override
  _Page6State createState() => _Page6State();
}

class _Page6State extends State<Page6> {
  final List<Invoice> invoices = [];
  double incomeValue = 0.0;
  double outcomeValue = 0.0;
  int subsPercent = 0;
  int billsPercent = 0;
  int othersPercent = 0;
  double sumOfSubs = 0.0;
  double sumOfBills = 0.0;
  double sumOfOthers = 0.0;
  double sumOfTV = 0.0;
  double sumOfGame = 0.0;
  double sumOfMusic = 0.0;
  double sumOfHome = 0.0;
  double sumOfInternet = 0.0;
  double sumOfPhone = 0.0;
  double sumOfRent = 0.0;
  double sumOfKitchen = 0.0;
  double sumOfCatering = 0.0;
  double sumOfEnt = 0.0;
  double sumOfOther = 0.0;
  String selectedTitle = '';
  String convertSum = "";
  String convertSum2 = "";
  String convertSum3 = "";

  @override
  void initState() {
    super.initState();
    // Update the index to 0 when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SelectedIndexCubit>().setIndex(0);
    });

    _load();
  }

  Widget _createPage(int index) {
    switch (index) {
      case 0:
        return HomePage();
      case 1:
        return IncomePage();
      case 2:
        return OutcomePage();
      case 3:
        return InvestmentPage();
      case 4:
        return WishesPage();
      default:
        return HomePage();
    }
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
    final ab2 = prefs.getString('income_value') ?? '0';
    final ab3 = prefs.getDouble('sumOfTV2') ?? 0.0;
    final ab4 = prefs.getDouble('sumOfGame2') ?? 0.0;
    final ab5 = prefs.getDouble('sumOfMusic2') ?? 0.0;
    final ab6 = prefs.getDouble('sumOfHome2') ?? 0.0;
    final ab7 = prefs.getDouble('sumOfInternet2') ?? 0.0;
    final ab8 = prefs.getDouble('sumOfPhone2') ?? 0.0;
    final ab9 = prefs.getDouble('sumOfRent2') ?? 0.0;
    final ab10 = prefs.getDouble('sumOfKitchen2') ?? 0.0;
    final ab11 = prefs.getDouble('sumOfCatering2') ?? 0.0;
    final ab12 = prefs.getDouble('sumOfEnt2') ?? 0.0;
    final ab13 = prefs.getDouble('sumOfOther2') ?? 0.0;
    final ab14 = prefs.getDouble('sumOfSubs2') ?? 0.0;
    final ab15 = prefs.getDouble('sumOfBills2') ?? 0.0;
    final ab16 = prefs.getDouble('sumOfOthers2') ?? 0.0;
    final ab17 = prefs.getStringList('invoices') ?? [];
    setState(() {
      selectedTitle = labelForOption(SelectedOption.values[ab1]);
      incomeValue = NumberFormat.decimalPattern('tr_TR').parse(ab2) as double;
      sumOfTV = ab3;
      sumOfGame = ab4;
      sumOfMusic = ab5;
      sumOfHome = ab6;
      sumOfInternet = ab7;
      sumOfPhone = ab8;
      sumOfRent = ab9;
      sumOfKitchen = ab10;
      sumOfCatering = ab11;
      sumOfEnt = ab12;
      sumOfOther = ab13;
      sumOfSubs = ab14;
      sumOfBills = ab15;
      sumOfOthers = ab16;
      for (final invoiceString in ab17) {
        final Map<String, dynamic> invoiceJson = jsonDecode(invoiceString);
        final Invoice invoice = Invoice.fromJson(invoiceJson);
        invoices.add(invoice);
        print("INVOICE LENGTH E08 : ${invoices.length}");
      }
    });
    convertSum = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfTV);
    convertSum2 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfGame);
    convertSum3 = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2).format(sumOfMusic);
  }

  @override
  Widget build(BuildContext context) {

    String formatLocalizedDate(String languageCode) {
      DateFormat dateFormat = DateFormat('dd MMMM yyyy', languageCode);
      return dateFormat.format(DateTime.now());
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(125, 183, 255, 217),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 40.h,
        automaticallyImplyLeading: false,
        leadingWidth: 30.w,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        title: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    context.push('/settings');
                  },
                  icon: const Icon(Icons.settings, color: Colors.black),
                ),
                IconButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushNamed(context, 'gelir-ekle');
                  },
                  icon: FaIcon(FontAwesomeIcons.circleUser, color: Colors.black),
                ),
              ],
            ),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                String localizedDate = formatLocalizedDate(state.language);
                return Text(
                  localizedDate,
                  style: TextStyle(
                    fontFamily: 'Keep Calm',
                    color: Colors.black,
                    fontSize: 20.sp,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<SelectedIndexCubit, int>(
        builder: (context, selectedIndex) {
          return _createPage(selectedIndex);
        },
      ),
      bottomNavigationBar: BlocBuilder<SelectedIndexCubit, int>(
        builder: (context, selectedIndex) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex,
            onTap: (index) {
              context.read<SelectedIndexCubit>().setIndex(index); // Update the index when tapped
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Income'),
              BottomNavigationBarItem(icon: Icon(Icons.money_off), label: 'Outcome'),
              BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Investment'),
              BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Wishes'),
            ],
          );
        },
      ),
    );
  }
}
