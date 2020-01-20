import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/widget/dialog/vault_field.dart';

import 'package:free_authenticator/widget/entry_list.dart';
import 'package:mockito/mockito.dart';

import '../../mock/mock_store.dart';
import '../../parentWidget/main_test_widget.dart';

const int PUMP_DURATION_MS = 10;

class MockDialogs extends Mock implements Dialogs {}

void main() {
  testWidgets('Show title', (WidgetTester tester) async {
    final store = MockStore();
    TextEditingController vaultInput = TextEditingController();

    await tester.pumpWidget(MainTestWidget(VaultField(controller: vaultInput), store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text('Storing in Main Vault'), findsOneWidget);
  });
}
