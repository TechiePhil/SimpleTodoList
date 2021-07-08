import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../models/todo_item.dart';

class DatabaseFileRoutines {
  // get the path to the local directory
  Future<String> get _getLocalFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  
  // get the file (todo_list.json) from the path
  Future<File> get _getLocalFile async {
    final path = await _getLocalFilePath;
    return File('$path/todo_list.json');
  }
  
  // read the (todo_list.json file) as a string, this string contains
  // the entire todo items as a json object
  Future<String> readFromDatabase() async {
    try {
      final file = await _getLocalFile;
      
      // if the file does not exists, create it and
      // write the todo list structure (json object) into the file
      if (!file.existsSync()) {
        await writeToDatabase('{"undoneTasks": [], "completedTasks": []}');
      }
      // read the entire json object as string
      return await file.readAsString();
    }
    catch (error) {
      print('error reading todo list: $error');
      return '';
    }
  }
  
  // after stringifying the json object (the todo list),
  // write the string onto a file
  Future<File> writeToDatabase(String json) async {
    final file = await _getLocalFile;
    return file.writeAsString('$json');
  }
}

// // load todo list from database file (.json file)
// Future<List<TodoItem>> loadTodoListItems(Database database, String group) 
// async {
//   List<TodoItem> dataset;
//   await DatabaseFileRoutines().readFromDatabase()
//   .then((jsonData) {
//     database = databaseFromJsonString(jsonData);
//     // print('this is the data: $todoListJson');
//   });
  
//   if (group == 'unchecked') {
//     dataset = database.unchecked;
//   }
//   else if (group == 'checked') {
//     dataset = database.checked;
//   }
//   return dataset;
// }

// function to accept a JSON string and parse it into a JSON object
// decode the JSON string read from the .json file.
// the function will return a JSON object (which will serve as the database)
Database databaseFromJsonString(String jsonString) {
  final dataFromJsonString = jsonDecode(jsonString);
  return Database.fromJson(dataFromJsonString);
}

// encode the JSON object as a string to be serialized.
// take a Database object (JSON object) and encode it as a string to be
// stored in a .json file.
// return the stringified JSON object.
String databaseToJsonString(Database database, String group1, String group2) {
  // convert the database to a JSON object.
  final dataToJsonString = database.toJson(group1, group2);
  // serialize the JSON object to persist it to a .json file
  return jsonEncode(dataToJsonString);
}

// the Database class handles the Encoding and Decoding of the entire
// database JSON object stored in the .json file
class Database {
  // unchecked todo list items
  List<TodoItem> unchecked;
  // checked todo list items
  List<TodoItem> checked;
  // Database constructor
  Database({this.unchecked, this.checked});
  
  // parse the entire todo list from a JSON string into JSON objects
  factory Database.fromJson(Map<String, dynamic> json) {
    // factory methods instanciate and cache the object of the class that
    // they are in and return that class instead of instanciating
    // the class for each call
    return Database(
      unchecked: List<TodoItem>.from(json['unchecked'].map((uncheckedItem) {
        return TodoItem.convertFromJsonObject(uncheckedItem);
      })),
      checked: List<TodoItem>.from(json['checked'].map((checkedItem) {
        return TodoItem.convertFromJsonObject(checkedItem);
      })),
    );
  }
  
  // parse the entire todo list database into a JSON object.
  // the keys are 'unchecked' and 'checked' which are keys to 
  // arrays of TodoItem(s)
  Map<String, dynamic> toJson(String group1, String group2) {
    return {
      group1: List<dynamic>.from(unchecked.map((uncheckedItem) {
        return uncheckedItem.convertToJsonObject();
      })),
      group2: List<dynamic>.from(checked.map((checkedItem) {
        return checkedItem.convertToJsonObject();
      }))
    };
  }
}
