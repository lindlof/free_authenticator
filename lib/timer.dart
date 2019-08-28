
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class Timer extends StatefulWidget {
  final int interval;

  const Timer({
    Key key,
    @required this.interval,
  }) : super(key: key);

  @override
  _Timer createState() => _Timer();
}

class _Timer extends State<Timer> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Tween<double> valueTween;

  @override
  void initState() {
    super.initState();
    this._controller = AnimationController(
      vsync: this,
    );
    resetState();
  }

  void resetState() {
    var now = new DateTime.now();
    var ms = (now.second * 1000 + now.millisecond) % this.widget.interval;
    print("Reset state ms " + ms.toString());
    Duration duration = Duration(milliseconds: this.widget.interval - ms);
    this._controller.duration = duration;

    this.valueTween = Tween<double>(
      begin: ms/this.widget.interval,
      end: 1,
    );
    this._controller.repeat();
    
    new Future.delayed(duration, () {
      resetState();
    });
  }

  @override
  void dispose() {
    this._controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: this._controller,
      child: Container(),
      builder: (context, child) {
        return CircularProgressIndicator(
          value: this.valueTween.evaluate(this._controller)
        );
      },
    );
  }
}
