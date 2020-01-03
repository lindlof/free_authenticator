import 'package:flutter/material.dart';
import 'package:free_authenticator/model/interface/entry.dart';
import 'package:free_authenticator/model/interface/entry_type.dart';
import 'package:free_authenticator/widget/dependencies.dart';
import 'package:free_authenticator/widget/dialog/vault_field.dart';

class EditEntry extends StatefulWidget {
  EditEntry({
    Key key,
    this.onEdit,
    @required this.entry,
  }) : super(key: key);

  final Future Function(Entry entry) onEdit;
  final Entry entry;

  @override
  _EditEntry createState() => _EditEntry();
}

class _EditEntry extends State<EditEntry> {
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
            Entry entry = await Dependencies.of(context).store.getEntry(this.widget.entry.id);
            Navigator.of(context).pop();
            await widget.onEdit(entry);
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
