
class TodoItem {
  String id, checked, note;
  
  TodoItem({this.id, this.checked, this.note});
  
  // convert a JSON object into a TodoItem object
  factory TodoItem.convertFromJsonObject(Map<String, dynamic> jsonObject) {
    return TodoItem(
      id: jsonObject['id'],
      checked: jsonObject['checked'],
      note: jsonObject['note'],
    );
  }
  
  // convert a TodoItem object to a JSON object
  Map<String, dynamic> convertToJsonObject() {
    return {
      'id': this.id,
      'checked': this.checked,
      'note': this.note,
    };
  }
}

// apart from representing a single TodoItem, the TodoItem class
// handles the conversion of each TodoItem from and to a JSON object
// class TodoItem {
//   String id, checked, note;
  
//   TodoItem({this.id, this.checked, this.note});
  
//   // convert the JSON object into a single TodoItem instance
//   factory TodoItem.fromJson(Map<String, dynamic> json) {
//     return TodoItem(
//       id: json['id'],
//       checked: json['checked'],
//       note: json['note']
//     );
//   }
  
//   // convert the TodoItem instance into a JSON object
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'checked': checked,
//       'note': note
//     };
//   }
// }