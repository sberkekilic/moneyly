import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryData {
  final String category;
  final String subcategory;

  CategoryData({
    required this.category,
    required this.subcategory
  });
}

class CategoryStorage {
  static const _key = 'userCategories';

  static Future<void> save(List<CategoryData> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((e) => jsonEncode({
      'category': e.category,
      'subcategory': e.subcategory
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
        subcategory: map['subcategory']
      );
    }).toList();
  }
}