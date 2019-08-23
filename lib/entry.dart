import 'package:free_authenticator/keychain_helper.dart';

class Entry {

  static final table = 'entry';
  static final columnId = 'id';
  static final columnName = 'name';
  static final columnKey = 'key';

  final keychain = KeychainHelper.instance;

  String name;
  String key;

  Entry(this.name, this.key);

  static Future<Entry> fromDbFormat(Map<String, dynamic> map) async {
    print("Entry from map: " + map.values.join(", "));
    final keychain = KeychainHelper.instance;
    var name = await keychain.decrypt(map[columnName]);
    if (name == null) name = "Decryption error";
    final key = await keychain.decrypt(map[columnKey]);
    return Entry(name, key);
  }

  Future<Map<String, dynamic>> toDbFormat() async {
    Map<String, dynamic> map = {
      Entry.columnName : await keychain.encrypt(this.name),
      Entry.columnKey  : await keychain.encrypt(this.key),
    };
    return map;
  }

}
