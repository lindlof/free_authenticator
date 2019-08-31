import 'package:flutter/material.dart';
import 'package:free_authenticator/totp.dart';
import 'package:free_authenticator/entry.dart';
import 'package:barcode_scan/barcode_scan.dart';

class CreateEntry extends StatefulWidget {
  CreateEntry({Key key, this.onCreate}) : super(key: key);

  final Future Function(Entry entry) onCreate;

  @override
  _CreateEntry createState() => _CreateEntry();
}

class _CreateEntry extends State<CreateEntry> {
  TextEditingController nameInput = TextEditingController();
  TextEditingController secretInput = TextEditingController();

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
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('Ok'),
          onPressed: () async {
            final entry = TOTP(nameInput.text, secretInput.text);
            await widget.onCreate(entry);
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
