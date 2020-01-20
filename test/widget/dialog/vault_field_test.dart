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
const Key KEY = ValueKey("vaultInput");
const String HELP_TEXT_VAULT_MAIN = 'Storing in Main Vault';
const String HELP_TEXT_VAULT_NEW = 'Forging a new vault';
const String HELP_TEXT_VAULT_EXIST = 'Storing in an existing vault';

class MockDialogs extends Mock implements Dialogs {}

void main() {
  testWidgets('Help texts', (WidgetTester tester) async {
    final store = MockStore();
    TextEditingController vaultInput = TextEditingController();
    final vaultField = VaultField(key: KEY, controller: vaultInput);
    final existing1 = "Yellow submarine";

    await store.createEntry(EntryType.vault, VaultEntry.rootId, name: existing1);

    await tester.pumpWidget(MainTestWidget(vaultField, store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text(HELP_TEXT_VAULT_MAIN),  findsOneWidget);
    expect(find.text(HELP_TEXT_VAULT_NEW),   findsNothing);
    expect(find.text(HELP_TEXT_VAULT_EXIST), findsNothing);

    await tester.enterText(find.byKey(KEY), "x");
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text(HELP_TEXT_VAULT_MAIN),  findsNothing);
    expect(find.text(HELP_TEXT_VAULT_NEW),   findsOneWidget);
    expect(find.text(HELP_TEXT_VAULT_EXIST), findsNothing);

    await tester.enterText(find.byKey(KEY), existing1);
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));
    
    expect(find.text(HELP_TEXT_VAULT_MAIN),  findsNothing);
    expect(find.text(HELP_TEXT_VAULT_NEW),   findsNothing);
    expect(find.text(HELP_TEXT_VAULT_EXIST), findsOneWidget);
  });

  testWidgets('Autocomplete matching vaults', (WidgetTester tester) async {
    final store = MockStore();
    TextEditingController vaultInput = TextEditingController();
    final vaultField = VaultField(key: KEY, controller: vaultInput);
    final match1 = "Yellow submarine";
    final match2 = "Yell what up";
    final noMatch = "Hot baste";

    await store.createEntry(EntryType.vault, VaultEntry.rootId, name: match1);
    await store.createEntry(EntryType.vault, VaultEntry.rootId, name: match2);
    await store.createEntry(EntryType.vault, VaultEntry.rootId, name: noMatch);

    await tester.pumpWidget(MainTestWidget(vaultField, store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    await tester.enterText(find.byKey(KEY), "Yel");
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text(match1), findsOneWidget);
    expect(find.text(match2), findsOneWidget);
    expect(find.text(noMatch), findsNothing);
  });

  testWidgets('Don\'t autocomplete non-vaults', (WidgetTester tester) async {
    final store = MockStore();
    TextEditingController vaultInput = TextEditingController();
    final vaultField = VaultField(key: KEY, controller: vaultInput);
    final match1 = "Yellow submarine";
    final secret = "123456";

    await store.createEntry(EntryType.totp, VaultEntry.rootId, name: match1, secret: secret, timestep: 30);

    await tester.pumpWidget(MainTestWidget(vaultField, store: store));
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    await tester.enterText(find.byKey(KEY), "Yel");
    await tester.pump(Duration(milliseconds: PUMP_DURATION_MS));

    expect(find.text(match1), findsNothing);
  });
}
