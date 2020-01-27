import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/model/entry/entry_base.dart';

class EntryImpl extends EntryBase {
  EntryImpl(EntryType type, int id, String name, int position, int vault) :
    super(type, id, name, position, vault);
}

void main() {
  test('Implements required interfaces', () async {
    final vault = EntryImpl(EntryType.vault, 2, "name", 1, 1);

    expect(vault, isA<Entry>());
  });

  test('Returns correct values', () async {
    final vault = EntryImpl(EntryType.vault, 88, "name", 85, 53);

    expect(vault.type, equals(EntryType.vault));
    expect(vault.id, equals(88));
    expect(vault.name, equals("name"));
    expect(vault.position, equals(85));
    expect(vault.vault, equals(53));
  });
}
