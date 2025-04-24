import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../pages/add-expense/faturalar.dart';

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  InvoiceCard({super.key,
    required this.invoice,
    required this.onDelete,
    required this.onEdit
  }) {
    faturaDonemi = DateTime.parse(invoice.periodDate);
    if (invoice.dueDate != null){
      sonOdeme = DateTime.parse(invoice.dueDate!);
    }
  }

  DateTime faturaDonemi = DateTime.now();
  DateTime sonOdeme = DateTime.now();
  bool isPaidActive = false;

  String getDaysRemainingMessage2() {
    final currentDate = DateTime.now();
    final formattedCurrentDate = DateFormat('yyyy-MM-dd').format(currentDate);
    final formattedPeriodDate = DateFormat('yyyy-MM-dd').format(faturaDonemi);
    final dueDateKnown = invoice.dueDate != null;

    if (currentDate.isBefore(faturaDonemi)) {
      isPaidActive = false;
      return "Fatura kesimine kalan gün";
    } else if (dueDateKnown) {
      isPaidActive = true;
      if (currentDate.isBefore(sonOdeme)) {
        return "Son ödeme tarihine kalan gün";
      } else {
        isPaidActive = true;
        return "Ödeme için son gün";
      }
    } else if (formattedCurrentDate == formattedPeriodDate){
      isPaidActive = true;
      return "Ödeme dönemi";
    } else {
      return "Gecikme süresi";
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysRemainingMessage = getDaysRemainingMessage2();
    return IntrinsicWidth(
      child: Container(
        width: 200.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color.fromARGB(125, 169, 219, 255),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color.fromARGB(125, 70, 181, 255),
              ),
              child: ListTile(
                dense: true,
                title: Text(
                  invoice.name,
                  style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  invoice.category,
                  style: GoogleFonts.montserrat(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.normal),
                ),
              ),
            ),
            ListTile(
              dense: true,
              title: Text(
                "Fatura Dönemi",
                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                invoice.periodDate,
                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.normal),
              ),
            ),
            ListTile(
              dense: true,
              title: Text(
                "Son Ödeme Tarihi",
                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                invoice.dueDate ?? "Bilinmiyor",
                style: GoogleFonts.montserrat(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.normal),
              ),
            ),
            Flexible( // Use Flexible here
              child: Container(
                constraints: BoxConstraints(
                  minHeight: 70.h,
                ),
                child: ListTile(
                  title: Text(
                    daysRemainingMessage,
                    style: GoogleFonts.montserrat(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.normal),
                  ),
                  subtitle: daysRemainingMessage != "Ödeme dönemi" ? Text(
                    invoice.difference,
                    style: GoogleFonts.montserrat(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ) : null,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color.fromARGB(125, 173, 198, 255),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: SizedBox(
                      width: 22.h,
                      height: 22.h,
                      child: IconButton(
                        padding: EdgeInsets.zero, // Remove the default padding
                        onPressed: onDelete,
                        icon: Icon(Icons.done_rounded, size: 24),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 22.h,
                      height: 22.h,
                      child: IconButton(
                        padding: EdgeInsets.zero, // Remove the default padding
                        onPressed: onEdit,
                        icon: Icon(Icons.edit_rounded, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}