import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/entry/vault.dart';
import 'package:free_authenticator/model/interface/entry_type.dart';

import 'package:free_authenticator/widget/entry_list.dart';
import 'package:free_authenticator/widget/store_injector.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(buildTestableWidget(EntryList(title: 'title')));
    await tester.pump(Duration(milliseconds:400));

    expect(find.text('title'), findsOneWidget);
  });
}

Widget buildTestableWidget(Widget child) {
  var injector = StoreInjector(
    child : child,
    getEntry: (int id) async { return Vault(id, "name", 0, 0); },
    getEntries: ({ EntryType type, int vault, int limit, int offset }) async { return []; },
  );
  return MaterialApp(home: injector);
}
