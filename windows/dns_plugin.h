#ifndef FLUTTER_PLUGIN_DNS_PLUGIN_H_
#define FLUTTER_PLUGIN_DNS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace dns {

class DnsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  DnsPlugin();

  virtual ~DnsPlugin();

  // Disallow copy and assign.
  DnsPlugin(const DnsPlugin&) = delete;
  DnsPlugin& operator=(const DnsPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace dns

#endif  // FLUTTER_PLUGIN_DNS_PLUGIN_H_
