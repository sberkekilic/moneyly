
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'home-page.dart';
import 'income-page.dart';
import 'investment-page.dart';
import 'outcome-page.dart';
import 'wishes-page.dart';

class Page6 extends StatefulWidget {
  @override
  _Page6State createState() => _Page6State();
}

class _Page6State extends State<Page6> {
  int _selectedIndex = 0;
  String currentDate = DateFormat('dd MMMM yyyy').format(DateTime.now());
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    HomePage(),
    IncomePage(),
    OutcomePage(),
    InvestmentPage(),
    WishesPage(),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff0f0f1),
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
                  icon: const Icon(Icons.settings, color: Colors.black), // Replace with the desired left icon
                ),
                IconButton(
                  onPressed: () {
                  },
                  icon: const Icon(Icons.person, color: Colors.black), // Replace with the desired right icon
                ),
              ],
            ),
            Text(
              currentDate,
              style: GoogleFonts.montserrat(color: Colors.black, fontSize: 20.sp, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
        physics: NeverScrollableScrollPhysics(), // Disable swipe to change page
      ),
        bottomNavigationBar: Container(
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
              child: BottomNavigationBar( //Wrapped in Theme to disable splash color
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
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Container(
                        width: double.infinity,
                        decoration: _selectedIndex == 0
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
                        decoration: _selectedIndex == 1
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
                        decoration: _selectedIndex == 2
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
                        decoration: _selectedIndex == 3
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
                        decoration: _selectedIndex == 4
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
        )
    );
  }
}