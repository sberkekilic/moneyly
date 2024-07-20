import 'dart:math';

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expandable PageView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CategoryScroll(),
    );
  }
}

class CategoryScroll extends StatefulWidget {
  @override
  _CategoryScrollState createState() => _CategoryScrollState();
}

class _CategoryScrollState extends State<CategoryScroll> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expandable PageView Demo'),
      ),
      body: Column(
        children: [
          Container(
            height: 150,
            color: Colors.pink,
          ),
          SizedBox(height: 50),
          Expanded(
            child: PersistentTabView(
              context,
              controller: _controller,
              screens: [
                ExpandablePageView(
                  children: [
                    Container(
                      color: Colors.red,
                      child: Center(
                        child: Text(
                          'Page 1'*10,
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                ExpandablePageView(
                    children: [
                      Container(
                        color: Colors.green,
                        child: Center(
                          child: Text(
                            'Page 2'*20,
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                        ),
                      ),
                    ]
                ),
                ExpandablePageView(
                    children: [
                      Container(
                        color: Colors.blue,
                        child: Center(
                          child: Text(
                            'Page 3'*30,
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                        ),
                      ),
                    ]
                ),
              ],
              items: [
                PersistentBottomNavBarItem(
                  icon: Icon(Icons.home),
                  title: 'Page 1',
                  activeColorPrimary: Colors.blue,
                  inactiveColorPrimary: Colors.grey,
                ),
                PersistentBottomNavBarItem(
                  icon: Icon(Icons.explore),
                  title: 'Page 2',
                  activeColorPrimary: Colors.green,
                  inactiveColorPrimary: Colors.grey,
                ),
                PersistentBottomNavBarItem(
                  icon: Icon(Icons.person),
                  title: 'Page 3',
                  activeColorPrimary: Colors.orange,
                  inactiveColorPrimary: Colors.grey,
                ),
              ],
              confineToSafeArea: true,
              backgroundColor: Colors.white,
              handleAndroidBackButtonPress: true,
              resizeToAvoidBottomInset: true,
              stateManagement: true,
              isVisible: true,
              decoration: NavBarDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(height: 50),
          Container(
            height: 150,
            color: Colors.pink,
          ),
        ],
      ),
    );
  }
}

class ExpandablePageView extends StatefulWidget {
  final List<Widget> children;

  const ExpandablePageView({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  State<ExpandablePageView> createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late List<double> _heights;
  int _currentPage = 0;

  double get _currentHeight => _heights[_currentPage];

  @override
  void initState() {
    _heights = widget.children.map((e) => 0.0).toList();
    super.initState();
    _pageController = PageController()
      ..addListener(() {
        final newPage = _pageController.page?.round() ?? 0;
        if (_currentPage != newPage) {
          setState(() => _currentPage = newPage);
        }
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      curve: Curves.easeInOutCubic,
      duration: const Duration(milliseconds: 100),
      tween: Tween<double>(begin: _heights[0], end: _currentHeight),
      builder: (context, value, child) => SizedBox(height: value, child: child),
      child: PageView(
        controller: _pageController,
        children: _sizeReportingChildren
            .asMap() //
            .map((index, child) => MapEntry(index, child))
            .values
            .toList(),
      ),
    );
  }

  List<Widget> get _sizeReportingChildren => widget.children
      .asMap() //
      .map(
        (index, child) => MapEntry(
      index,
      OverflowBox(
        minHeight: 0,
        maxHeight: double.infinity,
        alignment: Alignment.topCenter,
        child: SizeReportingWidget(
          onSizeChange: (size) =>
              setState(() => _heights[index] = size.height),
          child: Align(child: child),
        ),
      ),
    ),
  )
      .values
      .toList();
}

class SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  const SizeReportingWidget({
    Key? key,
    required this.child,
    required this.onSizeChange,
  }) : super(key: key);

  @override
  State<SizeReportingWidget> createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) => _notifySize());
    return widget.child;
  }

  void _notifySize() {
    if (!mounted) {
      return;
    }
    final size = context.size;
    if (_oldSize != size && size != null) {
      _oldSize = size;
      widget.onSizeChange(size);
    }
  }
}
