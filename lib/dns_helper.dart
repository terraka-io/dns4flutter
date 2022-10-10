import 'dart:convert';
import 'dart:io';

import 'package:dns4flutter/dns_response.dart';
import 'package:dns4flutter/src/buffer.dart';
import 'package:dns4flutter/src/dns.dart';

Future<void> main() async {
  var resp = await DnsHelper.lookup('front.jetstream.site');
  var host = resp?.host;
  var web = resp?.web;
  print(host);
  print(web);
}

class DnsHelper {
  static const https = "https://";

  static const List<String> _defaultDnsUrls = [
    "https://beacon.dog/dns-query",
    "https://doh.pub/dns-query",
    "https://public.dns.iij.jp/dns-query",
    "https://doh.360.cn/dns-query"
  ];

  static DnsResponse _parseAddress(String rdata) {
    //裁切
    var list = rdata.split(":");
    String web = "";
    String host = "";
    for (var element in list) {
      if (element.contains("host")) {
        host = https + element.split("=").last;
      } else if (element.contains("web")) {
        web = https + element.split("=").last;
      }
    }

    return DnsResponse(host, web);
  }

  static final _httpClient = HttpClient();

  static Future<DnsResponse?> lookup(String host,
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
            return _parseAddress(rdata);
          }
        }
      } catch (e) {
        print(e);
      }
    }
    return null;
  }
}
