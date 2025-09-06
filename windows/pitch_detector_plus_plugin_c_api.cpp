#include "include/pitch_detector_plus/pitch_detector_plus_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "pitch_detector_plus_plugin.h"

void PitchDetectorPlusPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  pitch_detector_plus::PitchDetectorPlusPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
