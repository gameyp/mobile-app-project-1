// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoModel extends ChangeNotifier {
  final _items = <Map<String, String>>[];
  final _itemsNotifier = ValueNotifier<List<Map<String, String>>>([]);

  List<Map<String, String>> get items => _itemsNotifier.value;

  TodoModel() {
    _loadItems();
  }

  void _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('items');
    if (json != null) {
      _items.addAll(List<Map<String, String>>.from(
        jsonDecode(json).map(
              (item) => Map<String, String>.from(item),
        ),
      ));
      _itemsNotifier.value = _items;
    }
  }

  void _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_items);
    prefs.setString('items', json);
  }

  void addItem(Map<String, String> item) {
    _items.add(item);
    _itemsNotifier.value = _items;
    _saveItems();
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    _itemsNotifier.value = _items;
    _saveItems();
    notifyListeners();
  }
}