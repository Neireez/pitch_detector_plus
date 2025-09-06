import Flutter
import UIKit
import EZAudioClone

public class SwiftPitchDetectorPlusPlugin: NSObject, FlutterPlugin {
    public static var channel: FlutterMethodChannel?
    public static var eventChannel: FlutterEventChannel?
    public var eventSink: FlutterEventSink?
    public var microphone: EZMicrophone?
    public var fft: EZAudioFFTRolling?
    private var bufferSize = 2048
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        channel = FlutterMethodChannel(name: "pitch_detector", binaryMessenger: registrar.messenger())
        let instance = SwiftPitchDetectorPlusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel!)
        
        eventChannel = FlutterEventChannel(name: "pitch_detector_event_channel", binaryMessenger: registrar.messenger())
        eventChannel!.setStreamHandler(instance)
    }
    
    public func initAudioOld(){
        let session:AVAudioSession! = AVAudioSession.sharedInstance()
        
        do {
            try session.setPreferredSampleRate(48000)
            try session.setPreferredIOBufferDuration(0.05)
            try session.setCategory(AVAudioSession.Category.playAndRecord)
            try session.setActive(false)
            microphone = EZMicrophone(delegate: self)
            var audioFormat = AudioStreamBasicDescription();
            audioFormat.mSampleRate         = 48000;
            audioFormat.mFormatID           = kAudioFormatLinearPCM;
            audioFormat.mFormatFlags        = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
            audioFormat.mFramesPerPacket    = 1;
            audioFormat.mChannelsPerFrame   = 1;
            audioFormat.mBitsPerChannel     = 16;
            audioFormat.mBytesPerPacket     = 2;
            audioFormat.mBytesPerFrame      = 2;
            microphone?.setAudioStreamBasicDescription(audioFormat)

        } catch {
            print(error)
        }
    }
        
    public func initAudio(){
        initAudioOld()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch(MethodChannelNames(rawValue: call.method)) {
        case .getPlatformVersion:
            result("iOS " + UIDevice.current.systemVersion)
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
//            do {
//                let session:AVAudioSession! = AVAudioSession.sharedInstance()
//                try session.setActive(true)
//            } catch {
//                print(error)
//            }
            microphone?.startFetchingAudio()
            result("Recording started")
        case .stopRecording:
//            do {
//                let session:AVAudioSession! = AVAudioSession.sharedInstance()
//                try session.setActive(false)
//            } catch {
//                print(error)
//            }
            microphone?.stopFetchingAudio()
            result("Recording Stopped")
        default:
            result(true)
        }
    }
}

extension SwiftPitchDetectorPlusPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}

extension SwiftPitchDetectorPlusPlugin: EZMicrophoneDelegate {
    
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
