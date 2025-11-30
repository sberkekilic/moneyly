import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryData {
  final String category;
  final String subcategory;

  CategoryData({required this.category, required this.subcategory});
}

class CategoryStorage {
  static const _key = 'userCategories';

  static Future<void> save(List<CategoryData> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((e) => jsonEncode({
      'category': e.category,
      'subcategory': e.subcategory,
    })).toList();

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

  Future<void> _saveSelectedAccount(int accountId) async {
    final prefs = await SharedPreferences.getInstance();

    final bank = bankAccounts.firstWhere(
          (b) => (b['accounts'] as List).any((acc) => acc['accountId'] == accountId),
    );

    final acc = (bank['accounts'] as List)
        .firstWhere((acc) => acc['accountId'] == accountId);

    await prefs.setString('selectedAccount', jsonEncode({
      'accountId': acc['accountId'],
      'bankId': bank['bankId'],
    }));
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
        final List<Map<String, dynamic>> decodedData =
        List<Map<String, dynamic>>.from(jsonDecode(accountDataListJson));
        bankAccounts = decodedData.toSet().toList();

        // Filter for credit accounts with remaining debt
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
    setState(() {
      userCategories.removeAt(index);
    });
    await CategoryStorage.save(userCategories);
  }

  Future<CategoryData?> _showCategoryDialog({CategoryData? initial}) {
    final categoryController = TextEditingController(text: initial?.category);
    final subcategoryController = TextEditingController(text: initial?.subcategory);

    return showDialog<CategoryData>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initial == null ? 'Add Category' : 'Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subcategoryController,
              decoration: const InputDecoration(
                labelText: 'Subcategory',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final category = categoryController.text.trim();
              final subcategory = subcategoryController.text.trim();
              if (category.isNotEmpty && subcategory.isNotEmpty) {
                Navigator.pop(context, CategoryData(category: category, subcategory: subcategory));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Map<String, List<CategoryData>> get groupedCategories {
    final map = <String, List<CategoryData>>{};
    for (var item in userCategories) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
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

  Future<void> _addDebt() async {
    String? title;
    double? amount;

    await showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController();
        final amountController = TextEditingController();

        return AlertDialog(
          title: const Text("Add Debt"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                title = titleController.text.trim();
                amount = double.tryParse(amountController.text.trim());
                if (title!.isNotEmpty && amount != null) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.grey[900]!.withOpacity(0.3) : Colors.white.withOpacity(0.3);
    final borderColor = isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Switch
            GlassmorphismContainer(
              blur: 10,
              borderRadius: 16,
              borderColor: borderColor,
              color: bgColor,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Dark Theme",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: isDarkMode,
                    onChanged: (_) => widget.onThemeToggle(),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Select Account",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 12),

            bankAccounts.isEmpty
                ? GlassmorphismContainer(
              blur: 10,
              borderRadius: 16,
              borderColor: borderColor,
              color: bgColor,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "No accounts available",
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // hesap ekleme sayfasına yönlendirme
                      Navigator.pushNamed(context, "/accounts-add");
                    },
                    child: Text("Add"),
                  ),
                ],
              ),
            )
                : GlassmorphismContainer(
              blur: 10,
              borderRadius: 16,
              borderColor: borderColor,
              color: bgColor,
              padding: const EdgeInsets.all(12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: selectedAccountId,
                  hint: Text("Select Account"),
                  items: bankAccounts.expand<DropdownMenuItem<int>>((bank) {
                    return (bank['accounts'] as List?)?.map((account) {
                      return DropdownMenuItem<int>(
                        value: account['accountId'],
                        child: Text("${bank['bankName']} - ${account['name']}"),
                      );
                    }) ?? [];
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _saveSelectedAccount(value);
                      setState(() {
                        selectedAccountId = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Categories Section
            Text(
              "Categories",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            GlassmorphismContainer(
              blur: 10,
              borderRadius: 16,
              borderColor: borderColor,
              color: bgColor,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  if (userCategories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "No categories added yet",
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    )
                  else
                    ...groupedCategories.entries.map((entry) {
                      final category = entry.key;
                      final subcategories = entry.value;

                      return ExpansionTile(
                        leading: Icon(
                          Icons.category,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          category,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        children: subcategories.asMap().entries.map((e) {
                          final index = userCategories.indexOf(e.value);
                          final item = e.value;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: GlassmorphismContainer(
                              blur: 10,
                              borderRadius: 12,
                              borderColor: borderColor,
                              color: bgColor,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: ListTile(
                                title: Text(item.subcategory),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Theme.of(context).colorScheme.primary,
                                        size: 20,
                                      ),
                                      onPressed: () => _editCategory(index),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Theme.of(context).colorScheme.error,
                                        size: 20,
                                      ),
                                      onPressed: () => _deleteCategory(index),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),

                  Divider(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      "Add Category",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: _addCategory,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Debts Section
            Text(
              "Debts",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            GlassmorphismContainer(
              blur: 10,
              borderRadius: 16,
              borderColor: borderColor,
              color: bgColor,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  if (debtAccounts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "No active debts",
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    )
                  else
                    ...debtAccounts.expand((acc) {
                      final debts = (acc['debts'] is List) ? acc['debts'] as List : [];
                      return debts.map((debt) {
                        final amount = debt['amount'] ?? 0;
                        final title = debt['title'] ?? '';
                        final currency = acc['currency'] ?? '';

                        return ListTile(
                          leading: Icon(
                            Icons.credit_card,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(
                            acc['name'] ?? 'Unnamed Account',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          subtitle: Text(
                            "$title • ${amount.toStringAsFixed(2)} $currency",
                            style: TextStyle(color: Theme.of(context).hintColor),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Theme.of(context).hintColor,
                          ),
                        );
                      });
                    }).toList(),

                  Divider(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      "Add Debt",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: _addDebt,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // App Info Section
            Text(
              "App Info",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            GlassmorphismContainer(
              blur: 10,
              borderRadius: 16,
              borderColor: borderColor,
              color: bgColor,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.info,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      "Version",
                      style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                    ),
                    trailing: Text(
                      "1.0.0",
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      "Privacy Policy",
                      style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  ListTile(
                    leading: Icon(
                      Icons.description,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      "Terms of Service",
                      style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final Color? color; // opsiyonel arkaplan rengi

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 10,
    required this.borderColor,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}