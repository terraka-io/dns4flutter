import 'dart:convert';
import 'dart:io';
import 'package:dns4flutter/dns_response.dart';
import 'package:dns4flutter/src/buffer.dart';
import 'package:dns4flutter/src/dns.dart';

// use case
// Future<void> main() async {
//   var resp = await DnsHelper.lookupTxt('front.jetstream.site');
//   var host = resp?.host;
//   var web = resp?.web;
//
// }

class DnsHelper {
  static const https = "https://";

  static const List<String> _defaultDnsUrls = [
    "https://beacon.dog/dns-query",
    "https://doh.pub/dns-query",
    "https://public.dns.iij.jp/dns-query",
    "https://doh.360.cn/dns-query"
  ];

  static final _httpClient = HttpClient();

  static Future<DnsResponse?> lookupTxt(String host,
      {List<String> dnsUrls = _defaultDnsUrls}) async {
    var requestBuffer = DNS.generateAMessage(host, type: DNS.QTYPE_TXT);
    var requestQuery = requestBuffer.toBase64().replaceAll('=', '');

    for (var dnsUrl in dnsUrls) {
      try {
        var request = await _httpClient.getUrl(Uri.parse("$dnsUrl?dns=$requestQuery"));
        var response = await request.close();
        var responseBuffer = <int>[];
        await for (var part in response) {
          responseBuffer.addAll(part);
        }
        var dnsBuffer = DNSBuffer.fromList(responseBuffer);
        var message = DNS.parseMessage(dnsBuffer);
        if (message.header.ancount > 0) {
          for (var record in message.answer) {
            var rdata = utf8.decode(record.rdata, allowMalformed: true);
            return _parseData(rdata);
          }
        }
      } catch (e) {
        print(e);
      }
    }
    return null;
  }

  static DnsResponse? _parseData(String data) {
    //裁切
    var list = data.split(":");
    String web = "";
    String host = "";
    for (var element in list) {
      if (element.contains("host")) {
        host = https + element.split("=").last;
      } else if (element.contains("web")) {
        web = https + element.split("=").last;
      }
    }
    if (web.isNotEmpty && host.isNotEmpty) {
      return DnsResponse(host, web);
    }
    return null;
  }
}
