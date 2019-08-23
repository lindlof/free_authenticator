
class Entry {

  static final table = 'entry';
  static final columnId = 'id';
  static final columnName = 'name';
  static final columnKey = 'key';

  String name;
  String key;

  Entry(this.name, this.key);

  Entry.fromMap(Map<String, dynamic> map) {
    this.name = map[columnName];
    this.key = map[columnKey];
  }

  toMap() {
    Map<String, dynamic> map = {
      Entry.columnName : this.name,
      Entry.columnKey  : this.key,
    };
    return map;
  }

}
