import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FinancialMetricCards extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double netProfit;
  final String formattedIncome;
  final String formattedExpense;
  final String formattedProfit;
  final bool isDebtVisible;
  final VoidCallback onToggleVisibility;

  const FinancialMetricCards({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
    required this.formattedIncome,
    required this.formattedExpense,
    required this.formattedProfit,
    required this.isDebtVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white54 : Colors.grey.shade600;
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderCol = isDark ? Colors.white10 : Colors.grey.shade200;

    // Calculate real progress: expense vs income ratio
    final expenseRatio = totalIncome > 0 ? (totalExpense / totalIncome).clamp(0.0, 1.0) : 0.0;
    final profitRatio = totalIncome > 0 ? (netProfit.abs() / totalIncome).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: borderCol),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Finansal Özet',
                style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.w700, color: textColor),
              ),
              _VisibilityToggle(
                isVisible: isDebtVisible,
                onToggle: onToggleVisibility,
                isDark: isDark,
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // ── Income ──
          _MetricTile(
            label: 'Toplam Gelir',
            value: isDebtVisible ? formattedIncome : '••••••',
            icon: LucideIcons.trendingUp,
            color: const Color(0xFF10B981), // Green
            progress: 1.0, // Income is always the baseline (100%)
            isDark: isDark,
            textColor: textColor,
            mutedColor: mutedColor,
          ),
          SizedBox(height: 12.h),

          // ── Expense ──
          _MetricTile(
            label: 'Toplam Gider',
            value: isDebtVisible ? formattedExpense : '••••••',
            icon: LucideIcons.trendingDown,
            color: const Color(0xFFEF4444), // Red
            progress: expenseRatio,
            isDark: isDark,
            textColor: textColor,
            mutedColor: mutedColor,
          ),
          SizedBox(height: 12.h),

          // ── Net Profit ──
          _MetricTile(
            label: netProfit >= 0 ? 'Net Kâr' : 'Net Zarar',
            value: isDebtVisible ? formattedProfit : '••••••',
            icon: netProfit >= 0 ? LucideIcons.wallet : LucideIcons.triangleAlert,
            color: netProfit >= 0 ? Colors.blueAccent : const Color(0xFFF59E0B),
            progress: profitRatio,
            isDark: isDark,
            textColor: textColor,
            mutedColor: mutedColor,
            showSign: true,
            isPositive: netProfit >= 0,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// METRIC TILE
// ══════════════════════════════════════════════════════

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double progress;
  final bool isDark;
  final Color textColor;
  final Color mutedColor;
  final bool showSign;
  final bool isPositive;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.progress,
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
    this.showSign = false,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final tileBg = isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50;
    final borderCol = isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200;
    final isHidden = value == '••••••';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        children: [
          // ── Top Row: Icon + Label + Value ──
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 18.r, color: color),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: textColor),
                ),
              ),
              if (isHidden)
                Text(
                  value,
                  style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.w700, color: mutedColor, letterSpacing: 2),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    if (showSign)
                      Text(
                        isPositive ? '+' : '-',
                        style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.w700, color: color),
                      ),
                    Text(
                      value == '0,00' ? '—' : value,
                      style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.w700, color: textColor),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '₺',
                      style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w600, color: color),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 14.h),

          // ── Progress Bar ──
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
              color: color,
            ),
          ),
          SizedBox(height: 8.h),

          // ── Footer ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _progressLabel,
                style: GoogleFonts.montserrat(fontSize: 11.sp, color: mutedColor),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '%${(progress * 100).toStringAsFixed(0)}',
                  style: GoogleFonts.montserrat(fontSize: 10.sp, fontWeight: FontWeight.w600, color: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _progressLabel {
    if (label.contains('Gelir')) return 'Gelir tabanı';
    if (label.contains('Gider')) return 'Gelire oranla gider';
    if (label.contains('Kâr')) return 'Gelire oranla kâr';
    if (label.contains('Zarar')) return 'Gelire oranla zarar';
    return '';
  }
}

// ══════════════════════════════════════════════════════
// VISIBILITY TOGGLE
// ══════════════════════════════════════════════════════

class _VisibilityToggle extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onToggle;
  final bool isDark;

  const _VisibilityToggle({
    required this.isVisible,
    required this.onToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          isVisible ? LucideIcons.eye : LucideIcons.eyeOff,
          size: 18.r,
          color: isDark ? Colors.white54 : Colors.grey.shade600,
        ),
      ),
    );
  }
}