import 'package:free_authenticator/model/interface/entry.dart';
import 'package:free_authenticator/model/interface/entry_type.dart';

abstract class Store {
  Future<Entry> getEntry(int id);
  Future<List<Entry>> getEntries({ EntryType type, int vault, int limit, int offset });
  Future<int> createEntry(EntryType type, int vault, {String name, String secret, int timestep});
  Future<void> updateEntry(Entry entry, {int vault, String name, String secret, int timestep});
  Future<void> deleteEntry(int id);
  Future<void> reorderEntry(int id, int position);
  Future<int> getOrCreateVault(String name);
}
