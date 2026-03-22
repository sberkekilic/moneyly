import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/investment_components.dart';
import '../../models/investment_models.dart';

class InvestmentPage extends StatefulWidget {
  const InvestmentPage({super.key});

  @override
  State<InvestmentPage> createState() => _InvestmentPageState();
}

class _InvestmentPageState extends State<InvestmentPage> {
  final InvestmentService _investmentService = InvestmentService();

  bool _isLoading = true;
  List<Investment> _allInvestments = [];
  List<InvestmentModel> _investmentModels = [];
  List<String> _selectedCategories = [];

  String _selectedCurrency = 'Dolar';
  String _currencySymbol = r'$';

  static const _allCategories = [
    'Döviz', 'Nakit', 'Gayrimenkül', 'Araba', 'Elektronik', 'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── Data ──────────────────────────────────────────────

  Future<void> _loadData() async {
    if (!_isLoading) setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final investments = await _investmentService.getInvestments();
      final models = await _investmentService.getInvestmentModels();
      final categories = prefs.getStringList('selectedCategories') ?? [];

      if (!mounted) return;
      setState(() {
        _allInvestments = investments;
        _investmentModels = models;
        _selectedCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InvestmentModel _findModel(Investment inv) {
    return _investmentModels.firstWhere(
          (m) => m.id == inv.id,
      orElse: () => InvestmentModel(id: inv.id, aim: 0, amount: double.tryParse(inv.amount) ?? 0),
    );
  }

  /// Filtered goals for the selected currency
  List<Investment> get _filteredInvestments {
    return _allInvestments.where((i) => i.currency == _selectedCurrency).toList();
  }

  /// Goals grouped by category (only for selected currency)
  Map<String, List<Investment>> get _groupedInvestments {
    final map = <String, List<Investment>>{};
    for (final inv in _filteredInvestments) {
      map.putIfAbsent(inv.category, () => []).add(inv);
    }
    return map;
  }

  // ── Calculations ─────────────────────────────────────

  /// Total target for selected currency
  double get _totalTarget {
    return _filteredInvestments.fold(0.0, (s, i) => s + (double.tryParse(i.amount) ?? 0));
  }

  /// Total saved for selected currency
  double get _totalSaved {
    double total = 0;
    for (final inv in _filteredInvestments) {
      final model = _findModel(inv);
      total += model.aim;
    }
    return total;
  }

  double get _progress {
    if (_totalTarget == 0) return 0;
    return (_totalSaved / _totalTarget).clamp(0.0, 1.0);
  }

  // ── Actions ──────────────────────────────────────────

  Future<void> _addToSavings(int id, double value) async {
    final idx = _investmentModels.indexWhere((m) => m.id == id);
    if (idx == -1) return;

    final old = _investmentModels[idx];
    // Find the target to cap savings
    final inv = _allInvestments.firstWhere((i) => i.id == id);
    final target = double.tryParse(inv.amount) ?? 0;
    final newAim = (old.aim + value).clamp(0.0, target);

    _investmentModels[idx] = InvestmentModel(id: id, aim: newAim, amount: old.amount);
    setState(() {});
    _persistAll();
  }

  Future<void> _removeFromSavings(int id, double value) async {
    final idx = _investmentModels.indexWhere((m) => m.id == id);
    if (idx == -1) return;

    final old = _investmentModels[idx];
    final newAim = (old.aim - value).clamp(0.0, double.infinity);

    _investmentModels[idx] = InvestmentModel(id: id, aim: newAim, amount: old.amount);
    setState(() {});
    _persistAll();
  }

  Future<void> _saveInvestment(Investment investment, InvestmentModel model) async {
    await _investmentService.saveInvestment(investment);
    await _investmentService.saveInvestmentModel(model);

    setState(() {
      _allInvestments.add(investment);
      _investmentModels.add(model);
      if (!_selectedCategories.contains(investment.category)) {
        _selectedCategories.add(investment.category);
      }
    });
    _persistAll();
  }

  Future<void> _deleteInvestment(Investment investment) async {
    setState(() {
      _allInvestments.removeWhere((i) => i.id == investment.id);
      _investmentModels.removeWhere((m) => m.id == investment.id);
      if (!_allInvestments.any((i) => i.category == investment.category)) {
        _selectedCategories.remove(investment.category);
      }
    });
    _persistAll();
  }

  Future<void> _persistAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'investments',
      _allInvestments.map((i) => jsonEncode(i.toMap())).toList(),
    );
    await prefs.setStringList(
      'exchangeDollarList',
      _investmentModels.map((m) => jsonEncode(m.toMap())).toList(),
    );
    await prefs.setStringList('selectedCategories', _selectedCategories);
  }

  // ── Navigation ───────────────────────────────────────

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => _CategoryPickerSheet(
        categories: _allCategories,
        getIcon: _iconFor,
        onSelected: (cat) {
          Navigator.pop(context);
          _showAddSheet(cat);
        },
      ),
    );
  }

