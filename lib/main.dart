import 'dart:async' show Timer;
import 'dart:core';
import 'package:audioplayers/audioplayers.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

const durationKey = "duration";
const soundKey = "sound";
const defaultSound = "sounds/gong.mp3";

void main() {
  Logger.level = Level.debug;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gong',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gong'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final log = Logger(
    printer: PrettyPrinter(
      lineLength: 90,
      colors: true,
      methodCount: 0,
      noBoxingByDefault: true,
      errorMethodCount: 5,
    ),
  );
  Duration _duration = Duration.zero;
  Duration _remaining = Duration.zero;
  SharedPreferences? _preferences;
  String _sound = "sounds/gong.mp3";
  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    loadPrefs();
  }

  void loadPrefs() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      _duration = Duration(seconds: _preferences!.getInt(durationKey) ?? 0);
      log.d("Duration from prefs: ${_duration}");
      _sound = _preferences!.getString(soundKey) ?? 'sounds/gong.mp3';
      log.d("Sound from prefs: ${_sound}");
    });
  }

  void _startCountdown() async {
    var stopwatch = Stopwatch()..start();
    _remaining = _duration - stopwatch.elapsed;
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) async {
      _remaining = _duration - stopwatch.elapsed;
      if (_remaining <= Duration.zero) {
        timer.cancel();
        _countdown = null;
        final player = AudioPlayer();
        log.d("play sound");
        await player.play(AssetSource(_sound));
      }
      setState(() => {});
    });
    log.d('play after ${_duration.inSeconds} seconds)');
    setState(() => {});
  }

  void _stopCountdown() async {
    _countdown?.cancel();
    _countdown = null;
    log.d('stop');
    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _countdown == null
                ? DurationPicker(
                    duration: _duration,
                    baseUnit: BaseUnit.second,
                    onChange: (val) {
                      _preferences!.setInt(durationKey, val.inSeconds);
                      setState(() => _duration = val);
                    },
                    snapToMins: 5.0,
                  )
                : Text("Time remaining: ${_remaining.inSeconds}s"),
            DropdownButton(
              value: _sound,
              items: const [
                DropdownMenuItem(value: defaultSound, child: Text("Gong")),
                DropdownMenuItem(value: "sounds/ding.mp3", child: Text("Ding")),
              ],
              onChanged: (String? value) {
                _preferences!.setString(defaultSound, value!);
                setState(() => _sound = value);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _countdown == null ? _startCountdown : _stopCountdown,
        tooltip: _countdown == null ? "Start" : "Stop",
        child: _countdown == null
            ? const Icon(Icons.play_arrow)
            : const Icon(Icons.stop),
      ),
    );
  }
}
