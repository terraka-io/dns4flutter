import 'package:dns4flutter/dns_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

void main() {
  group('DnsHelper', () {
    test('lookupTxt returns correct TXT record for domain', () async {
      final result = await DnsHelper.lookupTxt("front.flashvpn.io");

      expect(result, isNotNull);
      expect(result!.origin, isNotEmpty);
      // Add more specific expectations based on the expected TXT record
      // For example:
      // expect(result.origin, contains('expected-text'));
    });

    test('lookupTxt returns null for non-existent domain', () async {
      final result = await DnsHelper.lookupTxt("non-existent-domain.example");

      expect(result, isNull);
    });

    // Add more tests as needed
  });
}
