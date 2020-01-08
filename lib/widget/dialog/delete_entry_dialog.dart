import 'package:flutter/material.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/widget/dependencies.dart';

class DeleteEntryDialog extends StatefulWidget {
  DeleteEntryDialog({
    Key key,
    @required this.entry,
    this.onDelete,
  }) : super(key: key);

  final Entry entry;
  final Future Function(int id) onDelete;

  @override
  _DeleteEntry createState() => _DeleteEntry();
}

class _DeleteEntry extends State<DeleteEntryDialog> {
  Widget _buildConfirm() {
    return AlertDialog(
      title: Text('Deletion'),
      content: Text(
        "You may lose access to your account! Make sure you disable 2FA before deleting your secret.\n\n" +
        "Are you sure you want to delete " + this.widget.entry.name + "?"),
      actions: <Widget>[
        new FlatButton(
          child: new Text('Delete'),
          onPressed: () async {
            await Dependencies.of(context).store.deleteEntry(this.widget.entry.id);
            Navigator.of(context).pop();
            if (widget.onDelete != null) this.widget.onDelete(this.widget.entry.id);
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

  Widget _buildVault() {
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
    if (this.widget.entry.type == EntryType.vault) {
      return _buildVault();
    }
    return _buildConfirm();
  }
}
