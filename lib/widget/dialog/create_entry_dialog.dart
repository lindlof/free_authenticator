import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/widget/dependencies.dart';
import 'package:free_authenticator/widget/dialog/vault_field.dart';

class CreateEntryDialog extends StatefulWidget {
  CreateEntryDialog({
    Key key,
    this.onCreate,
  }) : super(key: key);

  final Future Function(int id) onCreate;

  @override
  _CreateEntry createState() => _CreateEntry();
}

class _CreateEntry extends State<CreateEntryDialog> {
  TextEditingController nameInput = TextEditingController();
  TextEditingController secretInput = TextEditingController();
  TextEditingController vaultInput = TextEditingController();

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
            controller: secretInput,
            decoration: InputDecoration(hintText: "Secret"),
          ),
          VaultField(
            controller: vaultInput,
            decoration: InputDecoration(hintText: "Vault"),
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('Ok'),
          onPressed: () async {
            int vault = vaultInput.text == "" ? VaultEntry.rootId :
              await Dependencies.of(context).store.getOrCreateVault(vaultInput.text);
            int id = await Dependencies.of(context).store.createEntry(
              EntryType.totp, vault, name: nameInput.text, secret: secretInput.text, timestep: 30
            );
            Navigator.of(context).pop();
            if (widget.onCreate != null) await widget.onCreate(id);
          },
        ),
        new FlatButton(
          child: new Text('Scan'),
          onPressed: () async {
            String otpauth = await BarcodeScanner.scan();
            var uri = Uri.parse(otpauth);
            if (uri.scheme != 'otpauth') {
              print("QR code is not a 2FA secret");
              return;
            }
            print("host " + uri.host);
            if (uri.host != 'totp') {
              print("Only TOTP is supported");
              return;
            }
            nameInput.text = uri.pathSegments[0];
            secretInput.text = uri.queryParameters['secret'];
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
