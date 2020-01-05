import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/entry/vault.dart';
import 'package:free_authenticator/widget/dependencies.dart';

import 'package:free_authenticator/widget/entry_list.dart';
import 'package:free_authenticator/widget/store.dart';
import 'package:mockito/mockito.dart';

class MockStore extends Mock implements Store {}

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
}

Widget buildTestableWidget(Widget child, Store store) {
  var injector = Dependencies(
    child : child,
    store: store,
  );
  return MaterialApp(home: injector);
}
