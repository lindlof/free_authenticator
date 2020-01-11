import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/entry/vault.dart';
import 'package:free_authenticator/widget/dependencies.dart';

import 'package:free_authenticator/widget/entry_list.dart';
import 'package:free_authenticator/widget/store.dart';
import 'package:mockito/mockito.dart';

import '../mock/mock_dialog.dart';

class MockStore extends Mock implements Store {}
class MockDialogs extends Mock implements Dialogs {}

void main() {
  testWidgets('Show given title', (WidgetTester tester) async {
    final store = MockStore();

    when(store.getEntry(1))
        .thenAnswer((_) async => Vault(1, "", 0, 0));
    when(store.getEntries(vault: 1))
        .thenAnswer((_) async => []);
    
    await tester.pumpWidget(buildTestableWidget(EntryList(title: 'title'), store));
    await tester.pump(Duration(milliseconds:400));

    expect(find.text('title'), findsOneWidget);
  });

  testWidgets('List entry', (WidgetTester tester) async {
    final store = MockStore();

    when(store.getEntry(1))
        .thenAnswer((_) async => Vault(1, "", 0, 0));
    when(store.getEntries(vault: 1))
        .thenAnswer((_) async => [Vault(2, "test entry", 1, 1)]);
    
    await tester.pumpWidget(buildTestableWidget(EntryList(title: ''), store));
    await tester.pump(Duration(milliseconds:400));

    expect(find.text('test entry'), findsOneWidget);
  });

  testWidgets('Created entry is displayed', (WidgetTester tester) async {
    final store = MockStore();
    final dialogs = MockDialogs();
    final entry = Vault(2, "test entry", 1, 1);

    when(store.getEntry(1))
      .thenAnswer((_) async => Vault(1, "", 0, 0));
    when(store.getEntries(vault: 1))
      .thenAnswer((_) async => []);
    when(dialogs.createEntryDialog(key: anyNamed("key"), onCreate: anyNamed("onCreate")))
      .thenAnswer((invocation) {
        final Function(int) onCreate = invocation.namedArguments[Symbol("onCreate")];
        return MockDialog(onClose: () { onCreate(entry.id); });
      });
    
    await tester.pumpWidget(buildTestableWidget(EntryList(title: '', dialogs: dialogs), store));
    await tester.pump(Duration(milliseconds:400));

    expect(find.text(entry.name), findsNothing, reason: "Entry found before creation");

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    verify(dialogs.createEntryDialog(key: anyNamed("key"), onCreate: anyNamed("onCreate")))
      .called(1);
    when(store.getEntries(vault: 1))
      .thenAnswer((_) async => [entry]);

    await tester.tap(find.text(MockDialog.CLOSE_DIALOG_TEXT));
    await tester.pump(Duration(milliseconds:400));

    expect(find.text(entry.name), findsOneWidget, reason: "Entry not found after creation");
  });

   testWidgets('Edit entry is updated', (WidgetTester tester) async {
    final store = MockStore();
    final dialogs = MockDialogs();
    final entryStart = Vault(2, "before test entry", 1, 1);
    final entryEnd = Vault(2, "after test entry", 1, 1);

    when(store.getEntry(1))
      .thenAnswer((_) async => Vault(1, "", 0, 0));
    when(store.getEntries(vault: 1))
      .thenAnswer((_) async => [entryStart]);
    when(dialogs.editEntryDialog(key: anyNamed("key"), entry: entryStart, onEdit: anyNamed("onEdit")))
      .thenAnswer((invocation) {
        final Function(int) onCreate = invocation.namedArguments[Symbol("onEdit")];
        return MockDialog(onClose: () { onCreate(entryStart.id); });
      });
    
    await tester.pumpWidget(buildTestableWidget(EntryList(title: '', dialogs: dialogs), store));
    await tester.pump(Duration(milliseconds:400));

    expect(find.text(entryStart.name), findsOneWidget, reason: "Start entry missing before edit");
    expect(find.text(entryEnd.name), findsNothing, reason: "End entry present before edit");

    await tester.longPress(find.text(entryStart.name));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pump();

    verify(dialogs.editEntryDialog(key: anyNamed("key"), entry: entryStart, onEdit: anyNamed("onEdit")))
      .called(1);
    when(store.getEntries(vault: 1))
      .thenAnswer((_) async => [entryEnd]);

    await tester.tap(find.text(MockDialog.CLOSE_DIALOG_TEXT));
    await tester.pump(Duration(milliseconds:400));

    expect(find.text(entryStart.name), findsNothing, reason: "Start entry present after edit");
    expect(find.text(entryEnd.name), findsOneWidget, reason: "End entry missing after edit");
  });

  testWidgets('Entry not displayed after deletion', (WidgetTester tester) async {
    final store = MockStore();
    final dialogs = MockDialogs();
    final entry = Vault(2, "test entry", 1, 1);

    when(store.getEntry(1))
      .thenAnswer((_) async => Vault(1, "", 0, 0));
    when(store.getEntries(vault: 1))
      .thenAnswer((_) async => [entry]);
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
    when(store.getEntries(vault: 1))
      .thenAnswer((_) async => []);

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
