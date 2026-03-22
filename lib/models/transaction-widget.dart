import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../blocs/transaction/transaction_bloc.dart';
import '../components/edit_transaction_modal.dart';
import '../pages/add-expense/faturalar.dart';
import 'account.dart';
import 'category.dart';
import 'transaction.dart';

class TransactionWidget extends StatefulWidget {
  final List<Invoice> invoices;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<Account> accounts;

  const TransactionWidget({
    super.key,
    required this.invoices,
    this.startDate,
    this.endDate,
    required this.accounts,
  });

  @override
  State<TransactionWidget> createState() => _TransactionWidgetState();
}

class _TransactionWidgetState extends State<TransactionWidget> {
  int _currentPage = 0;
  static const int _itemsPerPage = 8;
  List<CategoryData> _userCategories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadTransactions();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    final categories = await CategoryStorage.load();
    if (mounted) {
      setState(() {
        _userCategories = categories;
        _isLoadingCategories = false;
      });
    }
  }

  void _loadTransactions() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionBloc>().add(LoadTransactions(
          startDate: widget.startDate,
          endDate: widget.endDate,
        ));
      }
    });
  }

  List<String> get _uniqueCategories {
    final cats = _userCategories.map((c) => c.category).toSet().toList();
    return cats.isNotEmpty ? cats : ['Genel'];
  }

  List<String> _getSubcategories(String category) {
    final subs = _userCategories
        .where((c) => c.category == category)
        .map((c) => c.subcategory)
        .toSet()
        .toList();
    return subs.isNotEmpty ? subs : ['Genel'];
  }

  // ══════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      buildWhen: (prev, curr) =>
      prev.transactions != curr.transactions ||
          prev.filteredTransactions != curr.filteredTransactions,
      builder: (context, state) => _buildContent(state.filteredTransactions),
    );
  }

  Widget _buildContent(List<Transaction> transactions) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white54 : Colors.grey.shade600;

    // Filter by date range
    final filtered = transactions.where((t) {
      final afterStart = widget.startDate == null || !t.date.isBefore(widget.startDate!);
      final beforeEnd = widget.endDate == null || !t.date.isAfter(widget.endDate!);
      return afterStart && beforeEnd;
    }).toList();

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    if (filtered.isEmpty) {
      return _EmptyState(isDark: isDark);
    }

    final totalPages = (filtered.length / _itemsPerPage).ceil();
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filtered.length);
    final pageItems = filtered.sublist(startIndex, endIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──
        _buildHeader(filtered.length, textColor, mutedColor),
        SizedBox(height: 12.h),

        // ── Transaction List ──
        ...pageItems.asMap().entries.map((entry) {
          final index = entry.key;
          final tx = entry.value;
          return _TransactionTile(
            transaction: tx,
            isDark: isDark,
            isLast: index == pageItems.length - 1,
            onTap: () => _showEditSheet(tx),
            onLongPress: () => _showDeleteDialog(tx),
          );
        }),

        // ── Pagination ──
        if (totalPages > 1) ...[
          SizedBox(height: 16.h),
          _Pagination(
            currentPage: _currentPage,
            totalPages: totalPages,
            totalItems: filtered.length,
            startIndex: startIndex + 1,
            endIndex: endIndex,
            onPrevious: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
            onNext: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  Widget _buildHeader(int count, Color textColor, Color mutedColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'İşlemler',
            style: GoogleFonts.montserrat(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '$count işlem',
              style: GoogleFonts.montserrat(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ACTIONS
  // ══════════════════════════════════════════════════════════════

  void _showEditSheet(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditTransactionModal(
        transaction: transaction,
        userCategories: _userCategories,
        onTransactionUpdated: (updated) {
          TransactionService.updateTransaction(updated);
          context.read<TransactionBloc>().add(UpdateTransaction(updated));
          _snack('İşlem güncellendi', Colors.green);
        },
        onTransactionDeleted: (id, isInstallment) => _showDeleteDialog(transaction),
      ),
    );
  }

  void _showDeleteDialog(Transaction transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInstallment = transaction.isInstallment && (transaction.installment ?? 0) > 1;

    final blocState = context.read<TransactionBloc>().state;
    final relatedCount = isInstallment
        ? blocState.transactions
        .where((t) =>
    t.parentTransactionId == transaction.parentTransactionId ||
        (t.initialInstallmentDate == transaction.initialInstallmentDate &&
            t.title.contains(transaction.title.split(' (')[0]) &&
            t.category == transaction.category))
        .length
        : 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Icon(LucideIcons.triangleAlert, color: Colors.red, size: 22.r),
            SizedBox(width: 10.w),
            Text('İşlemi Sil', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 18.sp)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isInstallment) ...[
              _InfoBanner(
                icon: LucideIcons.layers,
                text: '${transaction.installment} taksitli işlem ($relatedCount taksit bulundu)',
                color: Colors.orange,
                isDark: isDark,
              ),
              SizedBox(height: 12.h),
            ],
            Text(
              isInstallment ? 'Hangi işlemi silmek istiyorsunuz?' : '"${transaction.title}" işlemini silmek istediğinize emin misiniz?',
              style: GoogleFonts.montserrat(fontSize: 13.sp, color: isDark ? Colors.white70 : Colors.black87),
            ),
          ],
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal', style: GoogleFonts.montserrat(color: Colors.grey)),
          ),
          if (isInstallment) ...[
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<TransactionBloc>().add(DeleteTransaction(transaction.transactionId, deleteAllInstallments: false));
                _snack('Taksit silindi', Colors.orange);
              },
              child: Text('Sadece Bu', style: GoogleFonts.montserrat(color: Colors.orange, fontWeight: FontWeight.w600)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx);
                context.read<TransactionBloc>().add(DeleteTransaction(transaction.transactionId, deleteAllInstallments: true));
                _snack('Tüm taksitler silindi', Colors.red);
              },
              child: Text('Tümünü Sil', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
            ),
          ] else
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx);
                context.read<TransactionBloc>().add(DeleteTransaction(transaction.transactionId));
                _snack('İşlem silindi', Colors.red);
              },
              child: Text('Sil', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.montserrat()),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TRANSACTION TILE
