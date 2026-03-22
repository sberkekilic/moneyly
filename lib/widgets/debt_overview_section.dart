import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DebtOverviewSection extends StatefulWidget {
  final double totalDebt;
  final double remainingDebt;
  final double newDebt;
  final List<dynamic> debts;
  final bool isDebtVisible;

  const DebtOverviewSection({
    super.key,
    required this.totalDebt,
    required this.remainingDebt,
    required this.newDebt,
    required this.debts,
    required this.isDebtVisible,
  });

  @override
  State<DebtOverviewSection> createState() => _DebtOverviewSectionState();
}

class _DebtOverviewSectionState extends State<DebtOverviewSection> {
  bool _expanded = false;

  static final _currencyFmt = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    if (!widget.isDebtVisible || widget.totalDebt <= 0) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white54 : Colors.grey.shade600;
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderCol = isDark ? Colors.white10 : Colors.grey.shade200;

    // Debt severity color
    final utilization = widget.totalDebt > 0 ? (widget.remainingDebt / widget.totalDebt).clamp(0.0, 1.0) : 0.0;
    final severityColor = _severityColor(utilization);

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderCol),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          _buildHeader(textColor, mutedColor, severityColor, isDark),
          SizedBox(height: 20.h),

          // ── Metric Cards ──
          Row(
            children: [
              Expanded(child: _DebtMetricCard(label: 'Önceki Dönem', amount: widget.remainingDebt, icon: LucideIcons.history, isDark: isDark)),
              SizedBox(width: 12.w),
              Expanded(child: _DebtMetricCard(label: 'Yeni Borçlar', amount: widget.newDebt, icon: LucideIcons.plus, isDark: isDark)),
            ],
          ),
          SizedBox(height: 20.h),

          // ── Utilization Bar ──
          _buildUtilizationBar(utilization, severityColor, textColor, mutedColor, isDark),

          // ── Debt Details ──
          if (widget.debts.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildExpandToggle(isDark),
            if (_expanded) ...[
              SizedBox(height: 12.h),
              ...widget.debts.map((debt) => _DebtItemTile(debt: debt, isDark: isDark)),
            ],
          ],
        ],
      ),
    );
  }

  // ── Header ──

  Widget _buildHeader(Color textColor, Color mutedColor, Color severityColor, bool isDark) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: severityColor.withOpacity(isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(LucideIcons.circleAlert, size: 20.r, color: severityColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Toplam Borç',
                style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w500, color: mutedColor),
              ),
              SizedBox(height: 2.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _currencyFmt.format(widget.totalDebt),
                      style: GoogleFonts.montserrat(fontSize: 22.sp, fontWeight: FontWeight.w700, color: severityColor),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '₺',
                      style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w600, color: severityColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Severity badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: severityColor.withOpacity(isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            _severityLabel(widget.totalDebt),
            style: GoogleFonts.montserrat(fontSize: 10.sp, fontWeight: FontWeight.w700, color: severityColor),
          ),
        ),
      ],
    );
  }

  // ── Utilization Bar ──

  Widget _buildUtilizationBar(double utilization, Color color, Color textColor, Color mutedColor, bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Borç Kullanım Oranı',
              style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w500, color: textColor),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                '%${(utilization * 100).toStringAsFixed(0)}',
                style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w600, color: color),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: utilization,
            minHeight: 8.h,
            backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
            color: color,
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ödenen: ${_currencyFmt.format(widget.totalDebt - widget.remainingDebt)} ₺',
              style: GoogleFonts.montserrat(fontSize: 10.sp, color: mutedColor),
            ),
            Text(
              'Kalan: ${_currencyFmt.format(widget.remainingDebt)} ₺',
              style: GoogleFonts.montserrat(fontSize: 10.sp, color: mutedColor),
            ),
          ],
        ),
      ],
    );
  }

  // ── Expand Toggle ──

  Widget _buildExpandToggle(bool isDark) {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
              size: 16.r,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
            SizedBox(width: 8.w),
            Text(
              _expanded ? 'Detayları Gizle' : '${widget.debts.length} borç detayını göster',
              style: GoogleFonts.montserrat(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──

  Color _severityColor(double utilization) {
    if (utilization >= 0.8) return Colors.red;
    if (utilization >= 0.5) return Colors.orange;
    return Colors.blueAccent;
  }

  String _severityLabel(double totalDebt) {
    if (totalDebt >= 50000) return 'YÜKSEK';
    if (totalDebt >= 10000) return 'ORTA';
    return 'DÜŞÜK';
  }
}

// ══════════════════════════════════════════════════════
// DEBT METRIC CARD
// ══════════════════════════════════════════════════════

class _DebtMetricCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final bool isDark;

  const _DebtMetricCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.isDark,
  });

  static final _fmt = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white54 : Colors.grey.shade600;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 14.r, color: Colors.orange),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w500, color: mutedColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _fmt.format(amount),
                  style: GoogleFonts.montserrat(fontSize: 17.sp, fontWeight: FontWeight.w700, color: textColor),
                ),
                SizedBox(width: 3.w),
                Text(
                  '₺',
                  style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.orange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// DEBT ITEM TILE
// ══════════════════════════════════════════════════════

class _DebtItemTile extends StatelessWidget {
  final dynamic debt;
  final bool isDark;

  const _DebtItemTile({required this.debt, required this.isDark});

  static final _fmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white38 : Colors.grey.shade500;

    final description = (debt is Map ? debt['description'] : null) ?? 'Borç';
    final amount = (debt is Map ? (debt['amount'] as num?)?.toDouble() : null) ?? 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(isDark ? 0.1 : 0.06),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(LucideIcons.receipt, size: 16.r, color: Colors.orange),
            ),
            SizedBox(width: 12.w),

            // Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: textColor),
                  ),
                  if (debt is Map && debt['dueDate'] != null) ...[
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(LucideIcons.calendar, size: 11.r, color: mutedColor),
                        SizedBox(width: 4.w),
                        Text(
                          debt['dueDate'].toString(),
                          style: GoogleFonts.montserrat(fontSize: 11.sp, color: mutedColor),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Amount
            Text(
              _fmt.format(amount),
              style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}