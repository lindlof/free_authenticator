import 'package:flutter/material.dart';
import 'package:free_authenticator/store/entry_store.dart';
import 'package:free_authenticator/store/vault_store.dart';
import 'package:free_authenticator/widget/entry_list.dart';
import 'package:free_authenticator/widget/store_injector.dart';

void main() {
  var injector = StoreInjector(
    child : FreeAuthenticatorApp(),
    getEntry: EntryStore.get,
    getEntries: EntryStore.getEntries,
    createEntry: EntryStore.create,
    getEntryInPosition: EntryStore.getEntryInPosition,
    updateEntry: EntryStore.update,
    getOrCreateVault: VaultStore.getOrCreate,
  );
	runApp(injector);
}

class FreeAuthenticatorApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Free Authenticator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EntryList(title: 'One-time Passwords'),
    );
  }
}
