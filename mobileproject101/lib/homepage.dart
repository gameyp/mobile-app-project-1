import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> _items = [];

  void _addNewItem(String topic, String? description) {
    if (topic.isNotEmpty) {
      setState(() {
        _items.add({
          'topic': topic,
          'description': description ?? '',
        });
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO app [V1]'),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(_items[index]['topic']!),
            onDismissed: (direction) {
              _removeItem(index);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
            child: ListTile(
              title: Text(_items[index]['topic'] ?? ''),
              subtitle: _items[index]['description']?.isNotEmpty == true
                  ? Text(_items[index]['description']!)
                  : null,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<String, String?>? result = await showDialog(
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
            _addNewItem(result['topic']!, result['description']);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
