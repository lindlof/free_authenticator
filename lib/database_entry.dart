import 'package:free_authenticator/entry_type.dart';

abstract class DatabaseEntry {
  static final table = 'entry';
  static final columnId = 'id';
  static final columnType = 'type';
  static final columnData = 'data';
  static final columnPosition = 'position';
  static final columnGrouping = 'grouping';

  static final dataName = 'name';
  static final dataSecret = 'secret';

  static final dataTimeStep = 'timestep';
}

const Map<EntryType, int> EntryTypeId = {
  EntryType.totp: 1,
};