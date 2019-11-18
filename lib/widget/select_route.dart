import 'package:flutter/material.dart';

class SelectRoute<T> extends Route<T> with LocalHistoryRoute<T> {
  Function onRemove;

  SelectRoute({
    this.onRemove,
  }) : super();

  @override
  bool didPop(T result) {
    if (this.onRemove != null) this.onRemove();
    return super.didPop(result);
  }
}
