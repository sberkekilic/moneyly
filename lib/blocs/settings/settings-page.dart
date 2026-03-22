import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// MODELS
// ============================================================================

class CategoryData {
  final String category;
  final String subcategory;

  CategoryData({required this.category, required this.subcategory});
}

class CategoryStorage {
  static const _key = 'userCategories';

  static Future<void> save(List<CategoryData> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list
        .map((e) => jsonEncode({
      'category': e.category,
      'subcategory': e.subcategory,
    }))
        .toList();

    await prefs.setStringList(_key, jsonList);
  }

  static Future<List<CategoryData>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key);
    if (jsonList == null) return [];

    return jsonList.map((e) {
      final map = jsonDecode(e);
      return CategoryData(
        category: map['category'],
        subcategory: map['subcategory'],
      );
    }).toList();
  }
}

// ============================================================================
// THEME COLORS
// ============================================================================

class SettingsColors {
  final bool isDark;

  SettingsColors({required this.isDark});

  // Backgrounds
  Color get scaffold => isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA);
  Color get card => isDark ? const Color(0xFF1A1A1A) : Colors.white;
  Color get cardHover => isDark ? const Color(0xFF242424) : const Color(0xFFF5F5F5);

  // Text
  Color get primaryText => isDark ? Colors.white : const Color(0xFF1A1A1A);
  Color get secondaryText => isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280);
  Color get tertiaryText => isDark ? const Color(0xFF707070) : const Color(0xFF9CA3AF);

  // Borders
  Color get border => isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB);
  Color get divider => isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6);

  // Accent colors
  Color get primary => isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);
  Color get success => const Color(0xFF10B981);
  Color get warning => const Color(0xFFF59E0B);
  Color get error => const Color(0xFFEF4444);

  // Icon backgrounds
  Color get iconBg => isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6);
  Color get iconBgAccent => isDark ? primary.withOpacity(0.15) : primary.withOpacity(0.1);
}

// ============================================================================
// SETTINGS PAGE
// ============================================================================

