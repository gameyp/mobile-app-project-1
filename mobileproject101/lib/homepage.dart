import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'todoItem.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // AppBar
        appBar: AppBar(
          title: const Text('TODO App'),
        ),
        // Body
        body: Consumer<TodoModel>(
          builder: (context, todoModel, child) {
            // ListView with Dismissible
            return ListView.builder(
              itemCount: todoModel.items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = todoModel.items[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey, width: 2.0),
                  ),
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                  // Dismissible widget
                  child: Dismissible(
                    key: UniqueKey(),
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        // Remove item from the list when swiped to the left
                        todoModel.removeItem(index);
                      } else {
                        // Show edit dialog when swiped to the right
                        _showEditDialog(context, todoModel, item);
                      }
                    },
                    background: Container(
                      color: Colors.green,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Icon(Icons.edit, color: Colors.white),
                            Text('Edit', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(Icons.delete, color: Colors.white),
                            Text('Delete',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    // CheckboxListTile widget
                    child: CheckboxListTile(
                      title: Text(item.topic),
                      subtitle: item.description != null &&
                              item.description!.isNotEmpty
                          ? Text(item.description!)
                          : null,
                      value: item.isDone,
                      onChanged: (newValue) {
                        todoModel.toggleDone(index);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
        // FloatingActionButton
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            TodoModel todoModel = context.read<TodoModel>();
            // Show add item dialog
            Map<String, String?>? result = await showDialog<Map<String, String?>>(
              context: context,
              builder: (BuildContext context) {
                final topicController = TextEditingController();
                final descriptionController = TextEditingController();
                return AlertDialog(
                  title: const Text('Add an item'),
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
                      child: const Text('Add'),
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
          child: const Icon(Icons.add),
        ),
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
