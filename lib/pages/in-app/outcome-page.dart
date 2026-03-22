import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../blocs/income-selections.dart';
import '../../components/add_transaction_modal.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../add-expense/faturalar.dart';

class OutcomePage extends StatefulWidget {
  const OutcomePage({super.key});

  @override
  State<OutcomePage> createState() => _OutcomePageState();
}

class _OutcomePageState extends State<OutcomePage> {
  // ── Core State ──
  List<Map<String, dynamic>> bankAccounts = [];
  Map<String, dynamic>? selectedAccount;
  bool _isLoading = true;

  // ── Categories & Invoices ──
  List<CategoryData> userCategories = [];
  final List<Invoice> invoices = [];

  // ── Legacy sums (kept for backward compatibility) ──
  double sumOfTV = 0, sumOfGame = 0, sumOfMusic = 0;
  double sumOfHome = 0, sumOfInternet = 0, sumOfPhone = 0;
  double sumOfRent = 0, sumOfKitchen = 0, sumOfCatering = 0;
  double sumOfEnt = 0, sumOfOther = 0;
  double sumOfSubs = 0, sumOfBills = 0, sumOfOthers = 0;

  List<String> tvTitleList = [], gameTitleList = [], musicTitleList = [];
  List<String> tvPriceList = [], gamePriceList = [], musicPriceList = [];
  List<String> homeBillsTitleList = [], internetTitleList = [], phoneTitleList = [];
  List<String> homeBillsPriceList = [], internetPriceList = [], phonePriceList = [];
  List<String> rentTitleList = [], kitchenTitleList = [], cateringTitleList = [];
  List<String> entertainmentTitleList = [], otherTitleList = [];
  List<String> rentPriceList = [], kitchenPriceList = [], cateringPriceList = [];
  List<String> entertainmentPriceList = [], otherPriceList = [];

  String selectedTitle = '';
  String faturaDonemi = '';
  String? sonOdeme;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ══════════════════════════════════════════════════════
  // DATA LOADING
  // ══════════════════════════════════════════════════════

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // Income selection
    final optionIndex = prefs.getInt('selected_option') ?? SelectedOption.None.index;
    selectedTitle = _labelForOption(SelectedOption.values[optionIndex]);

    // Legacy sums
    sumOfTV = prefs.getDouble('sumOfTV2') ?? 0;
    sumOfGame = prefs.getDouble('sumOfGame2') ?? 0;
    sumOfMusic = prefs.getDouble('sumOfMusic2') ?? 0;
    sumOfHome = prefs.getDouble('sumOfHome2') ?? 0;
    sumOfInternet = prefs.getDouble('sumOfInternet2') ?? 0;
    sumOfPhone = prefs.getDouble('sumOfPhone2') ?? 0;
    sumOfRent = prefs.getDouble('sumOfRent2') ?? 0;
    sumOfKitchen = prefs.getDouble('sumOfKitchen2') ?? 0;
    sumOfCatering = prefs.getDouble('sumOfCatering2') ?? 0;
    sumOfEnt = prefs.getDouble('sumOfEnt2') ?? 0;
    sumOfOther = prefs.getDouble('sumOfOther2') ?? 0;
    sumOfSubs = prefs.getDouble('sumOfSubs2') ?? 0;
    sumOfBills = prefs.getDouble('sumOfBills2') ?? 0;
    sumOfOthers = prefs.getDouble('sumOfOthers2') ?? 0;

