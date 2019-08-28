import 'package:free_authenticator/database_entry.dart';
import 'package:free_authenticator/keychain_helper.dart';
import 'dart:convert';
import 'totp.dart';
import 'entry.dart';

class EntryBase {
  String name;
  String secret;

  EntryBase(this.name, this.secret);

  static Future<Entry> fromDbFormat(Map<String, dynamic> map) async {
    print("Entry from map: " + map.values.join(", "));
    final data = await KeychainHelper.decrypt(map[DatabaseEntry.columnData]);

    Map entry = jsonDecode(data);
    var name = entry[DatabaseEntry.dataName];
    if (name == null) name = "Decryption error";
    final secret = entry[DatabaseEntry.dataSecret];

    if (map[DatabaseEntry.columnType] == DatabaseEntry.typeTotp) {
      final timeStep = entry[DatabaseEntry.dataTimeStep];
      return TOTP(name, secret, timeStep: timeStep);
    }
    return null;
  }

  Future<Map<String, dynamic>> toDbFormat(int type, Map<String, dynamic> dataMap) async {
    var data = await KeychainHelper.encrypt(jsonEncode(dataMap));

    Map<String, dynamic> map = {
      DatabaseEntry.columnType : type,
      DatabaseEntry.columnData : data,
    };
    return map;
  }
}
