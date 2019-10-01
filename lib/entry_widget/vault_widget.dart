import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:free_authenticator/model/interface/entry.dart';

class VaultWidget extends StatelessWidget {
  final Entry entry;

  final Function onTap;

  const VaultWidget({
    Key key,
    @required this.entry,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Icon(Icons.group_work),
        ),
      ),
      title: Text(this.entry.name),
      trailing: Icon(Icons.more_vert),
      onTap: () => this.onTap(this.entry.id),
    );
  }
}
