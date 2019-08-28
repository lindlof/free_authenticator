abstract class Entry {
  Future<Map<String, dynamic>> toDbFormat();
  int get type;
  String get name;
  String genPassword();
}
