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

    Map<String, dynamic> map = EntryMarshal.marshal(type, encryptedData, position: position, vault: vault);
    int id = await DatabaseEntry.create(db, map);
    return id;
  }

  static Future<List<Entry>> getEntries(int vault, { int limit, int offset }) async {
    final db = await DbFactory.database;
    List<Entry> rEntries = [];
    List<Map<String, dynamic>> entries = await DatabaseEntry.getEntries(db, vault, limit: limit, offset: offset);
    if (entries.isNotEmpty) {
      var fEntries = entries.map((e) => EntryMarshal.unmarshal(e)).toList(growable: true);
      rEntries.addAll(await Future.wait(fEntries));
    }
    return rEntries;
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

    Map<String, dynamic> map = EntryMarshal.marshal(
      entry.type, encryptedData, position: position, vault: vault, entry: entry);
    await DatabaseEntry.update(db, entry.id, map);
  }

  static Future<void> reorder(int id, int position) async {
    final entry = await EntryStore.get(id);
    if (position == entry.position) return;

    Map<String, dynamic> data = EntryMarshal.marshalData(entry.type, entry: entry);
    var encryptedData = await KeychainHelper.encryptJson(data);
    Map<String, dynamic> mapFreePos = EntryMarshal.marshal(
      entry.type, encryptedData, position: -1, entry: entry);
    Map<String, dynamic> map = EntryMarshal.marshal(
      entry.type, encryptedData, position: position, entry: entry);

    await (await DbFactory.database).transaction((txn) async {
      if (position < entry.position) {
        // Entry was reordered up
        DatabaseEntry.update(txn, id, mapFreePos);
        DatabaseEntry.entryUpdatePositions(txn, entry.vault, position, entry.position-1, true);
        DatabaseEntry.update(txn, id, map);
      } else {
        // Entry was reordered down
        DatabaseEntry.update(txn, id, mapFreePos);
        DatabaseEntry.entryUpdatePositions(txn, entry.vault, entry.position+1, position, false);
        DatabaseEntry.update(txn, id, map);
      }
    });
  }
}
