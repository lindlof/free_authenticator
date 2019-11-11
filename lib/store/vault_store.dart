import 'package:free_authenticator/database/database_entry.dart';
import 'package:free_authenticator/keychain/keychain_helper.dart';
import 'package:free_authenticator/model/entry/vault.dart';
import 'package:free_authenticator/model/interface/entry_type.dart';
import 'package:free_authenticator/store/db_factory.dart';

import 'entry_marshal.dart';

class VaultStore {
  static Future<int> getOrCreate(String name) async {
    Vault vault = await _getName(name);
    if (vault == null) vault = await _create(name);
    return vault.id;
  }

  static Future<Vault> _getName(String name) async {
    final db = await DbFactory.database;
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

  static Future<Vault> _create(String name) async {
    final db = await DbFactory.database;
    int position = await DatabaseEntry.nextPosition(db, Vault.rootId);

    Map<String, dynamic> data = EntryMarshal.marshalData(EntryType.vault, name: name);
    String encryptedData = await KeychainHelper.encryptJson(data);
    Map<String, dynamic> map = EntryMarshal.marshal(EntryType.vault, position, Vault.rootId, encryptedData);

    int vaultId = await DatabaseEntry.create(db, map);
    return Vault(
      vaultId,
      name,
      position,
      Vault.rootId);
  }
}
