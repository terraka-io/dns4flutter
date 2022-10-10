import 'package:dns4flutter/dns_helper.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? host;
  String? web;

  @override
  void initState() {
    super.initState();
    DnsHelper.lookupTxt('front.jetstream.site').then((value) {
      host = value?.host;
      web = value?.web;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Text("host:$host"),
            Text("web:$web"),
          ],
        ),
      ),
    );
  }
}
