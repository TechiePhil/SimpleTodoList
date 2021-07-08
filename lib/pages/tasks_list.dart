import 'dart:ui';

import 'package:flutter/material.dart';
import '../utils/database.dart';
import '../models/todo_item.dart';
import 'dart:math';

class TasksListPage extends StatefulWidget {
  @override
  _TasksListPageState createState() => _TasksListPageState();
}

class _TasksListPageState extends State<TasksListPage> {
  TextEditingController inputController = TextEditingController();
  // use the 'unchecked' variable to access the "unchecked" entry
  // in the JSON object and use 'checked' variable to access the
  // "checked" entry in thesame JSON object.
  Database database;
  
  @override
  void initState() {
    super.initState();
    // initialize the database object with an empty todo list
    database = Database(unchecked: [], checked: []);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Todo List'),
        actions: <IconButton>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              // functionality to add new task to the list
              await openInputDialogPage(context).then((result) {
                if (result.isNotEmpty) {
                  setState(() {
                    database.unchecked.add(
                      TodoItem(
                        id: Random().nextInt(99999).toString(),
                        checked: 'no',
                        note: result,
                      )
                    );
                  });
                  DatabaseFileRoutines().writeToDatabase(
                    databaseToJsonString(database, 'unchecked', 'checked')
                  );
                }
              });
            }
          ),
        ]
      ),
      body: FutureBuilder(
          initialData: database.unchecked,
          future: loadTodoListItems(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return database.unchecked.length == 0 ?
              emptyTaskList : buildListView(snapshot);
          }
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {            
            // enter the new task from a new page
            await openInputDialogPage(context).then((result) {
              if (result.isNotEmpty) {
                addNewTask(database, result);
                // with each new task, update the database .json file
                DatabaseFileRoutines().writeToDatabase(
                  databaseToJsonString(
                    database, 'unchecked', 'checked')
                );
                // show database string
                // print('this: ${databaseToJsonString(database, 'unchecked', 'checked')}');
              }
            });
          }
        )
    );
  }
  
  // function to add new task to the undone task list
  void addNewTask(Database database, String taskNote) {
    setState(() {
      database.unchecked.add(
        TodoItem(
          id: Random().nextInt(99999).toString(),
          checked: 'no',
          note: taskNote,
        )
      );
    });
  }
  
  // empty widget to display when the list is empty
  Widget emptyTaskList = Container(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.list_alt_rounded,
            color: Colors.blue,
            size: 200,
          ),
          Text(
            'Tasks added will show here.\n' +
            'No task yet.',
            textAlign: TextAlign.center,
          )
        ]
      ),
    ),
  );
  
  // open a page to enter the task text
  Future<String> openInputDialogPage(BuildContext context) async {
    String stringData = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: false,
        builder: (context) {
          return Scaffold(
            body: Container(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  // mainAxisAlignment: MainAxisAlignment.end,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Text(
                            'What to do?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                              color: Colors.grey,
                            )
                          )
                        )
                      ]
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        TextField(
                          autofocus: true,
                          controller: inputController,
                          maxLines: null,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10, right: 10),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(),
                              borderRadius: BorderRadius.all(Radius.circular(20))
                            )
                          )
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.grey.shade100,
                                )
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              }
                            ),
                            SizedBox(width: 5),
                            TextButton(
                              child: Text('Add Task'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.greenAccent.shade100
                                ),
                              ),
                              onPressed: () {
                                if (inputController.text.isNotEmpty) {
                                  Navigator.pop(context, inputController.text);
                                  inputController.clear();
                                }
                                // Navigator.pop(context);
                              }
                            ),
                          ]
                        ),
                      ]
                    )
                  ]
                )
              ),
            )
          );
        }
      )
    );
    return stringData;
  }
  
  // load todo list from database file (.json file)
  Future<List<TodoItem>> loadTodoListItems() async {
    await DatabaseFileRoutines().readFromDatabase()
    .then((todoListJson) {
      database = databaseFromJsonString(todoListJson);
      // print('this is the data: $todoListJson');
    });
    return database.unchecked;
  }
  
  // build the todo list and display it
  Widget buildListView(AsyncSnapshot snapshot) {
    return ListView.builder(
      itemCount: database.unchecked.length,
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          key: Key(snapshot.data[index].id),
          background: Container(
            color: Colors.green,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16),
            child: Icon(
              Icons.check, 
              color: Colors.white
            )
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: Card(
            child: ListTile(
              title: Text(
                snapshot.data[index].note,
              ),
              subtitle: Text(
                'Proper Time Managment',
              ),
            ),
            shape: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.all(Radius.circular(20))
            ),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              // if dismiss direction is from left to right, then
              // a task has been completed. move it to the completed task list
              setState(() {
                snapshot.data[index].checked = 'yes';
                database.checked.add(snapshot.data[index]);
                database.unchecked.removeAt(index);
              });
              // with each new task, update the database .json file
              DatabaseFileRoutines().writeToDatabase(
                databaseToJsonString(database, 'unchecked', 'checked')
              );
              // show database string
              // print('this: ${databaseToJsonString(database, 'unchecked', 'checked')}');
            }
            else if (direction == DismissDirection.endToStart) {
              // if the dismiss direction is from right to left,
              // delete a task from the database entirely.
              setState(() {
                snapshot.data.removeAt(index);
              });
              // write the new data to the database file (after deleting
              // an item from the list)
              DatabaseFileRoutines().writeToDatabase(
                databaseToJsonString(database, 'unchecked', 'checked')
              );
              // show database string
              // print('this: ${databaseToJsonString(database, 'unchecked', 'checked')}');
            }
          }
        );
      },
    );
  }
}