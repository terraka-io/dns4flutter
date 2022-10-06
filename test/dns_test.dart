import 'package:flutter_test/flutter_test.dart';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDnsPlatform 
    with MockPlatformInterfaceMixin {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  // final DnsPlatform initialPlatform = DnsPlatform.instance;
  //
  // test('$MethodChannelDns is the default instance', () {
  //   expect(initialPlatform, isInstanceOf<MethodChannelDns>());
  // });
  //
  // test('getPlatformVersion', () async {
  //   Dns dnsPlugin = Dns();
  //   MockDnsPlatform fakePlatform = MockDnsPlatform();
  //   DnsPlatform.instance = fakePlatform;
  //
  //   expect(await dnsPlugin.getPlatformVersion(), '42');
  // });
}
