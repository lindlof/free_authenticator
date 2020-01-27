import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/model/entry/vault.dart';

void main() {
  test('Implements required interfaces', () async {
    final vault = Vault(2, "Uber vault", 1, 1);

    expect(vault, isA<VaultEntry>());
    expect(vault, isA<Entry>());
  });

  test('Returns correct values', () async {
    final vault = Vault(44, "Uber vault", 74, 502);

    expect(vault.type, equals(EntryType.vault));
    expect(vault.id, equals(44));
    expect(vault.name, equals("Uber vault"));
    expect(vault.position, equals(74));
    expect(vault.vault, equals(502));
  });
}
