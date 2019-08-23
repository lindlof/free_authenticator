import 'package:sqflite/sqflite.dart';
import 'package:free_authenticator/entry.dart';

class DatabaseHelper {
  
  static final _databaseName = "free_authenticator.db";
  static final _databaseVersion = 1;

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }
  
  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    return await openDatabase(_databaseName,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE ${Entry.table} (
            ${Entry.columnId} INTEGER PRIMARY KEY,
            ${Entry.columnName} TEXT NOT NULL,
            ${Entry.columnKey} TEXT NOT NULL
          )
          ''');
  }
}