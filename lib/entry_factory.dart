
import 'dart:convert';

import 'package:free_authenticator/database_entry.dart';
import 'package:free_authenticator/entry.dart';
import 'package:free_authenticator/entry_type.dart';
import 'package:free_authenticator/keychain_helper.dart';
import 'package:free_authenticator/totp.dart';
import 'package:free_authenticator/vault.dart';

class EntryFactory {
  static final jsonType = 'type';
  static final jsonName = 'name';
  static final jsonSecret = 'secret';
  static final jsonTimeStep = 'timestep';

  static Future<void> create(Map<String, dynamic> values, int vault) async {
    EntryType type = values[jsonType];
    int position = await DatabaseEntry.nextPosition(vault);
    Map<String, dynamic> secretData = {
      jsonName: values[jsonName] as String,
      jsonSecret: values[jsonSecret] as String,
    };

    if (type == EntryType.totp) {
      secretData[jsonTimeStep] = values[jsonTimeStep] ?? 30;
    } else {
      throw ArgumentError("SecretFactory does not produce " + EntryTypeDesc[type]);
    }

    var encryptedData = await KeychainHelper.encrypt(jsonEncode(secretData));
    await DatabaseEntry.create(type, encryptedData, position, vault);
  }

  static Future<List<Entry>> getEntries(int vault) async {
    List<Map<String, dynamic>> entries = await DatabaseEntry.getEntries(vault);
    if (entries.isNotEmpty) {
      var fEntries = entries.map((e) => _fromJSON(e)).toList();
      return await Future.wait(fEntries);
    }
    return [];
  }

  static Future<Entry> getEntry(int position, int vault) async {
    Map<String, dynamic> entry = await DatabaseEntry.getEntry(position, vault);
    if (entry == null) return null;
    return _fromJSON(entry);
  }

  static Future<Entry> _fromJSON(Map<String, dynamic> map) async {
    print("Entry from map: " + map.toString());
    EntryType type = EntryTypeId.keys.firstWhere(
      (k) => EntryTypeId[k] == map[DatabaseEntry.columnType]);
    String data = [EntryType.totp].contains(type) ?
      await KeychainHelper.decrypt(map[DatabaseEntry.columnData]) :
      map[DatabaseEntry.columnData];

    int id = map[DatabaseEntry.columnId];
    int position = map[DatabaseEntry.columnPosition];
    int vault = map[DatabaseEntry.columnVault];

    Map entry = jsonDecode(data);
    var name = entry[jsonName];
    if (name == null) name = "Decryption error";
    final secret = entry[jsonSecret];

    if (type == EntryType.totp) {
      final timeStep = entry[jsonTimeStep];
      return TOTP(id, name, secret, position, vault, timeStep);
    } else if (type == EntryType.vault) {
      return Vault(id, name, position, vault);
    }
    throw StateError("Unknown type " + type.toString());
  }
}