import 'package:flutter/material.dart';

class SelectRoute<T> extends Route<T> with LocalHistoryRoute<T> {
  Function onRemove;

  SelectRoute({
    this.onRemove,
  }) : super();

  @override
  Future<RoutePopDisposition> willPop() async {
    if (this.onRemove != null) this.onRemove();
    return await super.willPop();
  }
}
