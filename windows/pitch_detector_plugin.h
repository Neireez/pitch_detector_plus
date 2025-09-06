#ifndef FLUTTER_PLUGIN_PITCH_DETECTOR_PLUGIN_H_
#define FLUTTER_PLUGIN_PITCH_DETECTOR_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace pitch_detector {

class PitchDetectorPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  PitchDetectorPlugin();

  virtual ~PitchDetectorPlugin();

  // Disallow copy and assign.
  PitchDetectorPlugin(const PitchDetectorPlugin&) = delete;
  PitchDetectorPlugin& operator=(const PitchDetectorPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace pitch_detector

#endif  // FLUTTER_PLUGIN_PITCH_DETECTOR_PLUGIN_H_
