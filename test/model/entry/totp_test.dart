import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/model/entry/totp.dart';

void main() {
  test('Implements required interfaces', () async {
    final vault = TOTP(2, "Uber secret", "123456", 1, 1, 30);

    expect(vault, isA<TimedPasswordEntry>());
    expect(vault, isA<Entry>());
  });

  test('Returns correct values', () async {
    final vault = TOTP(88, "Uber secret", "123456", 85, 53, 468);

    expect(vault.type, equals(EntryType.totp));
    expect(vault.id, equals(88));
    expect(vault.name, equals("Uber secret"));
    expect(vault.position, equals(85));
    expect(vault.vault, equals(53));
    expect(vault.secret, equals("123456"));
    expect(vault.timeStep, equals(468));
    expect(vault.genPassword(), isNotEmpty);
  });
}
