import 'package:free_authenticator/database/database_entry.dart';
import 'package:free_authenticator/database/database_init.dart';
import 'package:free_authenticator/keychain/keychain_provider.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:sqflite/sqlite_api.dart';

class DbProvider {
  final KeychainProvider _keychainProvider;

  DbProvider(KeychainProvider keychainProvider) :
    this._keychainProvider = keychainProvider;

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await DatabaseInit.initDatabase(this.getRootVault);
    return _database;
  }

  Future<Map<String, dynamic>> getRootVault() async {
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
