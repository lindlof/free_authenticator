import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/api/entry_type.dart';

void main() {
  testWidgets('EntryTypeName contains all types', (WidgetTester tester) async {
    for (var type in EntryType.values) {
      expect(EntryTypeName, contains(type));
    }
  });

  testWidgets('EntryTypeDesc contains all types', (WidgetTester tester) async {
    for (var type in EntryType.values) {
      expect(EntryTypeDesc, contains(type));
    }
  });
}
