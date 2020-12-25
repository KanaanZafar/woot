import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/model/feedModel.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/state/feedState.dart';

class VideoThumbnailWidget extends StatefulWidget {
  final String path;
  final WootType type;
  final FeedModel model;

  VideoThumbnailWidget({Key key, this.path, this.type, this.model})
      : super(key: key);

  @override
  _VideoThumbnailWidgetState createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  FeedState feedState;
  Uint8List uint8list;
  AuthState authState;

  Future<Uint8List> generateImage() async {
    uint8list = await VideoThumbnail.thumbnailData(
      video: widget.path,
      imageFormat: ImageFormat.WEBP,
      maxWidth: 480,
      quality: 25,
    );
    widget.model.isImageAvailable = true;
    for(int i = 0; i<feedState.feedlist.length; ++i) {
      if (feedState.feedlist.elementAt(i).key == widget.model.key) {
        feedState.feedlist.elementAt(i).isImageAvailable = true;
        feedState.feedlist.elementAt(i).uint8list = uint8list;
        break;
      }
    }

    return uint8list;
  }

  @override
  void initState() {
    feedState = Provider.of<FeedState>(context,listen: false);
    authState = Provider.of<AuthState>(context,listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 200,
        // width: double.infinity,
        child: widget.model.isImageAvailable
            ? videoWidget(context)
            : FutureBuilder<Uint8List>(
          future: generateImage(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                color: Colors.white,
                child: Image.asset(
                  'assets/images/video-loading.png',
                  fit: BoxFit.cover,
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                color: Colors.red,
                child: Icon(Icons.error),
              );
            }
            return videoWidget(context);
          },
        ),
      ),
    );
  }

  Widget videoWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.type == WootType.ParentWoot) {
          return;
        }
        var state = Provider.of<FeedState>(context, listen: false);
        state.getpostDetailFromDatabase(widget.model.key);
        state.setWootToReply = widget.model;
        state.updateViews(widget.model, authState.user.uid);
        Navigator.pushNamed(context, '/VideoViewPge');
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            feedState.feedlist.firstWhere((element) => element.key == widget.model.key).uint8list,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              child: Icon(
                Icons.play_circle_fill,
              ),
            ),
          )
        ],
      ),
    );
  }
}
