import 'package:free_authenticator/database_entry.dart';
import 'package:free_authenticator/entry_type.dart';
import 'package:free_authenticator/keychain_helper.dart';
import 'dart:convert';
import 'totp.dart';
import 'entry.dart';

class EntryBase {
  String name;
  String secret;
  int position;
  int vault;

  EntryBase(this.name, this.secret, {this.position, this.vault});

  setPosition(int position, int vault) {
    this.position = position;
    this.vault = vault;
  }

  static Future<Entry> fromDbFormat(Map<String, dynamic> map) async {
    print("Entry from map: " + map.toString());
    final data = await KeychainHelper.decrypt(map[DatabaseEntry.columnData]);
    int position = map[DatabaseEntry.columnPosition];
    int vault = map[DatabaseEntry.columnVault];

    Map entry = jsonDecode(data);
    var name = entry[DatabaseEntry.dataName];
    if (name == null) name = "Decryption error";
    final secret = entry[DatabaseEntry.dataSecret];

    if (map[DatabaseEntry.columnType] == EntryTypeId[EntryType.totp]) {
      final timeStep = entry[DatabaseEntry.dataTimeStep];
      return TOTP(name, secret, position: position, vault: vault, timeStep: timeStep);
    }
    return null;
  }

  Future<Map<String, dynamic>> toDbFormat(EntryType type, Map<String, dynamic> dataMap) async {
    var data = await KeychainHelper.encrypt(jsonEncode(dataMap));

    Map<String, dynamic> map = {
      DatabaseEntry.columnType : EntryTypeId[type],
      DatabaseEntry.columnData : data,
      DatabaseEntry.columnPosition  : this.position,
      DatabaseEntry.columnVault : this.vault,
    };
    return map;
  }
}
