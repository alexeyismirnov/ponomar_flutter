import 'package:flutter/material.dart';

import 'package:audioplayers/audioplayers.dart';

class AudioPlayerView extends StatefulWidget {
  final String url;
  const AudioPlayerView(this.url);

  @override
  _AudioPlayerViewState createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<AudioPlayerView> {
  AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  Duration? currentTime;
  Duration? completeTime;

  @override
  void initState() {
    super.initState();

    player.onAudioPositionChanged.listen((Duration duration) {
      setState(() {
        currentTime = duration;
      });
    });

    player.onDurationChanged.listen((Duration duration) {
      setState(() {
        completeTime = duration;
      });
    });

    player.onPlayerCompletion.listen((event) {
      player.stop();

      setState(() {
        isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    player.stop();
    player.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.start, children: [
        IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle_outlined : Icons.play_circle_outlined,
              color: Colors.black,
              size: 35,
            ),
            onPressed: () async {
              if (isPlaying) {
                player.pause();

                setState(() {
                  isPlaying = false;
                });
              } else {
                if (currentTime == null) {
                  await player.play(widget.url, isLocal: true);
                } else {
                  player.resume();
                }

                setState(() {
                  isPlaying = true;
                });
              }
            }),
        const SizedBox(width: 5),
        Expanded(
            child: LinearProgressIndicator(
                value: (currentTime == null || completeTime == null)
                    ? 0.0
                    : currentTime!.inSeconds / completeTime!.inSeconds))
      ]);
}
