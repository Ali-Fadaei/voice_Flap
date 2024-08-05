import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:siri_wave/siri_wave.dart';

class Recorder extends StatefulWidget {
  //
  const Recorder({
    super.key,
    required this.onDone,
  });

  final void Function(String? recordFilePath) onDone;

  @override
  State<Recorder> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  //
  //
  bool recording = false;

  final record = AudioRecorder();

  StreamSubscription<Amplitude>? ampSubcription;

  final recordingWaveCtrl = IOS7SiriWaveformController(
    amplitude: 0.001,
    speed: 0.001,
    color: Colors.grey.shade900,
  );

  void _record() async {
    //record setup
    try {
      //state setup
      setState(() => recording = true);
      Directory? tempDir;
      Directory? punasTempDir;
      if (!kIsWeb) {
        tempDir = await getTemporaryDirectory();
        punasTempDir =
            await Directory('${tempDir.path}/punas_support_temp').create();
      }
      final vmsgPath = '${punasTempDir?.path}/vmsg_'
          '${DateTime.now().microsecondsSinceEpoch}.m4a';
      if (await record.hasPermission()) {
        await record.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: vmsgPath,
        );
        //wave setup
        recordingWaveCtrl.color = Colors.green;

        final ampStream = record.onAmplitudeChanged(
          const Duration(milliseconds: 1000),
        );
        ampSubcription = ampStream.listen((amp) {
          final temp = max(
            kIsWeb ? 0.5 : 0.1,
            1 - ((amp.current / (amp.max / 4))),
          );
          recordingWaveCtrl.amplitude = temp;
          recordingWaveCtrl.speed = temp / 10;
        });
      }
    } catch (_) {
      setState(() => recording = false);
    }
  }

  void _stop() async {
    try {
      //state setup
      setState(() => recording = false);
      //record setup
      final recordFile = await record.stop();
      ampSubcription?.cancel();
      //wave setup
      recordingWaveCtrl.color = Colors.grey.shade900;
      recordingWaveCtrl.amplitude = 0.001;
      recordingWaveCtrl.speed = 0.001;
      widget.onDone(recordFile);
    } catch (_) {
      setState(() => recording = true);
    }
  }

  @override
  void dispose() {
    ampSubcription?.cancel();
    record.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: SiriWaveform.ios7(
            controller: recordingWaveCtrl,
            options: const IOS7SiriWaveformOptions(
              height: 85,
              width: 200,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            !recording
                ? IconButton.filled(
                    icon: const Icon(
                      Icons.fiber_manual_record_sharp,
                    ),
                    onPressed: () => _record(),
                  )
                : IconButton.filled(
                    icon: const Icon(
                      Icons.stop_circle,
                    ),
                    onPressed: () => _stop(),
                  ),
          ],
        ),
      ],
    );
  }
}
