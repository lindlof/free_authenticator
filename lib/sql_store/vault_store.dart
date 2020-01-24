import 'package:free_authenticator/database/database_entry.dart';
import 'package:free_authenticator/keychain/keychain_helper.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/entry/vault.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/sql_store/db_provider.dart';
import 'package:sqflite/sqlite_api.dart';

import 'entry_marshal.dart';

class VaultStore {
  DbProvider dbProvider;

  VaultStore(DbProvider dbProvider) {
    this.dbProvider = dbProvider;
  }

  Future<int> getOrCreate(String name) async {
    Vault vault = await _getName(name);
    if (vault == null) vault = await _create(name);
    return vault.id;
  }

  Future<Vault> _getName(String name) async {
    Database db = await dbProvider.database;
    String columnData = DatabaseEntry.columnData;
    List<Map<String, dynamic>> vaults = await DatabaseEntry.getByType(db, DatabaseEntry.vaultTypeId);
    print("vaults " + vaults.toString());

    Map<String, dynamic> vault;
    for (var v in vaults) {
      if ((await KeychainHelper.decryptJson(v[columnData]))["name"] == name) {
        vault = v;
        break;
      }
    }
    if (vault == null) return null;
    return Vault(
      vault[DatabaseEntry.columnId],
      name,
      vault[DatabaseEntry.columnPosition],
      vault[DatabaseEntry.columnVault]);
  }

  Future<Vault> _create(String name) async {
    Database db = await dbProvider.database;
    int position = await DatabaseEntry.nextPosition(db, VaultEntry.rootId);

    Map<String, dynamic> data = EntryMarshal.marshalData(EntryType.vault, name: name);
    String encryptedData = await KeychainHelper.encryptJson(data);
    Map<String, dynamic> map = EntryMarshal.marshal(
      EntryType.vault, encryptedData, position: position, vault: VaultEntry.rootId);

    int vaultId = await DatabaseEntry.create(db, map);
    return Vault(
      vaultId,
      name,
      position,
      VaultEntry.rootId);
  }
}
