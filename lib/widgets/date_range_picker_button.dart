import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateRangePickerButton extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;
  final VoidCallback onReset;

  const DateRangePickerButton({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeSelected,
    required this.onReset,
  }) : super(key: key);

  Future<String> _formatDateRange() async {
    if (startDate != null && endDate != null) {
      final DateFormat dateFormat = DateFormat('dd MMMM yyyy', 'tr');
      return '${dateFormat.format(startDate!)} - ${dateFormat.format(endDate!)}';
    }
    return 'Gün Aralığı Seç';
  }

  void _showDateRangePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tarih Aralığı Seç',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SfDateRangePicker(
                  backgroundColor: const Color(0xFFFCF5FD),
                  selectionMode: DateRangePickerSelectionMode.range,
                  onSelectionChanged: (args) {
                    onDateRangeSelected(
                      args.value.startDate,
                      args.value.endDate,
                    );
                    Navigator.pop(context);
                  },
                  showActionButtons: false,
                  initialSelectedRange: startDate != null && endDate != null
                      ? PickerDateRange(startDate, endDate)
                      : null,
                  headerStyle: const DateRangePickerHeaderStyle(
                    backgroundColor: Color(0xFFFCF5FD),
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue
                    ),
                  ),
                  monthViewSettings: DateRangePickerMonthViewSettings(
                    weekendDays: const [6, 7],
                    firstDayOfWeek: 1,
                    showTrailingAndLeadingDates: true,
                    viewHeaderStyle: DateRangePickerViewHeaderStyle(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue
                      ),
                    ),
                  ),
                  selectionColor: Colors.blueAccent.withOpacity(0.5),
                  startRangeSelectionColor: Colors.blue,
                  endRangeSelectionColor: Colors.blue,
                  rangeSelectionColor: Colors.blue.withOpacity(0.2),
                  todayHighlightColor: Colors.red,
                  toggleDaySelection: true,
                  showNavigationArrow: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _showDateRangePicker(context),
          child: FutureBuilder<String>(
            future: _formatDateRange(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(
                    'Yükleniyor...',
                    style: GoogleFonts.montserrat(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.normal
                    )
                );
              }
              return Text(
                  snapshot.data ?? 'Gün Aralığı Seç',
                  style: GoogleFonts.montserrat(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.normal
                  )
              );
            },
          ),
        ),
        SizedBox(width: 10.w),
        ElevatedButton(
          onPressed: onReset,
          child: Text(
              "Sıfırla",
              style: GoogleFonts.montserrat(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w500
              )
          ),
        )
      ],
    );
  }
}