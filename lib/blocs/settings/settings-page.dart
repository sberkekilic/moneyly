import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadCategories();
    await _loadAccountsFromPrefs();
    setState(() {}); // Refresh UI after loading
  }

  Future<void> _loadCategories() async {
    userCategories = await CategoryStorage.load();
  }

  Future<void> _loadAccountsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final accountDataListJson = prefs.getString("accountDataList");

    if (accountDataListJson != null) {
      try {
        final List<Map<String, dynamic>> decodedData =
        List<Map<String, dynamic>>.from(jsonDecode(accountDataListJson));
        bankAccounts = decodedData.toSet().toList();

        // Sadece borçlu (credit) ve kalan borcu olan hesapları filtrele
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

  // Kategori ekle/düzenle/sil metodları aynı kalabilir

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
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
            TextField(controller: subcategoryController, decoration: const InputDecoration(labelText: 'Subcategory')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final category = categoryController.text.trim();
              final subcategory = subcategoryController.text.trim();
              if (category.isNotEmpty && subcategory.isNotEmpty) {
                Navigator.pop(context, CategoryData(category: category, subcategory: subcategory));
              }
            },
            child: const Text('Save'),
          )
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
      print('[DEBUG] Saved accountDataList: $jsonString');
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
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(
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
      // Örnek olarak ilk borç hesabına ekliyoruz (gerçekte hangi hesaba ekleneceği UI'dan alınmalı)
      if (debtAccounts.isNotEmpty) {
        final acc = debtAccounts.first;

        // Eğer debts listesi yoksa oluştur
        acc['debts'] ??= [];
        (acc['debts'] as List).add({'title': title, 'amount': amount});

        // bankAccounts içinde bu hesabı bulup güncelle
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text("Dark Theme"),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (_) => widget.onThemeToggle(),
          ),
          const SizedBox(height: 24),

          // CATEGORIES HEADER + ADD BUTTON
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addCategory,
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...groupedCategories.entries.map((entry) {
            final category = entry.key;
            final subcategories = entry.value;
            return ExpansionTile(
              title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
              children: subcategories.asMap().entries.map((e) {
                final index = userCategories.indexOf(e.value);
                final item = e.value;
                return ListTile(
                  title: Text(item.subcategory),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _editCategory(index)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteCategory(index)),
                    ],
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),

          // DEBTS HEADER + ADD BUTTON
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Debts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addDebt,
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (debtAccounts.isEmpty)
            const Text("No active debts.")
          else
            ...debtAccounts.expand((acc) {
              final debts = (acc['debts'] is List) ? acc['debts'] as List : [];
              return debts.map((debt) {
                final amount = debt['amount'] ?? 0;
                final title = debt['title'] ?? '';
                final dueDate = debt['dueDate'] ?? '';
                final currency = acc['currency'] ?? '';
                return ListTile(
                  title: Text(acc['name'] ?? 'Unnamed Account'),
                  subtitle: Text("$title • ${amount.toStringAsFixed(2)} $currency"),
                  leading: const Icon(Icons.credit_card),
                );
              });
            }).toList(),
        ],
      ),
    );
  }
}