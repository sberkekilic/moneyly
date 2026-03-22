import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models/account.dart';

class AccountDetailsCard extends StatelessWidget {
  final Account account;
  final VoidCallback onInfoPressed;

  const AccountDetailsCard({
    super.key,
    required this.account,
    required this.onInfoPressed,
  });

  static final _fmt = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2);
  static final _fmtCompact = NumberFormat.compact(locale: 'tr_TR');
  static final _dateFmt = DateFormat('d MMM', 'tr');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white54 : Colors.grey.shade600;
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderCol = isDark ? Colors.white10 : Colors.grey.shade200;

    final isCredit = !account.isDebit;
    final accentColor = account.isDebit ? Colors.blueAccent : Colors.purple;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderCol),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // ════════════════════════════════════════
          // TOP SECTION — Account Info + Balance
          // ════════════════════════════════════════
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                // Icon
                _AccountIcon(isDebit: account.isDebit, color: accentColor, isDark: isDark),
                SizedBox(width: 12.w),

                // Name + Type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          _TypeBadge(isDebit: account.isDebit, isDark: isDark),
                          SizedBox(width: 6.w),
                          Text(
                            account.currency,
                            style: GoogleFonts.montserrat(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Balance (main focus)
                GestureDetector(
                  onTap: onInfoPressed,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_fmt.format(account.balance ?? 0)} ₺',
                        style: GoogleFonts.montserrat(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Detaylar',
                            style: GoogleFonts.montserrat(
                              fontSize: 10.sp,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(LucideIcons.chevronRight, size: 12.r, color: Colors.blueAccent),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ════════════════════════════════════════
          // CREDIT CARD SECTION (only for credit)
          // ════════════════════════════════════════
          if (isCredit) _CreditSection(account: account, isDark: isDark),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// ACCOUNT ICON
// ══════════════════════════════════════════════════════════════════════════

class _AccountIcon extends StatelessWidget {
  final bool isDebit;
  final Color color;
  final bool isDark;

  const _AccountIcon({required this.isDebit, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        isDebit ? LucideIcons.wallet : LucideIcons.creditCard,
        color: color,
        size: 18.r,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// TYPE BADGE
// ══════════════════════════════════════════════════════════════════════════

class _TypeBadge extends StatelessWidget {
  final bool isDebit;
  final bool isDark;

  const _TypeBadge({required this.isDebit, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDebit ? Colors.blueAccent : Colors.purple;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        isDebit ? 'Banka' : 'Kredi',
        style: GoogleFonts.montserrat(
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// CREDIT SECTION — Compact Mobile-First Design
// ══════════════════════════════════════════════════════════════════════════

class _CreditSection extends StatelessWidget {
  final Account account;
  final bool isDark;

  const _CreditSection({required this.account, required this.isDark});

  static final _fmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);
  static final _fmtFull = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);
  static final _dateFmt = DateFormat('d MMM', 'tr');

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark ? Colors.white38 : Colors.grey.shade500;

    final limit = account.creditLimit ?? 0.0;
    final available = account.availableCredit ?? 0.0;
    final used = limit - available;
    final progress = limit == 0 ? 0.0 : (used / limit).clamp(0.0, 1.0);
    final barColor = _progressColor(progress);

    final minPayment = account.minPayment ?? 0.0;
    final totalDebt = account.totalDebt ?? 0.0;
    final currentDebt = account.currentDebt ?? 0.0;

    return Container(
      padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
      child: Column(
        children: [
          // ── Divider ──
          Divider(height: 1, color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200),
          SizedBox(height: 14.h),

          // ═══════════════════════════════════════════
          // USAGE BAR — Full Width
          // ═══════════════════════════════════════════
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kullanım',
                          style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w600, color: mutedColor),
                        ),
                        Text(
                          '${_fmt.format(used)} / ${_fmt.format(limit)}',
                          style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Stack(
                      children: [
                        Container(
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              // Percentage Circle
              _PercentageCircle(progress: progress, color: barColor, isDark: isDark),
            ],
          ),

          SizedBox(height: 14.h),

          // ═══════════════════════════════════════════
          // STATS — 2x2 Grid (Compact)
          // ═══════════════════════════════════════════
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: LucideIcons.circleCheck,
                  label: 'Kullanılabilir',
                  value: _fmt.format(available),
                  color: Colors.green,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _StatTile(
                  icon: LucideIcons.receipt,
                  label: 'Dönem Borcu',
                  value: _fmt.format(currentDebt),
                  color: Colors.orange,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: LucideIcons.trendingDown,
                  label: 'Toplam Borç',
                  value: _fmt.format(totalDebt),
                  color: Colors.red,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _StatTile(
                  icon: LucideIcons.circleAlert,
                  label: 'Asgari Ödeme',
                  value: _fmt.format(minPayment),
                  color: Colors.purple,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          // ═══════════════════════════════════════════
          // DUE DATE BANNER (if present)
          // ═══════════════════════════════════════════
          if (account.nextDueDate != null) ...[
            SizedBox(height: 12.h),
            _DueDateBanner(dueDate: account.nextDueDate!, isDark: isDark),
          ],
        ],
      ),
    );
  }

  Color _progressColor(double progress) {
    if (progress >= 0.8) return Colors.red;
    if (progress >= 0.6) return Colors.orange;
    return Colors.green;
  }
}

// ══════════════════════════════════════════════════════════════════════════
// PERCENTAGE CIRCLE — Compact visual indicator
// ══════════════════════════════════════════════════════════════════════════

class _PercentageCircle extends StatelessWidget {
  final double progress;
  final Color color;
  final bool isDark;

  const _PercentageCircle({required this.progress, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(isDark ? 0.12 : 0.08),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 36.r,
            height: 36.r,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3.r,
              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(
            '${(progress * 100).toInt()}',
            style: GoogleFonts.montserrat(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// STAT TILE — Compact with icon
// ══════════════════════════════════════════════════════════════════════════

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 14.r, color: color),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 9.sp,
                    color: isDark ? Colors.white38 : Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// DUE DATE BANNER — Compact and informative
// ══════════════════════════════════════════════════════════════════════════

class _DueDateBanner extends StatelessWidget {
  final DateTime dueDate;
  final bool isDark;

  const _DueDateBanner({required this.dueDate, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final daysLeft = dueDate.difference(DateTime.now()).inDays;
    final color = _getColor(daysLeft);
    final dateFmt = DateFormat('d MMMM', 'tr');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            daysLeft < 0 ? LucideIcons.triangleAlert : LucideIcons.calendar,
            size: 16.r,
            color: color,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Son Ödeme Tarihi',
                  style: GoogleFonts.montserrat(fontSize: 9.sp, color: isDark ? Colors.white38 : Colors.grey),
                ),
                SizedBox(height: 2.h),
                Text(
                  dateFmt.format(dueDate),
                  style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: color),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              _getDaysLabel(daysLeft),
              style: GoogleFonts.montserrat(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(int daysLeft) {
    if (daysLeft < 0) return Colors.red;
    if (daysLeft <= 3) return Colors.red;
    if (daysLeft <= 7) return Colors.orange;
    return Colors.green;
  }

  String _getDaysLabel(int daysLeft) {
    if (daysLeft < 0) return '${daysLeft.abs()} gün geçti';
    if (daysLeft == 0) return 'Bugün!';
    if (daysLeft == 1) return 'Yarın';
    return '$daysLeft gün';
  }
}