import 'package:free_authenticator/keychain_helper.dart';

class Entry {

  static final table = 'entry';
  static final columnId = 'id';
  static final columnName = 'name';
  static final columnSecret = 'secret';

  final keychain = KeychainHelper.instance;

  String name;
  String secret;

  Entry(this.name, this.secret);

  static Future<Entry> fromDbFormat(Map<String, dynamic> map) async {
    print("Entry from map: " + map.values.join(", "));
    final keychain = KeychainHelper.instance;
    var name = await keychain.decrypt(map[columnName]);
    if (name == null) name = "Decryption error";
    final secret = await keychain.decrypt(map[columnSecret]);
    return Entry(name, secret);
  }

  Future<Map<String, dynamic>> toDbFormat() async {
    Map<String, dynamic> map = {
      Entry.columnName : await keychain.encrypt(this.name),
      Entry.columnSecret  : await keychain.encrypt(this.secret),
    };
    return map;
  }

}
