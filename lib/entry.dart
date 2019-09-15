import 'package:free_authenticator/entry_type.dart';

abstract class Entry {
  Future<Map<String, dynamic>> toDbFormat();
  EntryType get type;
  String get name;
  int get position;
  int get vault;
  void setPosition(int position, int vault);
  String genPassword();
}
