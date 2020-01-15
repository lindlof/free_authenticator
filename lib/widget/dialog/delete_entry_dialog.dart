import 'package:flutter/material.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/widget/dependencies.dart';

class DeleteEntryDialog extends StatelessWidget {
  DeleteEntryDialog({
    Key key,
    @required this.entry,
    this.onDelete,
  }) : super(key: key);

  final Entry entry;
  final Future Function(int id) onDelete;

  Widget _buildConfirm(BuildContext context) {
    return AlertDialog(
      title: Text('Deletion'),
      content: Text(
        "You may lose access to your account! Make sure you disable 2FA before deleting your secret.\n\n" +
        "Are you sure you want to delete " + this.entry.name + "?"),
      actions: <Widget>[
        new FlatButton(
          child: new Text('Delete'),
          onPressed: () async {
            await Dependencies.of(context).store.deleteEntry(this.entry.id);
            Navigator.of(context).pop();
            if (this.onDelete != null) this.onDelete(this.entry.id);
          },
        ),
        new FlatButton(
          child: new Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  Widget _buildVault(BuildContext context) {
    return AlertDialog(
      title: Text('Deletion'),
      content: Text("Empty this vault to delete it."),
      actions: <Widget>[
        new FlatButton(
          child: new Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (this.entry.type == EntryType.vault) {
      return _buildVault(context);
    }
    return _buildConfirm(context);
  }
}
