import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:free_authenticator/entry.dart';
import 'package:free_authenticator/timer.dart';

class TimedPassword extends StatefulWidget {
  final TimedPasswordEntry entry;

  const TimedPassword({
    Key key,
    @required this.entry,
  }) : super(key: key);

  @override
  _TimedPassword createState() => _TimedPassword();
}

class _TimedPassword extends State<TimedPassword> {
  int interval;
  String password;

  @override
  void initState() {
    super.initState();
    this.interval = this.widget.entry.timeStep*1000;
    resetState();
  }

  void resetState() {
    setState(() {
      this.password = this.widget.entry.genPassword();
    });

    var now = new DateTime.now();
    var ms = (now.second * 1000 + now.millisecond) % this.interval;
    new Future.delayed(Duration(milliseconds: this.interval - ms), () {
      resetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Timer(interval: this.interval, padding: 14),
      title: Text(this.password),
      subtitle: Text(this.widget.entry.name),
      trailing: Icon(Icons.more_vert),
    );
  }
}
