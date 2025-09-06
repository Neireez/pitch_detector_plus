#include "include/pitch_detector/pitch_detector_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "pitch_detector_plugin.h"

void PitchDetectorPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  pitch_detector::PitchDetectorPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
