import 'package:flutter/material.dart';
import 'package:wave_form/player.dart';
import 'package:wave_form/recorder.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('WaveForm Example')),
        body: const MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  //
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //
  String? lastRecordedMsgPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Recorder(
          onDone: (recordFilePath) => setState(() {
            lastRecordedMsgPath = recordFilePath;
          }),
        ),
        const SizedBox(height: 40),
        if (lastRecordedMsgPath != null) ...[
          Center(
            child: Text(
              lastRecordedMsgPath ?? '',
            ),
          ),
          Player(filePath: lastRecordedMsgPath!),
        ],
        const SizedBox(height: 40),
        // const Player(
        //   fileUrl:
        //       'https://dl.solahangs.com/Music/1403/02/H/128/Hiphopologist%20-%20Shakkak%20%28128%29.mp3',
        // ),
      ],
    );
    // return AnimatedWaveList(
    //   stream: _amplitudeStream,
    // );
  }
}
