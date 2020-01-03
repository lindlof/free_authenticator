import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/entry/vault.dart';
import 'package:free_authenticator/widget/dependencies.dart';

import 'package:free_authenticator/widget/entry_list.dart';
import 'package:free_authenticator/widget/store.dart';
import 'package:mockito/mockito.dart';

class MockStore extends Mock implements Store {}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final store = MockStore();

    when(store.getEntry(1))
        .thenAnswer((_) async => Vault(1, "name", 0, 0));
    when(store.getEntries(vault: 1))
        .thenAnswer((_) async => []);
    
    await tester.pumpWidget(buildTestableWidget(EntryList(title: 'title'), store));
    await tester.pump(Duration(milliseconds:400));

    expect(find.text('title'), findsOneWidget);
  });
}

Widget buildTestableWidget(Widget child, Store store) {
  var injector = Dependencies(
    child : child,
    store: store,
  );
  return MaterialApp(home: injector);
}
