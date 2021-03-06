import 'package:free_authenticator/database/database_provider.dart';
import 'package:free_authenticator/keychain/keychain_provider.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/widget/store.dart';

import 'entry_store.dart';
import 'vault_store.dart';

class SqlStore implements Store {
  EntryStore _entryStore;
  VaultStore _vaultStore;

  SqlStore() {
    final keychainProvider = KeychainProvider();
    final dbProvider = DatabaseProvider(keychainProvider);
    this._entryStore = EntryStore(dbProvider, keychainProvider);
    this._vaultStore = VaultStore(dbProvider, keychainProvider);
  }

  @override
  Future<Entry> getEntry(int id) => _entryStore.get(id);

  @override
  Future<List<Entry>> getEntries({ EntryType type, int vault, int limit, int offset }) =>
    _entryStore.getEntries(type: type, vault: vault, limit: limit, offset: offset);

  @override
  Future<int> createEntry(EntryType type, int vault, {String name, String secret, int timestep}) =>
    _entryStore.create(type, vault, name: name, secret: secret, timestep: timestep);
  
  @override
  Future<void> updateEntry(Entry entry, {int vault, String name, String secret, int timestep}) =>
    _entryStore.update(entry, vault: vault, name: name, secret: secret, timestep: timestep);
  
  @override
  Future<void> deleteEntry(int id) => _entryStore.delete(id);
  
  @override
  Future<void> reorderEntry(int id, int position) => _entryStore.reorder(id, position);
  
  @override
  Future<int> getOrCreateVault(String name) => _vaultStore.getOrCreate(name);
  
}
