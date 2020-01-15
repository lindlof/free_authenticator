import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/widget/dependencies.dart';
import 'package:free_authenticator/widget/dialog/create_entry_dialog.dart';

import 'package:free_authenticator/widget/entry_list.dart';
import 'package:free_authenticator/widget/store.dart';
import 'package:mockito/mockito.dart';

import '../../mock/mock_store.dart';

const int PUMP_DURATION_MS = 10;

class MockDialogs extends Mock implements Dialogs {}

void main() {
  testWidgets('Show title', (WidgetTester tester) async {
    final store = MockStore();

    await tester.pumpWidget(buildTestableWidget(CreateEntryDialog(), store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text('Enter a secret'), findsOneWidget);
  });
}

Widget buildTestableWidget(Widget child, Store store) {
  return Dependencies(
    child : MaterialApp(home: child),
    store: store,
  );
}
