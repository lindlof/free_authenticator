import 'package:flutter/material.dart';

class MockDialog extends StatelessWidget {
  static const String CLOSE_DIALOG_TEXT = 'close mock dialog';

  MockDialog({
    Key key,
    this.onClose,
  }) : super(key: key);

  final Function() onClose;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('mock dialog'),
      actions: <Widget>[
        new FlatButton(
          child: new Text(CLOSE_DIALOG_TEXT),
          onPressed: () {
            Navigator.of(context).pop();
            this.onClose();
          },
        )
      ],
    );
  }
}
