import 'package:dns4flutter/dns_helper.dart';
import 'package:flutter_test/flutter_test.dart';


Future<void> main() async {
  var lookupTxt = await DnsHelper.lookupTxt("front.flashvpn.io");
  print(lookupTxt?.origin);
}
