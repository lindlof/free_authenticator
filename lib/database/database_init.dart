import 'package:free_authenticator/database/database_entry.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseInit {
  static final _databaseName = "free_authenticator.db";
  static final _databaseVersion = 1;
  
  // this opens the database (and creates it if it doesn't exist)
  static Future<Database> initDatabase(
      Future<Map<String, dynamic>> Function() getRootVault) async {
    return await openDatabase(_databaseName,
        version: _databaseVersion,
        onCreate: _onCreate(getRootVault));
  }

  static Function _onCreate(
      Future<Map<String, dynamic>> Function() getRootVault) {
    // SQL code to create the database table
    return (Database db, int version) async {
      final table = DatabaseEntry.table;
      final id = DatabaseEntry.columnId;
      final type = DatabaseEntry.columnType;
      final data = DatabaseEntry.columnData;
      final position = DatabaseEntry.columnPosition;
      final vault = DatabaseEntry.columnVault;

      await db.execute('''
            CREATE TABLE $table (
              $id INTEGER PRIMARY KEY,
              $type INTEGER NOT NULL,
              $data TEXT NOT NULL,
              $position INTEGER NOT NULL,
              $vault INTEGER,
              FOREIGN KEY($vault) REFERENCES $table($id),
              UNIQUE($position,$vault)
            );
            ''');
      
      await db.insert(table, await getRootVault());
    };
  }
}
