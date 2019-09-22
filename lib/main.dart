import 'package:flutter/material.dart';
import 'package:free_authenticator/entry_list.dart';
import 'package:free_authenticator/vault.dart';

void main() {
  runApp(MaterialApp(
    title: 'Free Authenticator',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: EntryList(title: 'One-time Passwords', vaultId: Vault.rootId),
  ));
}
