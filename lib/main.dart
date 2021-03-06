import 'package:flutter/material.dart';
import 'pages/tasks_list.dart';
import 'pages/completed_tasks.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    )
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // current page to display when the app launches
  int _currentIndex = 0;
  // list of all the pages
  List _pages = [];
  Widget _currentPage;
  
  @override
  void initState() {
    super.initState();
    // initialize page list
    _pages..add(TasksListPage())..add(CompletedTasksPage());
    _currentPage = TasksListPage();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPage,
      // app's main navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list_alt_rounded, 
              color: Colors.blue
            ),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.done_all_rounded, 
              color: Colors.lightGreen,
            ),
            label: 'Completed Tasks',
          ),
        ],
        onTap: (int selectedIndex) {
          setState(() {
            _currentIndex = selectedIndex;
            _currentPage = _pages[selectedIndex];
          });
        }
      )
    );
  }
}