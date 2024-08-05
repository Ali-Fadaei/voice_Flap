import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class Player extends StatefulWidget {
  //
  final String? filePath;

  final String? fileUrl;

  const Player({
    super.key,
    this.filePath,
    this.fileUrl,
  });

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  //
  bool isPlaying = false;

  Duration? fileDuration;

  final player = AudioPlayer();

  void play() async {
    try {
      if (widget.filePath != null) {
        await player.resume();
        setState(() => isPlaying = true);
        return;
      }
      if (widget.fileUrl != null) {
        await player.resume();
        setState(() => isPlaying = true);
        return;
      }
    } catch (_) {
      setState(() => isPlaying = false);
    }
  }

  void pause() async {
    try {
      await player.pause();
      setState(() => isPlaying = false);
    } catch (_) {
      setState(() => isPlaying = true);
    }
  }

  void seek(Duration duratoion) async {
    await player.seek(duratoion);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      player.setReleaseMode(ReleaseMode.stop);
      if (widget.filePath != null) {
        await player.setSourceDeviceFile(widget.filePath!);
        final duration = await player.getDuration();
        setState(() => fileDuration = duration);
        return;
      }
      if (widget.fileUrl != null) {
        await player.setSourceUrl(widget.fileUrl!);
        final duration = await player.getDuration();
        setState(() => fileDuration = duration);
        return;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          fileDuration == null
              ? const CircularProgressIndicator()
              : !isPlaying
                  ? IconButton.filled(
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                      ),
                      onPressed: () => play(),
                    )
                  : IconButton.filled(
                      icon: const Icon(
                        Icons.pause,
                      ),
                      onPressed: () => pause(),
                    ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 20,
              child: StreamBuilder(
                stream: player.onPositionChanged,
                builder: (context, snapshot) {
                  return ProgressBar(
                    onSeek: seek,
                    progress: snapshot.data ?? Duration.zero,
                    total: fileDuration ?? Duration.zero,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
