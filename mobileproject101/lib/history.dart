import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'todoItem.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todoModel = context.watch<TodoModel>();
    final completedItems = todoModel.items.where((item) => item.isDone).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO app [V1]'),
      ),
      body: ListView.builder(
        itemCount: completedItems.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(completedItems[index].topic),
            subtitle: completedItems[index].description != null &&
                completedItems[index].description!.isNotEmpty
                ? Text(completedItems[index].description!)
                : null,
          );
        },
      ),
    );
  }
}
