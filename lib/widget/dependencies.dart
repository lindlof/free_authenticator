import 'package:flutter/widgets.dart';

import 'store.dart';

// Application-wide dependency injection
class Dependencies extends InheritedWidget {
  final Store store;

  Dependencies({
    Key key,
    @required Widget child,
    @required this.store,
  }) : assert(child != null),
        super(key: key, child: child);

  static Dependencies of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Dependencies>();
  }

  @override
  bool updateShouldNotify(Dependencies old) => false;
}
