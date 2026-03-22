import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../blocs/income-selections.dart';
import '../../models/income_model.dart';
import '../../storage/income_storage_service.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  // ── State ──
  List<Income> _incomes = [];
  List<Map<String, dynamic>> _bankAccounts = [];
  Map<String, dynamic>? _selectedAccount;
  bool _isLoading = true;

  // ── Income Form ──
  bool _isAddingIncome = false;
  int _selectedSourceIndex = 0;
  final _amountController = TextEditingController();

  static const _sources = ['İş', 'Burs', 'Emekli'];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════
  // DATA
  // ══════════════════════════════════════════════════════

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final accountListJson = prefs.getString('accountDataList');
      final savedAccountJson = prefs.getString('selectedAccount');

      if (accountListJson != null) {
        _bankAccounts = List<Map<String, dynamic>>.from(jsonDecode(accountListJson));

        if (savedAccountJson != null) {
          final saved = Map<String, dynamic>.from(jsonDecode(savedAccountJson));
          if (saved['accountId'] != null) {
            _selectedAccount = _findAccountById(saved['accountId']);
          }
        }
      }

      _incomes = await IncomeStorageService.loadIncomes();
    } catch (e) {
      debugPrint('Error loading income data: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveSelectedAccount(Map<String, dynamic> account) async {
    final accountId = account['accountId'];
    final bankId = account['bankId'];
    if (accountId == null || bankId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAccount', jsonEncode({'accountId': accountId, 'bankId': bankId}));
  }

  Map<String, dynamic>? _findAccountById(int? accountId) {
    if (accountId == null) return null;
    for (var bank in _bankAccounts) {
      for (var account in bank['accounts'] ?? []) {
        if (account['accountId'] == accountId) {
          return {...account, 'bankId': bank['bankId'], 'bankName': bank['bankName']};
        }
      }
    }
    return null;
  }

  // ── Actions ──

  Future<void> _addIncome() async {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0 || _selectedAccount == null) {
      _snack('Lütfen geçerli bir miktar girin ve hesap seçin', Colors.red);
      return;
    }

    final newIncome = Income(
      incomeId: DateTime.now().millisecondsSinceEpoch,
      accountId: _selectedAccount!['accountId'],
      accountName: _selectedAccount!['name'] ?? 'Bilinmeyen Hesap',
      source: _sources[_selectedSourceIndex],
      amount: amount,
      date: DateTime.now(),
      currency: _selectedAccount!['currency'] ?? 'TRY',
      description: '${_sources[_selectedSourceIndex]} geliri',
    );

    await IncomeStorageService.addIncome(newIncome);
    _incomes = await IncomeStorageService.loadIncomes();

    setState(() {
      _isAddingIncome = false;
      _amountController.clear();
    });

    _snack('Gelir başarıyla eklendi', Colors.green);
  }

  Future<void> _deleteIncome(Income income) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Geliri Sil', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Text('Bu geliri silmek istediğinize emin misiniz?', style: GoogleFonts.montserrat()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    _incomes.removeWhere((i) => i.incomeId == income.incomeId);
    await IncomeStorageService.saveIncomes(_incomes);
    setState(() {});
    _snack('Gelir silindi', Colors.orange);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.montserrat()),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Helpers ──

  Color _sourceColor(String source) => switch (source) {
    'İş' => Colors.blueAccent,
    'Burs' => Colors.purple,
    'Emekli' => Colors.orange,
    _ => Colors.grey,
  };

  IconData _sourceIcon(String source) => switch (source) {
    'İş' => LucideIcons.briefcase,
    'Burs' => LucideIcons.graduationCap,
    'Emekli' => LucideIcons.user,
    _ => LucideIcons.handHelping,
  };

  // ══════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F6F8);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Gelirler', style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.bold, color: textColor)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : RefreshIndicator.adaptive(
        onRefresh: _loadAll,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          children: [
            // 1. Account Selector
            if (_bankAccounts.isNotEmpty) ...[
              _buildAccountSelector(isDark),
              SizedBox(height: 16.h),
            ],

            // 2. Add Income Section
            _buildAddIncomeSection(isDark),
            SizedBox(height: 20.h),

            // 3. Summary
            _buildSummarySection(isDark),
            SizedBox(height: 20.h),

            // 4. Recent Incomes
            _buildRecentIncomes(isDark),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // ── 1. Account Selector ──

  Widget _buildAccountSelector(bool isDark) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderCol = isDark ? Colors.white10 : Colors.grey.shade200;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white54 : Colors.grey.shade600;

    // Build unique account list
    final uniqueAccounts = <Map<String, dynamic>>[];
    final seenIds = <int>{};
    for (var bank in _bankAccounts) {
      for (var acc in (bank['accounts'] as List?) ?? []) {
        final id = acc['accountId'] as int;
        if (seenIds.add(id)) {
          uniqueAccounts.add({...acc, 'bankId': bank['bankId'], 'bankName': bank['bankName']});
        }
      }
    }

    // Find matching selected
    Map<String, dynamic>? currentSelected;
    if (_selectedAccount != null) {
      currentSelected = uniqueAccounts.firstWhere(
            (a) => a['accountId'] == _selectedAccount!['accountId'],
        orElse: () => _selectedAccount!,
      );
    }

    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Hesap Seçin', LucideIcons.wallet, Colors.green, textColor),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.black12 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: borderCol),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                value: currentSelected,
                isExpanded: true,
                hint: Text('Hesap seçin', style: GoogleFonts.montserrat(color: mutedColor, fontSize: 14.sp)),
                icon: Icon(LucideIcons.chevronDown, size: 18.r, color: mutedColor),
                dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                style: GoogleFonts.montserrat(fontSize: 14.sp, color: textColor),
                items: uniqueAccounts.map((acc) {
                  return DropdownMenuItem(
                    value: acc,
                    child: Text(
                      '${acc['bankName']} — ${acc['name']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() => _selectedAccount = val);
                  _saveSelectedAccount(val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. Add Income Section ──

  Widget _buildAddIncomeSection(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;

    if (!_isAddingIncome) {
      return _card(
        isDark: isDark,
        onTap: () {
          if (_selectedAccount == null && _bankAccounts.isNotEmpty) {
            _snack('Lütfen önce bir hesap seçin', Colors.orange);
            return;
          }
          setState(() => _isAddingIncome = true);
        },
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(LucideIcons.circlePlus, color: Colors.green, size: 22.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                'Gelir Ekle',
                style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.green),
              ),
            ),
            Icon(LucideIcons.chevronRight, color: Colors.green.withOpacity(0.5), size: 20.r),
          ],
        ),
      );
    }

    // Expanded form
    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Gelir Ekle', LucideIcons.trendingUp, Colors.green, textColor),
              IconButton(
                icon: Icon(LucideIcons.x, size: 20.r, color: Colors.grey),
                onPressed: () => setState(() {
                  _isAddingIncome = false;
                  _amountController.clear();
                }),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Selected account info
          if (_selectedAccount != null) ...[
            _infoBanner(
              icon: LucideIcons.building2,
              text: '${_selectedAccount!['bankName']} — ${_selectedAccount!['name']}',
              color: Colors.blueAccent,
              isDark: isDark,
            ),
            SizedBox(height: 16.h),
          ],

          // Source selector
          _label('Gelir Kaynağı', isDark),
          SizedBox(height: 8.h),
          _sourceSelector(isDark),
          SizedBox(height: 16.h),

          // Amount
          _label('Miktar', isDark),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  style: GoogleFonts.montserrat(fontSize: 16.sp),
                  decoration: InputDecoration(
                    hintText: 'Miktar girin',
                    hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                    prefixIcon: Icon(LucideIcons.dollarSign, size: 18.r, color: Colors.grey),
                    filled: true,
                    fillColor: isDark ? Colors.black12 : Colors.grey.shade100,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Colors.green, width: 1.5),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                height: 48.h,
                child: FilledButton(
                  onPressed: _addIncome,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                  ),
                  child: Icon(LucideIcons.check, size: 22.r),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sourceSelector(bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: List.generate(_sources.length, (i) {
          final isSelected = _selectedSourceIndex == i;
          final source = _sources[i];
          final color = _sourceColor(source);

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSourceIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_sourceIcon(source), size: 14.r, color: isSelected ? Colors.white : Colors.grey),
                    SizedBox(width: 4.w),
                    Text(
                      source,
                      style: GoogleFonts.montserrat(
                        fontSize: 12.sp,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── 3. Summary ──

  Widget _buildSummarySection(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white54 : Colors.grey.shade600;

    return FutureBuilder<Map<String, dynamic>>(
      future: IncomeStorageService.getIncomeSummary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _card(
            isDark: isDark,
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: const Center(child: CircularProgressIndicator.adaptive()),
            ),
          );
        }

        final summary = snapshot.data ?? {'work': 0.0, 'scholarship': 0.0, 'pension': 0.0, 'total': 0.0};
        final fmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);

        final total = summary['total'] ?? 0.0;
        final items = [
          _SummaryItem('İş Geliri', summary['work'] ?? 0.0, _sourceColor('İş'), _sourceIcon('İş')),
          _SummaryItem('Burs Geliri', summary['scholarship'] ?? 0.0, _sourceColor('Burs'), _sourceIcon('Burs')),
          _SummaryItem('Emekli Geliri', summary['pension'] ?? 0.0, _sourceColor('Emekli'), _sourceIcon('Emekli')),
        ];

        return _card(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Gelir Özeti', LucideIcons.chartPie, Colors.blueAccent, textColor),
              SizedBox(height: 20.h),

              // Total
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(isDark ? 0.08 : 0.05),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Toplam Gelir', style: GoogleFonts.montserrat(fontSize: 13.sp, color: mutedColor)),
                        SizedBox(height: 4.h),
                        Text(
                          fmt.format(total),
                          style: GoogleFonts.montserrat(fontSize: 24.sp, fontWeight: FontWeight.w700, color: Colors.green),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(LucideIcons.trendingUp, color: Colors.green, size: 24.r),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Breakdown
              ...items.map((item) {
                final percent = total > 0 ? item.amount / total : 0.0;
                return Padding(
                  padding: EdgeInsets.only(bottom: 14.h),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6.r),
                            decoration: BoxDecoration(
                              color: item.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(item.icon, size: 14.r, color: item.color),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(item.label, style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: textColor)),
                          ),
                          Text(fmt.format(item.amount), style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: textColor)),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: item.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '%${(percent * 100).toStringAsFixed(0)}',
                              style: GoogleFonts.montserrat(fontSize: 10.sp, fontWeight: FontWeight.w600, color: item.color),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: percent.clamp(0.0, 1.0),
                          minHeight: 5.h,
                          backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                          color: item.color,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ── 4. Recent Incomes ──

  Widget _buildRecentIncomes(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white54 : Colors.grey.shade600;

    if (_incomes.isEmpty) {
      return _card(
        isDark: isDark,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Column(
            children: [
              Icon(LucideIcons.inbox, size: 40.r, color: mutedColor),
              SizedBox(height: 12.h),
              Text('Henüz gelir eklenmemiş', style: GoogleFonts.montserrat(fontSize: 14.sp, color: mutedColor)),
            ],
          ),
        ),
      );
    }

    final recent = _incomes.take(10).toList();
    final fmt = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);
    final dateFmt = DateFormat('d MMM yyyy', 'tr');

    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Son Gelirler', LucideIcons.history, Colors.purple, textColor),
          SizedBox(height: 16.h),
          ...recent.asMap().entries.map((entry) {
            final income = entry.value;
            final isLast = entry.key == recent.length - 1;
            final color = _sourceColor(income.source);

            return Column(
              children: [
                Dismissible(
                  key: Key('income_${income.incomeId}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 16.w),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12.r)),
                    child: Icon(LucideIcons.trash2, color: Colors.white, size: 18.r),
                  ),
                  onDismissed: (_) => _deleteIncome(income),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      children: [
                        // Color bar
                        Container(
                          width: 3.w, height: 40.h,
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                        ),
                        SizedBox(width: 12.w),

                        // Icon
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(_sourceIcon(income.source), size: 16.r, color: color),
                        ),
                        SizedBox(width: 12.w),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                income.source,
                                style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w600, color: textColor),
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Text(
                                    income.accountName,
                                    style: GoogleFonts.montserrat(fontSize: 11.sp, color: mutedColor),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 6.w),
                                    width: 3.r, height: 3.r,
                                    decoration: BoxDecoration(color: mutedColor, shape: BoxShape.circle),
                                  ),
                                  Text(
                                    dateFmt.format(income.date),
                                    style: GoogleFonts.montserrat(fontSize: 11.sp, color: mutedColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Amount
                        Text(
                          fmt.format(income.amount),
                          style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast) Divider(height: 1, color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ══════════════════════════════════════════════════════

  Widget _card({required bool isDark, required Widget child, VoidCallback? onTap}) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderCol = isDark ? Colors.white10 : Colors.grey.shade200;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderCol),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, IconData icon, Color color, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: color),
        SizedBox(width: 8.w),
        Text(text, style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.bold, color: textColor)),
      ],
    );
  }

  Widget _label(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white54 : Colors.grey.shade600,
      ),
    );
  }

  Widget _infoBanner({required IconData icon, required String text, required Color color, required bool isDark}) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.r, color: color),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w500, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper class for summary items ──
class _SummaryItem {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryItem(this.label, this.amount, this.color, this.icon);
}

// ── Parsing helpers (kept from original) ──
double parseAmount(dynamic amount) {
  try {
    if (amount == null) return 0.0;
    return NumberFormat.decimalPattern('tr_TR').parse(amount.toString()).toDouble();
  } catch (_) {
    try {
      return double.parse(amount.toString().replaceAll('.', '').replaceAll(',', '.'));
    } catch (_) {
      return 0.0;
    }
  }
}

double parseTurkishDouble(String numberString) {
  final normalized = numberString.replaceAll('.', '').replaceAll(',', '.');
  return NumberFormat.decimalPattern('tr_TR').parse(normalized).toDouble();
}