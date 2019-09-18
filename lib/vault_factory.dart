import 'dart:convert';

import 'package:free_authenticator/database_entry.dart';
import 'package:free_authenticator/entry_type.dart';
import 'package:free_authenticator/vault.dart';

class VaultFactory {
  static Future<int> getOrCreate(String name) async {
    Vault vault = await _getName(name);
    if (vault == null) vault = await _create(name);
    return vault.id;
  }

  static Future<Vault> _getName(String name) async {
    String columnData = DatabaseEntry.columnData;
    List<Map<String, dynamic>> vaults = await DatabaseEntry.getByType(EntryTypeId[EntryType.vault]);
    print("vaults " + vaults.toString());
    Map<String, dynamic> vault = vaults.
      firstWhere((v) => jsonDecode(v[columnData])["name"] == name,
      orElse: () => null);
    if (vault == null) return null;
    return Vault(
      vault[DatabaseEntry.columnId],
      name,
      vault[DatabaseEntry.columnPosition],
      vault[DatabaseEntry.columnVault]);
  }

  static Future<Vault> _create(String name) async {
    int position = await DatabaseEntry.nextPosition(Vault.rootId);
    var vaultData = jsonEncode({
      "name": name,
    });
    int vaultId = await DatabaseEntry.create(EntryType.vault, vaultData, position, Vault.rootId);
    return Vault(
      vaultId,
      name,
      position,
      Vault.rootId);
  }
}