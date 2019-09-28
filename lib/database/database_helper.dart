import 'package:free_authenticator/database/database_entry.dart';
import 'package:free_authenticator/keychain/keychain_helper.dart';
import 'package:free_authenticator/model/interface/entry.dart';
import 'package:free_authenticator/model/interface/entry_type.dart';
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
    
    var secretData = {
    'name': "root",
    };
    var encryptedData = await KeychainHelper.encryptJson(secretData);
    Map<String, dynamic> rootEntry = {
      "$id": "${VaultEntry.rootId}",
      "$type": "${EntryTypeId[EntryType.vault]}",
      "$data": "$encryptedData",
      "$position": "1",
    };
    await db.insert(table, rootEntry);
  }
}
