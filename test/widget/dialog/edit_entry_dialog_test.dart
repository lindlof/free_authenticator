import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/widget/dialog/edit_entry_dialog.dart';

import 'package:free_authenticator/widget/entry_list.dart';
import 'package:mockito/mockito.dart';

import '../../mock/mock_store.dart';
import '../../parentWidget/main_test_widget.dart';

const int PUMP_DURATION_MS = 10;

class MockDialogs extends Mock implements Dialogs {}

void main() {
  testWidgets('Edit entry name', (WidgetTester tester) async {
    final store = MockStore();
    final nameStart = "Start name";
    final nameAfter = "Name after";
    final secret = "123456";

    await store.createEntry(EntryType.totp, VaultEntry.rootId, name: nameStart, secret: secret, timestep: 30);
    final Entry entry = await store.getEntry(2);

    await tester.pumpWidget(MainTestWidget(EditEntryDialog(entry: entry), store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    await tester.enterText(find.byKey(ValueKey("nameInput")), nameAfter);
    await tester.tap(find.widgetWithText(FlatButton, "Ok"));

    var entryAfter = await store.getEntry(2);
    expect(entryAfter.name, equals(nameAfter), reason: "Entry name not changed after edit");
  });

  testWidgets('Edit entry vault', (WidgetTester tester) async {
    final store = MockStore();
    final name = "Best password";
    final vault = "New vault";
    final secret = "123456";

    await store.createEntry(EntryType.totp, VaultEntry.rootId, name: name, secret: secret, timestep: 30);
    final Entry entry = await store.getEntry(2);
    expect(entry.vault, equals(VaultEntry.rootId), reason: "Entry not starting in root vault");

    await tester.pumpWidget(MainTestWidget(EditEntryDialog(entry: entry), store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    await tester.enterText(find.byKey(ValueKey("vaultInput")), vault);
    await tester.tap(find.widgetWithText(FlatButton, "Ok"));

    var entryAfter = await store.getEntry(2);
    expect(entryAfter.vault, equals(3), reason: "Entry not in new vault");
  });

  testWidgets('Cannot put vault in vault', (WidgetTester tester) async {
    final store = MockStore();
    final name = "Vaulting";

    await store.createEntry(EntryType.vault, VaultEntry.rootId, name: name);
    final Entry entry = await store.getEntry(2);

    await tester.pumpWidget(MainTestWidget(EditEntryDialog(entry: entry), store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.byKey(ValueKey("vaultInput")), findsNothing, reason: "Vault input visible");
  });

  testWidgets('Edit entry callback', (WidgetTester tester) async {
    final store = MockStore();
    var callbackCalled = false;

    await store.createEntry(EntryType.vault, VaultEntry.rootId, name: "Abc");
    final Entry entry = await store.getEntry(2);

    await tester.pumpWidget(MainTestWidget(
      EditEntryDialog(
        entry: entry,
        onEdit: (_) {
          callbackCalled = true;
          return Future.value();
        }),
      store: store
    ));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));
    await tester.tap(find.text("Ok"));

    expect(callbackCalled, isTrue, reason: "Callback wasn't called on edit");
  });
}
