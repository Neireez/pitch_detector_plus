import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _audioRecorder = FlutterAudioCapture();
  final pitchDetectorDart = PitchDetector(44100, 735);

  var note = "";
  var status = "Click on start";

  Future<void> _startCapture() async {
    await _audioRecorder.start(listener, onError,
        sampleRate: 44100, bufferSize: 735*4);

    setState(() {
      note = "";
      status = "Play something";
    });
  }

  Future<void> _stopCapture() async {
    await _audioRecorder.stop();

    setState(() {
      note = "";
      status = "Click on start";
    });
  }

  void listener(dynamic obj) {
    //Gets the audio sample
    var buffer = Float64List.fromList(obj.cast<double>());
    final List<double> audioSample = buffer.toList();

    //Uses pitch_detector_dart library to detect a pitch from the audio sample
    final result = pitchDetectorDart.getPitch(audioSample);

    //If there is a pitch - evaluate it
    print('${DateTime.now().toString()}   ${result.pitch}');
    setState(() {
      note = '${result.pitch.toStringAsFixed(1)}';
    });
    // if (result.pitched) {
    //   //Uses the pitchupDart library to check a given pitch for a Guitar
    //   final handledPitchResult = pitchupDart.handlePitch(result.pitch);
    //
    //   //Updates the state with the result
    //   setState(() {
    //     note = handledPitchResult.note;
    //     status = handledPitchResult.tuningStatus.toString();
    //   });
    // }
  }

  void onError(Object e) {
    print(e);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(children: [
          const Spacer(),
          Center(
              child: Text(
            note,
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 105.0,
                fontWeight: FontWeight.bold),
          )),
          const Spacer(),
          Center(
              child: Text(
            status,
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 14.0,
                fontWeight: FontWeight.bold),
          )),
          Expanded(
              child: Row(
            children: [
              Expanded(
                child: Center(
                  child: FloatingActionButton(
                    onPressed: _startCapture,
                    child: const Text("Start"),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: FloatingActionButton(
                    onPressed: _stopCapture,
                    child: const Text("Stop"),
                  ),
                ),
              ),
            ],
          ))
        ]),
      ),
    );
  }
}
