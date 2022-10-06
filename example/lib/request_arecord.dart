
import 'dart:io' as io;
import 'dart:convert' show Utf8Decoder, json, utf8;


import 'package:dns/dns.dart';

main(List<String> argv) async {
  var domain = 'front.jetstream.site';
  if (argv.isNotEmpty) {
    domain = argv[0];
  }
  var requestBuffer = DNS.generateAMessage(domain,type:DNS.QTYPE_TXT);
  var requestQuery = requestBuffer.toBase64().replaceAll('=', '');
  print('; Request query');
  print(';; $requestQuery');
  print(';; -- ');
  // static const List<String> dnsQueryUrls = [
  //   "https://doh.pub/dns-query$_SUFFIX",
  //   "https://cloudflare-dns.com/dns-query$_SUFFIX",
  //   "https://rubyfish.cn/dns-query$_SUFFIX",
  //   "https://doh.rixcloud.dev/dns-query$_SUFFIX",
  //   "https://doh.dns.sb/dns-query$_SUFFIX",
  //   "https://public.dns.iij.jp/dns-query$_SUFFIX",
  //   "https://doh-jp.blahdns.com/dns-query$_SUFFIX",
  //   "https://dns.adguard.com/dns-query$_SUFFIX",
  //   "https://beacon.dog/dns-query$_SUFFIX",
  // ];
  var client = io.HttpClient();

  var request = await client.getUrl(Uri(scheme: 'https', host: 'doh.pub', path: 'dns-query', query: "dns=${requestQuery}"));
  var response = await request.close();

  // var dio = Dio();
  // dio.interceptors.add(LogInterceptor(responseBody: true));
  // var response1 =await  dio.get("https://doh.pub/dns-query",queryParameters: {"dns":requestQuery});
  // print('; Response dio json  $response1');
  // print('; Response dio data  ${response1.data}');


  var statusCode = response.statusCode;
  print("statusCode $statusCode");

 // var responseBody = await response.transform(const Utf8Decoder(allowMalformed: true)).join();

//  print('; Response json ${responseBody.toString()}');

  var responseBuffer = <int>[];
  await for (var part in response) {
    responseBuffer.addAll(part);
  }
  var dnsBuffer = DNSBuffer.fromList(responseBuffer);
  print('; Response');
  print(';; statusCode: ${response.statusCode}');
  print(';; body as hex: ${DNSBuffer.fromList(responseBuffer).toString()}');
  print(';; body as text: ${utf8.decode(responseBuffer, allowMalformed: true)}');
  print(';; -- ');

  var message = DNS.parseMessage(dnsBuffer);

  if (message.header.qdcount > 0) {
    print('; Questions');
    for (var question in message.question) {
      print(';; qName: ${question.qName}');
      print(';; qClass: ${question.qClass}');
      print(';; qType: ${question.qType}');
      print(';; -- ');
    }
  }
  if (message.header.ancount > 0) {
    print('; Answer');
    for (var record in message.answer) {
      print(';; name: ${record.name}');
      print(';; type: ${record.type}');
      print(';; class: ${record.clazz}');
      print(';; ttl: ${record.ttl}');
      print(';; rdlength: ${record.rdlength}');
      print(';; rdata: ${record.rdata}');
      print(';; rdata athex: ${DNSBuffer.fromList(record.rdata).toString()}');
      print(';; rdata utf-8: ${utf8.decode(record.rdata,allowMalformed: true)}');
      print(';; -- ');
    }
  }

  if (message.header.nscount > 0) {
    print('; Authority');
    for (var record in message.authority) {
      print(';; name: ${record.name}');
      print(';; type: ${record.type}');
      print(';; class: ${record.clazz}');
      print(';; ttl: ${record.ttl}');
      print(';; rdlength: ${record.rdlength}');
      print(';; rdata: ${record.rdata}');
      print(';; rdata athex: ${DNSBuffer.fromList(record.rdata).toString()}');
      print(';; rdata utf-8: ${utf8.decode(record.rdata,allowMalformed: true)}');
      print(';; -- ');
    }
  }

  if (message.header.arcount > 0) {
    print('; Additional');
    for (var record in message.additional) {
      print(';; name: ${record.name}');
      print(';; type: ${record.type}');
      print(';; class: ${record.clazz}');
      print(';; ttl: ${record.ttl}');
      print(';; rdlength: ${record.rdlength}');
      print(';; rdata: ${record.rdata}');
      print(';; rdata utf-8: ${utf8.decode(record.rdata,allowMalformed: true)}');

      print(';; rdata athex: ${DNSBuffer.fromList(record.rdata).toString()}');
      print(';; -- ');
    }
  }
}
