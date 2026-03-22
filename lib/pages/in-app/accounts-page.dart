import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/account.dart';
import '../../models/transaction.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  List<Map<String, dynamic>> _bankAccounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  // ══════════════════════════════════════════════════════
  // DATA
  // ══════════════════════════════════════════════════════

  Future<void> _loadAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('accountDataList');
      if (json != null) {
        _bankAccounts = List<Map<String, dynamic>>.from(jsonDecode(json));
      }
    } catch (e) {
      debugPrint('Error loading accounts: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accountDataList', jsonEncode(_bankAccounts));
  }

  // ── Bank CRUD ──

  Future<void> _addOrEditBank({int? editIndex}) async {
    final isEditing = editIndex != null;
    final existing = isEditing ? _bankAccounts[editIndex] : null;
    final controller = TextEditingController(text: existing?['bankName'] ?? '');

    final result = await _showInputSheet(
      title: isEditing ? 'Bankayı Düzenle' : 'Yeni Banka Ekle',
      hint: 'Banka adı girin',
      controller: controller,
      confirmLabel: isEditing ? 'Güncelle' : 'Ekle',
    );

    if (result == null || result.trim().isEmpty) return;

    final bankData = {
      'bankId': isEditing ? existing!['bankId'] : DateTime.now().millisecondsSinceEpoch,
      'bankName': result.trim(),
      'accounts': existing?['accounts'] ?? [],
    };

    setState(() {
      if (isEditing) {
        _bankAccounts[editIndex] = bankData;
      } else {
        _bankAccounts.add(bankData);
      }
    });
    await _saveAccounts();
  }

  Future<void> _deleteBank(int index) async {
    final bank = _bankAccounts[index];
    final confirmed = await _confirmDelete('${bank['bankName']} bankasını silmek istediğinize emin misiniz?');
    if (!confirmed) return;

    setState(() => _bankAccounts.removeAt(index));
    await _saveAccounts();
  }

  // ── Account CRUD ──

  void _showAddAccountSheet(int bankId) {
    final bank = _bankAccounts.firstWhere((b) => b['bankId'] == bankId);
    _showAccountFormSheet(bank: bank);
  }

  void _showEditAccountSheet(int bankId, int accountIndex) {
    final bank = _bankAccounts.firstWhere((b) => b['bankId'] == bankId);
    final accountData = bank['accounts'][accountIndex];
    final account = Account.fromJson(accountData);
    _showAccountFormSheet(bank: bank, account: account, accountIndex: accountIndex);
  }

  Future<void> _deleteAccount(int bankId, int accountIndex) async {
    final bank = _bankAccounts.firstWhere((b) => b['bankId'] == bankId);
    final account = Account.fromJson(bank['accounts'][accountIndex]);
    final confirmed = await _confirmDelete('"${account.name}" hesabını silmek istediğinize emin misiniz?');
    if (!confirmed) return;

    setState(() => bank['accounts'].removeAt(accountIndex));
    await _saveAccounts();
  }

  // ── Transaction ──

  void _showEditTransactionSheet(int bankId, Account account, Transaction transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final amountCtrl = TextEditingController(text: transaction.amount.abs().toString());
    final titleCtrl = TextEditingController(text: transaction.title);
    final descCtrl = TextEditingController(text: transaction.description);
    DateTime selectedDate = transaction.date;
    bool isSurplus = transaction.isSurplus;
    String category = transaction.category;
    String subcategory = transaction.subcategory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.only(
            left: 20.r, right: 20.r, top: 12.r,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.r,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _handle(),
                SizedBox(height: 20.h),
                Text('İşlemi Düzenle', style: _titleStyle()),
                SizedBox(height: 24.h),

                _formField(label: 'Başlık', controller: titleCtrl, icon: LucideIcons.tag),
                SizedBox(height: 14.h),
                _formField(label: 'Miktar', controller: amountCtrl, icon: LucideIcons.dollarSign, isNumber: true),
                SizedBox(height: 14.h),
                _formField(label: 'Açıklama', controller: descCtrl, icon: LucideIcons.fileText),
                SizedBox(height: 14.h),

                // Date
                _label('Tarih'),
                SizedBox(height: 6.h),
                _dateTile(
                  date: selectedDate,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setLocal(() => selectedDate = picked);
                  },
                ),
                SizedBox(height: 14.h),

                // Category
                _label('Kategori'),
                SizedBox(height: 6.h),
                _segmentRow(
                  options: ['Income', 'Expense', 'Transfer'],
                  selected: category,
                  onChanged: (val) => setLocal(() {
                    category = val;
                    isSurplus = val == 'Income';
                    subcategory = _getSubcategories(val).first;
                  }),
                ),
                SizedBox(height: 14.h),

                // Subcategory
                _label('Alt Kategori'),
                SizedBox(height: 6.h),
                _dropdownField(
                  value: subcategory,
                  items: _getSubcategories(category),
                  onChanged: (val) => setLocal(() => subcategory = val!),
                ),
                SizedBox(height: 28.h),

                // Actions
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: Text('İptal', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        final amount = double.tryParse(amountCtrl.text);
                        if (amount == null || titleCtrl.text.isEmpty) return;

                        final updated = transaction.copyWith(
                          date: selectedDate,
                          amount: isSurplus ? amount : -amount,
                          currency: account.currency,
                          subcategory: subcategory,
                          category: category,
                          title: titleCtrl.text,
                          description: descCtrl.text,
                          isSurplus: isSurplus,
                        );
                        await _updateTransaction(bankId, account.accountId, transaction, updated);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: Text('Güncelle', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateTransaction(int bankId, int accountId, Transaction old, Transaction updated) async {
    final bank = _bankAccounts.firstWhere((b) => b['bankId'] == bankId);
    for (var accData in bank['accounts']) {
      final acc = Account.fromJson(accData);
      if (acc.accountId == accountId) {
        final txList = List<dynamic>.from(accData['transactions'] ?? []);
        final idx = txList.indexWhere((t) => Transaction.fromJson(t).transactionId == old.transactionId);
        if (idx != -1) {
          txList[idx] = updated.toJson();
          accData['transactions'] = txList;
        }
        break;
      }
    }
    setState(() {});
    await _saveAccounts();
  }

  // ── Account Form Sheet ──

  void _showAccountFormSheet({
    required Map<String, dynamic> bank,
    Account? account,
    int? accountIndex,
  }) {
    final isEditing = account != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final nameCtrl = TextEditingController(text: account?.name ?? '');
    final typeCtrl = TextEditingController(text: account?.type ?? '');
    final balanceCtrl = TextEditingController(text: (account?.balance ?? 0.0).toString());
    final creditLimitCtrl = TextEditingController(text: (account?.creditLimit ?? 0.0).toString());
    final previousDebtCtrl = TextEditingController(text: (account?.previousDebt ?? 0.0).toString());
    final totalDebtCtrl = TextEditingController(text: (account?.totalDebt ?? 0.0).toString());
    final currentDebtCtrl = TextEditingController(text: (account?.currentDebt ?? 0.0).toString());
    final minPayRateCtrl = TextEditingController(text: _getMinPaymentRate(account).toString());

    String currency = account?.currency ?? 'TRY';
    bool isDebit = account?.isDebit ?? true;
    int cutoffDate = account?.cutoffDate ?? 1;

    double calcMinPayment() {
      final rate = double.tryParse(minPayRateCtrl.text) ?? 0;
      final debt = double.tryParse(currentDebtCtrl.text) ?? 0;
      return debt * (rate / 100);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.only(
            left: 20.r, right: 20.r, top: 12.r,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.r,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _handle(),
                SizedBox(height: 20.h),
                Text(
                  isEditing ? 'Hesabı Düzenle' : 'Yeni Hesap Ekle',
                  style: _titleStyle(),
                ),
                SizedBox(height: 4.h),
                Text(
                  bank['bankName'],
                  style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.blueAccent, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 24.h),

                // ── Basic Info ──
                _sectionHeader('Temel Bilgiler'),
                SizedBox(height: 12.h),
                _formField(label: 'Hesap Adı', controller: nameCtrl, icon: LucideIcons.tag, hint: 'Örn: Vadesiz Hesap'),
                SizedBox(height: 12.h),
                _formField(label: 'Hesap Türü', controller: typeCtrl, icon: LucideIcons.layers, hint: 'Örn: Banka, Kredi Kartı'),
                SizedBox(height: 12.h),

                // Currency
                _label('Para Birimi'),
                SizedBox(height: 6.h),
                _segmentRow(
                  options: ['TRY', 'USD', 'EUR'],
                  selected: currency,
                  onChanged: (val) => setLocal(() => currency = val),
                ),
                SizedBox(height: 16.h),

                // ── Account Type Toggle ──
                _accountTypeToggle(
                  isDebit: isDebit,
                  onChanged: (val) => setLocal(() => isDebit = val),
                ),
                SizedBox(height: 16.h),

                // ── Debit Fields ──
                if (isDebit) ...[
                  _formField(label: 'Bakiye', controller: balanceCtrl, icon: LucideIcons.wallet, isNumber: true),
                ],

                // ── Credit Card Fields ──
                if (!isDebit) ...[
                  _sectionHeader('Kredi Kartı Bilgileri'),
                  SizedBox(height: 12.h),
                  _formField(label: 'Kredi Limiti', controller: creditLimitCtrl, icon: LucideIcons.creditCard, isNumber: true),
                  SizedBox(height: 12.h),
                  _formField(label: 'Güncel Borç', controller: currentDebtCtrl, icon: LucideIcons.circleAlert, isNumber: true,
                    onChanged: (_) => setLocal(() {}),
                  ),
                  SizedBox(height: 12.h),
                  _formField(label: 'Önceki Dönem Borcu', controller: previousDebtCtrl, icon: LucideIcons.history, isNumber: true),
                  SizedBox(height: 12.h),
                  _formField(label: 'Toplam Borç', controller: totalDebtCtrl, icon: LucideIcons.trendingDown, isNumber: true),
                  SizedBox(height: 12.h),
                  _formField(label: 'Asgari Ödeme Oranı (%)', controller: minPayRateCtrl, icon: LucideIcons.percent, isNumber: true,
                    onChanged: (_) => setLocal(() {}),
                  ),
                  SizedBox(height: 8.h),

                  // Calculated min payment
                  _infoBox('Hesaplanan Asgari Ödeme', '${calcMinPayment().toStringAsFixed(2)} $currency'),
                  SizedBox(height: 12.h),

                  // Cutoff date
                  _label('Hesap Kesim Tarihi'),
                  SizedBox(height: 6.h),
                  _dropdownField(
                    value: cutoffDate.toString(),
                    items: List.generate(28, (i) => '${i + 1}'),
                    onChanged: (val) => setLocal(() => cutoffDate = int.parse(val!)),
                    suffix: '. Gün',
                  ),
                ],

                SizedBox(height: 28.h),

                // ── Submit ──
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty || typeCtrl.text.trim().isEmpty) {
                        _snack('Lütfen gerekli alanları doldurun');
                        return;
                      }

                      final creditLimit = double.tryParse(creditLimitCtrl.text) ?? 0;
                      final totalDebt = double.tryParse(totalDebtCtrl.text) ?? 0;
                      final previousDebt = double.tryParse(previousDebtCtrl.text) ?? 0;
                      final currentDebt = double.tryParse(currentDebtCtrl.text) ?? 0;

                      final newAccount = Account(
                        accountId: account?.accountId ?? DateTime.now().millisecondsSinceEpoch,
                        name: nameCtrl.text.trim(),
                        type: typeCtrl.text.trim(),
                        balance: double.tryParse(balanceCtrl.text) ?? 0.0,
                        transactions: account?.transactions ?? [],
                        debts: account?.debts ?? [],
                        currency: currency,
                        isDebit: isDebit,
                        creditLimit: isDebit ? null : creditLimit,
                        availableCredit: isDebit ? null : creditLimit - totalDebt,
                        remainingDebt: isDebit ? null : previousDebt,
                        currentDebt: isDebit ? null : currentDebt,
                        minPayment: isDebit ? null : calcMinPayment(),
                        remainingMinPayment: isDebit ? null : calcMinPayment(),
                        previousDebt: isDebit ? null : previousDebt,
                        totalDebt: isDebit ? null : totalDebt,
                        cutoffDate: isDebit ? 1 : cutoffDate,
                        previousCutoffDate: account?.previousCutoffDate,
                        nextCutoffDate: account?.nextCutoffDate,
                        previousDueDate: account?.previousDueDate,
                        nextDueDate: account?.nextDueDate,
                      );

                      if (!isDebit) newAccount.updateCreditDates();

                      if (isEditing) {
                        bank['accounts'][accountIndex!] = newAccount.toJson();
                      } else {
                        bank['accounts'] ??= [];
                        bank['accounts'].add(newAccount.toJson());
                      }

                      await _saveAccounts();
                      setState(() {});
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(
                      isEditing ? 'Güncelle' : 'Hesap Ekle',
                      style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════

  double _getMinPaymentRate(Account? account) {
    if (account == null || account.creditLimit == null) return 20.0;
    if (account.creditLimit! < 25000) return 20.0;
    if (account.creditLimit! > 50000) return 40.0;
    return 30.0;
  }

  List<String> _getSubcategories(String category) => switch (category) {
    'Income' => ['Salary', 'Bonus', 'Investment', 'İş', 'Burs', 'Emekli'],
    'Expense' => ['Food', 'Transport', 'Housing', 'Entertainment', 'Other'],
    'Transfer' => ['Between Accounts', 'To Savings', 'From Savings'],
    _ => ['Other'],
  };

  Future<String?> _showInputSheet({
    required String title,
    required String hint,
    required TextEditingController controller,
    required String confirmLabel,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20.r, right: 20.r, top: 12.r,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.r,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _handle(),
            SizedBox(height: 20.h),
            Text(title, style: _titleStyle()),
            SizedBox(height: 20.h),
            _formField(label: hint, controller: controller, icon: LucideIcons.building2),
            SizedBox(height: 24.h),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: Text('İptal', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, controller.text),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: Text(confirmLabel, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Silme Onayı', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Text(message, style: GoogleFonts.montserrat()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.montserrat()),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

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
        title: Text('Hesaplarım', style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.bold, color: textColor)),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.plus, color: Colors.blueAccent, size: 22.r),
            onPressed: () => _addOrEditBank(),
            tooltip: 'Banka Ekle',
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _bankAccounts.isEmpty
          ? _emptyState(isDark)
          : RefreshIndicator.adaptive(
        onRefresh: _loadAccounts,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          itemCount: _bankAccounts.length,
          itemBuilder: (_, i) => _buildBankCard(_bankAccounts[i], i, isDark),
        ),
      ),
    );
  }

  // ── Empty State ──

  Widget _emptyState(bool isDark) {
    final color = isDark ? Colors.white38 : Colors.grey.shade400;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.building2, size: 56.r, color: color),
          SizedBox(height: 16.h),
          Text('Henüz banka hesabı yok', style: GoogleFonts.montserrat(fontSize: 16.sp, color: color, fontWeight: FontWeight.w500)),
          SizedBox(height: 6.h),
          Text('Sağ üstteki + butonuyla ekleyin', style: GoogleFonts.montserrat(fontSize: 13.sp, color: color.withOpacity(0.7))),
        ],
      ),
    );
  }

  // ── Bank Card ──

  Widget _buildBankCard(Map<String, dynamic> bank, int bankIndex, bool isDark) {
    final accounts = bank['accounts'] as List<dynamic>? ?? [];
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderCol = isDark ? Colors.white10 : Colors.grey.shade200;
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white54 : Colors.grey.shade600;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: borderCol),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: ValueKey(bank['bankId']),
            tilePadding: EdgeInsets.fromLTRB(20.w, 8.h, 12.w, 8.h),
            childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            leading: Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.building2, color: Colors.blueAccent, size: 20.r),
            ),
            title: Text(bank['bankName'], style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 15.sp, color: textColor)),
            subtitle: Text('${accounts.length} hesap', style: GoogleFonts.montserrat(color: mutedColor, fontSize: 12.sp)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _tinyIconBtn(LucideIcons.pencil, Colors.blueAccent, () => _addOrEditBank(editIndex: bankIndex)),
                SizedBox(width: 4.w),
                _tinyIconBtn(LucideIcons.trash2, Colors.red, () => _deleteBank(bankIndex)),
                SizedBox(width: 4.w),
                Icon(LucideIcons.chevronDown, size: 18.r, color: mutedColor),
              ],
            ),
            children: [
              // Add Account Button
              _addAccountTile(bank['bankId'], isDark),
              SizedBox(height: 8.h),

              // Account List
              ...accounts.asMap().entries.map((entry) {
                final accIndex = entry.key;
                final accData = entry.value;
                return _buildAccountTile(bank, accData, accIndex, isDark);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addAccountTile(int bankId, bool isDark) {
    return InkWell(
      onTap: () => _showAddAccountSheet(bankId),
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.circlePlus, size: 18.r, color: Colors.blueAccent),
            SizedBox(width: 8.w),
            Text('Hesap Ekle', style: GoogleFonts.montserrat(color: Colors.blueAccent, fontWeight: FontWeight.w600, fontSize: 14.sp)),
          ],
        ),
      ),
    );
  }

  // ── Account Tile ──

  Widget _buildAccountTile(Map<String, dynamic> bank, dynamic accData, int accIndex, bool isDark) {
    final account = Account.fromJson(accData);
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white54 : Colors.grey.shade600;
    final transactions = (accData['transactions'] as List<dynamic>?) ?? [];

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: ValueKey(account.accountId),
            tilePadding: EdgeInsets.fromLTRB(16.w, 4.h, 8.w, 4.h),
            childrenPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
            leading: Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: account.isDebit
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                account.isDebit ? LucideIcons.wallet : LucideIcons.creditCard,
                color: account.isDebit ? Colors.green : Colors.orange,
                size: 18.r,
              ),
            ),
            title: Text(account.name, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 14.sp, color: textColor)),
            subtitle: Row(
              children: [
                Text(account.type, style: GoogleFonts.montserrat(fontSize: 12.sp, color: mutedColor)),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.w),
                  width: 3.r, height: 3.r,
                  decoration: BoxDecoration(color: mutedColor, shape: BoxShape.circle),
                ),
                Text(
                  '${(account.balance ?? 0).toStringAsFixed(2)} ${account.currency}',
                  style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.blueAccent),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _tinyIconBtn(LucideIcons.pencil, Colors.blueAccent, () => _showEditAccountSheet(bank['bankId'], accIndex)),
                _tinyIconBtn(LucideIcons.trash2, Colors.red, () => _deleteAccount(bank['bankId'], accIndex)),
              ],
            ),
            children: [
              // Credit card summary
              if (!account.isDebit) ...[
                _creditSummary(account, isDark),
                SizedBox(height: 8.h),
              ],

              // Transaction header
              if (transactions.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                  child: Row(
                    children: [
                      Text('Son İşlemler', style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w700, color: mutedColor, letterSpacing: 0.5)),
                      const Spacer(),
                      Text('${transactions.length} işlem', style: GoogleFonts.montserrat(fontSize: 11.sp, color: mutedColor)),
                    ],
                  ),
                ),

              // Transaction list
              ...transactions.map((txData) {
                final tx = Transaction.fromJson(txData);
                return _buildTransactionTile(bank['bankId'], account, tx, isDark);
              }),

              if (transactions.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text('Henüz işlem yok', style: GoogleFonts.montserrat(fontSize: 13.sp, color: mutedColor), textAlign: TextAlign.center),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _creditSummary(Account account, bool isDark) {
    final limit = account.creditLimit ?? 0;
    final totalDebt = account.totalDebt ?? 0;
    final available = account.availableCredit ?? (limit - totalDebt);
    final minPay = account.minPayment ?? 0;
    final mutedColor = isDark ? Colors.white38 : Colors.grey;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.orange.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(children: [
            _creditStat('Limit', '${limit.toStringAsFixed(0)} ${account.currency}', mutedColor, isDark),
            _creditStat('Borç', '${totalDebt.toStringAsFixed(0)} ${account.currency}', mutedColor, isDark),
          ]),
          SizedBox(height: 8.h),
          Row(children: [
            _creditStat('Kullanılabilir', '${available.toStringAsFixed(0)} ${account.currency}', mutedColor, isDark),
            _creditStat('Asgari Ödeme', '${minPay.toStringAsFixed(0)} ${account.currency}', mutedColor, isDark),
          ]),
        ],
      ),
    );
  }

  Widget _creditStat(String label, String value, Color mutedColor, bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 10.sp, color: mutedColor)),
          SizedBox(height: 2.h),
          Text(value, style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87)),
        ],
      ),
    );
  }

  // ── Transaction Tile ──

  Widget _buildTransactionTile(int bankId, Account account, Transaction tx, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white38 : Colors.grey.shade500;
    final amountColor = tx.isSurplus ? Colors.green : Colors.red;

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: InkWell(
        onTap: () => _showEditTransactionSheet(bankId, account, tx),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tx.isSurplus ? LucideIcons.arrowUpRight : LucideIcons.arrowDownRight,
                  color: amountColor,
                  size: 16.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.title, style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 2.h),
                    Text(
                      '${DateFormat('d MMM', 'tr').format(tx.date)} • ${tx.category}',
                      style: GoogleFonts.montserrat(fontSize: 11.sp, color: mutedColor),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${tx.isSurplus ? '+' : '-'}${tx.amount.abs().toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: amountColor),
                  ),
                  Text(tx.currency, style: GoogleFonts.montserrat(fontSize: 10.sp, color: mutedColor)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // SHARED FORM WIDGETS
  // ══════════════════════════════════════════════════════

  Widget _handle() => Center(
    child: Container(
      width: 36.w, height: 4.h,
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
    ),
  );

  TextStyle _titleStyle() => GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.bold);

  Widget _label(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(text, style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.white54 : Colors.grey.shade600));
  }

  Widget _sectionHeader(String text) {
    return Text(text, style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.blueAccent));
  }

  Widget _formField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    bool isNumber = false,
    ValueChanged<String>? onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          onChanged: onChanged,
          style: GoogleFonts.montserrat(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: hint ?? 'Giriniz...',
            hintStyle: GoogleFonts.montserrat(color: Colors.grey),
            prefixIcon: Icon(icon, size: 18.r, color: Colors.grey),
            filled: true,
            fillColor: isDark ? Colors.black12 : Colors.grey.shade100,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _segmentRow({required List<String> options, required String selected, required ValueChanged<String> onChanged}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: options.map((opt) {
          final isSel = selected == opt;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSel ? (isDark ? Colors.white.withOpacity(0.1) : Colors.white) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: isSel && !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)] : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  opt,
                  style: GoogleFonts.montserrat(
                    fontSize: 12.sp,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    color: isSel ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.white38 : Colors.grey),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _dropdownField({required String value, required List<String> items, required ValueChanged<String?> onChanged, String suffix = ''}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.black12 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text('$i$suffix', style: GoogleFonts.montserrat(fontSize: 14.sp)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _dateTile({required DateTime date, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isDark ? Colors.black12 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
        ),
        child: Row(children: [
          Icon(LucideIcons.calendar, size: 18.r, color: Colors.blueAccent),
          SizedBox(width: 12.w),
          Text(DateFormat('dd MMMM yyyy', 'tr').format(date), style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 14.sp)),
        ]),
      ),
    );
  }

  Widget _accountTypeToggle({required bool isDebit, required ValueChanged<bool> onChanged}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.blueAccent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: isDark ? Colors.white10 : Colors.blueAccent.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(isDebit ? LucideIcons.wallet : LucideIcons.creditCard, size: 20.r, color: Colors.blueAccent),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isDebit ? 'Banka Hesabı' : 'Kredi Kartı', style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 2.h),
                Text(
                  isDebit ? 'Para yatırılabilir hesap' : 'Kredi limiti olan hesap',
                  style: GoogleFonts.montserrat(fontSize: 11.sp, color: isDark ? Colors.white38 : Colors.grey),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: isDebit, onChanged: onChanged, activeColor: Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w500)),
          Text(value, style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.blueAccent)),
        ],
      ),
    );
  }

  Widget _tinyIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.all(6.r),
        child: Icon(icon, size: 16.r, color: color.withOpacity(0.7)),
      ),
    );
  }
}