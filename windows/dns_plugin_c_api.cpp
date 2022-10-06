#include "include/dns/dns_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "dns_plugin.h"

void DnsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  dns::DnsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
