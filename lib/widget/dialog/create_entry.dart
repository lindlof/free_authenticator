import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:free_authenticator/model/interface/entry_type.dart';

class CreateEntry extends StatefulWidget {
  CreateEntry({
    Key key,
    @required this.onCreate,
    @required this.typeKey,
    @required this.nameKey,
    @required this.secretKey,
    @required this.vaultKey,
  }) : super(key: key);

  final Future Function(Map<String, dynamic> input) onCreate;
  final String typeKey;
  final String nameKey;
  final String secretKey;
  final String vaultKey;

  @override
  _CreateEntry createState() => _CreateEntry();
}

class _CreateEntry extends State<CreateEntry> {
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
              this.widget.typeKey: EntryType.totp,
              this.widget.nameKey: nameInput.text,
              this.widget.secretKey: secretInput.text,
            };
            if (vaultInput.text != "") input[this.widget.vaultKey] = vaultInput.text;
            await widget.onCreate(input);
            Navigator.of(context).pop();
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
