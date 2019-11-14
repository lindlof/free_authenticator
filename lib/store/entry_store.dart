import 'package:free_authenticator/database/database_entry.dart';
import 'package:free_authenticator/keychain/keychain_helper.dart';
import 'package:free_authenticator/model/interface/entry.dart';
import 'package:free_authenticator/model/interface/entry_type.dart';
import 'package:free_authenticator/store/db_factory.dart';
import 'package:free_authenticator/store/entry_marshal.dart';

class EntryStore {
  static Future<Entry> get(int id) async {
    final db = await DbFactory.database;
    List<Map<String, dynamic>> entries = await DatabaseEntry.get(db, [id]);
    if (entries.isEmpty) {
      throw StateError("No entries with id " + id.toString());
    }
    return EntryMarshal.unmarshal(entries[0]);
  }

  static Future<int> create(
      EntryType type, int vault,
      {String name, String secret, int timestep}
    ) async {
    final db = await DbFactory.database;
    int position = await DatabaseEntry.nextPosition(db, vault);
    Map<String, dynamic> data = EntryMarshal.marshalData(type, name: name, secret: secret, timestep: timestep);
    String encryptedData = await KeychainHelper.encryptJson(data);

    Map<String, dynamic> map = EntryMarshal.marshal(type, position, vault, encryptedData);
    int id = await DatabaseEntry.create(db, map);
    return id;
  }

  static Future<List<Entry>> getEntries(int vault, int fromPosition) async {
    final db = await DbFactory.database;
    List<Map<String, dynamic>> entries = await DatabaseEntry.getEntries(db, vault, fromPosition: fromPosition);
    if (entries.isNotEmpty) {
      var fEntries = entries.map((e) => EntryMarshal.unmarshal(e)).toList();
      return await Future.wait(fEntries);
    }
    return [];
  }

  static Future<Entry> getEntryInPosition(int position, int vault) async {
    final db = await DbFactory.database;
    Map<String, dynamic> entry = await DatabaseEntry.getEntry(db, position, vault);
    if (entry == null) return null;
    return EntryMarshal.unmarshal(entry);
  }

  static Future<void> update(
      Entry entry,
      {int position, int vault, String name, String secret, int timestep}
    ) async {
    final db = await DbFactory.database;
    Map<String, dynamic> data = EntryMarshal.marshalData(
      entry.type,
      name: name, secret: secret, timestep: timestep, entry: entry
    );
    var encryptedData = await KeychainHelper.encryptJson(data);

    if (vault != null && vault != entry.vault) {
      position = await DatabaseEntry.nextPosition(db, vault);
    }

    Map<String, dynamic> map = EntryMarshal.marshal(entry.type, position, vault, encryptedData, entry: entry);
    await DatabaseEntry.update(db, entry.id, map);
  }
}
