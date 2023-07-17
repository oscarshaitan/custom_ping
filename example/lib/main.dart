import 'dart:async';

import 'package:custom_ping/custom_ping.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(Example());
}

class Example extends StatefulWidget {
  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  String service = 'No call';
  late StreamSubscription subscription;
  int pingCount = 0;

  @override
  void initState() {
    subscription = PingService().getSubscription(callBack: (e) {
      setState(() {
        pingCount++;
        service = 'Ping has connection $e,  count: $pingCount';
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Ping',
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Text(service),
          ),
        ),
      ),
    );
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }
}
