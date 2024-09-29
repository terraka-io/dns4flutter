import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:dns4flutter/dns_response.dart';
import 'package:dns4flutter/src/buffer.dart';
import 'package:dns4flutter/src/dns.dart';
import 'package:logging/logging.dart';

// use case
// Future<void> main() async {
//   var resp = await DnsHelper.lookupTxt('front.jetstream.site');
//   var host = resp?.host;
//   var web = resp?.web;
//
// }

class DnsHelper {
  static final Logger _logger = Logger('DnsHelper');

  static bool _loggingInitialized = false;

  static void initializeLogging() {
    if (!_loggingInitialized) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        print('${record.level.name}: ${record.time}: ${record.message}');
      });
      _loggingInitialized = true;
      _logger.info('Logging initialized');
    } else {
      _logger.warning('Logging already initialized. Skipping initialization.');
    }
  }

  // call this in prod to lower the log level, now it's WARNING
  static void setProductionLogLevel() {
    Logger.root.level = Level.WARNING;
    _logger.info('Log level set to WARNING for production');
  }

  static const https = "https://";

  static const List<String> _defaultDnsUrls = [
    "https://35313.flareai.site/dns-query",
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
        var request =
            await _httpClient.getUrl(Uri.parse("$dnsUrl?dns=$requestQuery"));

        _logger.info('Requesting DNS record for $host from $dnsUrl');
        // Add a timeout to the response
        var response =
            await request.close().timeout(Duration(milliseconds: 500));

        var responseBuffer = <int>[];
        await for (var part in response) {
          responseBuffer.addAll(part);
        }
        var dnsBuffer = DNSBuffer.fromList(responseBuffer);
        var message = DNS.parseMessage(dnsBuffer);
        if (message.header.ancount > 0) {
          for (var record in message.answer) {
            var rdata = utf8.decode(record.rdata, allowMalformed: true);
            _logger.info('Parsed TXT record: $rdata');
            return _parseData(rdata);
          }
        }
      } catch (e) {
        if (e is TimeoutException) {
          _logger.warning('Request timed out for $dnsUrl');
        } else {
          _logger.warning('Error occurred: $e');
        }
      }
    }
    _logger.severe('No DNS record found for $host');
    return null;
  }

  static DnsResponse _parseData(String data) {
    //裁切
    var list = data.split(":");
    String? web;
    String? host;
    String? aff;
    String? api;
    for (var element in list) {
      if (element.contains("host")) {
        host = https + element.split("=").last;
      } else if (element.contains("web")) {
        web = https + element.split("=").last;
      } else if (element.contains("aff")) {
        aff = https + element.split("=").last;
      } else if (element.contains("api")) {
        api = element.split("=").last;
      }
    }
    return DnsResponse(data, host: host, web: web, aff: aff, api: api);
  }
}
