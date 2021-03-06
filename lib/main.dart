import 'package:flutter/material.dart';
import 'package:free_authenticator/sql_store/sql_store.dart';
import 'package:free_authenticator/widget/dependencies.dart';
import 'package:free_authenticator/widget/entry_list.dart';

void main() {
  var injector = Dependencies(
    child : FreeAuthenticatorApp(),
    store : SqlStore(),
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
