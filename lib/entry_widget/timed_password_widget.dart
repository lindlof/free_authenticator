import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:free_authenticator/model/api/entry.dart';

import 'element/timer.dart';

class TimedPasswordWidget extends StatefulWidget {
  final TimedPasswordEntry entry;
  final bool isSelected;
  final Function(Entry) onSelect;

  const TimedPasswordWidget({
    Key key,
    @required this.entry,
    this.isSelected,
    this.onSelect,
  }) : super(key: key);

  @override
  _TimedPassword createState() => _TimedPassword();
}

class _TimedPassword extends State<TimedPasswordWidget> {
  int interval;
  String password;

  @override
  void initState() {
    super.initState();
    this.interval = this.widget.entry.timeStep*1000;
    resetState();
  }

  void resetState() {
    if (!this.mounted) return;
    setState(() {
      this.password = this.widget.entry.genPassword();
    });

    var now = new DateTime.now();
    var ms = (now.second * 1000 + now.millisecond) % this.interval;
    new Future.delayed(Duration(milliseconds: this.interval - ms), () {
      resetState();
    });
  }

  void _onSelect() {
    this.widget.onSelect(this.widget.entry);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Timer(interval: this.interval, padding: 14),
      title: Text(this.password),
      subtitle: Text(this.widget.entry.name),
      onLongPress: _onSelect,
      selected: this.widget.isSelected,
    );
  }
}
