
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:h3/h3_ffi.dart';



void main() {
 initializeH3((String name) => DynamicLibrary.process());
  initializeH3((String name) => Platform.isAndroid
      ? DynamicLibrary.open("lib${name}.so")
      : DynamicLibrary.process());

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('0x${geoToH3(
            GeoCoord.degrees(
              lat: 40.68942184369929,
              lon: -74.04443139990863,
            ),
            10,
          ).toRadixString(16).toUpperCase()}'),
        ),
      ),
    );
  }
}