class SettingsPage extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const SettingsPage({
    Key? key,
    required this.onThemeToggle,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<CategoryData> userCategories = [];
  List<Map<String, dynamic>> bankAccounts = [];
  List<Map<String, dynamic>> debtAccounts = [];
  int? selectedAccountId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadCategories();
    await _loadAccountsFromPrefs();
    setState(() {});
  }

  Future<void> _loadCategories() async {
    userCategories = await CategoryStorage.load();
  }

  Future<void> _loadAccountsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final accountDataListJson = prefs.getString("accountDataList");
    final saved = prefs.getString('selectedAccount');

    if (saved != null) {
      final map = jsonDecode(saved);
      selectedAccountId = map['accountId'];
    }

    if (accountDataListJson != null) {
      try {
        final List<dynamic> decodedData = jsonDecode(accountDataListJson);
        final cleanedData = _cleanDuplicateAccounts(decodedData);
        await prefs.setString('accountDataList', jsonEncode(cleanedData));

        setState(() {
          bankAccounts =
              cleanedData.map((e) => Map<String, dynamic>.from(e)).toList();
        });

        debtAccounts.clear();
        for (final bank in bankAccounts) {
          final accounts = (bank['accounts'] as List?) ?? [];
          for (final acc in accounts) {
            if (acc['isDebit'] == false && (acc['remainingDebt'] ?? 0) > 0) {
              debtAccounts.add(acc);
            }
          }
        }
      } catch (e) {
        print("Error decoding account data: $e");
      }
    }
  }

  List<Map<String, dynamic>> _cleanDuplicateAccounts(
      List<dynamic> accountList) {
    final List<Map<String, dynamic>> cleanedList = [];
    final Set<int> usedAccountIds = {};
    final Set<String> usedBankAccountPairs = {};

    for (var bankData in accountList) {
      final bankMap = Map<String, dynamic>.from(bankData);
      final bankId = bankMap['bankId']?.toString() ?? 'unknown';
      final accounts = (bankMap['accounts'] as List? ?? []);
      final List<Map<String, dynamic>> cleanedAccounts = [];

      for (var account in accounts) {
        final accountMap = Map<String, dynamic>.from(account);
        final accountId = accountMap['accountId'] as int?;
        final accountName = accountMap['name']?.toString() ?? 'Unnamed';
        final String pairKey = '$bankId-$accountName';

        if (accountId != null) {
          if (usedAccountIds.contains(accountId)) continue;
          if (usedBankAccountPairs.contains(pairKey)) continue;

          usedAccountIds.add(accountId);
          usedBankAccountPairs.add(pairKey);
          cleanedAccounts.add(accountMap);
        } else {
          final newId =
              DateTime.now().millisecondsSinceEpoch + cleanedAccounts.length;
          accountMap['accountId'] = newId;
          cleanedAccounts.add(accountMap);
        }
      }

      if (cleanedAccounts.isNotEmpty) {
        bankMap['accounts'] = cleanedAccounts;
        cleanedList.add(bankMap);
      }
    }

    return cleanedList;
  }

  Future<void> _saveSelectedAccount(int accountId) async {
    final prefs = await SharedPreferences.getInstance();

    final bank = bankAccounts.firstWhere(
          (b) =>
          (b['accounts'] as List).any((acc) => acc['accountId'] == accountId),
    );

    final acc = (bank['accounts'] as List)
        .firstWhere((acc) => acc['accountId'] == accountId);

    await prefs.setString(
        'selectedAccount',
        jsonEncode({
          'accountId': acc['accountId'],
          'bankId': bank['bankId'],
        }));
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final jsonString = jsonEncode(bankAccounts);
      await prefs.setString('accountDataList', jsonString);
    } catch (e) {
      print('[ERROR] Failed to save accountDataList: $e');
    }
  }

  Map<String, List<CategoryData>> get groupedCategories {
    final map = <String, List<CategoryData>>{};
    for (var item in userCategories) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = SettingsColors(isDark: isDark);

    return Scaffold(
      backgroundColor: colors.scaffold,
      body: CustomScrollView(
        slivers: [
          // App Bar
          _buildAppBar(colors),

          // Content
          SliverPadding(
            padding: EdgeInsets.all(20.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Appearance Section
                _buildSectionHeader(colors, "Appearance", LucideIcons.palette),
                SizedBox(height: 12.h),
                _buildThemeToggle(colors, isDark),

                SizedBox(height: 32.h),

                // Account Section
                _buildSectionHeader(colors, "Account", LucideIcons.wallet),
                SizedBox(height: 12.h),
                _buildAccountSelector(colors),

                SizedBox(height: 32.h),

                // Categories Section
                _buildSectionHeader(colors, "Categories", LucideIcons.folder),
                SizedBox(height: 12.h),
                _buildCategoriesSection(colors),

                SizedBox(height: 32.h),

                // Debts Section
                _buildSectionHeader(colors, "Debts", LucideIcons.creditCard),
                SizedBox(height: 12.h),
                _buildDebtsSection(colors),

                SizedBox(height: 32.h),

                // App Info Section
                _buildSectionHeader(colors, "About", LucideIcons.info),
                SizedBox(height: 12.h),
                _buildAppInfoSection(colors),

                SizedBox(height: 40.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // APP BAR
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildAppBar(SettingsColors colors) {
    return SliverAppBar(
      expandedHeight: 100.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: colors.scaffold,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: colors.border),
          ),
          child: Icon(
            LucideIcons.arrowLeft,
            size: 18.r,
            color: colors.primaryText,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 20.w, bottom: 16.h),
        title: Text(
          "Settings",
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: colors.primaryText,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SECTION HEADER
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(
      SettingsColors colors, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: colors.iconBgAccent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 16.r,
            color: colors.primary,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: colors.secondaryText,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // THEME TOGGLE
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildThemeToggle(SettingsColors colors, bool isDark) {
    return _SettingsCard(
      colors: colors,
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF3B2F0A)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              isDark ? LucideIcons.moon : LucideIcons.sun,
              size: 22.r,
              color: isDark
                  ? const Color(0xFFFBBF24)
                  : const Color(0xFFD97706),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dark Mode",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.primaryText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isDark ? "Currently enabled" : "Currently disabled",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          _MinimalSwitch(
            value: isDark,
            onChanged: (_) {
              HapticFeedback.lightImpact();
              widget.onThemeToggle();
            },
            colors: colors,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACCOUNT SELECTOR
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildAccountSelector(SettingsColors colors) {
    final items = _getUniqueAccountItems(colors);
    final hasSelectedItem = selectedAccountId != null &&
        items.any((item) => item.value == selectedAccountId);

    if (items.isEmpty) {
      return _SettingsCard(
        colors: colors,
        onTap: () => Navigator.pushNamed(context, "/accounts-add"),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: colors.iconBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                LucideIcons.plus,
                size: 22.r,
                color: colors.secondaryText,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Account",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.primaryText,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "No accounts available",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: colors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20.r,
              color: colors.tertiaryText,
            ),
          ],
        ),
      );
    }

    return _SettingsCard(
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Default Account",
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: colors.secondaryText,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: colors.iconBg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: hasSelectedItem ? selectedAccountId : null,
                hint: Text(
                  "Select Account",
                  style: TextStyle(
                    color: colors.tertiaryText,
                    fontSize: 15.sp,
                  ),
                ),
                items: items,
                onChanged: (value) {
                  if (value != null) {
                    HapticFeedback.selectionClick();
                    _saveSelectedAccount(value);
                    setState(() {
                      selectedAccountId = value;
                    });
                  }
                },
                icon: Icon(
                  LucideIcons.chevronDown,
                  color: colors.secondaryText,
                  size: 20.r,
                ),
                dropdownColor: colors.card,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: colors.primaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<int>> _getUniqueAccountItems(SettingsColors colors) {
    final List<DropdownMenuItem<int>> items = [];
    final Set<int> usedIds = {};

    try {
      for (var bank in bankAccounts) {
        final bankName = bank['bankName']?.toString() ?? 'Unknown Bank';
        final accounts = bank['accounts'] as List?;

        if (accounts != null) {
          for (var account in accounts) {
            final accountId = account['accountId'];
            if (accountId == null || accountId is! int) continue;
            if (usedIds.contains(accountId)) continue;

            usedIds.add(accountId);

            final accountName = account['name']?.toString() ?? 'Unnamed';
            final isDebit = account['isDebit'] == true;
            final balance = account['balance'] ?? 0.0;
            final currency = account['currency']?.toString() ?? 'TRY';

            items.add(DropdownMenuItem<int>(
              value: accountId,
              child: Row(
                children: [
                  Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: colors.iconBg,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      isDebit ? LucideIcons.wallet : LucideIcons.creditCard,
                      size: 16.r,
                      color: colors.secondaryText,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          accountName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: colors.primaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "$bankName • ${balance.toStringAsFixed(0)} $currency",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: colors.secondaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ));
          }
        }
      }
    } catch (e) {
      print('Error generating dropdown items: $e');
    }

    return items;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CATEGORIES SECTION
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildCategoriesSection(SettingsColors colors) {
    if (userCategories.isEmpty) {
      return _SettingsCard(
        colors: colors,
        child: _EmptyState(
          colors: colors,
          icon: LucideIcons.folderOpen,
          title: "No categories yet",
          subtitle: "Add custom categories for your transactions",
          buttonLabel: "Add Category",
          onButtonPressed: _addCategory,
        ),
      );
    }

    return _SettingsCard(
      colors: colors,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ...groupedCategories.entries.map((entry) {
            final category = entry.key;
            final subcategories = entry.value;

            return _CategoryTile(
              colors: colors,
              category: category,
              subcategories: subcategories,
              onEdit: (item) {
                final index = userCategories.indexOf(item);
                _editCategory(index);
              },
              onDelete: (item) {
                final index = userCategories.indexOf(item);
                _deleteCategory(index);
              },
            );
          }).toList(),
          Divider(height: 1, color: colors.divider),
          _AddButton(
            colors: colors,
            label: "Add Category",
            onTap: _addCategory,
          ),
        ],
      ),
    );
  }

  Future<void> _addCategory() async {
    final result = await _showCategoryDialog();
    if (result != null) {
      setState(() {
        userCategories.add(result);
      });
      await CategoryStorage.save(userCategories);
    }
  }

  Future<void> _editCategory(int index) async {
    final result = await _showCategoryDialog(initial: userCategories[index]);
    if (result != null) {
      setState(() {
        userCategories[index] = result;
      });
      await CategoryStorage.save(userCategories);
    }
  }

  Future<void> _deleteCategory(int index) async {
    HapticFeedback.mediumImpact();
    setState(() {
      userCategories.removeAt(index);
    });
    await CategoryStorage.save(userCategories);
  }

  Future<CategoryData?> _showCategoryDialog({CategoryData? initial}) {
    final categoryController = TextEditingController(text: initial?.category);
    final subcategoryController =
    TextEditingController(text: initial?.subcategory);
    final colors =
    SettingsColors(isDark: Theme.of(context).brightness == Brightness.dark);

    return showModalBottomSheet<CategoryData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Title
              Text(
                initial == null ? "Add Category" : "Edit Category",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.primaryText,
                ),
              ),
              SizedBox(height: 24.h),

              // Category Field
              _MinimalTextField(
                controller: categoryController,
                label: "Category",
                hint: "e.g. Food & Dining",
                icon: LucideIcons.folder,
                colors: colors,
              ),
              SizedBox(height: 16.h),

              // Subcategory Field
              _MinimalTextField(
                controller: subcategoryController,
                label: "Subcategory",
                hint: "e.g. Restaurants",
                icon: LucideIcons.tag,
                colors: colors,
              ),
              SizedBox(height: 32.h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: _MinimalButton(
                      label: "Cancel",
                      onTap: () => Navigator.pop(context),
                      colors: colors,
                      isOutlined: true,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _MinimalButton(
                      label: "Save",
                      onTap: () {
                        final category = categoryController.text.trim();
                        final subcategory = subcategoryController.text.trim();
                        if (category.isNotEmpty && subcategory.isNotEmpty) {
                          Navigator.pop(
                              context,
                              CategoryData(
                                category: category,
                                subcategory: subcategory,
                              ));
                        }
                      },
                      colors: colors,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DEBTS SECTION
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildDebtsSection(SettingsColors colors) {
    final allDebts = <Map<String, dynamic>>[];
    for (final acc in debtAccounts) {
      final debts = (acc['debts'] is List) ? acc['debts'] as List : [];
      for (final debt in debts) {
        allDebts.add({
          ...debt,
          'accountName': acc['name'],
          'currency': acc['currency'],
        });
      }
    }

    if (allDebts.isEmpty) {
      return _SettingsCard(
        colors: colors,
        child: _EmptyState(
          colors: colors,
          icon: LucideIcons.circleCheck200,
          title: "No active debts",
          subtitle: "You're debt-free! Keep it up.",
          buttonLabel: "Add Debt",
          onButtonPressed: _addDebt,
        ),
      );
    }

    return _SettingsCard(
      colors: colors,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ...allDebts.map((debt) => _DebtTile(
            colors: colors,
            title: debt['title'] ?? 'Unnamed',
            accountName: debt['accountName'] ?? 'Unknown',
            amount: debt['amount']?.toDouble() ?? 0,
            currency: debt['currency'] ?? 'TRY',
          )),
          Divider(height: 1, color: colors.divider),
          _AddButton(
            colors: colors,
            label: "Add Debt",
            onTap: _addDebt,
          ),
        ],
      ),
    );
  }

  Future<void> _addDebt() async {
    String? title;
    double? amount;
    final colors =
    SettingsColors(isDark: Theme.of(context).brightness == Brightness.dark);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        final titleController = TextEditingController();
        final amountController = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  "Add Debt",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: colors.primaryText,
                  ),
                ),
                SizedBox(height: 24.h),
                _MinimalTextField(
                  controller: titleController,
                  label: "Title",
                  hint: "e.g. Car Loan",
                  icon: LucideIcons.fileText,
                  colors: colors,
                ),
                SizedBox(height: 16.h),
                _MinimalTextField(
                  controller: amountController,
                  label: "Amount",
                  hint: "0.00",
                  icon: LucideIcons.dollarSign,
                  colors: colors,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: _MinimalButton(
                        label: "Cancel",
                        onTap: () => Navigator.pop(context),
                        colors: colors,
                        isOutlined: true,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _MinimalButton(
                        label: "Save",
                        onTap: () {
                          title = titleController.text.trim();
                          amount =
                              double.tryParse(amountController.text.trim());
                          if (title!.isNotEmpty && amount != null) {
                            Navigator.pop(context);
                          }
                        },
                        colors: colors,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );

    if (title != null && amount != null) {
      if (debtAccounts.isNotEmpty) {
        final acc = debtAccounts.first;
        acc['debts'] ??= [];
        (acc['debts'] as List).add({'title': title, 'amount': amount});

        for (final bank in bankAccounts) {
          final accounts = (bank['accounts'] as List?) ?? [];
          for (var i = 0; i < accounts.length; i++) {
            if (accounts[i]['accountId'] == acc['accountId']) {
              accounts[i] = acc;
              break;
            }
          }
        }

        await _saveToPrefs();
        setState(() {});
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // APP INFO SECTION
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildAppInfoSection(SettingsColors colors) {
    return _SettingsCard(
      colors: colors,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _InfoTile(
            colors: colors,
            icon: LucideIcons.box,
            title: "Version",
            value: "1.0.0",
          ),
          Divider(height: 1, indent: 72.w, color: colors.divider),
          _InfoTile(
            colors: colors,
            icon: LucideIcons.shield,
            title: "Privacy Policy",
            onTap: () {},
          ),
          Divider(height: 1, indent: 72.w, color: colors.divider),
          _InfoTile(
            colors: colors,
            icon: LucideIcons.fileText,
            title: "Terms of Service",
            onTap: () {},
          ),
          Divider(height: 1, indent: 72.w, color: colors.divider),
          _InfoTile(
            colors: colors,
            icon: LucideIcons.handHelping,
            title: "Help & Support",
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// REUSABLE COMPONENTS
// ============================================================================

class _SettingsCard extends StatelessWidget {
  final SettingsColors colors;
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const _SettingsCard({
    required this.colors,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: padding ?? EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: colors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _MinimalSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final SettingsColors colors;

  const _MinimalSwitch({
    required this.value,
    required this.onChanged,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52.w,
        height: 28.h,
        padding: EdgeInsets.all(2.r),
        decoration: BoxDecoration(
          color: value ? colors.primary : colors.iconBg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: value ? colors.primary : colors.border,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24.r,
            height: 24.r,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MinimalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final SettingsColors colors;
  final TextInputType? keyboardType;

  const _MinimalTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.colors,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: colors.secondaryText,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: colors.iconBg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colors.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 15.sp,
              color: colors.primaryText,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: colors.tertiaryText,
              ),
              prefixIcon: Icon(
                icon,
                size: 20.r,
                color: colors.secondaryText,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MinimalButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final SettingsColors colors;
  final bool isOutlined;

  const _MinimalButton({
    required this.label,
    required this.onTap,
    required this.colors,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isOutlined ? Colors.transparent : colors.primary,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: isOutlined ? Border.all(color: colors.border) : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: isOutlined ? colors.primaryText : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final SettingsColors colors;
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onButtonPressed;

  const _EmptyState({
    required this.colors,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8.h),
        Container(
          width: 64.r,
          height: 64.r,
          decoration: BoxDecoration(
            color: colors.iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 28.r,
            color: colors.tertiaryText,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: colors.primaryText,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13.sp,
            color: colors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),
        _MinimalButton(
          label: buttonLabel,
          onTap: onButtonPressed,
          colors: colors,
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  final SettingsColors colors;
  final String label;
  final VoidCallback onTap;

  const _AddButton({
    required this.colors,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: colors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  LucideIcons.plus,
                  size: 20.r,
                  color: colors.success,
                ),
              ),
              SizedBox(width: 14.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.success,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatefulWidget {
  final SettingsColors colors;
  final String category;
  final List<CategoryData> subcategories;
  final Function(CategoryData) onEdit;
  final Function(CategoryData) onDelete;

  const _CategoryTile({
    required this.colors,
    required this.category,
    required this.subcategories,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: widget.colors.iconBgAccent,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      LucideIcons.folder,
                      size: 20.r,
                      color: widget.colors.primary,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: widget.colors.primaryText,
                          ),
                        ),
                        Text(
                          "${widget.subcategories.length} subcategories",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: widget.colors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      LucideIcons.chevronDown,
                      size: 20.r,
                      color: widget.colors.tertiaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children:
            widget.subcategories.map((item) => _SubcategoryTile(
              colors: widget.colors,
              item: item,
              onEdit: () => widget.onEdit(item),
              onDelete: () => widget.onDelete(item),
            )).toList(),
          ),
          crossFadeState:
          _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        Divider(height: 1, color: widget.colors.divider),
      ],
    );
  }
}

class _SubcategoryTile extends StatelessWidget {
  final SettingsColors colors;
  final CategoryData item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubcategoryTile({
    required this.colors,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(56.w, 0, 16.w, 8.h),
      decoration: BoxDecoration(
        color: colors.iconBg,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.tag,
                    size: 16.r,
                    color: colors.secondaryText,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    item.subcategory,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: colors.primaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(
              LucideIcons.pencil,
              size: 16.r,
              color: colors.primary,
            ),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              LucideIcons.trash2,
              size: 16.r,
              color: colors.error,
            ),
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(width: 4.w),
        ],
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  final SettingsColors colors;
  final String title;
  final String accountName;
  final double amount;
  final String currency;

  const _DebtTile({
    required this.colors,
    required this.title,
    required this.accountName,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: colors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              LucideIcons.circleAlert100,
              size: 20.r,
              color: colors.error,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.primaryText,
                  ),
                ),
                Text(
                  accountName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${amount.toStringAsFixed(2)} $currency",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: colors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final SettingsColors colors;
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.colors,
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: colors.iconBg,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  size: 20.r,
                  color: colors.secondaryText,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.primaryText,
                  ),
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colors.tertiaryText,
                  ),
                )
              else if (onTap != null)
                Icon(
                  LucideIcons.chevronRight,
                  size: 20.r,
                  color: colors.tertiaryText,
                ),
            ],
          ),
        ),
      ),
    );
  }
}