import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/widget/dialog/delete_entry_dialog.dart';

import 'package:free_authenticator/widget/entry_list.dart';
import 'package:mockito/mockito.dart';

import '../../mock/mock_store.dart';
import '../../parentWidget/main_test_widget.dart';

const int PUMP_DURATION_MS = 10;

class MockDialogs extends Mock implements Dialogs {}

void main() {
  testWidgets('Delete entry', (WidgetTester tester) async {
    final store = MockStore();
    final name = "Redundant vault";
    final secret = "123456";

    await store.createEntry(EntryType.totp, VaultEntry.rootId, name: name, secret: secret, timestep: 30);
    final Entry entry = await store.getEntry(2);

    expect(entry, isNotNull, reason: "Entry id 2 missing before deletion");

    await tester.pumpWidget(MainTestWidget(DeleteEntryDialog(entry: entry), store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    // Make sure cancel reads cancel
    await tester.tap(find.widgetWithText(FlatButton, "Delete"));

    var entryAfter;
    try { entryAfter = await store.getEntry(2); }
    catch (e) { }
    expect(entryAfter, isNull, reason: "Entry id 2 exists after deletion");
  });

  testWidgets('Cancel delete', (WidgetTester tester) async {
    final store = MockStore();
    final name = "Important vault";
    final secret = "123456";

    await store.createEntry(EntryType.totp, VaultEntry.rootId, name: name, secret: secret, timestep: 30);
    final Entry entry = await store.getEntry(2);

    await tester.pumpWidget(MainTestWidget(DeleteEntryDialog(entry: entry), store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    // Make sure cancel reads cancel
    await tester.tap(find.widgetWithText(FlatButton, "Cancel"));

    var entryAfter;
    try { entryAfter = await store.getEntry(2); }
    catch (e) { }
    expect(entryAfter, isNotNull, reason: "Entry id 2 missing after canceling deletion");
  });

  testWidgets('Delete entry callback', (WidgetTester tester) async {
    final store = MockStore();
    final name = "Redundant vault";
    final secret = "123456";
    var callbackCalled = false;

    await store.createEntry(EntryType.totp, VaultEntry.rootId, name: name, secret: secret, timestep: 30);
    final Entry entry = await store.getEntry(2);

    await tester.pumpWidget(MainTestWidget(
      DeleteEntryDialog(entry: entry, onDelete: (_) {
        callbackCalled = true;
        return Future.value();
      }),
      store: store
    ));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    await tester.tap(find.widgetWithText(FlatButton, "Delete"));

    expect(callbackCalled, isTrue, reason: "Callback wasn't called on delete");
  });
}