// ══════════════════════════════════════════════════════════════════════════════

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final bool isDark;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TransactionTile({
    required this.transaction,
    required this.isDark,
    required this.isLast,
    required this.onTap,
    required this.onLongPress,
  });

  static final _dateFmt = DateFormat('d MMM', 'tr');
  static final _moneyFmt = NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white38 : Colors.grey.shade500;

    // Status logic
    final now = DateTime.now();
    final isPast = t.date.isBefore(now);
    final status = t.isProvisioned
        ? _Status(Colors.orange, LucideIcons.clock, 'Tahakkuk')
        : isPast
        ? _Status(Colors.green, LucideIcons.circleCheck, 'Tamamlandı')
        : _Status(Colors.blueAccent, LucideIcons.calendar, 'Bekliyor');

    // Amount color based on type
    final amountColor = t.isSurplus ? Colors.green : status.color;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
      child: Material(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            onLongPress();
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                // ── Status Icon ──
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: status.color.withOpacity(isDark ? 0.12 : 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(status.icon, size: 18.r, color: status.color),
                ),
                SizedBox(width: 12.w),

                // ── Content ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        t.title,
                        style: GoogleFonts.montserrat(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),

                      // Tags row
                      Row(
                        children: [
                          // Category
                          if (t.category.isNotEmpty) ...[
                            _Tag(text: t.category, color: Colors.blueAccent, isDark: isDark),
                            SizedBox(width: 4.w),
                          ],

                          // Status
                          _Tag(text: status.label, color: status.color, isDark: isDark),

                          // Installment
                          if (t.isInstallment && t.installment != null && t.installment! > 1) ...[
                            SizedBox(width: 4.w),
                            _Tag(
                              text: '${t.currentInstallment ?? 1}/${t.installment}',
                              color: Colors.purple,
                              isDark: isDark,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),

                      // Date
                      Text(
                        _dateFmt.format(t.date),
                        style: GoogleFonts.montserrat(fontSize: 10.sp, color: mutedColor),
                      ),
                    ],
                  ),
                ),

                // ── Amount ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.isSurplus ? '+' : '-',
                          style: GoogleFonts.montserrat(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: amountColor,
                          ),
                        ),
                        Text(
                          _moneyFmt.format(t.amount.abs()),
                          style: GoogleFonts.montserrat(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      t.currency,
                      style: GoogleFonts.montserrat(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: amountColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Status {
  final Color color;
  final IconData icon;
  final String label;
  const _Status(this.color, this.icon, this.label);
}

// ══════════════════════════════════════════════════════════════════════════════
// TAG
// ══════════════════════════════════════════════════════════════════════════════

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  final bool isDark;

  const _Tag({required this.text, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PAGINATION
// ══════════════════════════════════════════════════════════════════════════════

class _Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int startIndex;
  final int endIndex;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool isDark;

  const _Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.startIndex,
    required this.endIndex,
    required this.onPrevious,
    required this.onNext,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white38 : Colors.grey.shade500;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous
          _PaginationButton(
            icon: LucideIcons.chevronLeft,
            onTap: onPrevious,
            isDark: isDark,
          ),

          // Info
          Column(
            children: [
              Text(
                '${currentPage + 1} / $totalPages',
                style: GoogleFonts.montserrat(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '$startIndex-$endIndex / $totalItems işlem',
                style: GoogleFonts.montserrat(fontSize: 10.sp, color: mutedColor),
              ),
            ],
          ),

          // Next
          _PaginationButton(
            icon: LucideIcons.chevronRight,
            onTap: onNext,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  const _PaginationButton({required this.icon, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final color = isDisabled ? Colors.grey : Colors.blueAccent;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, size: 18.r, color: color),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ══════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final bool isDark;

  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark ? Colors.white38 : Colors.grey.shade400;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: mutedColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.receipt, size: 32.r, color: mutedColor),
          ),
          SizedBox(height: 16.h),
          Text(
            'İşlem bulunamadı',
            style: GoogleFonts.montserrat(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: mutedColor,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Bu tarih aralığında işlem yok',
            style: GoogleFonts.montserrat(fontSize: 12.sp, color: mutedColor.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// INFO BANNER (for dialogs)
// ══════════════════════════════════════════════════════════════════════════════

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isDark;

  const _InfoBanner({
    required this.icon,
    required this.text,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.r, color: color),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HELPER: Category Icon
// ══════════════════════════════════════════════════════════════════════════════

IconData getCategoryIcon(String category) => switch (category) {
  'Abonelikler' => LucideIcons.tv,
  'Faturalar' => LucideIcons.receipt,
  'Diğer Giderler' => LucideIcons.shoppingBag,
  'Gelir' => LucideIcons.trendingUp,
  'Market' => LucideIcons.shoppingCart,
  'Ulaşım' => LucideIcons.car,
  'Yeme İçme' => LucideIcons.utensils,
  'Sağlık' => LucideIcons.heart,
  'Eğlence' => LucideIcons.gamepad2,
  'Giyim' => LucideIcons.shirt,
  'Eğitim' => LucideIcons.graduationCap,
  'Konut' => LucideIcons.house,
  _ => LucideIcons.folder,
};