import 'dart:io';

import 'package:dio/io.dart';
import 'package:dio_compatibility_layer/dio_compatibility_layer.dart';
import 'package:dns4flutter/dns_helper.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:rhttp/rhttp.dart';

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
  String? origin;

  @override
  void initState() {
    super.initState();
    DnsHelper.initializeLogging();
    DnsHelper.lookupTxt('front.jetstream.site').then((value) {
      host = value?.host;
      web = value?.web;
      origin = value?.origin;
      setState(() {});
    });
    makeRequest('flashvpn.io');
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
            Text("origin:$origin"),
          ],
        ),
      ),
    );
  }

  Future<void> makeRequest(String domain) async {
    await Rhttp.init();
    final dio = Dio();
    final compatibleClient =
        await RhttpCompatibleClient.create(settings: ClientSettings(
      dnsSettings: DnsSettings.dynamic(resolver: (String host) async {
        return await DnsHelper.lookupARecords(domain);
      }),
    )); // or createSync()
    dio.httpClientAdapter = ConversionLayerAdapter(compatibleClient);
    try {
      final response = await dio.get('https://$domain');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.data}');
    } catch (e) {
      print('Error: $e');
    }
  }
}
