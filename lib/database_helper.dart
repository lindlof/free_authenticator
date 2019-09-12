import 'package:free_authenticator/database_entry.dart';
import 'package:free_authenticator/database_grouping.dart';
import 'package:free_authenticator/grouping.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  
  static final _databaseName = "free_authenticator.db";
  static final _databaseVersion = 1;

  // only have a single app-wide reference to the database
  static Database _database;
  static Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }
  
  // this opens the database (and creates it if it doesn't exist)
  static _initDatabase() async {
    return await openDatabase(_databaseName,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  static Future _onCreate(Database db, int version) async {
    final table = DatabaseEntry.table;
    final id = DatabaseEntry.columnId;
    final position = DatabaseEntry.columnPosition;
    final grouping = DatabaseEntry.columnGrouping;
    final groupingTable = DatabaseGrouping.table;
    await db.execute('''
          CREATE TABLE $groupingTable (
            ${DatabaseGrouping.columnId} INTEGER PRIMARY KEY,
            ${DatabaseGrouping.columnName} TEXT NOT NULL
          );
          ''');
    await db.execute('''
          CREATE TABLE $table (
            $id INTEGER PRIMARY KEY,
            ${DatabaseEntry.columnType} INTEGER NOT NULL,
            ${DatabaseEntry.columnData} TEXT NOT NULL,
            $position INTEGER NOT NULL,
            $grouping INTEGER NOT NULL,
            FOREIGN KEY($grouping) REFERENCES $groupingTable($id),
            UNIQUE($position,$grouping)
          );
          ''');
    await db.execute('''
          INSERT INTO $groupingTable(id, name) VALUES(${Grouping.rootId}, "root");
          ''');
  }
}
