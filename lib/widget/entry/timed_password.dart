
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:free_authenticator/timed_entry.dart';
import 'package:free_authenticator/timer.dart';

class TimedPassword extends StatefulWidget {
  final TimedEntry entry;

  const TimedPassword({
    Key key,
    @required this.entry,
  }) : super(key: key);

  @override
  _TimedPassword createState() => _TimedPassword();
}

class _TimedPassword extends State<TimedPassword> {
  int timeStep;
  String password;

  @override
  void initState() {
    super.initState();
    this.timeStep = this.widget.entry.timeStep;
    resetState();
  }

  void resetState() {
    setState(() {
      this.password = this.widget.entry.genPassword();
    });

    var now = new DateTime.now();
    var ms = now.second * 1000 + now.millisecond;
    if (ms > timeStep) ms = ms - timeStep;
    new Future.delayed(Duration(milliseconds: timeStep - ms), () {
      resetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Timer(interval: this.timeStep),
      title: Text(this.widget.entry.name + " " + this.password),
    );
  }
}
