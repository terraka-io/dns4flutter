import 'package:dns4flutter/dns_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DnsHelper', () {
    test('lookupTxt returns correct TXT record for domain', () async {
      final result = await DnsHelper.lookupTxt("front.flashvpn.io");

      expect(result, isNotNull);
      expect(result!.api, isNotNull);
      expect(result.web, isNotNull);
    });

    test('lookupTxt returns null for non-existent domain', () async {
      final result = await DnsHelper.lookupTxt("non-existent-domain.example");

      expect(result, isNull);
    });

    test('lookupIp returns correct IP address for domain', () async {
      final result = await DnsHelper.lookupARecords("flashvpn.io");

      expect(result, isNotEmpty);
      expect(result.first,
          matches(RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$')));
    });

    test('lookupIp returns null for non-existent domain', () async {
      final result =
          await DnsHelper.lookupARecords("non-existent-domain.example");

      expect(result, isEmpty);
    });
  });
}
