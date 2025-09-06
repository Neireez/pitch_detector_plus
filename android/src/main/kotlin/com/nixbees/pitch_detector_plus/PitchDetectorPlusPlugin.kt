package com.nixbees.pitch_detector_plus

import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** PitchDetectorPlusPlugin */
class PitchDetectorPlusPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  private lateinit var channel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private lateinit var handler: Handler
  private var receiver: EventChannel.EventSink? = null
  private var tarosDspInitialized = false
  private var audioCaptureStreamHandler = AudioCaptureStreamHandler()


  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    handler = Handler(Looper.getMainLooper());
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "pitch_detector_event_channel")
    eventChannel.setStreamHandler(this)
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "pitch_detector")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "initialize" -> {
        result.success(mapOf(
          "sampleRate" to audioCaptureStreamHandler.sampleRate,
          "bufferSize" to audioCaptureStreamHandler.bufferSize,
        ))
      }
      "isInitialized" -> {
        result.success(tarosDspInitialized)
      }
      "startRecording" -> {
        audioCaptureStreamHandler.startRecording()
        result.success("Recording started")
      }
      "stopRecording" -> {
        audioCaptureStreamHandler.stopRecording()
        result.success("Recording Stopped")
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    receiver = events
    if(events != null) {
      audioCaptureStreamHandler.setEventSink(events)
    }
  }

  override fun onCancel(arguments: Any?) {
    receiver = null
  }
}
