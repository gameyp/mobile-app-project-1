import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'todoItem.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO App'),
      ),
      body: Consumer<TodoModel>(
        builder: (context, todoModel, child) {
          return ListView.builder(
            itemCount: todoModel.items.length,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key: Key(todoModel.items[index].topic),
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    // Delete item
                    todoModel.removeItem(index);
                  } else if (direction == DismissDirection.startToEnd) {
                    // Edit item
                    _editItem(context, todoModel, index);
                  }
                },
                background: Container(
                  color: Colors.blue,
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                ),
                child: ListTile(
                  title: Text(todoModel.items[index].topic),
                  subtitle: todoModel.items[index].description != null &&
                      todoModel.items[index].description!.isNotEmpty
                      ? Text(todoModel.items[index].description!)
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          TodoModel todoModel = context.read<TodoModel>();
          Map<String, String?>? result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              final topicController = TextEditingController();
              final descriptionController = TextEditingController();
              return AlertDialog(
                title: Text('Add an item'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: topicController,
                      decoration: InputDecoration(
                        hintText: 'Enter item topic',
                      ),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Enter item description',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Add'),
                    onPressed: () {
                      Navigator.of(context).pop({
                        'topic': topicController.text.trim(),
                        'description': descriptionController.text.trim(),
                      });
                    },
                  ),
                ],
              );
            },
          );

          if (result != null) {
            todoModel.addItem(result['topic']!, result['description']);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _editItem(BuildContext context, TodoModel todoModel, int index) async {
    Map<String, String?>? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        final topicController =
        TextEditingController(text: todoModel.items[index].topic);
        final descriptionController =
        TextEditingController(text: todoModel.items[index].description);
        return AlertDialog(
          title: Text('Edit item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: topicController,
                decoration: InputDecoration(
                  hintText: 'Enter item topic',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Enter item description',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                todoModel.updateItem(
                  index,
                  topicController.text.trim(),
                  descriptionController.text.trim(),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (result != null) {
      todoModel.updateItem(
        index,
        result['topic']!,
        result['description'] ?? '',
      );
    }
  }
}
