import 'package:pitch_detector_plus/pitch_detector_plus_method_channel.dart';
import 'package:pitch_detector_plus_platform_interface/model.dart';

/// An implementation of [PitchDetectorPlatform] that uses method channels.
class PitchDetectorPlus {
  final pitchDetectorPlusMethodChannel = PitchDetectorPlusMethodChannel();

  Future<String> getPlatformVersion() async {
    final version = await pitchDetectorPlusMethodChannel.getPlatformVersion();
    return version;
  }

  Future<String> startRecording() async {
    final status = await pitchDetectorPlusMethodChannel.startRecording();
    return status;
  }

  Future<String> stopRecording() async {
    final status = await pitchDetectorPlusMethodChannel.stopRecording();
    return status;
  }

  Stream listenToPitchData() {
    return pitchDetectorPlusMethodChannel.listen().where((event) {
      return event is Map && event['type'] == 'PITCH_RAW_DATA';
    });
  }

  Future<PitchData> initialize() async {
    final status = await pitchDetectorPlusMethodChannel.initialize();
    return PitchData.fromJson(Map<String, dynamic>.from(status));
  }

  Future<bool?> isInitialized() async {
    final status = await pitchDetectorPlusMethodChannel.isInitialized();
    return status;
  }
}
