#import "DnsPlugin.h"
#if __has_include(<dns/dns-Swift.h>)
#import <dns/dns-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "dns-Swift.h"
#endif

@implementation DnsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDnsPlugin registerWithRegistrar:registrar];
}
@end
