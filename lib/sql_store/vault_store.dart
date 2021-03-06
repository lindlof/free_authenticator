import 'package:free_authenticator/database/database_entry.dart';
import 'package:free_authenticator/database/database_provider.dart';
import 'package:free_authenticator/keychain/keychain_provider.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/entry/vault.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:sqflite/sqlite_api.dart';

import 'entry_marshal.dart';

class VaultStore {
  DatabaseProvider _dbProvider;
  KeychainProvider _keychainProvider;

  VaultStore(DatabaseProvider dbProvider, KeychainProvider keychainProvider) {
    this._dbProvider = dbProvider;
    this._keychainProvider = keychainProvider;
  }

  Future<int> getOrCreate(String name) async {
    Vault vault = await _getName(name);
    if (vault == null) vault = await _create(name);
    return vault.id;
  }

  Future<Vault> _getName(String name) async {
    Database db = await _dbProvider.database;
    String columnData = DatabaseEntry.columnData;
    List<Map<String, dynamic>> vaults = await DatabaseEntry.getByType(db, DatabaseEntry.vaultTypeId);
    print("vaults " + vaults.toString());

    Map<String, dynamic> vault;
    for (var v in vaults) {
      if ((await _keychainProvider.decryptJson(v[columnData]))["name"] == name) {
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
    Database db = await _dbProvider.database;
    int position = await DatabaseEntry.nextPosition(db, VaultEntry.rootId);

    Map<String, dynamic> map = await EntryMarshal.marshal(EntryType.vault, _keychainProvider.encryptJson,
      position: position, vault: VaultEntry.rootId, name: name);

    int vaultId = await DatabaseEntry.create(db, map);
    return Vault(
      vaultId,
      name,
      position,
      VaultEntry.rootId);
  }
}
