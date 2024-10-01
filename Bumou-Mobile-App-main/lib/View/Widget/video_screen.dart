import 'dart:io';

import 'package:app/Constants/color.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen(
      {super.key,
      required this.videoUrl,
      this.title = 'Video',
      this.isMessage});
  final String videoUrl, title;
  final bool? isMessage;

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  double sliderValue = 0.0;

  @override
  void initState() {
    _controller = widget.videoUrl.startsWith('http')
        ? VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        : VideoPlayerController.file(File(widget.videoUrl));
    sliderValue = _controller.value.position.inSeconds.toDouble();
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    super.initState();
  }

  bool isControlVissible = true;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isControlVissible = !isControlVissible;
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.transparent,
          actions: [
            widget.isMessage != null
                ? IconButton.filled(
                    style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  )
                : const SizedBox()
          ],
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: SizedBox(
                child: FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller));
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
            if (isControlVissible)
              Positioned(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.black20,
                        foregroundColor: AppColors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _controller.seekTo(_controller.value.position -
                              const Duration(seconds: 10));
                        });
                      },
                      icon: const Icon(Icons.replay_10),
                      iconSize: 40,
                    ),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.black20,
                        foregroundColor: AppColors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            _controller.play();
                          }
                        });
                      },
                      icon: _controller.value.isPlaying
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow),
                      iconSize: 40,
                    ),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.black20,
                        foregroundColor: AppColors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _controller.seekTo(_controller.value.position +
                              const Duration(seconds: 10));
                        });
                      },
                      icon: const Icon(Icons.forward_10),
                      iconSize: 40,
                    ),
                  ],
                ),
              ),
            if (isControlVissible)
              Positioned(
                bottom: 0,
                child: SafeArea(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: AppColors.black20,
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColors.primary,
                        bufferedColor: AppColors.white,
                        backgroundColor: AppColors.white20,
                      ),
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
