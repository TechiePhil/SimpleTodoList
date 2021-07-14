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
            onPressed: () {
              // functionality to add new task to the list
              showInputModal(context);
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
            showInputModal(context);
          }
        )
    );
  }
  
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
  
  // function to add the new task to the task list
  void addTask(String task) {
    setState(() {
      database.unchecked.add(
        TodoItem(
          id: Random().nextInt(9999999).toString(),
          checked: 'no',
          note: task,
        )
      );
    });
  }
  
  // open up a modal with the input text field to add new task
  showInputModal(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          child: Center(
            child: SimpleDialog(
              titlePadding: EdgeInsets.only(left:5, top:5, bottom:10),
              contentPadding: EdgeInsets.only(left:5, right:5),
              title: Text('Add New Task'),
              children: <Widget>[
              Column(
                children: <Widget>[
                  TextField(
                    controller: inputController,
                    maxLines: null,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(5),
                      hintText: 'What to do?',
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
                        // close the modal
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
                        // add a new (nonempty) task to the list
                        onPressed: () {
                          if (inputController.text.isNotEmpty) {
                            addTask(inputController.text);
                            // with each new task, update the database .json file
                            DatabaseFileRoutines().writeToDatabase(
                              databaseToJsonString(
                                database, 'unchecked', 'checked')
                            );
                            // show database string
                            // print('this: ${databaseToJsonString(database, 'unchecked', 'checked')}');
                          }
                          // clear the current text from the input text field
                          inputController.clear();
                          // close the modal sheet
                          Navigator.pop(context);
                        }
                      ),
                    ]
                  ),
                ]
              ),
              ]
            )
          )
        );
      }
    );
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
  
  // build the todo list and display them
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