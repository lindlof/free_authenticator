import 'package:free_authenticator/database/database_entry.dart';
import 'package:free_authenticator/factory/db_factory.dart';
import 'package:free_authenticator/keychain/keychain_helper.dart';
import 'package:free_authenticator/model/entry/totp.dart';
import 'package:free_authenticator/model/entry/vault.dart';
import 'package:free_authenticator/model/interface/entry.dart';
import 'package:free_authenticator/model/interface/entry_type.dart';

class EntryFactory {
  static final jsonType = 'type';
  static final jsonName = 'name';
  static final jsonSecret = 'secret';
  static final jsonTimeStep = 'timestep';

  static final Map<EntryType, int> _typeId = {
    EntryType.vault: DatabaseEntry.vaultTypeId,
    EntryType.totp: DatabaseEntry.totpTypeId,
  };

  static Future<Entry> get(int id) async {
    final db = await DbFactory.database;
    List<Map<String, dynamic>> entries = await DatabaseEntry.get(db, [id]);
    if (entries.isEmpty) {
      throw StateError("No entries with id " + id.toString());
    }
    return _fromJSON(entries[0]);
  }

  static Future<void> create(Map<String, dynamic> values, int vault) async {
    final db = await DbFactory.database;
    int position = await DatabaseEntry.nextPosition(db, vault);
    EntryType type = values[jsonType];
    int typeId = _typeId[type];
    Map<String, dynamic> data = _toJsonData(values);

    var encryptedData = await KeychainHelper.encryptJson(data);
    await DatabaseEntry.create(db, typeId, encryptedData, position, vault);
  }

  static Future<List<Entry>> getEntries(int vault, int fromPosition) async {
    final db = await DbFactory.database;
    List<Map<String, dynamic>> entries = await DatabaseEntry.getEntries(db, vault, fromPosition: fromPosition);
    if (entries.isNotEmpty) {
      var fEntries = entries.map((e) => _fromJSON(e)).toList();
      return await Future.wait(fEntries);
    }
    return [];
  }

  static Future<Entry> getEntry(int position, int vault) async {
    final db = await DbFactory.database;
    Map<String, dynamic> entry = await DatabaseEntry.getEntry(db, position, vault);
    if (entry == null) return null;
    return _fromJSON(entry);
  }

  static Map<String, dynamic> _toJsonData(Map<String, dynamic> values) {
    EntryType type = values[jsonType];
    Map<String, dynamic> data = {
      jsonName: values[jsonName] as String,
      jsonSecret: values[jsonSecret] as String,
    };

    if (type == EntryType.totp) {
      data[jsonTimeStep] = values[jsonTimeStep] ?? 30;
    } else {
      throw ArgumentError("SecretFactory does not produce " + EntryTypeDesc[type]);
    }
    return data;
  }

  static Future<Entry> _fromJSON(Map<String, dynamic> map) async {
    print("Entry from map: " + map.toString());
    EntryType type = _typeId.keys.firstWhere(
      (k) => _typeId[k] == map[DatabaseEntry.columnType]);

    int id = map[DatabaseEntry.columnId];
    int position = map[DatabaseEntry.columnPosition];
    int vault = map[DatabaseEntry.columnVault];

    Map data = await KeychainHelper.decryptJson(map[DatabaseEntry.columnData]);
    var name = data[jsonName];
    if (name == null) name = "Decryption error";
    final secret = data[jsonSecret];

    if (type == EntryType.totp) {
      final timeStep = data[jsonTimeStep];
      return TOTP(id, name, secret, position, vault, timeStep);
    } else if (type == EntryType.vault) {
      return Vault(id, name, position, vault);
    }
    throw StateError("Unknown type " + type.toString());
  }
}