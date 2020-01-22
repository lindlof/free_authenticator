import '../api/entry.dart';
import 'entry_base.dart';
import '../api/entry_type.dart';

class Vault extends EntryBase implements VaultEntry {
  Vault(int id, String name, int position, int vault) :
    super(EntryType.vault, id, name, position, vault);

  int get id => super.id;
  String get name => super.name;
  int get position => super.position;
  int get vault => super.vault;
}