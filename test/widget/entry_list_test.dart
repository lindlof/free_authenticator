import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/entry/vault.dart';
import 'package:free_authenticator/widget/dependencies.dart';

import 'package:free_authenticator/widget/entry_list.dart';
import 'package:free_authenticator/widget/store.dart';
import 'package:mockito/mockito.dart';

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
        .thenAnswer((_) async => [Vault(2, "mock entry", 1, 1)]);
    
    await tester.pumpWidget(buildTestableWidget(EntryList(title: ''), store));
    await tester.pump(Duration(milliseconds:400));

    expect(find.text('mock entry'), findsOneWidget);
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
}

Widget buildTestableWidget(Widget child, Store store) {
  var injector = Dependencies(
    child : child,
    store: store,
  );
  return MaterialApp(home: injector);
}
