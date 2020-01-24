import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';

import 'package:free_authenticator/widget/entry_list.dart';
import 'package:free_authenticator/widget/reorderable_list.dart';
import 'package:mockito/mockito.dart';

import '../mock/mock_dialog.dart';
import '../mock/mock_store.dart';
import '../parentWidget/main_test_widget.dart';

const int PUMP_DURATION_MS = 10;

class MockDialogs extends Mock implements Dialogs {}

void main() {
  testWidgets('Show given title', (WidgetTester tester) async {
    final store = MockStore();
    
    await tester.pumpWidget(MainTestWidget(EntryList(title: 'title'), store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text('title'), findsOneWidget);
  });

  testWidgets('List entry', (WidgetTester tester) async {
    final store = MockStore(provision: 1);
    final Entry entry = await store.getEntry(2);
    
    await tester.pumpWidget(MainTestWidget(EntryList(title: ''), store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text(entry.name), findsOneWidget);
  });

  testWidgets('Created entry is displayed', (WidgetTester tester) async {
    final store = MockStore();
    final dialogs = MockDialogs();
    final String createdEntryName = "created entry";

    when(dialogs.createEntryDialog(key: anyNamed("key"), onCreate: anyNamed("onCreate")))
      .thenAnswer((invocation) {
        final Function(int) onCreate = invocation.namedArguments[Symbol("onCreate")];
        return MockDialog(onClose: () async {
          int id = await store.createEntry(EntryType.vault, VaultEntry.rootId, name: createdEntryName);
          onCreate(id);
        });
      });
    
    await tester.pumpWidget(MainTestWidget(EntryList(title: '', dialogs: dialogs), store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text(createdEntryName), findsNothing, reason: "Entry found before creation");

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    verify(dialogs.createEntryDialog(key: anyNamed("key"), onCreate: anyNamed("onCreate")))
      .called(1);

    await tester.tap(find.text(MockDialog.CLOSE_DIALOG_TEXT));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text(createdEntryName), findsOneWidget, reason: "Entry not found after creation");
  });

   testWidgets('Edited entry is updated', (WidgetTester tester) async {
    final store = MockStore(provision: 1);
    final dialogs = MockDialogs();
    final Entry entry = await store.getEntry(2);
    final String startName = entry.name;
    final String afterName = "after test entry";

    when(dialogs.editEntryDialog(key: anyNamed("key"), entry: entry, onEdit: anyNamed("onEdit")))
      .thenAnswer((invocation) {
        final Function(int) onCreate = invocation.namedArguments[Symbol("onEdit")];
        return MockDialog(onClose: () async {
          await store.updateEntry(entry, name: afterName);
          onCreate(entry.id);
        });
      });
    
    await tester.pumpWidget(MainTestWidget(EntryList(title: '', dialogs: dialogs), store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text(startName), findsOneWidget, reason: "Start entry missing before edit");
    expect(find.text(afterName), findsNothing, reason: "End entry present before edit");

    await tester.longPress(find.text(startName));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pump();

    verify(dialogs.editEntryDialog(key: anyNamed("key"), entry: entry, onEdit: anyNamed("onEdit")))
      .called(1);

    await tester.tap(find.text(MockDialog.CLOSE_DIALOG_TEXT));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text(startName), findsNothing, reason: "Start entry present after edit");
    expect(find.text(afterName), findsOneWidget, reason: "End entry missing after edit");
  });

  testWidgets('Deleted entry is removed', (WidgetTester tester) async {
    final store = MockStore(provision: 1);
    final dialogs = MockDialogs();
    final Entry entry = await store.getEntry(2);

    when(dialogs.deleteEntryDialog(key: anyNamed("key"), entry: entry, onDelete: anyNamed("onDelete")))
      .thenAnswer((invocation) {
        final Function(int) onDelete = invocation.namedArguments[Symbol("onDelete")];
        return MockDialog(onClose: () { onDelete(entry.id); });
      });
    
    await tester.pumpWidget(MainTestWidget(EntryList(title: '', dialogs: dialogs), store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text(entry.name), findsOneWidget, reason: "Missing entry to delete");

    await tester.longPress(find.text(entry.name));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    verify(dialogs.deleteEntryDialog(key: anyNamed("key"), entry: entry, onDelete: anyNamed("onDelete")))
      .called(1);

    await tester.tap(find.text(MockDialog.CLOSE_DIALOG_TEXT));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text('test entry'), findsNothing, reason: "Entry displayed after deletion");
  });

  testWidgets('Moved entry changes position', (WidgetTester tester) async {
    final store = MockStore(provision: 2);
    final dialogs = MockDialogs();
    final Entry entry1 = await store.getEntry(2);
    final Entry entry2 = await store.getEntry(3);
    final Finder finder1 = find.widgetWithText(ReorderableItemSelect, entry1.name);
    final Finder finder2 = find.widgetWithText(ReorderableItemSelect, entry2.name);
    
    await tester.pumpWidget(MainTestWidget(EntryList(title: '', dialogs: dialogs), store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    final Offset offset1 = tester.getCenter(finder1);
    final Offset offset2 = tester.getCenter(finder2);

    expect(tester.getCenter(finder1), offsetMoreOrLessEquals(offset1), reason: "Entry is not in initial position");

    await tester.longPress(finder1);
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));
    await tester.drag(finder1, Offset(0.0, 100.0));
    await tester.pumpAndSettle(Duration(milliseconds: PUMP_DURATION_MS));
    await tester.pumpAndSettle(Duration(milliseconds: PUMP_DURATION_MS));

    final Entry entryAfter1 = await store.getEntry(2);
    expect(tester.getCenter(finder1), offsetMoreOrLessEquals(offset2), reason: "Entry not in next position after dragging");
    expect(entryAfter1.position, equals(entry2.position), reason: "Entry not in saved to next position after dragging");
  });

  testWidgets('Vault opening and closing', (WidgetTester tester) async {
    final store = MockStore(provision: 1);
    final dialogs = MockDialogs();
    final Entry vault = await store.getEntry(2);
    final Entry entry = await store.getEntry(
      await store.createEntry(EntryType.vault, vault.id, name: "Vaulted entry")
    );
    
    await tester.pumpWidget(MainTestWidget(EntryList(title: '', dialogs: dialogs), store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text(entry.name), findsNothing, reason: "Vaulted entry visible in main vault");

    await tester.tap(find.text(vault.name));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text(entry.name), findsOneWidget, reason: "Vaulted entry not visible in test vault");

    await tester.pageBack();
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS*2));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS*2));

    expect(find.text(entry.name), findsNothing, reason: "Vaulted entry visible in main vault");
    expect(find.text(vault.name), findsOneWidget, reason: "Test vault not visible in main vault");
  });
}
