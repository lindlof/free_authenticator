import 'package:flutter/material.dart';
import 'package:free_authenticator/model/interface/entry.dart';

class EditEntry extends StatefulWidget {
  EditEntry({
    Key key,
    this.onEdit,
    @required this.entry,
    @required this.nameKey,
    @required this.vaultKey,
  }) : super(key: key);

  final Future Function(Map<String, dynamic> input) onEdit;
  final Entry entry;
  final String nameKey;
  final String vaultKey;

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
          TextField(
            controller: vaultInput,
            decoration: InputDecoration(hintText: "Vault"),
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('Ok'),
          onPressed: () async {
            Map<String, dynamic> input = {
              this.widget.nameKey: nameInput.text,
            };
            if (vaultInput.text != "") input["vault"] = vaultInput.text;
            await widget.onEdit(input);
            Navigator.of(context).pop();
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
