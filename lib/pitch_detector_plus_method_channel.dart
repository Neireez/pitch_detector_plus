import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pitch_detector_plus_platform_interface/model.dart';
import 'package:pitch_detector_plus_platform_interface/pitch_detector_plus_platform_interface.dart';

/// An implementation of [PitchDetectorPlatform] that uses method channels.
class PitchDetectorPlusMethodChannel extends PitchDetectorPlusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pitch_detector');

  @visibleForTesting
  final eventChannel = const EventChannel('pitch_detector_event_channel');

  @override
  Future<String> getPlatformVersion() async {
    final version =
        await PitchDetectorPlusPlatform.instance.getPlatformVersion();
    return version;
  }

  @override
  Future<String> startRecording() async {
    final status = await PitchDetectorPlusPlatform.instance.startRecording();
    return status;
  }

  @override
  Future<String> stopRecording() async {
    final status = await PitchDetectorPlusPlatform.instance.stopRecording();
    return status;
  }

  @override
  Stream listen() {
    return eventChannel.receiveBroadcastStream();
  }

  @override
  Future<Map> initialize() async {
    final status = await PitchDetectorPlusPlatform.instance.initialize();
    return status;
  }

  @override
  Future<bool?> isInitialized() async {
    final status = await PitchDetectorPlusPlatform.instance.isInitialized();
    return status;
  }
}
