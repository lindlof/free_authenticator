import 'package:flutter/material.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/widget/dependencies.dart';
import 'package:free_authenticator/widget/dialog/vault_field.dart';

class EditEntryDialog extends StatefulWidget {
  EditEntryDialog({
    Key key,
    @required this.entry,
    this.onEdit,
  }) : super(key: key);

  final Entry entry;
  final Future Function(int id) onEdit;

  @override
  _EditEntry createState() => _EditEntry();
}

class _EditEntry extends State<EditEntryDialog> {
  TextEditingController nameInput = TextEditingController();
  TextEditingController vaultInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.nameInput.text = this.widget.entry.name;
  }

  bool _showVaultInput() => this.widget.entry.type != EntryType.vault;
  Future<int> _getVault() async {
    if (!this._showVaultInput()) return null;
    else if (vaultInput.text == "") return VaultEntry.rootId;
    return await Dependencies.of(context).store.getOrCreateVault(vaultInput.text);
  }

  @override
  Widget build(BuildContext context) {
    var inputFields = (
      <Widget>[
            TextField(
              controller: nameInput,
              decoration: InputDecoration(hintText: "Name"),
            ),
      ]);
    if (this._showVaultInput()) {
      inputFields.add(
        VaultField(
          controller: vaultInput,
          decoration: InputDecoration(hintText: "Vault"),
          entry: this.widget.entry,
        ));
    }
    return AlertDialog(
      title: Text('Enter a secret'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: inputFields,
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('Ok'),
          onPressed: () async {
            int vault = await this._getVault();
            await Dependencies.of(context).store.updateEntry(this.widget.entry, name: nameInput.text, vault: vault);
            Navigator.of(context).pop();
            if (widget.onEdit != null) await widget.onEdit(this.widget.entry.id);
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
}
