import 'package:sqflite/sqflite.dart';
import 'package:free_authenticator/entry_base.dart';

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
    await db.execute('''
          CREATE TABLE ${EntryBase.table} (
            ${EntryBase.columnId} INTEGER PRIMARY KEY,
            ${EntryBase.columnType} INTEGER NOT NULL,
            ${EntryBase.columnData} TEXT NOT NULL
          );
          ''');
  }
}