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

  testWidgets('Open create entry dialog', (WidgetTester tester) async {
    final store = MockStore();
    final dialogs = MockDialogs();

    when(store.getEntry(1))
      .thenAnswer((_) async => Vault(1, "", 0, 0));
    when(store.getEntries(vault: 1))
      .thenAnswer((_) async => []);
    when(dialogs.createEntryDialog(key: anyNamed("key"), onCreate: anyNamed("onCreate")))
      .thenAnswer((_) => Container());
    
    await tester.pumpWidget(buildTestableWidget(EntryList(title: '', dialogs: dialogs), store));
    await tester.pump(Duration(milliseconds:400));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    verify(dialogs.createEntryDialog(key: anyNamed("key"), onCreate: anyNamed("onCreate")))
      .called(1);
  });

   testWidgets('Open edit entry dialog', (WidgetTester tester) async {
    final store = MockStore();
    final dialogs = MockDialogs();

    final entry = Vault(2, "test entry", 1, 1);

    when(store.getEntry(1))
      .thenAnswer((_) async => Vault(1, "", 0, 0));
    when(store.getEntries(vault: 1))
      .thenAnswer((_) async => [entry]);
    when(dialogs.editEntryDialog(key: anyNamed("key"), entry: entry, onEdit: anyNamed("onEdit")))
      .thenAnswer((_) => Container());
    
    await tester.pumpWidget(buildTestableWidget(EntryList(title: '', dialogs: dialogs), store));
    await tester.pump(Duration(milliseconds:400));

    await tester.longPress(find.text('test entry'));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pump();

    verify(dialogs.editEntryDialog(key: anyNamed("key"), entry: entry, onEdit: anyNamed("onEdit")))
      .called(1);
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

    expect(find.text('test entry'), findsOneWidget, reason: "Missing entry to delete");

    await tester.longPress(find.text('test entry'));
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
