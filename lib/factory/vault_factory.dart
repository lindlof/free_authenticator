import 'package:free_authenticator/database/database_entry.dart';
import 'package:free_authenticator/factory/db_factory.dart';
import 'package:free_authenticator/keychain/keychain_helper.dart';
import 'package:free_authenticator/model/entry/vault.dart';
import 'package:free_authenticator/model/interface/entry_type.dart';

class VaultFactory {
  static Future<int> getOrCreate(String name) async {
    Vault vault = await _getName(name);
    if (vault == null) vault = await _create(name);
    return vault.id;
  }

  static Future<Vault> _getName(String name) async {
    final db = await DbFactory.database;
    String columnData = DatabaseEntry.columnData;
    List<Map<String, dynamic>> vaults = await DatabaseEntry.getByType(db, EntryTypeId[EntryType.vault]);
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
    var secretData = {
      "name": name,
    };
    var encryptedData = await KeychainHelper.encryptJson(secretData);
    int vaultId = await DatabaseEntry.create(db, EntryType.vault, encryptedData, position, Vault.rootId);
    return Vault(
      vaultId,
      name,
      position,
      Vault.rootId);
  }
}