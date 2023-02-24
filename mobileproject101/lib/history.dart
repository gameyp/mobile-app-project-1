import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'todoItem.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late List<TodoItem> _completedItems;
  late List<TodoItem> _searchResults;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final todoModel = context.read<TodoModel>();
    _completedItems = todoModel.completedItems;
    _searchResults = List.of(_completedItems);
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchResults = _completedItems.where((item) =>
            item.topic.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO app [V1]'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for completed items',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_searchResults[index].topic),
                  subtitle: _searchResults[index].description != null &&
                      _searchResults[index].description!.isNotEmpty
                      ? Text(_searchResults[index].description!)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}