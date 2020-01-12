import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/model/entry/vault.dart';
import 'package:free_authenticator/widget/dependencies.dart';

import 'package:free_authenticator/widget/entry_list.dart';
import 'package:free_authenticator/widget/store.dart';
import 'package:mockito/mockito.dart';

import '../mock/mock_dialog.dart';
import '../mock/mock_store.dart';

class MockDialogs extends Mock implements Dialogs {}

void main() {
  testWidgets('Show given title', (WidgetTester tester) async {
    final store = MockStore();
    
    await tester.pumpWidget(buildTestableWidget(EntryList(title: 'title'), store));
    await tester.pump(Duration(milliseconds:400));

    expect(find.text('title'), findsOneWidget);
  });

  testWidgets('List entry', (WidgetTester tester) async {
    final store = MockStore(provision: 1);
    final Entry entry = await store.getEntry(2);
    
    await tester.pumpWidget(buildTestableWidget(EntryList(title: ''), store));
    await tester.pump(Duration(milliseconds:400));

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
          print("hello");
          int id = await store.createEntry(EntryType.vault, Vault.rootId, name: createdEntryName);
          onCreate(id);
        });
      });
    
    await tester.pumpWidget(buildTestableWidget(EntryList(title: '', dialogs: dialogs), store));
    await tester.pump(Duration(milliseconds:400));

    expect(find.text(createdEntryName), findsNothing, reason: "Entry found before creation");

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    verify(dialogs.createEntryDialog(key: anyNamed("key"), onCreate: anyNamed("onCreate")))
      .called(1);

    await tester.tap(find.text(MockDialog.CLOSE_DIALOG_TEXT));
    await tester.pump(Duration(milliseconds:400));

    expect(find.text(createdEntryName), findsOneWidget, reason: "Entry not found after creation");
  });

   testWidgets('Edit entry is updated', (WidgetTester tester) async {
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
    
    await tester.pumpWidget(buildTestableWidget(EntryList(title: '', dialogs: dialogs), store));
    await tester.pump(Duration(milliseconds:400));

    expect(find.text(startName), findsOneWidget, reason: "Start entry missing before edit");
    expect(find.text(afterName), findsNothing, reason: "End entry present before edit");

    await tester.longPress(find.text(startName));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pump();

    verify(dialogs.editEntryDialog(key: anyNamed("key"), entry: entry, onEdit: anyNamed("onEdit")))
      .called(1);

    await tester.tap(find.text(MockDialog.CLOSE_DIALOG_TEXT));
    await tester.pump(Duration(milliseconds:400));

    expect(find.text(startName), findsNothing, reason: "Start entry present after edit");
    expect(find.text(afterName), findsOneWidget, reason: "End entry missing after edit");
  });

  testWidgets('Entry not displayed after deletion', (WidgetTester tester) async {
    final store = MockStore(provision: 1);
    final dialogs = MockDialogs();
    final Entry entry = await store.getEntry(2);

    when(dialogs.deleteEntryDialog(key: anyNamed("key"), entry: entry, onDelete: anyNamed("onDelete")))
      .thenAnswer((invocation) {
        final Function(int) onDelete = invocation.namedArguments[Symbol("onDelete")];
        return MockDialog(onClose: () { onDelete(entry.id); });
      });
    
    await tester.pumpWidget(buildTestableWidget(EntryList(title: '', dialogs: dialogs), store));
    await tester.pump(Duration(milliseconds:400));

    expect(find.text(entry.name), findsOneWidget, reason: "Missing entry to delete");

    await tester.longPress(find.text(entry.name));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();

    verify(dialogs.deleteEntryDialog(key: anyNamed("key"), entry: entry, onDelete: anyNamed("onDelete")))
      .called(1);

    await tester.tap(find.text(MockDialog.CLOSE_DIALOG_TEXT));
    await tester.pump(Duration(milliseconds:400));

    expect(find.text('test entry'), findsNothing, reason: "Entry displayed after deletion");
  });
}

Widget buildTestableWidget(Widget child, Store store) {
  var injector = Dependencies(
    child : child,
    store: store,
  );
  return MaterialApp(home: injector);
}