    // Legacy lists
    tvTitleList = prefs.getStringList('tvTitleList2') ?? [];
    gameTitleList = prefs.getStringList('gameTitleList2') ?? [];
    musicTitleList = prefs.getStringList('musicTitleList2') ?? [];
    homeBillsTitleList = prefs.getStringList('homeBillsTitleList2') ?? [];
    internetTitleList = prefs.getStringList('internetTitleList2') ?? [];
    phoneTitleList = prefs.getStringList('phoneTitleList2') ?? [];
    rentTitleList = prefs.getStringList('rentTitleList2') ?? [];
    kitchenTitleList = prefs.getStringList('kitchenTitleList2') ?? [];
    cateringTitleList = prefs.getStringList('cateringTitleList2') ?? [];
    entertainmentTitleList = prefs.getStringList('entertainmentTitleList2') ?? [];
    otherTitleList = prefs.getStringList('otherTitleList2') ?? [];
    tvPriceList = prefs.getStringList('tvPriceList2') ?? [];
    gamePriceList = prefs.getStringList('gamePriceList2') ?? [];
    musicPriceList = prefs.getStringList('musicPriceList2') ?? [];
    homeBillsPriceList = prefs.getStringList('homeBillsPriceList2') ?? [];
    internetPriceList = prefs.getStringList('internetPriceList2') ?? [];
    phonePriceList = prefs.getStringList('phonePriceList2') ?? [];
    rentPriceList = prefs.getStringList('rentPriceList2') ?? [];
    kitchenPriceList = prefs.getStringList('kitchenPriceList2') ?? [];
    cateringPriceList = prefs.getStringList('cateringPriceList2') ?? [];
    entertainmentPriceList = prefs.getStringList('entertainmentPriceList2') ?? [];
    otherPriceList = prefs.getStringList('otherPriceList2') ?? [];

    // Invoices
    for (final s in prefs.getStringList('invoices') ?? []) {
      try {
        invoices.add(Invoice.fromJson(jsonDecode(s)));
      } catch (_) {}
    }

    // Categories
    final catData = await CategoryStorage.load();
    if (catData != null) userCategories = catData;

    // Bank accounts
    final accountListJson = prefs.getString('accountDataList');
    final savedAccountJson = prefs.getString('selectedAccount');

