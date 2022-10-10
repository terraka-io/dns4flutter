// import 'dart:convert';
// import 'dart:io' as io;
// import 'package:dns4flutter/src/dns.dart';
//
// import 'buffer.dart';
//
// const List<String> dnsQueryUrls = [
//   "beacon.dog",
//   "doh.pub",
//   "public.dns.iij.jp",
//   "doh.360.cn"
// ];
//
// const https = "https://";
//
// _parseAddress(String data) {
//   return https + data.split("=").last;
// }
//
// Future<void> run(String argv,String host) async {
//   var domain = argv;
//
//   var requestBuffer = DNS.generateAMessage(domain, type: DNS.QTYPE_TXT);
//   var requestQuery = requestBuffer.toBase64().replaceAll('=', '');
//   print('; Request host $host');
//
//   var client = io.HttpClient();
//
//   var request = await client.getUrl(Uri(
//       scheme: 'https',
//       host: host,
//       path: 'dns-query',
//       query: "dns=${requestQuery}"));
//   var response = await request.close();
//
//   var statusCode = response.statusCode;
//   print('; Response $host');
//   print("statusCode $statusCode ");
//
//  // var responseBody = await response.transform(const Utf8Decoder(allowMalformed: true)).join();
//  //
//  // print('; Response json ${responseBody.toString()}');
//
//   var responseBuffer = <int>[];
//   await for (var part in response) {
//     responseBuffer.addAll(part);
//   }
//   var dnsBuffer = DNSBuffer.fromList(responseBuffer);
//
//   print(';; statusCode: ${response.statusCode}');
//  // print(';; body as hex: ${DNSBuffer.fromList(responseBuffer).toString()}');
//  // print(';; body as text: ${utf8.decode(responseBuffer, allowMalformed: true)}');
//  //  print(';; -- ');
//
//   var message = DNS.parseMessage(dnsBuffer);
//
//   if (message.header.qdcount > 0) {
//     // print('; Questions');
//     // for (var question in message.question) {
//     //   print(';; qName: ${question.qName}');
//     //   print(';; qClass: ${question.qClass}');
//     //   print(';; qType: ${question.qType}');
//     //   print(';; -- ');
//     // }
//   }
//   if (message.header.ancount > 0) {
//     print('; Answer');
//     for (var record in message.answer) {
//       // print(';; name: ${record.name}');
//       // print(';; type: ${record.type}');
//       // print(';; class: ${record.clazz}');
//       // print(';; ttl: ${record.ttl}');
//       // print(';; rdlength: ${record.rdlength}');
//       // print(';; rdata: ${record.rdata}');
//       // print(';; rdata athex: ${DNSBuffer.fromList(record.rdata).toString()}');
//       var rdata = utf8.decode(record.rdata, allowMalformed: true);
//     //  print(';; rdata utf-8: rdata}');
//
//       //裁切
//       var list = rdata.split(":");
//       list.forEach((element) {
//         if (element.contains("host")) {
//           String host1 = _parseAddress(element);
//           print("host：" + host1);
//         } else if (element.contains("web")) {
//           String web = _parseAddress(element);
//           print("web：" + web);
//         }
//       });
//
//     //  print(';; -- ');
//     }
//   }
//
//   if (message.header.nscount > 0) {
//    // print('; Authority');
//     for (var record in message.authority) {
//       // print(';; name: ${record.name}');
//       // print(';; type: ${record.type}');
//       // print(';; class: ${record.clazz}');
//       // print(';; ttl: ${record.ttl}');
//       // print(';; rdlength: ${record.rdlength}');
//       // print(';; rdata: ${record.rdata}');
//       // print(';; rdata athex: ${DNSBuffer.fromList(record.rdata).toString()}');
//       // print(
//       //     ';; rdata utf-8: ${utf8.decode(record.rdata, allowMalformed: true)}');
//       // print(';; -- ');
//     }
//   }
//
//   if (message.header.arcount > 0) {
//   // print('; Additional');
//     for (var record in message.additional) {
//       // print(';; name: ${record.name}');
//       // print(';; type: ${record.type}');
//       // print(';; class: ${record.clazz}');
//       // print(';; ttl: ${record.ttl}');
//       // print(';; rdlength: ${record.rdlength}');
//       // print(';; rdata: ${record.rdata}');
//       // print(
//       //     ';; rdata utf-8: ${utf8.decode(record.rdata, allowMalformed: true)}');
//       //
//       // print(';; rdata athex: ${DNSBuffer.fromList(record.rdata).toString()}');
//       // print(';; -- ');
//     }
//   }
//
//
// }
//
//