  void _showAddSheet(String category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddInvestmentBottomSheet(
        category: category,
        onSave: _saveInvestment,
        onCategoryValueAdded: (_) {},
      ),
    );
  }

  IconData _iconFor(String category) => switch (category) {
    'Döviz' => LucideIcons.dollarSign,
    'Nakit' => LucideIcons.wallet,
    'Gayrimenkül' => LucideIcons.house,
    'Araba' => LucideIcons.car,
    'Elektronik' => LucideIcons.monitor,
    _ => LucideIcons.folder,
  };

  // ════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F6F8);

    return Scaffold(
      backgroundColor: bg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : RefreshIndicator.adaptive(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(isDark),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverList.list(children: [
                SizedBox(height: 8.h),
                _buildSummary(isDark),
                SizedBox(height: 20.h),
                _buildCurrencySelector(isDark),
                SizedBox(height: 20.h),
                _buildAddButton(),
                SizedBox(height: 24.h),
              ]),
            ),
            _buildGoalsList(isDark),
            SliverToBoxAdapter(child: SizedBox(height: 40.h)),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────

  SliverAppBar _buildAppBar(bool isDark) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F6F8),
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: IconButton(
        icon: Icon(LucideIcons.arrowLeft, color: isDark ? Colors.white : Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Birikimlerim',
        style: GoogleFonts.montserrat(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(LucideIcons.plus, color: Colors.blueAccent, size: 22.r),
          onPressed: _showCategoryPicker,
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  // ── Summary ────────────

  Widget _buildSummary(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white54 : Colors.grey.shade600;

    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Toplam Birikim', style: GoogleFonts.montserrat(fontSize: 13.sp, color: mutedColor)),
              _badge(_progress),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '$_currencySymbol ${_fmt(_totalSaved)}',
            style: GoogleFonts.montserrat(
              fontSize: 30.sp, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Hedef: $_currencySymbol ${_fmt(_totalTarget)}',
            style: GoogleFonts.montserrat(fontSize: 13.sp, color: mutedColor),
          ),
          SizedBox(height: 20.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8.h,
              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
              color: _progress >= 1.0 ? Colors.green : Colors.blueAccent,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stat('Biriken', '$_currencySymbol${_fmtCompact(_totalSaved)}', mutedColor, textColor),
              _stat('Kalan', '$_currencySymbol${_fmtCompact((_totalTarget - _totalSaved).clamp(0, double.infinity))}', mutedColor, textColor),
              _stat('Hedef', '$_currencySymbol${_fmtCompact(_totalTarget)}', mutedColor, textColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(double progress) {
    final pct = (progress * 100).toStringAsFixed(0);
    final color = progress >= 1.0 ? Colors.green : Colors.blueAccent;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20.r)),
      child: Text('%$pct', style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _stat(String label, String value, Color labelColor, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 11.sp, color: labelColor)),
        SizedBox(height: 2.h),
        Text(value, style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: valueColor)),
      ],
    );
  }

  // ── Currency Selector ──

  Widget _buildCurrencySelector(bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(children: [
        _currencyTab('Dolar', r'$', isDark),
        _currencyTab('Euro', '€', isDark),
        _currencyTab('Türk Lirası', '₺', isDark),
      ]),
    );
  }

  Widget _currencyTab(String label, String symbol, bool isDark) {
    final isSelected = _selectedCurrency == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedCurrency = label;
          _currencySymbol = symbol;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? Colors.white.withOpacity(0.1) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: isSelected && !isDark
                ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 13.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? (isDark ? Colors.white : Colors.black87)
                  : (isDark ? Colors.white38 : Colors.grey.shade500),
            ),
          ),
        ),
      ),
    );
  }

  // ── Add Button ─────────

  Widget _buildAddButton() {
    return Material(
      color: Colors.blueAccent,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: _showCategoryPicker,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.circlePlus, color: Colors.white, size: 20.r),
              SizedBox(width: 10.w),
              Text(
                'Yeni Birikim Hedefi Ekle',
                style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Goals List ─────────

  Widget _buildGoalsList(bool isDark) {
    final grouped = _groupedInvestments;

    if (grouped.isEmpty) {
      return SliverToBoxAdapter(child: _emptyState(isDark));
    }

    final categoryKeys = grouped.keys.toList();

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList.builder(
        itemCount: categoryKeys.length,
        itemBuilder: (_, index) {
          final category = categoryKeys[index];
          final items = grouped[category]!;
          return _buildCategoryGroup(category, items, isDark);
        },
      ),
    );
  }

  Widget _buildCategoryGroup(String category, List<Investment> items, bool isDark) {
    final headerColor = isDark ? Colors.white70 : Colors.grey.shade700;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(_iconFor(category), size: 16.r, color: Colors.blueAccent),
                ),
                SizedBox(width: 8.w),
                Text(
                  category.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 12.sp, fontWeight: FontWeight.w700, color: headerColor, letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '${items.length} hedef',
                  style: GoogleFonts.montserrat(fontSize: 11.sp, color: isDark ? Colors.white38 : Colors.grey.shade500),
                ),
              ],
            ),
          ),
          // Goal Cards
          ...items.map((inv) {
            final model = _findModel(inv);
            return GoalCard(
              investment: inv,
              model: model,
              currencySymbol: _currencySymbol,
              onAdd: (val) => _addToSavings(inv.id, val),
              onRemove: (val) => _removeFromSavings(inv.id, val),
              onDelete: () => _deleteInvestment(inv),
            );
          }),
        ],
      ),
    );
  }

  Widget _emptyState(bool isDark) {
    final color = isDark ? Colors.white38 : Colors.grey.shade400;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      child: Column(
        children: [
          Icon(LucideIcons.inbox, size: 48.r, color: color),
          SizedBox(height: 16.h),
          Text('Bu para biriminde hedef yok', style: GoogleFonts.montserrat(fontSize: 14.sp, color: color)),
          SizedBox(height: 6.h),
          Text('Yukarıdaki butona tıklayarak ekleyin',
              style: GoogleFonts.montserrat(fontSize: 12.sp, color: color.withOpacity(0.7))),
        ],
      ),
    );
  }

  // ── Formatters ─────────

  String _fmt(double v) => NumberFormat.currency(locale: 'tr', symbol: '', decimalDigits: 2).format(v);
  String _fmtCompact(double v) => NumberFormat.compact(locale: 'tr').format(v);
}

// ════════════════════════════════════════════════════════════
// Category Picker
// ════════════════════════════════════════════════════════════

class _CategoryPickerSheet extends StatelessWidget {
  final List<String> categories;
  final IconData Function(String) getIcon;
  final ValueChanged<String> onSelected;

  const _CategoryPickerSheet({
    required this.categories,
    required this.getIcon,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w, height: 4.h,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            SizedBox(height: 20.h),
            Text('Kategori Seçin',
                style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            SizedBox(height: 6.h),
            Text('Birikiminizin türünü seçin',
                style: GoogleFonts.montserrat(fontSize: 13.sp, color: isDark ? Colors.white54 : Colors.grey.shade600)),
            SizedBox(height: 20.h),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.1,
              children: categories.map((cat) => _chip(context, cat, isDark)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String category, bool isDark) {
    return InkWell(
      onTap: () => onSelected(category),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(getIcon(category), size: 20.r, color: Colors.blueAccent),
            ),
            SizedBox(height: 8.h),
            Text(category, style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87)),
          ],
        ),
      ),
    );
  }
}