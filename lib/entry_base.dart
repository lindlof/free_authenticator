import 'package:free_authenticator/keychain_helper.dart';
import 'dart:convert';
import 'totp.dart';
import 'entry.dart';

class EntryBase {
  static final table = 'entry';
  static final columnId = 'id';
  static final columnType = 'type';
  static final columnData = 'data';

  static final typeTotp = 1;

  static final dataName = 'name';
  static final dataSecret = 'secret';

  String name;
  String secret;

  EntryBase(this.name, this.secret);

  static Future<Entry> fromDbFormat(Map<String, dynamic> map) async {
    print("Entry from map: " + map.values.join(", "));
    final data = await KeychainHelper.decrypt(map[columnData]);

    Map entry = jsonDecode(data);
    var name = entry[EntryBase.dataName];
    if (name == null) name = "Decryption error";
    final secret = entry[EntryBase.dataSecret];

    if (map[columnType] == typeTotp) {
      return TOTP(name, secret);
    }
    return null;
  }

  Future<Map<String, dynamic>> toDbFormat(int type) async {
    Map<String, dynamic> dataMap = {
      EntryBase.dataName : this.name,
      EntryBase.dataSecret  : this.secret,
    };
    var data = await KeychainHelper.encrypt(jsonEncode(dataMap));

    Map<String, dynamic> map = {
      EntryBase.columnType : type,
      EntryBase.columnData : data,
    };
    return map;
  }

}
