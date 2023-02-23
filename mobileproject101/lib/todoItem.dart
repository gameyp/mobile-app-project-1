// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoItem {
  final String topic;
  final String? description;

  TodoItem({required this.topic, this.description});

  Map<String, dynamic> toMap() {
    return {
      'topic': topic,
      'description': description,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      topic: map['topic'],
      description: map['description'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TodoItem.fromJson(String source) =>
      TodoItem.fromMap(json.decode(source));
}

class TodoModel extends ChangeNotifier {
  final _items = <TodoItem>[];
  final _itemsNotifier = ValueNotifier<List<TodoItem>>([]);

  List<TodoItem> get items => _itemsNotifier.value;

  TodoModel() {
    _loadItems();
  }

  void _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('items');
    if (json != null) {
      _items.addAll(List<TodoItem>.from(
        jsonDecode(json).map(
              (item) => TodoItem.fromMap(item),
        ),
      ));
      _itemsNotifier.value = _items;
    }
  }

  void _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(items.map((e) => e.toMap()).toList());
    prefs.setString('items', json);
  }

  void addItem(String topic, String? description) {
    final newItem = TodoItem(topic: topic, description: description);
    _items.add(newItem);
    _itemsNotifier.value = _items;
    _saveItems();
    notifyListeners(); // add this line to notify the listeners
  }

  void removeItem(int index) {
    _items.removeAt(index);
    _itemsNotifier.value = _items;
    _saveItems();
    notifyListeners();
  }

  void updateItem(int index, String topic, String? description) {
    final updatedItem = TodoItem(topic: topic, description: description);
    _items[index] = updatedItem;
    _itemsNotifier.value = _items;
    _saveItems();
    notifyListeners();
  }
}