import 'package:dns4flutter/dns_helper.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();


    // dnsQueryUrls.forEach((element) async {
    //   try{
    //     await run('front.jetstream.site', element);
    //   }catch(e){
    //     print("报错地址$element $e");
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text("??"),
        ),
      ),
    );
  }
}
