import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:video_player/video_player.dart';

class WootVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const WootVideoPlayer({Key key, this.videoUrl}) : super(key: key);
  @override
  _WootVideoPlayerState createState() => _WootVideoPlayerState();
}

class _WootVideoPlayerState extends State<WootVideoPlayer> {
  bool isError = false;
  String errorString;
  VideoPlayerController _controller;
  Duration videoDuration;

  Future<void> _initializeVideoPlayerFuture;

  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          videoDuration = _controller.value.duration;
        });
      }).catchError((error) {
        setState(() {
          isError = true;
          errorString = error;
        });
      });
    _controller.setLooping(true);
    _controller.play();

  }


  @override
  Widget build(BuildContext context) {
    print(widget.videoUrl);
    return Center(
      child: isError
          ? Container(
              child: Center(
                child: Icon(Icons.error),
              ),
            )
          : _controller.value.initialized
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: GestureDetector(
                    onTap: () async {
                      Duration _duration = await _controller.position;
                      if (!_controller.value.isPlaying) {
                        if (_duration.compareTo(videoDuration) > 0) {
                          await _controller.initialize();
                        }
                      }
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        children: [
                          VideoPlayer(_controller),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3)),
                              child: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
