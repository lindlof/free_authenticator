import 'package:free_authenticator/entry_type.dart';

abstract class Entry {
  Future<Map<String, dynamic>> toDbFormat();
  EntryType get type;
  String get name;
  String genPassword();
}
