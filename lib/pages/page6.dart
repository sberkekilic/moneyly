import 'package:flutter/material.dart';

class CategoryScroll extends StatefulWidget {
  @override
  _CategoryScrollState createState() => _CategoryScrollState();
}

class _CategoryScrollState extends State<CategoryScroll> {
  late PageController _pageController;
  int _currentPage = 0;

  List<Color> pageColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  List<double> pageHeights = [200, 150, 100, 50];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Category ${_currentPage + 1}"),
      ),
      body: Center(
        child: SizedBox(
          height: pageHeights[_currentPage], // Set the height dynamically
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: pageColors.length,
            itemBuilder: (context, index) {
              return buildPage(index);
            },
          ),
        ),
      ),
    );
  }

  Widget buildPage(int index) {
    return Container(
      color: pageColors[index],
      child: Center(
        child: Text(
          "Page ${index + 1}",
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CategoryScroll(),
  ));
}
