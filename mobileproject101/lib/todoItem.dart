// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TodoItemStatus {
  Completed,
  Deleted,
}

class TodoItem {
  late final int id;
  late final String topic;
  late final String? description;
  late final TodoItemStatus status;
  bool isDone;
  bool isDeleted; // new property to mark an item as deleted
  Color priority;
  DateTime? completedDate;

  TodoItem({
    required this.id,
    required this.topic,
    this.description,
    this.isDone = false,
    this.isDeleted = false,
    this.priority = Colors.green,
    this.completedDate,
    this.status = TodoItemStatus.Completed, // default to Completed
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topic': topic,
      'description': description,
      'isDone': isDone,
      'isDeleted': isDeleted,
      'priority': priority.value,
      'completedDate': completedDate?.millisecondsSinceEpoch,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'],
      topic: map['topic'],
      description: map['description'],
      isDone: map['isDone'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      priority: Color(map['priority']),
      completedDate: map['completedDate'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['completedDate']),
    );
  }

  String toJson() => json.encode(toMap());

  factory TodoItem.fromJson(String source) =>
      TodoItem.fromMap(json.decode(source));
}

class TodoModel extends ChangeNotifier {
  final _items = <TodoItem>[];
  final _completedItems = <TodoItem>[];
  final _itemsNotifier = ValueNotifier<List<TodoItem>>([]);

  List<TodoItem> get items => _itemsNotifier.value;

  List<TodoItem> get completedItems => _completedItems;

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

  void addItem(String topic, String? description, Color priority) {
    final newItem = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch,
      topic: topic,
      description: description,
      priority: priority,
    );
    _items.add(newItem);
    _itemsNotifier.value = _items;
    _saveItems();
    notifyListeners();
  }

  void removeItem(int index) {
    final removedItem = _items.removeAt(index);
    if (index == 0) {
      // mark top item as done and move it to completedItems list
      final doneItem = _items.removeAt(0);
      doneItem.isDone = true;
      doneItem.completedDate = DateTime.now();
      doneItem.status = TodoItemStatus.Completed;
      _completedItems.add(doneItem);
    } else {
      // remove item at the specified index and add it to completedItems list
      final removedItem = _items.removeAt(index);
      removedItem.isDeleted = true;
      removedItem.completedDate = DateTime.now();
      removedItem.status = TodoItemStatus.Deleted;
      _completedItems.add(removedItem);
    }
    _itemsNotifier.value = _items;
    _saveItems();
    notifyListeners();
  }

  void updateItem(int id, String topic, String? description,
      {Color? priority}) {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    if (itemIndex >= 0) {
      final updatedItem = TodoItem(
        id: id,
        topic: topic,
        description: description,
        isDone: false,
        priority: priority ?? Colors.green,
        completedDate: _items[itemIndex].completedDate,
      );
      _items[itemIndex] = updatedItem;
      _itemsNotifier.value = _items;
      _saveItems();
      notifyListeners();
    }
  }

  void toggleDone(int index) {
    _items[index].isDone = !_items[index].isDone;
    if (_items[index].isDone) {
      final completedItem = _items[index];
      completedItem.completedDate =
          DateTime.now(); // set completedDate to current date and time
      _completedItems.add(completedItem);
      _items.removeAt(index);
    }
    _itemsNotifier.value = _items;
    _saveItems();
    notifyListeners();
  }
}
