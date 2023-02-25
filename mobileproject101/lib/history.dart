import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'todoItem.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // declare the necessary variables
  late final TextEditingController _searchController;
  late final List<TodoItem> _filteredItems;
  late bool _showDeletedIcon = false;

  @override
  void initState() {
    super.initState();
    // initialize the necessary variables in initState
    _searchController = TextEditingController();
    _filteredItems = [];
  }

  @override
  void dispose() {
    // dispose of the _searchController in dispose method
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoModel = context.watch<TodoModel>();
    final completedItems = todoModel.completedItems;

    // filter the completedItems based on the search query
    _filterItems(completedItems);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[800],
          title: const Text('TODO App'),
        ),
        body: Container(
          color: Colors.lightGreen[50], // set the background color to light green
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by topic',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // refilter the items when the search button is pressed
                        _filterItems(completedItems);
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = _filteredItems[index];
                    return ListTile(
                      title: Text(item.topic),
                      subtitle: item.description != null &&
                          item.description!.isNotEmpty
                          ? Text(item.description!)
                          : null,
                      trailing: _getTrailingIcon(item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // method to filter the completed items based on the search query
  void _filterItems(List<TodoItem> completedItems) {
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      _filteredItems.clear();
      _filteredItems.addAll(completedItems.where((item) =>
      item.topic.toLowerCase().contains(searchQuery) ||
          (item.description != null &&
              item.description!.toLowerCase().contains(searchQuery))));
      _showDeletedIcon = true; // Set _showDeletedIcon to true when there is a search query
    } else {
      _filteredItems.clear();
      _filteredItems.addAll(completedItems);
      _showDeletedIcon = false; // Set _showDeletedIcon to false when there is no search query
    }
  }

  // method to return the appropriate trailing icon based on the item's status and whether there is a search query
  Widget? _getTrailingIcon(TodoItem item) {
    // Delete items not show due to some typo need to check
    if (_showDeletedIcon && item.isDeleted) {
      return const Icon(Icons.delete, color: Colors.red);
    } else if (item.isDone) {
      return const Icon(Icons.check, color: Colors.green);
    } else {
      return null;
    }
  }
}