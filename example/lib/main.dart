import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitch_detector_plus/pitch_detector_plus.dart';

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
  final pitchDetectorDart = PitchDetectorPlus();
  late PitchDetector pitchDart;
  StreamSubscription? streamSub;

  var note = "";
  var status = "Click on start";
  Map<String, int> counts = {};

  Future<void> _startCapture() async {
    print(await pitchDetectorDart.startRecording());
    streamSub = pitchDetectorDart.listenToPitchData().listen((event) {
      listener(List<double>.from(event['data']));
    });
    setState(() {
      note = "";
      status = "Play something";
    });
  }

  Future<void> _stopCapture() async {
    print(await pitchDetectorDart.stopRecording());
    streamSub?.cancel();

    setState(() {
      note = "";
      status = "Click on start";
    });
  }

  void listener(List<double> audioSample) {
    final result = pitchDart.getPitch(audioSample);

    counts[DateTime.now().minute.toString() +
        DateTime.now().second.toString()] = counts[
                DateTime.now().minute.toString() +
                    DateTime.now().second.toString()] ==
            null
        ? 1
        : counts[DateTime.now().minute.toString() +
                DateTime.now().second.toString()]! +
            1;
    setState(() {
      note = result.pitch.toStringAsFixed(1);
    });
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
              fontWeight: FontWeight.bold,
            ),
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
                    onPressed: () async {
                      final data = await pitchDetectorDart.initialize();
                      pitchDart = PitchDetector(
                        data.sampleRate.toDouble(),
                        data.bufferSize,
                      );
                    },
                    child: const Text("Init"),
                  ),
                ),
              ),
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
              Expanded(
                child: Center(
                  child: FloatingActionButton(
                    onPressed: () {
                      print(jsonEncode(counts));
                    },
                    child: const Text("Log"),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: FloatingActionButton(
                    onPressed: () {
                      counts.clear();
                    },
                    child: const Text("Clear"),
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
