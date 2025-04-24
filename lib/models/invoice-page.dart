import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/add-expense/faturalar.dart';
import 'invoice-card.dart';

class InvoicePage extends StatefulWidget {
  final VoidCallback onReload;

  InvoicePage({required this.onReload});
  @override
  _InvoicePageState createState() => _InvoicePageState();
}
class _InvoicePageState extends State<InvoicePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showRightArrow = false;
  bool _showLeftArrow = false;
  bool _isTouching = false;
  final GlobalKey _intrinsicHeightKey = GlobalKey();
  final Map<int, GlobalKey> _intrinsicHeightKeys = {};
  final GlobalKey _scrollWidthKey = GlobalKey();
  double? _height;
  double? _width;
  double? _widthIntrinsic;
  int _currentPage = 0;
  double _rightArrowOpacity = 0.0;
  double _leftArrowOpacity = 0.0;
  List<Invoice> upcomingInvoices = [];
  List<Invoice> todayInvoices = [];
  List<Invoice> approachingDueInvoices = [];
  List<Invoice> paymentDueInvoices = [];
  List<Invoice> overdueInvoices = [];
  List<Invoice> selectedInvoices = [];
  List<Invoice> originalInvoices = [];


  @override
  void initState() {
    super.initState();
    _loadInvoices(); // Load invoices from SharedPreferences
    if (overdueInvoices.isNotEmpty){
      _currentPage = 4;
    } else if (paymentDueInvoices.isNotEmpty){
      _currentPage = 3;
    } else if (approachingDueInvoices.isNotEmpty){
      _currentPage = 2;
    } else if (todayInvoices.isNotEmpty){
      _currentPage = 1;
    } else {
      _currentPage = 0;
    }
  }

  Future<void> addSampleInvoice() async {
    try {
      print("DEBUG: Starting addSampleInvoice");
      final prefs = await SharedPreferences.getInstance();
      print("DEBUG: SharedPreferences instance obtained");

      final sampleInvoice = Invoice(
        id: 1,
        name: 'Sample Invoice',
        price: '100.0',
        periodDate: '2024-12-12',
        category: 'category',
        difference: 'diff',
        subCategory: 'sub',
        dueDate: null,
      );

      final invoicesJson = prefs.getStringList('invoices') ?? [];
      print("DEBUG: Initial invoicesJson: $invoicesJson");

      invoicesJson.add(jsonEncode(sampleInvoice.toJson()));
      print("DEBUG: Updated invoicesJson: $invoicesJson");

      await prefs.setStringList('invoices', invoicesJson);
      print("DEBUG: Invoices saved to SharedPreferences");
    } catch (e) {
      print("ERROR: $e");
    }
  }

  Future<void> _loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final invoicesJson = prefs.getStringList('invoices') ?? [];
    setState(() {
      selectedInvoices = invoicesJson.map((e) => Invoice.fromJson(jsonDecode(e))).toList();
      originalInvoices = invoicesJson.map((e) => Invoice.fromJson(jsonDecode(e))).toList();
    });
    print("HOME-PAGE 3| selectedInvoices:");
    for (var invoice in selectedInvoices) {
      print(invoice.toDisplayString());
    }
    _getHeightForAll();
    _getWidth();
    categorizeInvoices(selectedInvoices);
  }

  void _getHeightForAll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only calculate height for page 4
      double maxHeight = 0.0;

      // Ensure page 4 has a key for height measurement
      if (!_intrinsicHeightKeys.containsKey(_currentPage)) {
        _intrinsicHeightKeys[_currentPage] = GlobalKey();
      }

      final RenderBox? renderBox =
      _intrinsicHeightKeys[_currentPage]?.currentContext?.findRenderObject() as RenderBox?;
      final categoryHeight = renderBox?.size.height ?? 0.0;

      // Check if the height is too large
      if (categoryHeight > 800) { // Example threshold (e.g., 800px)
        print('Page 4 has an unexpectedly large height: $categoryHeight');
      }

      if (mounted){
        setState(() {
          _height = categoryHeight;
        });
      }
    });
  }

  void categorizeInvoices(List<Invoice> faturalar) {
    print("faturalar length : ${faturalar.length}");
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    // 1. Upcoming Invoice Date (those with PeriodDate before today)
    upcomingInvoices = faturalar.where((invoice) {
      print("AJAX1");
      DateTime periodDate = DateTime.parse(invoice.periodDate);
      return periodDate.isAfter(today);
    }).toList();

    // 2. Invoice Day (with PeriodDate today)
    todayInvoices = faturalar.where((invoice) {
      print("AJAX2");
      DateTime periodDate = DateTime.parse(invoice.periodDate);
      return periodDate.day == today.day && periodDate.month == today.month && periodDate.year == today.year;
    }).toList();

    // 3. Approaching Due Date (those with DueDate data and this date is before today)
    approachingDueInvoices = faturalar.where((invoice) {
      print("AJAX3");
      if (invoice.dueDate!= null) {
        DateTime periodDate = DateTime.parse(invoice.periodDate!);
        DateTime dueDate = DateTime.parse(invoice.dueDate!);
        return periodDate.isBefore(today) && today.isBefore(dueDate);
      }
      return false;
    }).toList();

    // 4. Payment Due Date (those with DueDate data and this date is today)
    paymentDueInvoices = faturalar.where((invoice) {
      print("AJAX4");
      if (invoice.dueDate!= null) {
        DateTime dueDate = DateTime.parse(invoice.dueDate!);
        return dueDate.day == today.day && dueDate.month == today.month && dueDate.year == today.year;
      }
      return false;
    }).toList();

    // 5. Overdue Invoices (Invoices with DueDate data that are overdue or invoices without DueDate data but with an overdue PeriodDate)
    overdueInvoices = faturalar.where((invoice) {
      print("AJAX");
      if (invoice.dueDate != null) {
        DateTime periodDate = DateTime.parse(invoice.periodDate!);
        DateTime dueDate = DateTime.parse(invoice.dueDate!);
        return dueDate.isBefore(today) && periodDate.isBefore(today);
      } else if (invoice.dueDate == null){
        DateTime periodDate = DateTime.parse(invoice.periodDate!);
        return periodDate.isBefore(today);
      }
      return false;
    }).toList();

    print("upcomingInvoices:${upcomingInvoices.length}\n"
        "todayInvoices:${todayInvoices.length}\n"
        "approachingDueInvoices:${approachingDueInvoices.length}\n"
        "paymentDueInvoices:${paymentDueInvoices.length}\n"
        "overdueInvoices:${overdueInvoices.length}");
  }

  String? calculateNewDiff(String? dueDate, String periodDate){
    final diff;
    final currentDate = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    final dueDateKnown = dueDate != null;
    if (currentDate.isBefore(DateTime.parse(periodDate))) {
      diff = (DateTime.parse(periodDate).difference(currentDate).inDays + 1).toString();
      return diff;
    } else if (formattedDate == periodDate) {
      diff = "0";
      return diff;
    } else if (dueDateKnown) {
      if (dueDate != null && currentDate.isAfter(DateTime.parse(periodDate))) {
        diff = (DateTime.parse(dueDate!).difference(currentDate).inDays + 1).toString();
        return diff;
      } else {
        return "error1";
      }
    } else {
      return "error2";
    }
  }

  Future<void> _saveInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    final invoicesJson = originalInvoices.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('invoices', invoicesJson);
  }

  void payInvoice(Invoice invoice, int id, String periodDate, String? dueDate) async {
    for (var invoice in originalInvoices) {
      print("IPA01\n${invoice.toDisplayString()}");
    }
    for (var invoice in selectedInvoices) {
      print("IPA02\n${invoice.toDisplayString()}");
    }
    int index = originalInvoices.indexWhere((invoice) => invoice.id == id);
    int index2 = selectedInvoices.indexWhere((invoice) => invoice.id == id);
    // Debugging: Check the indices
    print('Index in originalInvoices: $index');
    print('Index in selectedInvoices: $index2');
    bool confirmDelete = false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Disclaimer"),
          content: Text("Are you sure you paid your invoice?\nID : ${invoice.id}\nInvoice name : ${invoice.name}\nInvoice amount : ${invoice.price}"),
          actions: <Widget>[
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                setState(() {
                  confirmDelete = true;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      setState(() {
        DateTime incrementMonth(DateTime date) {
          // Calculate the next month
          int nextMonth = date.month + 1;
          int nextYear = date.year;

          // Check if we need to increment the year
          if (nextMonth > 12) {
            nextMonth = 1;
            nextYear++;
          }

          // Find the last day of the next month
          int lastDayOfNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;

          // Adjust the day if the original date is the last day of the month
          int adjustedDay = date.day > lastDayOfNextMonth ? lastDayOfNextMonth : date.day;

          // Use the adjusted day of the next month
          return DateTime(nextYear, nextMonth, adjustedDay);
        }
        DateTime originalPeriodDate = DateTime.parse(invoice.periodDate);
        DateTime newPeriodDate = incrementMonth(originalPeriodDate);
        String stringPeriodDate = DateFormat('yyyy-MM-dd').format(newPeriodDate);
        String? stringDueDate;
        if (invoice.dueDate != null){
          DateTime originalDueDate = DateTime.parse(invoice.dueDate!);
          DateTime newDueDate = incrementMonth(originalDueDate);
          stringDueDate = DateFormat('yyyy-MM-dd').format(newDueDate);
        }
        String? diff = calculateNewDiff(stringDueDate, stringPeriodDate);
        print("The delete has been confirmed. Current diff is : ${diff} while period date is now : ${stringPeriodDate}");
        final updatedInvoice = Invoice(
            id: invoice.id,
            price: invoice.price,
            subCategory: invoice.subCategory,
            category: invoice.category,
            name: invoice.name,
            periodDate: stringPeriodDate,
            dueDate: stringDueDate,
            difference: diff!
        );
        // Debugging: Print the updated invoice details
        print('Updated Invoice: ${updatedInvoice.toString()}');
        originalInvoices[index] = updatedInvoice;
        selectedInvoices[index2] = updatedInvoice;
        // Debugging: Verify the update
        print('Updated originalInvoices at index $index: ${originalInvoices[index].name}');
        print('Updated selectedInvoices at index $index2: ${selectedInvoices[index2].name}');
        categorizeInvoices(selectedInvoices);
        _saveInvoices();
        _getHeight(_currentPage); // Recalculate height
        widget.onReload; // UPDATE THE WIDGET BY CALLING _LOAD FUNCTION OF HOMEPAGESTATE
      });
    }
  }

  void _getHeight(int categoryIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
      _intrinsicHeightKeys[categoryIndex]?.currentContext?.findRenderObject() as RenderBox?;
      if (mounted){
        setState(() {
          _height = renderBox?.size.height;
          _widthIntrinsic = renderBox?.size.width;
        });
      }
    });
  }

  void _getWidth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
      _scrollWidthKey.currentContext?.findRenderObject() as RenderBox?;

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _width = (renderBox?.size.width ?? 0.0) - (_widthIntrinsic ?? 0.0);
        });
      }
    });
  }


  Widget buildIndicator(int itemCount, int currentIndex) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
          // Swiped left
          if (_currentPage < itemCount - 1) {
            setState(() {
              _currentPage++;
            });
          } else {
            setState(() {
              _currentPage = 0;
            });
          }
        } else if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          // Swiped right
          if (_currentPage > 0) {
            setState(() {
              _currentPage--;
            });
          } else {
            setState(() {
              _currentPage = itemCount - 1;
            });
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2), // Highlight color for the touchable area
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: IntrinsicWidth(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(itemCount, (index) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (currentIndex % itemCount == index)
                      ? Color.fromARGB(125, 0, 149, 30)
                      : Colors.grey,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  String getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return "Fatura Tarihi Yaklaşan";
      case 1:
        return "Fatura Günü";
      case 2:
        return "Son Ödeme Tarihi Yaklaşan";
      case 3:
        return "Son Ödeme Günü";
      case 4:
        return "Tarihi Geçmiş Faturalar";
      default:
        return "null";
    }
  }

  @override
  Widget build(BuildContext context) {
    _getHeightForAll();
    List<List<Invoice>> categorizedInvoices = [
      upcomingInvoices,
      todayInvoices,
      approachingDueInvoices,
      paymentDueInvoices,
      overdueInvoices
    ];
    double width = _width ?? 0.0;
    double _dragDistance = 0.0; // To track the drag distance
    final double _dragThreshold = 50.0; // Set your desired threshold
    selectedInvoices = categorizedInvoices[_currentPage];
    // If no key exists for the category, create one
    if (!_intrinsicHeightKeys.containsKey(_currentPage)) {
      _intrinsicHeightKeys[_currentPage] = GlobalKey();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            getTitleForIndex(_currentPage),
            style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        IntrinsicHeight(
          key: _intrinsicHeightKeys[_currentPage],
          child: selectedInvoices.isEmpty
              ? GestureDetector(
            onHorizontalDragUpdate: (details) {
              // Update the drag distance
              _dragDistance += details.primaryDelta ?? 0;

              // Check if the drag exceeds the threshold to change the page
              if (_dragDistance > _dragThreshold) {
                // Swiped right (moving to previous page)
                setState(() {
                  _currentPage--;
                  if (_currentPage < 0) {
                    _currentPage = 0; // Ensure it doesn't go below the first page
                  }
                });
                _dragDistance = 0; // Reset the drag distance
              } else if (_dragDistance < -_dragThreshold) {
                // Swiped left (moving to next page)
                setState(() {
                  _currentPage++;
                  if (_currentPage >= 5) {
                    _currentPage = 0; // Wrap around to the first page if exceeded
                  }
                });
                _dragDistance = 0; // Reset the drag distance
              }
            },
            onHorizontalDragEnd: (details) {
              // Reset the drag distance when the drag ends
              _dragDistance = 0;
            },

            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, // Allow vertical scrolling
              child: selectedInvoices.isEmpty
                  ? Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.redAccent.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    "Lütfen önce ${getTitleForIndex(_currentPage)} ekleyin.",
                    style: GoogleFonts.montserrat(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              )
                  : Container(
                height: _height,
                child: Center(
                  child: Text('Add Sample Invoice'),
                ),
              ),
            ),
          )
              : NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                double currentOffset = scrollNotification.metrics.pixels;
                width = selectedInvoices.length == 1 ? 20 : width;
                print("currentOffset : $currentOffset");
                print("selectedInvoices.length : ${selectedInvoices.length}");
                if (currentOffset < width) {
                  setState(() {
                    _showRightArrow = false;
                    _rightArrowOpacity = 0.0;
                  });
                } else if (currentOffset >= width && currentOffset < (width + 90)) {
                  setState(() {
                    _showRightArrow = true;
                    _rightArrowOpacity = (currentOffset - width) / ((width + 90) - width);
                  });
                } else if (currentOffset >= (width + 90)) {
                  setState(() {
                    _showRightArrow = true;
                    _rightArrowOpacity = 1.0;
                  });
                }

                if (currentOffset < 0) {
                  if (currentOffset > -100) {
                    // User is scrolling to the left but not beyond -100
                    setState(() {
                      _showLeftArrow = true;
                      _leftArrowOpacity = (currentOffset.abs()) / 100;
                    });
                  } else if (currentOffset <= -100 && !_isTouching) {
                    // User has scrolled more than -100, go to the last page (4)
                    if (_currentPage == 0) {
                      setState(() {
                        _currentPage = 4;
                        _showLeftArrow = false;
                      });
                    } else {
                      setState(() {
                        _currentPage--;
                        _showLeftArrow = false;
                      });
                    }
                  }
                }


                if (_rightArrowOpacity == 1.0 && !_isTouching) {
                  int nextPage = (_currentPage + 1) % categorizedInvoices.length;
                  if (_currentPage != nextPage) {
                    setState(() {
                      _currentPage = nextPage;
                      _showRightArrow = false;
                    });
                  }
                }
              }
              return false;
            },
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                setState(() {
                  _isTouching = true; // User started touching the screen
                });
              },
              onPointerUp: (event) {
                setState(() {
                  _isTouching = false; // User stopped touching the screen
                });
              },
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      key: _scrollWidthKey,
                      children: selectedInvoices.length == 1
                          ? [
                        // Add extra width to the container if there is only one InvoiceCard
                        SizedBox(width: (_widthIntrinsic != null ? (_widthIntrinsic! - 200.w) / 2 : 0)),

                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 50, 0),
                          child: InvoiceCard(
                            invoice: selectedInvoices.first,
                            onDelete: () => payInvoice(selectedInvoices.first, selectedInvoices.first.id, selectedInvoices.first.periodDate, selectedInvoices.first.dueDate),
                            onEdit: () {
                              // Handle edit logic
                            },
                          ),
                        ),
                      ]
                          : selectedInvoices.map((invoice) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: InvoiceCard(
                            invoice: invoice,
                            onDelete: () => payInvoice(invoice, invoice.id, invoice.periodDate, invoice.dueDate),
                            onEdit: () {
                              // Handle edit logic
                            },
                          ),
                        );
                      }).toList(),
                    ),

                  ),
                  if (_showLeftArrow)
                    Positioned(
                      left:10,
                      top:((_height! / 2)-20).toDouble(),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: AnimatedOpacity(
                          opacity: _leftArrowOpacity,
                          duration: Duration(milliseconds: 300),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  if (_showRightArrow)
                    Positioned(
                      right:10,
                      top:((_height! / 2)-20).toDouble(),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: AnimatedOpacity(
                          opacity: _rightArrowOpacity,
                          duration: Duration(milliseconds: 300),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.green,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        buildIndicator(5, _currentPage),
        if (_height != null)
          Text('Height of IntrinsicHeight: ${_height!.toString()} px'),
      ],
    );
  }
}