import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/model/entry/totp.dart';
import 'package:free_authenticator/widget/dependencies.dart';
import 'package:free_authenticator/widget/dialog/create_entry_dialog.dart';

import 'package:free_authenticator/widget/entry_list.dart';
import 'package:free_authenticator/widget/store.dart';
import 'package:mockito/mockito.dart';

import '../../mock/mock_store.dart';

const int PUMP_DURATION_MS = 10;

class MockDialogs extends Mock implements Dialogs {}

void main() {
  testWidgets('Show title', (WidgetTester tester) async {
    final store = MockStore();

    await tester.pumpWidget(buildTestableWidget(CreateEntryDialog(), store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text('Enter a secret'), findsOneWidget);
  });

  testWidgets('Create TOTP entry', (WidgetTester tester) async {
    final store = MockStore();
    final name = "Hello entry";
    final secret = "123456";

    await tester.pumpWidget(buildTestableWidget(CreateEntryDialog(), store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    var initialEntry;
    try { initialEntry = await store.getEntry(2); }
    catch (e) { initialEntry = e; }
    expect(initialEntry, isStateError, reason: "Entry id 2 already exists");

    await tester.enterText(find.byKey(ValueKey("nameInput")), name);
    await tester.enterText(find.byKey(ValueKey("secretInput")), secret);
    await tester.tap(find.text("Ok"));

    final newEntry = await store.getEntry(2);
    expect(newEntry, isNotNull, reason: "Created entry not in store");
    expect(newEntry, isA<TOTP>());

    final totp = newEntry as TOTP;
    expect(totp.name, equals(name));
    expect(totp.type, equals(EntryType.totp));
    expect(totp.vault, equals(VaultEntry.rootId));
    expect(totp.secret, equals(secret));
  });
}

Widget buildTestableWidget(Widget child, Store store) {
  return Dependencies(
    child : MaterialApp(home: child),
    store: store,
  );
}
