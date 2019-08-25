import 'package:free_authenticator/keychain_helper.dart';
import 'dart:convert';

class Entry {

  static final table = 'entry';
  static final columnId = 'id';
  static final columnData = 'data';

  static final typeTotp = 1; // https://tools.ietf.org/html/rfc6238

  static final dataName = 'name';
  static final dataSecret = 'secret';

  final keychain = KeychainHelper.instance;

  String name;
  String secret;

  Entry(this.name, this.secret);

  static Future<Entry> fromDbFormat(Map<String, dynamic> map) async {
    print("Entry from map: " + map.values.join(", "));
    final keychain = KeychainHelper.instance;
    final data = await keychain.decrypt(map[columnData]);

    Map entry = jsonDecode(data);
    var name = entry[Entry.dataName];
    if (name == null) name = "Decryption error";
    final secret = entry[Entry.dataSecret];
    return Entry(name, secret);
  }

  Future<Map<String, dynamic>> toDbFormat() async {
    Map<String, dynamic> dataMap = {
      Entry.dataName : this.name,
      Entry.dataSecret  : this.secret,
    };
    var data = await keychain.encrypt(jsonEncode(dataMap));

    Map<String, dynamic> map = {
      Entry.columnData : data,
    };
    return map;
  }

}
