
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyly/blocs/settings/selected-index-cubit.dart';

import 'home-page.dart';
import 'income-page.dart';
import 'investment-page.dart';
import 'outcome-page.dart';
import 'wishes-page.dart';

class Page6 extends StatefulWidget {
  final PageController pageController;

  Page6({required this.pageController});

  @override
  _Page6State createState() => _Page6State();
}

class _Page6State extends State<Page6> {
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = List.generate(5, (index) => _createPage(index));
  }
  String currentDate = DateFormat('dd MMMM yyyy').format(DateTime.now());

  Widget _createPage(int index) {
    switch (index) {
      case 0:
        return HomePage();
      case 1:
        return IncomePage(pageController: widget.pageController);
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

  void _onPageChanged(int index) {
    context.read<SelectedIndexCubit>().updateIndex(index);
  }

  void _onItemTapped(int index) {
    context.read<SelectedIndexCubit>().updateIndex(index);
    widget.pageController.jumpToPage(index); // Sync PageView with BottomNavigationBar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffa7a7a7),
        elevation: 0,
        toolbarHeight: 50.h,
        automaticallyImplyLeading: false,
        leadingWidth: 30.w,
        title: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'settings');
                  },
                  icon: const Icon(Icons.settings, color: Colors.black),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.person, color: Colors.black),
                ),
              ],
            ),
            BlocBuilder<SelectedIndexCubit, int>(
              builder: (context, selectedIndex) {
                String currentDate = DateFormat('dd MMMM yyyy').format(DateTime.now());
                return Text(
                  currentDate,
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.normal,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: PageView(
        controller: widget.pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
        physics: NeverScrollableScrollPhysics(), // Disable swipe to change page
      ),
      bottomNavigationBar: BlocBuilder<SelectedIndexCubit, int>(
        builder: (context, selectedIndex) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Theme(
                data: ThemeData(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent
                ),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: const Color.fromARGB(255, 26, 183, 56),
                  selectedLabelStyle: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: GoogleFonts.montserrat(
                    color: const Color.fromARGB(255, 26, 183, 56),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  currentIndex: selectedIndex,
                  onTap: _onItemTapped,
                  items: [
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Container(
                          width: double.infinity,
                          decoration: selectedIndex == 0
                              ? BoxDecoration(
                            color: const Color.fromARGB(125, 26, 183, 56),
                            borderRadius: BorderRadius.circular(20),
                          )
                              : null,
                          child: Icon(Icons.home, size: 30.sp),
                        ),
                      ),
                      label: 'Ana Sayfa',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Container(
                          width: double.infinity,
                          decoration: selectedIndex == 1
                              ? BoxDecoration(
                            color: const Color.fromARGB(125, 26, 183, 56),
                            borderRadius: BorderRadius.circular(20),
                          )
                              : null,
                          child: const Icon(Icons.attach_money, size: 30),
                        ),
                      ),
                      label: 'Gelir',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Container(
                          width: double.infinity,
                          decoration: selectedIndex == 2
                              ? BoxDecoration(
                            color: const Color.fromARGB(125, 26, 183, 56),
                            borderRadius: BorderRadius.circular(20),
                          )
                              : null,
                          child: const Icon(Icons.money_off, size: 30),
                        ),
                      ),
                      label: 'Gider',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Container(
                          width: double.infinity,
                          decoration: selectedIndex == 3
                              ? BoxDecoration(
                            color: const Color.fromARGB(125, 26, 183, 56),
                            borderRadius: BorderRadius.circular(20),
                          )
                              : null,
                          child: const Icon(Icons.trending_up, size: 30),
                        ),
                      ),
                      label: 'Yatırım',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Container(
                          width: double.infinity,
                          decoration: selectedIndex == 4
                              ? BoxDecoration(
                            color: const Color.fromARGB(125, 26, 183, 56),
                            borderRadius: BorderRadius.circular(20),
                          )
                              : null,
                          child: const Padding(
                            padding: EdgeInsets.only(top: 5, bottom: 5),
                            child: Icon(FontAwesome.bank, size: 20),
                          ),
                        ),
                      ),
                      label: 'İstekler',
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
}


