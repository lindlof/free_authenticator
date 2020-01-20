import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/entry/totp.dart';
import 'package:free_authenticator/model/entry/vault.dart';
import 'package:free_authenticator/widget/dialog/create_entry_dialog.dart';

import 'package:free_authenticator/widget/entry_list.dart';
import 'package:mockito/mockito.dart';

import '../../mock/mock_store.dart';
import '../../parentWidget/dialog_opener.dart';
import '../../parentWidget/main_test_widget.dart';

const int PUMP_DURATION_MS = 10;

class MockDialogs extends Mock implements Dialogs {}

void main() {
  testWidgets('Show title', (WidgetTester tester) async {
    final store = MockStore();

    await tester.pumpWidget(MainTestWidget(CreateEntryDialog(), store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text('Enter a secret'), findsOneWidget);
  });

  testWidgets('Create TOTP entry', (WidgetTester tester) async {
    final store = MockStore();
    final name = "Hello entry";
    final secret = "123456";

    await tester.pumpWidget(MainTestWidget(CreateEntryDialog(), store: store));
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
    expect(totp.vault, equals(VaultEntry.rootId));
    expect(totp.secret, equals(secret));
  });

  testWidgets('Create entries in vault', (WidgetTester tester) async {
    final store = MockStore();
    final name1 = "Hello entry 1";
    final name2 = "Hello entry 2";
    final secret = "123456";
    final vaultName = "Hello vault";

    await tester.pumpWidget(MainTestWidget(DialogOpener(() => CreateEntryDialog()), store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));
    await tester.tap(DialogOpener.findOpenButton());
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    var initialEntry;
    try { initialEntry = await store.getEntry(2); }
    catch (e) { initialEntry = e; }
    expect(initialEntry, isStateError, reason: "Entry id 2 already exists");

    await tester.enterText(find.byKey(ValueKey("nameInput")), name1);
    await tester.enterText(find.byKey(ValueKey("secretInput")), secret);
    await tester.enterText(find.byKey(ValueKey("vaultInput")), vaultName);
    await tester.tap(find.text("Ok"));

    final vault = await store.getEntry(2);
    expect(vault, isNotNull, reason: "Created vault not in store");
    expect(vault, isA<Vault>());
    expect(vault.name, equals(vaultName));

    final entry1 = await store.getEntry(3);
    expect(entry1, isNotNull, reason: "Created entry not in store");
    expect(entry1.name, equals(name1));
    expect(entry1.vault, equals(vault.id));

    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));
    await tester.tap(DialogOpener.findOpenButton());
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    await tester.enterText(find.byKey(ValueKey("nameInput")), name2);
    await tester.enterText(find.byKey(ValueKey("secretInput")), secret);
    await tester.enterText(find.byKey(ValueKey("vaultInput")), vaultName);
    await tester.tap(find.text("Ok"));

    final entry2 = await store.getEntry(3);
    expect(entry2, isNotNull, reason: "Created entry not in store");
    expect(entry2.name, equals(name1));
    expect(entry2.vault, equals(vault.id));
  });

  testWidgets('Create entry callback', (WidgetTester tester) async {
    final store = MockStore();
    final name = "Hello entry";
    final secret = "123456";
    var callbackCalled = false;

    await tester.pumpWidget(MainTestWidget(
      CreateEntryDialog(onCreate: (_) {
        callbackCalled = true;
        return Future.value();
      }),
      store: store
    ));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    await tester.enterText(find.byKey(ValueKey("nameInput")), name);
    await tester.enterText(find.byKey(ValueKey("secretInput")), secret);
    await tester.tap(find.text("Ok"));

    expect(callbackCalled, isTrue, reason: "Callback wasn't called on create");
  });
}
