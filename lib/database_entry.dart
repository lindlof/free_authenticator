
abstract class DatabaseEntry {
  static final table = 'entry';
  static final columnId = 'id';
  static final columnType = 'type';
  static final columnData = 'data';

  static final typeTotp = 1;

  static final dataName = 'name';
  static final dataSecret = 'secret';

  static final dataTimeStep = 'timestep';
}