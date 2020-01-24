import 'package:free_authenticator/database/database_entry.dart';
import 'package:free_authenticator/keychain/keychain_helper.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/sql_store/db_provider.dart';
import 'package:sqflite/sqlite_api.dart';

import 'entry_marshal.dart';

class EntryStore {
  DbProvider dbProvider;

  EntryStore(DbProvider dbProvider) {
    this.dbProvider = dbProvider;
  }

  Future<Entry> get(int id) async {
    Database db = await dbProvider.database;
    List<Map<String, dynamic>> entries = await DatabaseEntry.get(db, [id]);
    if (entries.isEmpty) {
      throw StateError("No entries with id " + id.toString());
    }
    return EntryMarshal.unmarshal(entries[0]);
  }

  Future<int> create(
      EntryType type, int vault,
      {String name, String secret, int timestep}
    ) async {
    Database db = await dbProvider.database;
    int position = await DatabaseEntry.nextPosition(db, vault);
    Map<String, dynamic> data = EntryMarshal.marshalData(type, name: name, secret: secret, timestep: timestep);
    String encryptedData = await KeychainHelper.encryptJson(data);

    Map<String, dynamic> map = EntryMarshal.marshal(type, encryptedData, position: position, vault: vault);
    int id = await DatabaseEntry.create(db, map);
    return id;
  }

  Future<List<Entry>> getEntries({ EntryType type, int vault, int limit, int offset }) async {
    Database db = await dbProvider.database;
    List<Entry> rEntries = [];
    List<Map<String, dynamic>> entries = await DatabaseEntry.getEntries(
      db,
      type: type == null ? null : EntryMarshal.typeId[type],
      vault: vault,
      limit: limit,
      offset: offset
    );
    if (entries.isNotEmpty) {
      var fEntries = entries.map((e) => EntryMarshal.unmarshal(e)).toList(growable: true);
      rEntries.addAll(await Future.wait(fEntries));
    }
    return rEntries;
  }

  Future<void> update(
      Entry entry,
      {int position, int vault, String name, String secret, int timestep}
    ) async {
    Database db = await dbProvider.database;
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

  Future<void> delete(int id) async {
    Database db = await dbProvider.database;
    await DatabaseEntry.delete(db, id);
  }

  Future<void> reorder(int id, int position) async {
    Database db = await dbProvider.database;
    final entry = await this.get(id);
    if (position == entry.position) return;

    Map<String, dynamic> data = EntryMarshal.marshalData(entry.type, entry: entry);
    var encryptedData = await KeychainHelper.encryptJson(data);
    Map<String, dynamic> map = EntryMarshal.marshal(
      entry.type, encryptedData, position: position, entry: entry);

    await (db).transaction((txn) async {
      if (position < entry.position) {
        // Entry was reordered up
        await DatabaseEntry.entryUpdatePositions(txn, entry.vault, position, entry.position-1, true);
        await DatabaseEntry.update(txn, id, map);
      } else {
        // Entry was reordered down
        await DatabaseEntry.entryUpdatePositions(txn, entry.vault, entry.position+1, position, false);
        await DatabaseEntry.update(txn, id, map);
      }
    });
  }
}