    if (accountListJson != null) {
      try {
        bankAccounts = List<Map<String, dynamic>>.from(jsonDecode(accountListJson));

        if (savedAccountJson != null) {
          final saved = Map<String, dynamic>.from(jsonDecode(savedAccountJson));
          if (saved['accountId'] != null) {
            selectedAccount = _findAccountById(saved['accountId']);
          }
        }
      } catch (e) {
        debugPrint('Error loading accounts: $e');
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ══════════════════════════════════════════════════════
  // PERSISTENCE
  // ══════════════════════════════════════════════════════

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accountDataList', jsonEncode(bankAccounts));
  }

  Future<void> _saveSelectedAccount(Map<String, dynamic> account) async {
    final accountId = account['accountId'] ?? (account['accounts'] as List?)?.firstOrNull?['accountId'];
    final bankId = account['bankId'];
    if (accountId == null || bankId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAccount', jsonEncode({'accountId': accountId, 'bankId': bankId}));
  }

  Future<void> saveInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('invoices', invoices.map((i) => jsonEncode(i.toJson())).toList());
  }

  // ══════════════════════════════════════════════════════
  // TRANSACTION LOGIC (unchanged business logic)
  // ══════════════════════════════════════════════════════

  Map<String, Map<String, List<Transaction>>> _groupedTransactions() {
    final grouped = <String, Map<String, List<Transaction>>>{};
    final txList = selectedAccount?['transactions'] as List?;
    if (txList == null) return grouped;

    for (var t in txList) {
      late Transaction tx;
      if (t is Map) {
        tx = Transaction.fromJson(Map<String, dynamic>.from(t));
      } else if (t is Transaction) {
        tx = t;
      } else {
        continue;
      }
      if (tx.isSurplus) continue;

      final cat = tx.category.isNotEmpty ? tx.category : 'Diğer';
      final sub = tx.subcategory.isNotEmpty ? tx.subcategory : 'Diğer';
      grouped.putIfAbsent(cat, () => {});
      grouped[cat]!.putIfAbsent(sub, () => []);
      grouped[cat]![sub]!.add(tx);
    }
    return grouped;
  }

  double _totalFromGrouped(Map<String, Map<String, List<Transaction>>> grouped) {
    double total = 0;
    for (final cat in grouped.values) {
      for (final subList in cat.values) {
        total += subList.fold<double>(0, (s, tx) => s + tx.amount);
      }
    }
    return total;
  }

  Future<void> _processTransactionUpdate(Transaction newTx, [Transaction? existing]) async {
    final isEditing = existing != null;

    setState(() {
      for (var bank in bankAccounts) {
        if (bank['bankId'] != selectedAccount!['bankId']) continue;
        final accounts = bank['accounts'] as List?;
        if (accounts == null) continue;

        for (var account in accounts) {
          if (account['accountId'] != selectedAccount!['accountId']) continue;

          account['transactions'] = account['transactions'] ?? [];
          Account accountInstance = Account.fromJson(account);

          if (isEditing) {
            final txList = account['transactions'] as List;
            final index = txList.indexWhere((tx) => Transaction.fromJson(tx).transactionId == existing.transactionId);
            if (index != -1) {
              final oldTx = Transaction.fromJson(txList[index]);
              _reverseTransactionDebt(account, oldTx);
              _applyTransactionDebt(account, newTx);
              txList[index] = newTx.toJson();
              accountInstance = Account.fromJson(account);
              account['minPayment'] = accountInstance.calculateMinPayment();
              account['remainingMinPayment'] = account['minPayment'];
            }
          } else {
            account['transactions'].add(newTx.toJson());
            _applyTransactionDebt(account, newTx);
            accountInstance = Account.fromJson(account);
            account['minPayment'] = accountInstance.calculateMinPayment();
            account['remainingMinPayment'] = account['minPayment'];
          }
        }
      }
    });

    await _saveToPrefs();
    await _saveSelectedAccount(selectedAccount!);
  }

  void _applyTransactionDebt(Map<String, dynamic> account, Transaction tx) {
    if (account['isDebit'] == true) return;

    if (tx.isInstallment && tx.installment! > 1 && tx.totalAmount != null) {
      final totalAmount = tx.totalAmount!;
      final perInstallment = tx.amount;
      final isPaid = tx.isInstallmentPaid ?? false;

      account['availableCredit'] = (account['availableCredit'] ?? account['creditLimit']) - totalAmount;
      account['totalDebt'] = (account['totalDebt'] ?? 0.0) + totalAmount;

      if (isPaid) {
        account['availableCredit'] = (account['availableCredit'] ?? 0.0) + perInstallment;
        if (!tx.isProvisioned) account['currentDebt'] = (account['currentDebt'] ?? 0.0) - perInstallment;
      } else {
        if (!tx.isProvisioned) account['currentDebt'] = (account['currentDebt'] ?? 0.0) + perInstallment;
      }
      _updatePeriodDebts(account, tx, isAdding: true);
    } else {
      account['availableCredit'] = (account['availableCredit'] ?? account['creditLimit']) - tx.amount;
      if (!tx.isProvisioned) account['currentDebt'] = (account['currentDebt'] ?? 0.0) + tx.amount;
      account['totalDebt'] = (account['totalDebt'] ?? 0.0) + tx.amount;
      _updatePeriodDebts(account, tx, isAdding: true);
    }
  }

  void _reverseTransactionDebt(Map<String, dynamic> account, Transaction tx) {
    if (account['isDebit'] == true) return;

    if (tx.isInstallment && tx.installment! > 1 && tx.totalAmount != null) {
      final totalAmount = tx.totalAmount!;
      final perInstallment = tx.amount;
      final isPaid = tx.isInstallmentPaid ?? false;

      account['availableCredit'] = (account['availableCredit'] ?? 0.0) + totalAmount;
      account['totalDebt'] = (account['totalDebt'] ?? 0.0) - totalAmount;

      if (isPaid) {
        account['availableCredit'] = (account['availableCredit'] ?? 0.0) - perInstallment;
        if (!tx.isProvisioned) account['currentDebt'] = (account['currentDebt'] ?? 0.0) + perInstallment;
      } else {
        if (!tx.isProvisioned) account['currentDebt'] = (account['currentDebt'] ?? 0.0) - perInstallment;
      }
      _updatePeriodDebts(account, tx, isAdding: false);
    } else {
      account['availableCredit'] = (account['availableCredit'] ?? 0.0) + tx.amount;
      if (!tx.isProvisioned) account['currentDebt'] = (account['currentDebt'] ?? 0.0) - tx.amount;
      account['totalDebt'] = (account['totalDebt'] ?? 0.0) - tx.amount;
      _updatePeriodDebts(account, tx, isAdding: false);
    }
  }

  void _updatePeriodDebts(Map<String, dynamic> account, Transaction tx, {required bool isAdding}) {
    DateTime parseDate(String dateStr) {
      try {
        return DateFormat('dd/MM/yyyy').parse(dateStr);
      } catch (_) {
        return DateTime.now();
      }
    }

    final nextCutoff = parseDate(account['nextCutoffDate'] ?? DateTime.now().toString());
    final multiplier = isAdding ? 1 : -1;

    if (tx.date.isBefore(nextCutoff)) {
      if (!tx.isProvisioned) {
        account['remainingDebt'] = (account['remainingDebt'] ?? 0.0) + (tx.amount * multiplier);
      }
    } else {
      account['previousDebt'] = (account['previousDebt'] ?? 0.0) + (tx.amount * multiplier);
    }
  }

  Future<void> _deleteTransaction(Transaction tx, {bool deleteAllInstallments = false}) async {
    final prefs = await SharedPreferences.getInstance();

    List<Transaction> toDelete = [tx];

    if (deleteAllInstallments && tx.isInstallment && tx.parentTransactionId != null) {
      final allTx = selectedAccount?['transactions'] as List? ?? [];
      for (var json in allTx) {
        final t = Transaction.fromJson(json);
        if (t.parentTransactionId == tx.parentTransactionId) toDelete.add(t);
      }
    }

    List<Map<String, dynamic>> transactions = List<Map<String, dynamic>>.from(selectedAccount!['transactions'] ?? []);
    double totalRemoved = 0;

    for (var del in toDelete) {
      transactions.removeWhere((t) => t['transactionId'] == del.transactionId);
      totalRemoved += del.amount;
    }

    selectedAccount!['transactions'] = transactions;
    selectedAccount!['balance'] = (selectedAccount!['balance'] ?? 0.0) - totalRemoved;

    if (selectedAccount!['isDebit'] == false) {
      selectedAccount!['currentDebt'] = (selectedAccount!['currentDebt'] ?? 0.0) - totalRemoved;
      selectedAccount!['totalDebt'] = (selectedAccount!['totalDebt'] ?? 0.0) - totalRemoved;
      selectedAccount!['availableCredit'] = (selectedAccount!['availableCredit'] ?? 0.0) + totalRemoved;

      DateTime parseDate(String s) {
        try { return DateFormat('dd/MM/yyyy').parse(s); } catch (_) { return DateTime.now(); }
      }
      final nextCutoff = parseDate(selectedAccount!['nextCutoffDate'] ?? DateTime.now().toString());

      for (var del in toDelete) {
        if (del.date.isBefore(nextCutoff)) {
          if (!del.isProvisioned) {
            selectedAccount!['remainingDebt'] = (selectedAccount!['remainingDebt'] ?? 0.0) - del.amount;
          }
        } else {
          selectedAccount!['previousDebt'] = (selectedAccount!['previousDebt'] ?? 0.0) - del.amount;
        }
      }

      Account inst = Account.fromJson(selectedAccount!);
      selectedAccount!['minPayment'] = inst.calculateMinPayment();
      selectedAccount!['remainingMinPayment'] = selectedAccount!['minPayment'];
    }

    for (var bank in bankAccounts) {
      if (bank['bankId'] == selectedAccount!['bankId']) {
        List accounts = List.from(bank['accounts'] ?? []);
        for (int i = 0; i < accounts.length; i++) {
          if (accounts[i]['accountId'] == selectedAccount!['accountId']) {
            accounts[i] = selectedAccount!;
            break;
          }
        }
        bank['accounts'] = accounts;
        break;
      }
    }

    await prefs.setString('accountDataList', jsonEncode(bankAccounts));
    await _saveSelectedAccount(selectedAccount!);
    setState(() {});
  }

  // ══════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════

  String _labelForOption(SelectedOption option) => switch (option) {
    SelectedOption.Is => 'İş',
    SelectedOption.Burs => 'Burs',
    SelectedOption.Emekli => 'Emekli',
    _ => '',
  };

  Map<String, dynamic>? _findAccountById(int? accountId) {
    if (accountId == null) return null;
    for (var bank in bankAccounts) {
      for (var account in bank['accounts'] ?? []) {
        if (account['accountId'] == accountId) {
          return {...account, 'bankId': bank['bankId'], 'bankName': bank['bankName']};
        }
      }
    }
    return null;
  }

  String getDaysRemainingMessage(Invoice invoice) {
    final now = DateTime.now();
    final formatted = DateFormat('yyyy-MM-dd').format(now);

    if (now.isBefore(DateTime.parse(faturaDonemi))) {
      invoice.difference = (DateTime.parse(faturaDonemi).difference(now).inDays + 1).toString();
      return invoice.difference;
    } else if (formatted == faturaDonemi) {
      invoice.difference = '0';
      return '0';
    } else if (invoice.dueDate != null && sonOdeme != null && now.isAfter(DateTime.parse(faturaDonemi))) {
      invoice.difference = (DateTime.parse(sonOdeme!).difference(now).inDays + 1).toString();
      return invoice.difference;
    }
    return '0';
  }

  void onSave(Invoice invoice) {
    getDaysRemainingMessage(invoice);
    setState(() => invoices.add(invoice));
    saveInvoices();
  }

  void removeInvoice(int id) {
    setState(() {
      invoices.removeWhere((i) => i.id == id);
    });
    saveInvoices();
  }

  // ══════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F6F8);
    final textColor = isDark ? Colors.white : Colors.black87;
    final mutedColor = isDark ? Colors.white54 : Colors.grey.shade600;

    final grouped = _groupedTransactions();
    final totalAmount = _totalFromGrouped(grouped);

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
        title: Text(
          'Giderler',
          style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : RefreshIndicator.adaptive(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          children: [
            // ── Account Selector ──
            if (bankAccounts.isNotEmpty) ...[
              _buildAccountSelector(isDark, textColor, mutedColor),
              SizedBox(height: 20.h),
            ],

            // ── Total Summary ──
            if (totalAmount > 0) ...[
              _buildTotalCard(totalAmount, isDark, textColor, mutedColor),
              SizedBox(height: 20.h),
            ],

            // ── Category Progress Bars ──
            if (grouped.isNotEmpty) ...[
              _buildCategoryBars(grouped, totalAmount, isDark, textColor, mutedColor),
              SizedBox(height: 20.h),
              _buildTransactionGroups(grouped, isDark, textColor, mutedColor),
            ],

            // ── Empty State ──
            if (grouped.isEmpty) _buildEmptyState(isDark, mutedColor),

            SizedBox(height: 80.h),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTransactionModal,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus),
        label: Text('İşlem Ekle', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
    );
  }

  // ── Account Selector ──

  Widget _buildAccountSelector(bool isDark, Color textColor, Color mutedColor) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderCol = isDark ? Colors.white10 : Colors.grey.shade200;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderCol),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: DropdownButtonFormField<int>(
        value: selectedAccount?['accountId'],
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Hesap Seçin',
          labelStyle: GoogleFonts.montserrat(fontSize: 14.sp, color: mutedColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          prefixIcon: Icon(LucideIcons.wallet, size: 20.r, color: Colors.blueAccent),
        ),
        style: GoogleFonts.montserrat(fontSize: 14.sp, color: textColor),
        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        items: bankAccounts.expand<DropdownMenuItem<int>>((bank) {
          return (bank['accounts'] as List?)?.map((acc) {
            return DropdownMenuItem<int>(
              value: acc['accountId'],
              child: Text(
                "${bank['bankName']} — ${acc['name']}",
                style: GoogleFonts.montserrat(fontSize: 14.sp),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }) ??
              [];
        }).toList(),
        onChanged: (id) {
          if (id == null) return;
          final acc = _findAccountById(id);
          if (acc != null) {
            setState(() => selectedAccount = acc);
            _saveSelectedAccount(acc);
          }
        },
      ),
    );
  }

  // ── Total Card ──

  Widget _buildTotalCard(double total, bool isDark, Color textColor, Color mutedColor) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderCol = isDark ? Colors.white10 : Colors.grey.shade200;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderCol),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.trendingDown, color: Colors.red, size: 18.r),
                    SizedBox(width: 8.w),
                    Text('Toplam Gider', style: GoogleFonts.montserrat(fontSize: 13.sp, color: mutedColor)),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  '${total.toStringAsFixed(2)} ₺',
                  style: GoogleFonts.montserrat(fontSize: 28.sp, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.5),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(LucideIcons.receipt, color: Colors.red, size: 28.r),
          ),
        ],
      ),
    );
  }

  // ── Category Progress Bars ──

  Widget _buildCategoryBars(
      Map<String, Map<String, List<Transaction>>> grouped,
      double totalAmount,
      bool isDark,
      Color textColor,
      Color mutedColor,
      ) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderCol = isDark ? Colors.white10 : Colors.grey.shade200;

    // Generate colors for categories
    final catKeys = grouped.keys.toList();

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderCol),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kategori Dağılımı', style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: textColor)),
          SizedBox(height: 16.h),
          ...catKeys.asMap().entries.map((entry) {
            final idx = entry.key;
            final catName = entry.value;
            final subMap = grouped[catName]!;
            double catTotal = 0;
            for (var subList in subMap.values) {
              catTotal += subList.fold<double>(0, (s, tx) => s + tx.amount);
            }
            final percent = totalAmount > 0 ? catTotal / totalAmount : 0.0;
            final color = _categoryColor(idx);

            return Padding(
              padding: EdgeInsets.only(bottom: idx < catKeys.length - 1 ? 14.h : 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10.r, height: 10.r,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          SizedBox(width: 8.w),
                          Text(catName, style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: textColor)),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '${catTotal.toStringAsFixed(2)} ₺',
                            style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: textColor),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '%${(percent * 100).toStringAsFixed(0)}',
                              style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w600, color: color),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: percent.clamp(0.0, 1.0),
                      minHeight: 6.h,
                      backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _categoryColor(int index) {
    const colors = [
      Colors.blueAccent,
      Colors.orange,
      Colors.teal,
      Colors.purple,
      Colors.red,
      Colors.green,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }

  // ── Transaction Groups ──

  Widget _buildTransactionGroups(
      Map<String, Map<String, List<Transaction>>> grouped,
      bool isDark,
      Color textColor,
      Color mutedColor,
      ) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderCol = isDark ? Colors.white10 : Colors.grey.shade200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İŞLEMLER',
          style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w700, color: mutedColor, letterSpacing: 1.2),
        ),
        SizedBox(height: 12.h),
        ...grouped.entries.map((catEntry) {
          final catIdx = grouped.keys.toList().indexOf(catEntry.key);

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: borderCol),
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  childrenPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                  leading: Container(
                    width: 36.r, height: 36.r,
                    decoration: BoxDecoration(
                      color: _categoryColor(catIdx).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.folder, size: 16.r, color: _categoryColor(catIdx)),
                  ),
                  title: Text(catEntry.key, style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.w600, color: textColor)),
                  subtitle: Text(
                    '${catEntry.value.values.fold<int>(0, (s, l) => s + l.length)} işlem',
                    style: GoogleFonts.montserrat(fontSize: 12.sp, color: mutedColor),
                  ),
                  children: catEntry.value.entries.map((subEntry) {
                    return Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(horizontal: 12.w),
                        childrenPadding: EdgeInsets.symmetric(horizontal: 8.w),
                        leading: Icon(LucideIcons.tag, size: 16.r, color: Colors.blueAccent),
                        title: Text(subEntry.key, style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w500, color: textColor)),
                        children: subEntry.value.map((tx) => _buildTransactionTile(tx, isDark, textColor, mutedColor)).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTransactionTile(Transaction tx, bool isDark, Color textColor, Color mutedColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Dismissible(
        key: Key('tx_${tx.transactionId}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 16.w),
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12.r)),
          child: Icon(LucideIcons.trash2, color: Colors.white, size: 18.r),
        ),
        confirmDismiss: (_) async {
          if (tx.isInstallment && tx.installment != null && tx.installment! > 1) {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Taksit Silme', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                content: Text('Tüm taksitleri silmek ister misiniz?', style: GoogleFonts.montserrat()),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
                  TextButton(
                    onPressed: () {
                      _deleteTransaction(tx, deleteAllInstallments: false);
                      Navigator.pop(ctx, false);
                    },
                    child: const Text('Sadece Bu'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      _deleteTransaction(tx, deleteAllInstallments: true);
                      Navigator.pop(ctx, false);
                    },
                    child: const Text('Tümünü Sil'),
                  ),
                ],
              ),
            );
          }
          return true;
        },
        onDismissed: (_) => _deleteTransaction(tx),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 34.r, height: 34.r,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.arrowDownRight, color: Colors.red, size: 16.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(LucideIcons.calendar, size: 11.r, color: mutedColor),
                        SizedBox(width: 4.w),
                        Text(
                          DateFormat('d MMM yyyy', 'tr').format(tx.date),
                          style: GoogleFonts.montserrat(fontSize: 11.sp, color: mutedColor),
                        ),
                        if (tx.isInstallment && tx.installment != null && tx.installment! > 1) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '${tx.currentInstallment ?? 1}/${tx.installment}',
                              style: GoogleFonts.montserrat(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.blueAccent),
                            ),
                          ),
                        ],
                        if (tx.isProvisioned) ...[
                          SizedBox(width: 6.w),
                          Icon(LucideIcons.shield, size: 12.r, color: Colors.orange),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '${tx.amount.toStringAsFixed(2)} ${tx.currency}',
                style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty State ──

  Widget _buildEmptyState(bool isDark, Color mutedColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      child: Column(
        children: [
          Icon(LucideIcons.inbox, size: 48.r, color: mutedColor),
          SizedBox(height: 16.h),
          Text('Henüz işlem yok', style: GoogleFonts.montserrat(fontSize: 15.sp, color: mutedColor, fontWeight: FontWeight.w500)),
          SizedBox(height: 6.h),
          Text('+ butonuyla yeni gider ekleyin', style: GoogleFonts.montserrat(fontSize: 13.sp, color: mutedColor.withOpacity(0.7))),
        ],
      ),
    );
  }

  // ── Add Transaction Modal ──

  Future<void> _showAddTransactionModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionModal(
        accounts: bankAccounts,
        selectedAccount: selectedAccount,
        onTransactionAdded: (tx) => _processTransactionUpdate(tx),
        userCategories: userCategories,
      ),
    );
  }
}