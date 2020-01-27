import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/api/entry_type.dart';

void main() {
  test('EntryTypeName contains all types', () async {
    for (var type in EntryType.values) {
      expect(EntryTypeName, contains(type));
    }
  });

  test('EntryTypeDesc contains all types', () async {
    for (var type in EntryType.values) {
      expect(EntryTypeDesc, contains(type));
    }
  });
}
