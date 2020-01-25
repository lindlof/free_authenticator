import 'package:free_authenticator/database/database_entry.dart';
import 'package:free_authenticator/keychain/keychain_provider.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseProvider {
  static final _databaseName = "free_authenticator.db";
  static final _databaseVersion = 1;

  final KeychainProvider _keychainProvider;

  DatabaseProvider(KeychainProvider keychainProvider) :
    this._keychainProvider = keychainProvider;

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await openDatabase(_databaseName,
        version: _databaseVersion,
        onCreate: this._create());
    return _database;
  }

  Function _create() {
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
              FOREIGN KEY($vault) REFERENCES $table($id)
            );
            ''');
      
      await db.insert(table, await this._rootVault());
    };
  }

  Future<Map<String, dynamic>> _rootVault() async {
    final id = DatabaseEntry.columnId;
    final type = DatabaseEntry.columnType;
    final data = DatabaseEntry.columnData;
    final position = DatabaseEntry.columnPosition;

    var secretData = {
      'name': "Main Vault",
    };
    var encryptedData = await _keychainProvider.encryptJson(secretData);
    Map<String, dynamic> rootEntry = {
      "$id": "${VaultEntry.rootId}",
      "$type": "${DatabaseEntry.vaultTypeId}",
      "$data": "$encryptedData",
      "$position": "1", // TODO magic number, should be ENTRY_MIN_POSITION
    };
    return rootEntry;
  }
}
