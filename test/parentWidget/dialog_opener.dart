import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class DialogOpener extends StatelessWidget {
  static const Key _OPEN_DIALOG_KEY = ValueKey('openDialog');

  static Finder findOpenButton() {
    return find.byKey(DialogOpener._OPEN_DIALOG_KEY);
  }

  DialogOpener(
    this.dialog,
    { Key key }
  ) : super(key: key);

  final Widget Function() dialog;

  openDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return this.dialog();
      });
  }

  @override
  Widget build(BuildContext context) {
    return new FlatButton(
      key: _OPEN_DIALOG_KEY,
      child: new Container(),
      onPressed: () {
        this.openDialog(context);
      },
    );
  }
}
