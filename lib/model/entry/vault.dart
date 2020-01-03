import '../interface/entry.dart';
import 'entry_base.dart';
import '../interface/entry_type.dart';

class Vault implements Entry, VaultEntry {
  static final rootId = 1;
  
  EntryType type = EntryType.vault;
  int timeStep;
  EntryBase entry;
  
  Vault(int id, String name, int position, int vault) {
    this.entry = EntryBase(id, name, position, vault);
    this.timeStep = (timeStep == null) ? 30 : timeStep;
  }

  int get id => this.entry.id;
  String get name => this.entry.name;
  int get position => this.entry.position;
  int get vault => this.entry.vault;
  Function setPosition(position, vault) => this.entry.setPosition;
}