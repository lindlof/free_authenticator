import 'entry_type.dart';

abstract class Entry {
  EntryType get type;
  int get id;
  String get name;
  int get position;
  int get vault;
}

abstract class PasswordEntry implements Entry {
  String genPassword();
}

abstract class TimedEntry implements Entry {
  int get timeStep;
}

abstract class TimedPasswordEntry implements Entry, PasswordEntry, TimedEntry {}

abstract class VaultEntry {
  static const rootId = 1;
}
