import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:dns4flutter/dns_response.dart';
import 'package:logging/logging.dart';
import 'package:async/async.dart';

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

  static var timeoutMilliseconds = 1000;

  static void initializeLogging() {
    if (!_loggingInitialized) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        print(
            '${record.level.name}: DNSHelper: ${record.time}: ${record.message}');
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
    "https://doh.pub/dns-query",
    "https://doh.360.cn/resolve",
    "https://dns.alidns.com/resolve"
  ];

  static final _httpClient = HttpClient();
  static Future<DnsResponse?> lookupTxt(String host,
      {List<String> dnsUrls = _defaultDnsUrls}) async {
    for (var dnsUrl in dnsUrls) {
      try {
        var request =
            await _httpClient.getUrl(Uri.parse("$dnsUrl?name=$host&type=TXT"));
        request.headers.set('accept', 'application/dns-json');

        _logger.info('Requesting DNS record for $host from $dnsUrl');
        // Add a timeout to the response
        var response =
            await request.close().timeout(const Duration(milliseconds: 500));

        var responseBody = await utf8.decodeStream(response);
        var jsonResponse = jsonDecode(responseBody);

        if (jsonResponse['Answer'] != null &&
            jsonResponse['Answer'].isNotEmpty) {
          for (var answer in jsonResponse['Answer']) {
            if (answer['type'] == 16) {
              // TXT record type
              var rdata = answer['data'];
              _logger.info('Parsed TXT record: $rdata');
              return _parseData(rdata);
            }
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

  static final Map<String, CachedDnsResult> _dnsCache = {};

  static Future<List<String>> lookupARecords(String domain,
      {List<String> dnsUrls = _defaultDnsUrls}) async {
    // Check cache first
    if (_dnsCache.containsKey(domain)) {
      var cachedResult = _dnsCache[domain]!;
      if (DateTime.now().difference(cachedResult.timestamp).inMinutes < 5) {
        _logger.info('Returning cached A records for $domain');
        _logger.info('Found cached A records: $cachedResult.ips for $domain');
        return cachedResult.ips;
      }
    }

    var requestQuery = "name=$domain&type=A";

    var group = FutureGroup<List<String>>();

    for (var dnsUrl in dnsUrls) {
      group.add(_queryDnsServer(dnsUrl, requestQuery));
    }

    group.close();

    List<String> allIps = [];

    try {
      var results = await group.future
          .timeout(Duration(milliseconds: timeoutMilliseconds * 2));
      for (var ips in results) {
        allIps.addAll(ips);
      }
    } on TimeoutException {
      _logger.warning('Timeout occurred while querying DNS servers');
    }

    // Remove duplicates
    var uniqueIps = allIps.toSet().toList();

    // Cache the result
    _dnsCache[domain] = CachedDnsResult(uniqueIps, DateTime.now());

    _logger
        .info('Found ${uniqueIps.length} unique IP(s) for $domain: $uniqueIps');
    return uniqueIps;
  }

  static Future<List<String>> _queryDnsServer(
      String dnsUrl, String requestQuery) async {
    try {
      var request =
          await _httpClient.getUrl(Uri.parse("$dnsUrl?$requestQuery"));
      _logger.info('Requesting A records from $dnsUrl');

      var response = await request
          .close()
          .timeout(Duration(milliseconds: timeoutMilliseconds));
      var responseBody = await utf8.decodeStream(response);
      var jsonResponse = jsonDecode(responseBody);

      List<String> ips = [];
      if (jsonResponse['Answer'] != null) {
        for (var answer in jsonResponse['Answer']) {
          if (answer['type'] == 1) {
            // Type 1 is A record
            ips.add(answer['data']);
          }
        }
      }

      _logger.info('Parsed ${ips.length} IP(s) from JSON response');
      return ips;
    } catch (e) {
      if (e is TimeoutException) {
        _logger.warning('Timeout querying $dnsUrl');
      } else {
        _logger.warning('Error querying $dnsUrl: $e');
      }
      return [];
    }
  }
}

class CachedDnsResult {
  final List<String> ips;
  final DateTime timestamp;

  CachedDnsResult(this.ips, this.timestamp);
}
