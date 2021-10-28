class NoteModel {
  String id;
  String title;
  String message;
  int timestamp;
  int lastUpdate;
  bool isDone;

  NoteModel(
      {this.id,
      this.title,
      this.message,
      this.timestamp,
      this.lastUpdate,
      this.isDone = false});

  NoteModel.fromMap(Map<String, dynamic> map) {
    id = map["\$id"];
    title = map['title'];
    message = map['message'];
    timestamp = map['timestamp'];
    lastUpdate = map['lastUpdate'];
    isDone = map['isDone'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data["\$id"] = this.id;
    data['title'] = this.title;
    data['message'] = this.message;
    data['timestamp'] = this.timestamp;
    data['lastUpdate'] = this.lastUpdate;
    data['isDone'] = this.isDone;
    return data;
  }
}
