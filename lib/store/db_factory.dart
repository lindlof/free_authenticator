import 'package:free_authenticator/database/database_entry.dart';
import 'package:free_authenticator/database/database_init.dart';
import 'package:free_authenticator/keychain/keychain_helper.dart';
import 'package:free_authenticator/model/interface/entry.dart';
import 'package:sqflite/sqlite_api.dart';

class DbFactory {
  // only have a single app-wide reference to the database
  static Database _database;

  static Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await DatabaseInit.initDatabase(getRootVault);
    return _database;
  }

  static Future<Map<String, dynamic>> getRootVault() async {
    final id = DatabaseEntry.columnId;
    final type = DatabaseEntry.columnType;
    final data = DatabaseEntry.columnData;
    final position = DatabaseEntry.columnPosition;

    var secretData = {
      'name': "root",
    };
    var encryptedData = await KeychainHelper.encryptJson(secretData);
    Map<String, dynamic> rootEntry = {
      "$id": "${VaultEntry.rootId}",
      "$type": "${DatabaseEntry.vaultTypeId}",
      "$data": "$encryptedData",
      "$position": "1", // TODO magic number, should be ENTRY_MIN_POSITION
    };
    return rootEntry;
  }
}
