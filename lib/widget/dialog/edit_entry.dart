import 'package:flutter/material.dart';
import 'package:free_authenticator/model/interface/entry.dart';
import 'package:free_authenticator/widget/dialog/vault_field.dart';
import 'package:free_authenticator/widget/store_injector.dart';

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter a secret'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: nameInput,
            decoration: InputDecoration(hintText: "Name"),
          ),
          VaultField(
            controller: vaultInput,
            decoration: InputDecoration(hintText: "Vault"),
            entry: this.widget.entry,
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('Ok'),
          onPressed: () async {
            int vault = vaultInput.text == "" ? null :
              await StoreInjector.of(context).getOrCreateVault(vaultInput.text);
            await StoreInjector.of(context).updateEntry(this.widget.entry, name: nameInput.text, vault: vault);
            Entry entry = await StoreInjector.of(context).getEntry(this.widget.entry.id);
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
