import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback onInfoPressed;
  final VoidCallback? onSendPressed;
  final VoidCallback? onDepositPressed;
  final VoidCallback? onReceiptPressed;

  const QuickActionsRow({
    super.key,
    required this.onInfoPressed,
    this.onSendPressed,
    this.onDepositPressed,
    this.onReceiptPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderCol = isDark ? Colors.white10 : Colors.grey.shade200;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderCol),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          _QuickActionItem(
            icon: LucideIcons.arrowUpRight,
            label: 'Gönder',
            color: Colors.blueAccent,
            onTap: onSendPressed,
            isDark: isDark,
          ),
          _QuickActionItem(
            icon: LucideIcons.arrowDownLeft,
            label: 'Yatır',
            color: Colors.green,
            onTap: onDepositPressed,
            isDark: isDark,
          ),
          _QuickActionItem(
            icon: LucideIcons.receipt,
            label: 'Dekont',
            color: Colors.orange,
            onTap: onReceiptPressed,
            isDark: isDark,
          ),
          _QuickActionItem(
            icon: LucideIcons.grip,
            label: 'Diğer',
            color: Colors.purple,
            onTap: onInfoPressed,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isDark;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_QuickActionItem> createState() => _QuickActionItemState();
}

class _QuickActionItemState extends State<_QuickActionItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;
    final iconColor = isDisabled ? Colors.grey : widget.color;
    final labelColor = isDisabled
        ? Colors.grey
        : (widget.isDark ? Colors.white70 : Colors.black87);

    return Expanded(
      child: GestureDetector(
        onTapDown: isDisabled ? null : _onTapDown,
        onTapUp: isDisabled ? null : _onTapUp,
        onTapCancel: isDisabled ? null : _onTapCancel,
        onTap: isDisabled
            ? null
            : () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(widget.isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: iconColor.withOpacity(widget.isDark ? 0.2 : 0.15),
                    width: 1,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  size: 20.r,
                  color: iconColor,
                ),
              ),
              SizedBox(height: 8.h),

              // Label
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// ALTERNATE VERSION — Horizontal Scrollable (for more actions)
// ══════════════════════════════════════════════════════════════════════════

class QuickActionsScrollable extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionsScrollable({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 90.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: actions.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final action = actions[index];
          return _ScrollableActionItem(action: action, isDark: isDark);
        },
      ),
    );
  }
}

class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool showBadge;

  const QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.showBadge = false,
  });
}

class _ScrollableActionItem extends StatelessWidget {
  final QuickAction action;
  final bool isDark;

  const _ScrollableActionItem({required this.action, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isDisabled = action.onTap == null;
    final color = isDisabled ? Colors.grey : action.color;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
        HapticFeedback.lightImpact();
        action.onTap?.call();
      },
      child: Container(
        width: 70.w,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
          boxShadow: isDark
              ? []
              : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: color.withOpacity(isDark ? 0.12 : 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(action.icon, size: 18.r, color: color),
                ),
                if (action.showBadge)
                  Positioned(
                    top: -4.r,
                    right: -4.r,
                    child: Container(
                      width: 10.r,
                      height: 10.r,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? const Color(0xFF1A1A1A) : Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// COMPACT VERSION — Icon Only (for tight spaces)
// ══════════════════════════════════════════════════════════════════════════

class QuickActionsCompact extends StatelessWidget {
  final VoidCallback? onSendPressed;
  final VoidCallback? onDepositPressed;
  final VoidCallback? onReceiptPressed;
  final VoidCallback onMorePressed;

  const QuickActionsCompact({
    super.key,
    this.onSendPressed,
    this.onDepositPressed,
    this.onReceiptPressed,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CompactButton(icon: LucideIcons.arrowUpRight, color: Colors.blueAccent, onTap: onSendPressed, isDark: isDark, tooltip: 'Gönder'),
        SizedBox(width: 12.w),
        _CompactButton(icon: LucideIcons.arrowDownLeft, color: Colors.green, onTap: onDepositPressed, isDark: isDark, tooltip: 'Yatır'),
        SizedBox(width: 12.w),
        _CompactButton(icon: LucideIcons.receipt, color: Colors.orange, onTap: onReceiptPressed, isDark: isDark, tooltip: 'Dekont'),
        SizedBox(width: 12.w),
        _CompactButton(icon: LucideIcons.ellipsis, color: Colors.grey, onTap: onMorePressed, isDark: isDark, tooltip: 'Diğer'),
      ],
    );
  }
}

class _CompactButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isDark;
  final String tooltip;

  const _CompactButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isDark,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final effectiveColor = isDisabled ? Colors.grey : color;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            color: effectiveColor.withOpacity(isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: effectiveColor.withOpacity(0.2)),
          ),
          child: Icon(icon, size: 18.r, color: effectiveColor),
        ),
      ),
    );
  }
}