import Cocoa
import FlutterMacOS
import EZAudioClone
//import EZAudioUtilies


public class PitchDetectorPlusPlugin: NSObject, FlutterPlugin {
    public static var channel: FlutterMethodChannel?
        public static var eventChannel: FlutterEventChannel?
        public var eventSink: FlutterEventSink?
        public var microphone: EZMicrophone?
        private var bufferSize = 512
        
        public static func register(with registrar: FlutterPluginRegistrar) {
            
            channel = FlutterMethodChannel(name: "pitch_detector", binaryMessenger: registrar.messenger)
            let instance = PitchDetectorPlusPlugin()
            registrar.addMethodCallDelegate(instance, channel: channel!)
            
            eventChannel = FlutterEventChannel(name: "pitch_detector_event_channel", binaryMessenger: registrar.messenger)
            eventChannel!.setStreamHandler(instance)
        }
        
        public func initAudio(){
            microphone = EZMicrophone(delegate: self)
        }
        
        public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            
            switch(MethodChannelNames(rawValue: call.method)) {
            case .getPlatformVersion:
                result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
            case .initialize:
                initAudio()
                let data: [String: Any] = [
                    "sampleRate" : Int(microphone!.audioStreamBasicDescription().mSampleRate),
                    "bufferSize" : bufferSize
                ]
                result(data)
            case .isInitialized:
                result(true)
            case .startRecording:
                microphone?.startFetchingAudio()
                result("Recording started")
            case .stopRecording:
                microphone?.stopFetchingAudio()
                result("Recording Stopped")
            default:
                result(true)
            }
        }
        
    }

    extension PitchDetectorPlusPlugin: FlutterStreamHandler {
        public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            eventSink = events
            return nil
        }
        
        public func onCancel(withArguments arguments: Any?) -> FlutterError? {
            eventSink = nil
            return nil
        }
    }

    extension PitchDetectorPlusPlugin: EZMicrophoneDelegate {
        
        func convert(count: Int, data: UnsafePointer<Float>) -> [Float] {
            let buffer = UnsafeBufferPointer(start: data, count: count);
            return Array(buffer)
        }
        
        public func microphone(_ microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
            if( eventSink != nil){
                let data: [String: Any] = [
                    "data" : convert(count: Int(bufferSize), data: buffer[0]!),
                    "type" : "PITCH_RAW_DATA"
                ]
                eventSink!(data)
            }
        }
    }


    public enum MethodChannelNames: String {
        case startRecording
        case stopRecording
        case getPlatformVersion
        case initialize
        case isInitialized
    }
