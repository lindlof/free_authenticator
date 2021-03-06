import 'package:free_authenticator/database/database_entry.dart';
import 'package:free_authenticator/model/entry/totp.dart';
import 'package:free_authenticator/model/entry/vault.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';

class EntryMarshal {
  static final _name = 'name';
  static final _secret = 'secret';
  static final _timestep = 'timestep';

  static final Map<EntryType, int> typeId = {
    EntryType.vault: DatabaseEntry.vaultTypeId,
    EntryType.totp: DatabaseEntry.totpTypeId,
  };

  static Future<Map<String, dynamic>> marshal(
    EntryType type,
    Future<String> encryptJson(Map<String, dynamic> data),
    {
      int position, int vault,
      String name, String secret, int timestep,
      Entry entry
    }) async {
    Map<String, dynamic> data = EntryMarshal._marshalData(
      type, name: name, secret: secret, timestep: timestep, entry: entry);
    String encryptedData = await encryptJson(data);
    Map<String, dynamic> map = {
      DatabaseEntry.columnType : typeId[type],
      DatabaseEntry.columnData : encryptedData,
      DatabaseEntry.columnPosition : _val("position", position, entry?.position),
      DatabaseEntry.columnVault : _val("vault", vault, entry?.vault),
    };
    return map;
  }

  static Map<String, dynamic> _marshalData(
      EntryType type,
      {String name, String secret, int timestep, Entry entry}
    ) {
    Map<String, dynamic> data = {
      _name: _val("name", name, entry?.name),
    };

    if (type == EntryType.totp) {
      TOTP totp = entry as TOTP;
      data[_secret] = _val("secret", secret, totp?.secret);
      data[_timestep] = _val("timestep", timestep, totp?.timeStep);
    } else if (type == EntryType.vault) {
    } else {
      throw ArgumentError("SecretFactory does not produce " + EntryTypeDesc[type]);
    }
    return data;
  }

  static Future<Entry> unmarshal(
      Map<String, dynamic> map,
      Future<Map<String, dynamic>> decryptJson(String encrypted)
    ) async {
    print("Entry from map: " + map.toString());
    EntryType type = typeId.keys.firstWhere(
      (k) => typeId[k] == map[DatabaseEntry.columnType]);

    int id = map[DatabaseEntry.columnId];
    int position = map[DatabaseEntry.columnPosition];
    int vault = map[DatabaseEntry.columnVault];

    Map data = await decryptJson(map[DatabaseEntry.columnData]);
    var name = data[_name];
    if (name == null) name = "Decryption error";
    final secret = data[_secret];

    if (type == EntryType.totp) {
      final timeStep = data[_timestep];
      return TOTP(id, name, secret, position, vault, timeStep);
    } else if (type == EntryType.vault) {
      return Vault(id, name, position, vault);
    }
    throw StateError("Unknown type " + type.toString());
  }

  static _val(String field, dynamic value1, dynamic value2) {
    if (value1 == null && value2 == null) throw ArgumentError("Missing field $field");
    return value1 != null ? value1 : value2;
  }
}
