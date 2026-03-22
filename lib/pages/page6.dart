import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/pages/in-app/accounts-page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../blocs/income-selections.dart';
import '../blocs/settings/selected-index-cubit.dart';
import 'add-expense/faturalar.dart';
import 'in-app/home-page.dart';
import 'in-app/income-page.dart';
import 'in-app/investment-page.dart';
import 'in-app/outcome-page.dart';

class Page6 extends StatefulWidget {
  @override
  _Page6State createState() => _Page6State();
}

class _Page6State extends State<Page6> {
  List<Map<String, dynamic>> bankAccounts = [];
  Map<String, dynamic>? selectedAccount;
  bool isLoading = true;
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
        return AccountsPage();
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
    String? accountDataListJson = prefs.getString('accountDataList'); //TÜM HESAP
    String? accountData = prefs.getString('selectedAccount');
    setState(() {
      selectedTitle = labelForOption(SelectedOption.values[ab1]);
      //incomeValue = NumberFormat.decimalPattern('tr_TR').parse(ab2) as double;
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
    // Handle account data list
    if (accountDataListJson != null) {
      try {
        List<Map<String, dynamic>> decodedData = List<Map<String, dynamic>>.from(jsonDecode(accountDataListJson));
        print('Tüm Hesaplar: $decodedData');
        bankAccounts = decodedData.toSet().toList();

        if (accountData != null) {
          final Map<String, dynamic> accountFromPrefs = Map<String, dynamic>.from(jsonDecode(accountData));
          print('Saved account data: $accountFromPrefs');

          // Only proceed if we have both bankId and accountId
          if (accountFromPrefs['bankId'] != null && accountFromPrefs['accountId'] != null) {
            // Find the bank first
            final bank = bankAccounts.firstWhere(
                  (bank) => bank['bankId'] == accountFromPrefs['bankId'],
              orElse: () => {},
            );

            if (bank.isNotEmpty) {
              // Then find the specific account within that bank
              final accounts = bank['accounts'] as List?;
              if (accounts != null) {
                final account = accounts.firstWhere(
                      (acc) => acc['accountId'] == accountFromPrefs['accountId'],
                  orElse: () => {},
                );

                if (account.isNotEmpty) {
                  // Combine bank info with account info
                  selectedAccount = {
                    ...account,
                    'bankId': bank['bankId'],
                    'bankName': bank['bankName'],
                    // Include any other bank fields you need
                  };
                }
              }
            }
          }
        }

        setState(() => isLoading = false);
      } catch (e) {
        print('Error decoding account data: $e');
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
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
    String localizedDate = formatLocalizedDate("tr");

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 70.h,
        automaticallyImplyLeading: false,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900]!.withOpacity(0.3) : Colors.white.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizedDate,
                  style: TextStyle(
                    fontFamily: 'Keep Calm',
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    GlassmorphismContainer(
                      borderColor: borderColor,
                      blur: 5,
                      borderRadius: 50,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                      padding: EdgeInsets.zero,
                      child: IconButton(
                        onPressed: () => context.push('/settings'),
                        icon: Icon(
                          Icons.settings,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                          size: 16.sp),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    GlassmorphismContainer(
                      borderColor: borderColor,
                      blur: 5,
                      borderRadius: 50,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                      padding: EdgeInsets.zero,
                      child: IconButton(
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          Navigator.pushNamed(context, 'gelir-ekle');
                          },
                        icon: FaIcon(
                          FontAwesomeIcons.circleUser,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                          size: 16.sp
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (selectedAccount == null)
              Text(
                "No account selected",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Text(
                selectedAccount!['name'],
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
          ],
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<SelectedIndexCubit, int>(
          builder: (context, selectedIndex) {
            return selectedAccount == null && selectedIndex != 4
                ? _buildNoAccountsState(context, selectedIndex)
                : _createPage(selectedIndex);
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<SelectedIndexCubit, int>(
        builder: (context, selectedIndex) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.5) // Dark mode shadow
                      : Colors.grey.withOpacity(0.5), // Light mode shadow
                  spreadRadius: 5,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.zero, // No radius for bottom left
                bottomRight: Radius.zero, // No radius for bottom right
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.zero, // No radius for bottom left
                bottomRight: Radius.zero, // No radius for bottom right
              ),
              child: Theme(
                data: ThemeData(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                    bottomNavigationBarTheme: BottomNavigationBarThemeData(
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[850] // Dark mode background
                          : Colors.white, // Light mode background
                    )
                ),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? Color.fromARGB(220, 30, 30, 30)
                      : Colors.white,
                  selectedItemColor: const Color.fromARGB(255, 26, 183, 56),
                  unselectedItemColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                  selectedLabelStyle: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  unselectedLabelStyle: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  elevation: 8,
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    context.read<SelectedIndexCubit>().setIndex(index);
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: selectedIndex == 0
                              ? const Color.fromARGB(40, 26, 183, 56)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: selectedIndex == 0
                              ? Border.all(color: const Color.fromARGB(100, 26, 183, 56), width: 1)
                              : null,
                        ),
                        child: Icon(
                          Icons.home,
                          size: 26.sp,
                          color: selectedIndex == 0
                              ? const Color.fromARGB(255, 26, 183, 56)
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      label: 'Ana Sayfa',
                    ),
                    BottomNavigationBarItem(
                      icon: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: selectedIndex == 1
                              ? const Color.fromARGB(40, 26, 183, 56)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: selectedIndex == 1
                              ? Border.all(color: const Color.fromARGB(100, 26, 183, 56), width: 1)
                              : null,
                        ),
                        child: Icon(
                          Icons.attach_money,
                          size: 26.sp,
                          color: selectedIndex == 1
                              ? const Color.fromARGB(255, 26, 183, 56)
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      label: 'Gelir',
                    ),
                    BottomNavigationBarItem(
                      icon: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: selectedIndex == 2
                              ? const Color.fromARGB(40, 26, 183, 56)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: selectedIndex == 2
                              ? Border.all(color: const Color.fromARGB(100, 26, 183, 56), width: 1)
                              : null,
                        ),
                        child: Icon(
                          Icons.money_off,
                          size: 26.sp,
                          color: selectedIndex == 2
                              ? const Color.fromARGB(255, 26, 183, 56)
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      label: 'Gider',
                    ),
                    BottomNavigationBarItem(
                      icon: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: selectedIndex == 3
                              ? const Color.fromARGB(40, 26, 183, 56)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: selectedIndex == 3
                              ? Border.all(color: const Color.fromARGB(100, 26, 183, 56), width: 1)
                              : null,
                        ),
                        child: Icon(
                          Icons.trending_up,
                          size: 26.sp,
                          color: selectedIndex == 3
                              ? const Color.fromARGB(255, 26, 183, 56)
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      label: 'Yatırım',
                    ),
                    BottomNavigationBarItem(
                      icon: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: selectedIndex == 4
                              ? const Color.fromARGB(40, 26, 183, 56)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: selectedIndex == 4
                              ? Border.all(color: const Color.fromARGB(100, 26, 183, 56), width: 1)
                              : null,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          size: 26.sp,
                          color: selectedIndex == 4
                              ? const Color.fromARGB(255, 26, 183, 56)
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      label: 'Hesaplarım',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Map<String, dynamic>? _findAccountById(int? accountId) {
    if (accountId == null) {
      print('Warning: _findAccountById called with null accountId');
      return null;
    }

    for (var bank in bankAccounts) {
      for (var account in bank['accounts'] ?? []) {
        if (account['accountId'] == accountId) {
          // Return a flattened structure with account + bank info
          return {
            ...account, // Spread all account fields
            'bankId': bank['bankId'],
            'bankName': bank['bankName'],
            'currency': account['currency'],
            'isDebit': account['isDebit'],
            'creditLimit': account['creditLimit'],
            'availableCredit': account['availableCredit'],
            'cutoffDate': account['cutoffDate']
            // Don't include nested accounts array since we're selecting one account
          };
        }
      }
    }
    return null;
  }
}

Widget _buildNoAccountsState(BuildContext context, int selectedIndex) {
  return Center(
    child: Padding(
      padding: EdgeInsets.all(20.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 40.r,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            "Henüz hesap eklenmemiş",
            style: GoogleFonts.montserrat(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Hesap eklemek için aşağıdaki butona tıklayın\nveya banka bağlantısı yapın",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 32.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate to add manual account
                  context.read<SelectedIndexCubit>().setIndex(4);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  "Hesap Ekle",
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              OutlinedButton(
                onPressed: () {
                  // Navigate to bank connection
                  context.push('/connect-bank');
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: Text(
                  "Banka Bağla",
                  style: GoogleFonts.montserrat(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final Color? color; // opsiyonel arkaplan rengi

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 10,
    required this.borderColor,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}