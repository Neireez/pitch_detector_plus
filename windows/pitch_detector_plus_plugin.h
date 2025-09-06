#ifndef FLUTTER_PLUGIN_PITCH_DETECTOR_PLUS_PLUGIN_H_
#define FLUTTER_PLUGIN_PITCH_DETECTOR_PLUS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace pitch_detector_plus {

class PitchDetectorPlusPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  PitchDetectorPlusPlugin();

  virtual ~PitchDetectorPlusPlugin();

  // Disallow copy and assign.
  PitchDetectorPlusPlugin(const PitchDetectorPlusPlugin&) = delete;
  PitchDetectorPlusPlugin& operator=(const PitchDetectorPlusPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace pitch_detector_plus

#endif  // FLUTTER_PLUGIN_PITCH_DETECTOR_PLUS_PLUGIN_H_
