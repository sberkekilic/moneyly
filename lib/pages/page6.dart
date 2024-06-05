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
  List<List<String>> pageContents = [
    ["Lorem ipsum dolor sit amet, consectetur adipiscing elit.", "More content for page 1."],
    ["Content for page 2.", "Some additional text for page 2."],
    ["Short content for page 3."],
    ["A very long text for page 4. " * 10], // Example of a long paragraph
  ];
  List<double> pageHeights = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    pageHeights = List.filled(pageContents.length, 200.0);
    Future.delayed(Duration.zero, () {
      calculatePageHeights();
      setState(() {});
    });
  }

  void calculatePageHeights() {
    pageHeights = List.generate(pageContents.length, (index) {
      double maxHeight = 0.0;

      // Calculate the height of the title
      final titleTextPainter = TextPainter(
        text: TextSpan(
          text: "Some Title", // Add your title here
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: MediaQuery.of(context).size.width - 16.0);

      maxHeight += titleTextPainter.size.height;

      // Calculate the height of each InvoiceCard
      for (String content in pageContents[index]) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: content,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          maxLines: 999,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: MediaQuery.of(context).size.width - 16.0);

        maxHeight += textPainter.size.height;
      }

      double height = maxHeight + 56.0; // Add padding
      print('Page $index height: $height');
      return height;
    });
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
        child: pageHeights.isEmpty
            ? CircularProgressIndicator()
            : SizedBox(
          height: pageHeights[_currentPage],
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Some Title", // Add your title here
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: pageContents[index].length,
              itemBuilder: (context, contentIndex) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    pageContents[index][contentIndex],
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                );
              },
            ),
          ],
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
