import 'package:app/Constants/color.dart';
import 'package:app/Data/Local/hive_storage.dart';
import 'package:app/Model/chats/chat_message.dart';
import 'package:app/View/Chat/Widget/seekbar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as rx;

class AudioMessageWidget extends StatefulWidget {
  const AudioMessageWidget({
    super.key,
    required this.msg,
  });

  final ChatMessage msg;

  @override
  State<AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<AudioMessageWidget> {
  double? totalDuration;
  double? currentPlaybackPosition;
  double? bufferedPosition;
  AudioPlayer audioController = AudioPlayer();
  Stream<PositionData> get positionDataStream => rx.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      audioController.positionStream,
      audioController.bufferedPositionStream,
      audioController.durationStream,
      (position, bufferedPosition, duration) => PositionData(position, bufferedPosition, duration ?? Duration.zero));

  void setAudio() {
    audioController.setAudioSource(
      AudioSource.uri(Uri.parse(widget.msg.file!)),
      initialPosition: const Duration(seconds: 0),
      preload: true,
    );
  }

  @override
  void initState() {
    setAudio();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AudioMessageWidget oldWidget) {
    if (oldWidget.msg.file != widget.msg.file) {
      setState(() {
        setAudio();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    audioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMe = widget.msg.senderId == LocalStorage.getUserId;
    return Row(
      children: [
        StreamBuilder<PlayerState>(
          stream: audioController.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
              return Container(
                height: 30,
                width: 30,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: const CircularProgressIndicator.adaptive(strokeWidth: 2, backgroundColor: AppColors.white),
              );
            } else if (playing != true) {
              return IconButton(
                color: isMe ? AppColors.white : AppColors.black,
                icon: const Icon(Icons.play_arrow),
                iconSize: 30.0,
                onPressed: playerState?.playing != true ? audioController.play : null,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                color: isMe ? AppColors.white : AppColors.black,
                iconSize: 30.0,
                onPressed: audioController.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                color: isMe ? AppColors.white : AppColors.black,
                iconSize: 30.0,
                onPressed: () => audioController.seek(Duration.zero),
              );
            }
          },
        ),
        Expanded(
          child: StreamBuilder<PositionData>(
            stream: positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              return Row(
                children: [
                  Expanded(
                    child: SeekBar(
                      duration: positionData?.duration ?? Duration.zero,
                      position: positionData?.position ?? Duration.zero,
                      bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
                      onChangeEnd: (newPosition) {
                        audioController.seek(newPosition);
                      },
                    ),
                  ),
                  Text(
                    positionData?.position.toMinutesSecondsString ?? '00:00',
                    style: TextStyle(
                      color: isMe ? AppColors.white : AppColors.black,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

extension DurationToMinuteSeconds on Duration {
  String get toMinutesSecondsString {
    final seconds = inSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
