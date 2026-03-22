import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreviousPeriodScreen extends StatefulWidget {
  final String bankName;
  final String accountName;
  final String cutoffDate;
  final String dueDate;
  final double debt;
  final List<dynamic> transactions;
  final String periodKey; // e.g., "bankId_accountId_cutoffDate"

  const PreviousPeriodScreen({
    Key? key,
    required this.bankName,
    required this.accountName,
    required this.cutoffDate,
    required this.dueDate,
    required this.debt,
    required this.transactions,
    required this.periodKey,
  }) : super(key: key);

  @override
  State<PreviousPeriodScreen> createState() => _PreviousPeriodScreenState();
}

class _PreviousPeriodScreenState extends State<PreviousPeriodScreen> {
  bool _dontShowAgain = false;
  final moneyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          width: 0.9.sw,
          height: 0.8.sh,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            children: [
              // Header with drag handle and close button
              Container(
                padding: EdgeInsets.all(16.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Önceki Dönem Özeti',
                      style: GoogleFonts.montserrat(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account info
                      Container(
                        padding: EdgeInsets.all(16.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.bankName} - ${widget.accountName}',
                              style: GoogleFonts.montserrat(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            _infoRow('Kesim Tarihi', widget.cutoffDate),
                            _infoRow('Son Ödeme Tarihi', widget.dueDate),
                            _infoRow(
                              'Dönem Borcu',
                              moneyFormat.format(widget.debt),
                              valueColor: Colors.red,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Transactions
                      Text(
                        'Dönem İçindeki Harcamalar',
                        style: GoogleFonts.montserrat(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      if (widget.transactions.isEmpty)
                        Center(
                          child: Text(
                            'Bu dönemde işlem bulunmamaktadır.',
                            style: GoogleFonts.montserrat(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      else
                        ...widget.transactions.map((tx) => Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.all(12.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx['description'] ?? 'İşlem',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (tx['date'] != null)
                                      Text(
                                        DateFormat('dd MMM yyyy').format(
                                          DateTime.parse(tx['date']),
                                        ),
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                moneyFormat.format(tx['amount'] ?? 0),
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  color: (tx['amount'] ?? 0) > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        )),
                    ],
                  ),
                ),
              ),
              // Footer with action buttons
              Container(
                padding: EdgeInsets.all(16.h),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // "Don't show again" checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _dontShowAgain,
                          onChanged: (value) {
                            setState(() {
                              _dontShowAgain = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Bir daha bu dönem için gösterme',
                            style: GoogleFonts.montserrat(
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              if (_dontShowAgain) {
                                _markAsReadPermanently();
                              }
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Daha Sonra',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to payment screen (to be implemented)
                              if (_dontShowAgain) {
                                _markAsReadPermanently();
                              }
                              Navigator.pop(context);
                              // TODO: Navigate to payment flow
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ödeme ekranı henüz eklenmedi')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'Öde',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsReadPermanently() async {
    final prefs = await SharedPreferences.getInstance();
    // Store that this period has been dismissed
    List<String> dismissed = prefs.getStringList('dismissed_periods') ?? [];
    if (!dismissed.contains(widget.periodKey)) {
      dismissed.add(widget.periodKey);
      await prefs.setStringList('dismissed_periods', dismissed);
    }
  }
}