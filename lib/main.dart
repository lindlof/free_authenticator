import 'package:flutter/material.dart';
import 'package:free_authenticator/model/interface/entry.dart';
import 'package:free_authenticator/widget/entry_list.dart';

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
      home: EntryList(title: 'One-time Passwords'),
    );
  }
}