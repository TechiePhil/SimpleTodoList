import 'package:flutter/material.dart';
import '../utils/database.dart';
import '../models/todo_item.dart';

class CompletedTasksPage extends StatefulWidget {
  @override
  _CompletedTasksPageState createState() => _CompletedTasksPageState();
}

class _CompletedTasksPageState extends State<CompletedTasksPage> {
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
        title: Text('Completed Tasks'),
        backgroundColor: Colors.lightGreen,
      ),
      body: FutureBuilder(
        initialData: database.checked,
        future: loadTodoListItems(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return database.checked.length == 0 ?
            emptyCompletedList : buildListView(snapshot);
        }
      ),
    );
  }
  
  Widget emptyCompletedList = Container(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.done_all_rounded,
            color: Colors.green.shade100,
            size: 200
          ),
          Text(
            'Completed tasks will appear here.\n' +
            'You haven\'t completed a task yet.',
            textAlign: TextAlign.center,
          )
        ]
      )
    )
  );
  
  // load todo list from database file (.json file)
  Future<List<TodoItem>> loadTodoListItems() async {
    await DatabaseFileRoutines().readFromDatabase()
    .then((jsonData) {
      database = databaseFromJsonString(jsonData);
      // print('this is the data: $todoListJson');
    });
    return database.checked;
  }
  
  // build the todo list and display them
  Widget buildListView(AsyncSnapshot snapshot) {
    return ListView.builder(
      // cross-check "itemCount: snapshot.data.length", it has a logic error!
      itemCount: database.checked.length,
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          key: Key(snapshot.data[index].id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16),
            child: Icon(
              Icons.delete, 
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
            )
          ),
          onDismissed: (direction) {
            setState(() {
              // delete a checked item completely
              database.checked.removeAt(index);
            });
            // write the new data to the database file (after deleting
            // an item from the list)
            DatabaseFileRoutines().writeToDatabase(
              databaseToJsonString(database, 'unchecked', 'checked')
            );
            // show database string
          }
        );
      },
    );
  }
}