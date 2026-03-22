import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreviousPeriodDialog extends StatefulWidget {
  final String bankName;
  final String accountName;
  final String cutoffDate;
  final String dueDate;
  final double debt;
  final List<dynamic>? transactions;
  final String periodKey;

  const PreviousPeriodDialog({
    Key? key,
    required this.bankName,
    required this.accountName,
    required this.cutoffDate,
    required this.dueDate,
    required this.debt,
    this.transactions,
    required this.periodKey,
  }) : super(key: key);

  @override
  State<PreviousPeriodDialog> createState() => _PreviousPeriodDialogState();
}

class _PreviousPeriodDialogState extends State<PreviousPeriodDialog> {
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    final moneyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Container(
        width: 0.9.sw,
        constraints: BoxConstraints(maxHeight: 0.8.sh),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20.h),
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
                    'Önceki Dönem Bilgisi',
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
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account summary card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
                          _infoRow('Son Ödeme', widget.dueDate),
                          _infoRow(
                            'Borç',
                            moneyFormat.format(widget.debt),
                            valueColor: Colors.red,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Transactions section
                    if (widget.transactions != null && widget.transactions!.isNotEmpty) ...[
                      Text(
                        'Dönem Hareketleri',
                        style: GoogleFonts.montserrat(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ...widget.transactions!.map((tx) => Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.all(12.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.withOpacity(0.2)),
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
                          style: GoogleFonts.montserrat(fontSize: 13.sp),
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
                            'Kapat',
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
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
                            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
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
    List<String> dismissed = prefs.getStringList('dismissed_periods') ?? [];
    if (!dismissed.contains(widget.periodKey)) {
      dismissed.add(widget.periodKey);
      await prefs.setStringList('dismissed_periods', dismissed);
    }
  }
}