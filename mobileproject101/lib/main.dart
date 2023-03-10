import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'history.dart';
import 'homepage.dart';
import 'todoItem.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<TodoModel>(
          create: (_) => TodoModel(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(), // First tab is the home page
    const HistoryPage(), // Second tab is the history page
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO app [V1]',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'ShakyHandSomeComic', // Set the font family for the app
        textTheme: const TextTheme(
          bodyText1: TextStyle(fontSize: 20.0),
          // Increase the font size for body text
          bodyText2: TextStyle(fontSize: 20.0),
          // Increase the font size for body text
          headline6:
              TextStyle(fontSize: 30.0), // Increase the font size for headlines
        ),
      ),
      home: SafeArea(
        child: Scaffold(
          body: _pages[_currentIndex],
          // Show the current page based on the current index
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'History',
              ),
            ],
            onTap: (index) {
              setState(() {
                _currentIndex =
                    index; // Set the current index to the selected tab
              });
            },
          ),
        ),
      ),
    );
  }
}
