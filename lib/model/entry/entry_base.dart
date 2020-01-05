import '../api/entry.dart';
import '../api/entry_type.dart';

class EntryBase implements Entry {
  final EntryType type;
  final int id;
  final String name;
  final int position;
  final int vault;

  EntryBase(this.type, this.id, this.name, this.position, this.vault);
}
