import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:free_authenticator/widget/dependencies.dart';
import 'package:free_authenticator/widget/store.dart';

class MainTestWidget extends StatelessWidget {
  MainTestWidget(
    this.child,
    {
      Key key,
      this.store,
    }
  ): super(key: key);

  final Widget child;
  final Store store;

  @override
  Widget build(BuildContext context) {
    if (this.store != null) {
      return Dependencies(
        child : MaterialApp(home: this.child),
        store: store,
      );
    }
    return MaterialApp(home: this.child);
  }
}
