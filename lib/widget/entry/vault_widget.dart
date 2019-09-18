import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:free_authenticator/entry.dart';

class VaultWidget extends StatelessWidget {
  final Entry entry;

  const VaultWidget({
    Key key,
    @required this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(this.entry.name),
      trailing: Icon(Icons.more_vert),
    );
  }
}
