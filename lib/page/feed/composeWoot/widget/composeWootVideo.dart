import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:video_player/video_player.dart';

class ComposeWootVideo extends StatefulWidget {
  final File video;
  final Function onCrossIconPressed;
  ComposeWootVideo({Key key, this.video, this.onCrossIconPressed})
      : super(key: key);

  @override
  _ComposeWootVideoState createState() => _ComposeWootVideoState();
}

class _ComposeWootVideoState extends State<ComposeWootVideo> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.video)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.video == null
          ? Container()
          : Stack(
              children: <Widget>[
                Container(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: 220,
                    width: fullWidth(context) * .8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: _controller.value.initialized
                        ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )
                        : Container(),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.black54),
                    child: IconButton(
                      padding: EdgeInsets.all(0),
                      iconSize: 20,
                      onPressed: widget.onCrossIconPressed,
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
