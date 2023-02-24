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
              final item = todoModel.items[index];
              return Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    todoModel.removeItem(index);
                  } else {
                    _showEditDialog(context, todoModel, item);
                  }
                },
                background: Container(
                  color: Colors.green,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.edit, color: Colors.white),
                        Text('Edit', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        Text('Delete', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                child: CheckboxListTile(
                  title: Text(item.topic),
                  subtitle:
                      item.description != null && item.description!.isNotEmpty
                          ? Text(item.description!)
                          : null,
                  value: item.isDone,
                  onChanged: (newValue) {
                    todoModel.toggleDone(index);
                  },
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
                      String topic = topicController.text.trim();
                      String? description = descriptionController.text.trim();
                      if (topic.isNotEmpty) {
                        Navigator.of(context).pop({
                          'topic': topic,
                          'description': description,
                        });
                      }
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

  void _showEditDialog(
      BuildContext context, TodoModel todoModel, TodoItem item) async {
    final topicController = TextEditingController(text: item.topic);
    final descriptionController = TextEditingController(text: item.description);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: topicController,
                decoration: const InputDecoration(
                  hintText: 'Enter item topic',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Enter item description',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                final newTopic = topicController.text.trim();
                final newDescription = descriptionController.text.trim();
                if (newTopic.isNotEmpty) {
                  todoModel.updateItem(
                      todoModel.items.indexOf(item), newTopic, newDescription);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
