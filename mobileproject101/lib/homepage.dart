import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'todoItem.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _comparePriorities(TodoItem a, TodoItem b) {
    final priorityValue = {
      Colors.green: 1,
      Colors.yellow: 2,
      Colors.red: 3,
    };

    if (a.isDone != b.isDone) {
      return a.isDone ? 1 : -1;
    } else if (priorityValue[a.priority] != null && priorityValue[b.priority] != null) {
      return priorityValue[b.priority]! - priorityValue[a.priority]!;
    } else if (a.completedDate != null && b.completedDate != null) {
      int dateComparison = b.completedDate!.compareTo(a.completedDate!);
      if (dateComparison != 0) {
        return dateComparison;
      } else {
        return a.topic.compareTo(b.topic);
      }
    } else {
      return a.topic.compareTo(b.topic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // AppBar
        appBar: AppBar(
          backgroundColor: Colors.green[800], // Updated color
          title: const Text('TODO List'),
        ),
        // Body
        body: Container(
          color: Colors.lightGreen[50],
          // set the background color to light green
          child: Consumer<TodoModel>(
            builder: (context, todoModel, child) {
              // sort the items by priority
              final items = todoModel.items.toList()
                ..sort((a, b) => _comparePriorities(a, b));
              // ListView with Dismissible
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = items[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey, width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
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
                                Text('Edit',
                                    style: TextStyle(color: Colors.white)),
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
                        child: Row(
                          children: [
                            Container(
                              height: 24,
                              width: 24,
                              margin: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: item.priority,
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                title: Text(item.topic,
                                  style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),),
                                subtitle: item.description != null &&
                                        item.description!.isNotEmpty
                                    ? Text(item.description!)
                                    : null,
                                value: item.isDone,
                                onChanged: (newValue) {
                                  setState(() {
                                    todoModel.toggleDone(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        // FloatingActionButton
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            TodoModel todoModel = context.read<TodoModel>();
            // Show add item dialog
            Map<String, dynamic>? result =
                await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (BuildContext context) {
                final topicController = TextEditingController();
                final descriptionController = TextEditingController();
                Color priority = Colors.green;
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: const Text('Add TODO item'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: topicController,
                            decoration: const InputDecoration(
                              hintText: 'TODO',
                            ),
                          ),
                          TextField(
                            controller: descriptionController,
                            decoration: const InputDecoration(
                              hintText: 'Description (Optional)',
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Priority: '),
                              ChoiceChip(
                                label: const Text('Low'),
                                selectedColor: Colors.green,
                                selected: priority == Colors.green,
                                onSelected: (selected) {
                                  setState(() {
                                    priority = Colors.green;
                                  });
                                },
                              ),
                              ChoiceChip(
                                label: const Text('Medium'),
                                selectedColor: Colors.yellow,
                                selected: priority == Colors.yellow,
                                onSelected: (selected) {
                                  setState(() {
                                    priority = Colors.yellow;
                                  });
                                },
                              ),
                              ChoiceChip(
                                label: const Text('High'),
                                selectedColor: Colors.red,
                                selected: priority == Colors.red,
                                onSelected: (selected) {
                                  setState(() {
                                    priority = Colors.red;
                                  });
                                },
                              ),
                            ],
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
                            String? description =
                                descriptionController.text.trim();
                            if (topic.isNotEmpty) {
                              Navigator.of(context).pop({
                                'topic': topic,
                                'description': description,
                                'priority': priority,
                              });
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            );

            if (result != null) {
              todoModel.addItem(
                  result['topic']!, result['description'], result['priority']);
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
    final descriptionController =
        TextEditingController(text: item.description ?? '');
    Color priority = item.priority;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text('Low'),
                            selectedColor: Colors.green,
                            selected: priority == Colors.green,
                            onSelected: (bool selected) {
                              setState(() {
                                priority = selected ? Colors.green : Colors.red;
                              });
                            },
                          ),
                          const SizedBox(width: 10.0),
                          ChoiceChip(
                            label: const Text('Medium'),
                            selectedColor: Colors.yellow,
                            selected: priority == Colors.yellow,
                            onSelected: (bool selected) {
                              setState(() {
                                priority = selected ? Colors.yellow : Colors.red;
                              });
                            },
                          ),
                          const SizedBox(width: 10.0),
                          ChoiceChip(
                            label: const Text('High'),
                            selectedColor: Colors.red,
                            selected: priority == Colors.red,
                            onSelected: (bool selected) {
                              setState(() {
                                priority = selected ? Colors.red : Colors.green;
                              });
                            },
                          ),
                        ],
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
                        todoModel.updateItem(todoModel.items.indexOf(item),
                            newTopic, newDescription,
                            priority: priority);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              );
            },
          );
        });
  }
}
