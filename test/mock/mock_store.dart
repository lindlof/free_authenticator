import 'dart:math';

import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/model/entry/totp.dart';
import 'package:free_authenticator/model/entry/vault.dart';
import 'package:free_authenticator/widget/store.dart';

class MockStore implements Store {
  static const String ROOT_VAULT_NAME = "Main Vault";
  final db = Map<int, Entry>();

  MockStore({int provision: 0}) {
    db[Vault.rootId] = Vault(Vault.rootId, ROOT_VAULT_NAME, 1, null);
    for (int i = 0; i < provision; i++) {
      createEntry(EntryType.vault, Vault.rootId, name: "test entry ${i+1}");
    }
  }

  @override
  Future<Entry> getEntry(int id) async => db[id];

  @override
  Future<List<Entry>> getEntries({ EntryType type, int vault, int limit, int offset: 0 }) async {
    var entryIter = db.values;
    if (vault != null) entryIter = entryIter.where((e) => e.vault == vault);
    if (type != null) entryIter = entryIter.where((e) => e.type == type);
    var entryList = entryIter.toList();
    entryList.sort((a, b) => a.position - b.position);

    if (limit == null) limit = db.length-1 - offset;
    else if (offset + limit > entryList.length) limit = entryList.length - offset;
    return entryList.getRange(offset, offset + limit).toList();
  }

  @override
  Future<int> createEntry(EntryType type, int vault, {String name, String secret, int timestep}) async {
    int id = db.values.map((e) => e.id).reduce(max) + 1;
    int lastPosition = 0;
    db.values.forEach((e) => lastPosition = (e.vault == vault && e.position > lastPosition) ? e.position : lastPosition);
    int position = lastPosition + 1;
    db[id] = _dataToEntry(type, id, position: position, vault: vault, name: name, secret: secret, timeStep: timestep);
    return id;
  }

  @override
  Future<void> updateEntry(Entry entry, {int vault, String name, String secret, int timestep}) async {
    db[entry.id] = _dataToEntry(entry.type, entry.id, entry: entry, vault: vault, name: name, secret: secret, timeStep: timestep);
  }

  @override
  Future<void> deleteEntry(int id) async => db.remove(id);

  @override
  Future<void> reorderEntry(int id, int position) async {
    Entry entry = db[id];
    int fromPosition, toPosition;
    bool add;
    
    if (position < entry.position) {
      // Entry was reordered up
      fromPosition = position;
      toPosition = entry.position-1;
      add = true;
    } else {
      // Entry was reordered down
      fromPosition = entry.position+1;
      toPosition = position;
      add = false;
    }

    for (Entry e in db.values) {
      if (e.position >= fromPosition && e.position <= toPosition) {
        db[e.id] = _dataToEntry(e.type, e.id, position: add ? e.position+1 : e.position-1);
      }
    }
  }

  @override
  Future<int> getOrCreateVault(String name) async {
    Entry gotEntry = db.values.singleWhere((e) => e.type == EntryType.vault && e.name == name);
    if (gotEntry != null) return gotEntry.id;
    return createEntry(EntryType.vault, Vault.rootId, name: name);
  }

  Entry _dataToEntry(EntryType type, int id, {Entry entry, String name, int position, int vault, String secret, int timeStep}) {
    String nameVal = _val("name", name, entry?.name);
    int positionVal = _val("position", position, entry?.position);
    int vaultVal = _val("vault", vault, entry?.vault);

    if (type == EntryType.totp) {
      TOTP totp = entry as TOTP;
      String secretVal = _val("secret", secret, totp?.secret);
      int timeStepVal = _val("timestep", timeStep, totp?.timeStep);
      return TOTP(id, nameVal, secretVal, positionVal, vaultVal, timeStepVal);
    } else if (type == EntryType.vault) {
      return Vault(id, nameVal, positionVal, vaultVal);
    }
    throw("Unhandled type " + type.toString());
  }

  static _val(String field, dynamic value1, dynamic value2) {
    if (value1 == null && value2 == null) throw ArgumentError("Missing field $field");
    return value1 != null ? value1 : value2;
  }
}