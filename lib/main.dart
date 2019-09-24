import 'package:flutter/material.dart';
import 'package:free_authenticator/entry_list.dart';
import 'package:free_authenticator/vault.dart';

void main() {
  runApp(FreeAuthenticatorApp());
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
      home: EntryList(title: 'One-time Passwords', vaultId: Vault.rootId),
    );
  }
}