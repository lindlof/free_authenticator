import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
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

  testWidgets('Autocomplete matching vaults', (WidgetTester tester) async {
    final store = MockStore();
    TextEditingController vaultInput = TextEditingController();
    final vaultField = VaultField(key: ValueKey("vaultInput"), controller: vaultInput);
    final match1 = "Yellow submarine";
    final match2 = "Yell what up";
    final noMatch = "Hot baste";

    await store.createEntry(EntryType.vault, VaultEntry.rootId, name: match1);
    await store.createEntry(EntryType.vault, VaultEntry.rootId, name: match2);
    await store.createEntry(EntryType.vault, VaultEntry.rootId, name: noMatch);

    await tester.pumpWidget(MainTestWidget(vaultField, store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    await tester.enterText(find.byKey(ValueKey("vaultInput")), "Yel");
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text(match1), findsOneWidget);
    expect(find.text(match2), findsOneWidget);
    expect(find.text(noMatch), findsNothing);
  });

  testWidgets('Don\'t autocomplete non-vaults', (WidgetTester tester) async {
    final store = MockStore();
    TextEditingController vaultInput = TextEditingController();
    final vaultField = VaultField(key: ValueKey("vaultInput"), controller: vaultInput);
    final match1 = "Yellow submarine";
    final secret = "123456";

    await store.createEntry(EntryType.totp, VaultEntry.rootId, name: match1, secret: secret, timestep: 30);

    await tester.pumpWidget(MainTestWidget(vaultField, store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    await tester.enterText(find.byKey(ValueKey("vaultInput")), "Yel");
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text(match1), findsNothing);
  });
}
