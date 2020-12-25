import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wootter_x/helper/constant.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/model/feedModel.dart';
import 'package:wootter_x/model/user.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/state/feedState.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:wootter_x/widgets/woot/components/video_player.dart';
import 'package:wootter_x/widgets/woot/widgets/wootIconsRow.dart';
import 'package:provider/provider.dart';

class VideoViewPge extends StatefulWidget {
  _VideoViewPgeState createState() => _VideoViewPgeState();
}

class _VideoViewPgeState extends State<VideoViewPge> {
  bool isToolAvailable = true;

  FocusNode _focusNode;
  TextEditingController _textEditingController;

  @override
  void initState() {
    _focusNode = FocusNode();
    _textEditingController = TextEditingController();
    super.initState();
  }

  Widget _body() {
    var state = Provider.of<FeedState>(context);
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Container(
            color: Colors.brown.shade700,
            constraints: BoxConstraints(
              maxHeight: fullHeight(context),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  isToolAvailable = !isToolAvailable;
                });
              },
              child: _videoFeed(state.wootDetailModel.last.video),
            ),
          ),
        ),
        !isToolAvailable
            ? Container()
            : Align(
                alignment: Alignment.topLeft,
                child: SafeArea(
                  child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.brown.shade700.withAlpha(200),
                      ),
                      child: Wrap(
                        children: <Widget>[
                          BackButton(
                            color: Colors.white,
                          ),
                        ],
                      )),
                )),
        !isToolAvailable
            ? Container()
            : Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      WootIconsRow(
                        model: state.wootDetailModel.last,
                        iconColor: Theme.of(context).colorScheme.onPrimary,
                        iconEnableColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      Container(
                        color: TwitterColor.dodgetBlue_50.withAlpha(200),
                        padding:
                            EdgeInsets.only(right: 10, left: 10, bottom: 10),
                        child: TextField(
                          controller: _textEditingController,
                          maxLines: null,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            fillColor: Colors.blue,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                _submitButton();
                              },
                              icon: Icon(Icons.send, color: Colors.white),
                            ),
                            focusColor: Colors.black,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            hintText: 'Comment here..',
                            hintStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _videoFeed(String _video) {
    return _video == null
        ? Container()
        : Container(
            alignment: Alignment.center,
            child: WootVideoPlayer(
              videoUrl: _video,
            ),
          );
  }

  void addLikeToWoot() {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    state.addLikeToWoot(state.wootDetailModel.last, authState.userId);
  }

  void _submitButton() {
    if (_textEditingController.text == null ||
        _textEditingController.text.isEmpty) {
      return;
    }
    if (_textEditingController.text.length > 280) {
      return;
    }
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    var user = authState.userModel;
    var profilePic = user.profilePic;
    if (profilePic == null) {
      profilePic = dummyProfilePic;
    }
    var name = authState.userModel.displayName ??
        authState.userModel.email.split('@')[0];
    var pic = authState.userModel.profilePic ?? dummyProfilePic;
    var tags = getHashTags(_textEditingController.text);

    MyUser commentedUser = MyUser(
        displayName: name,
        userName: authState.userModel.userName,
        isVerified: authState.userModel.isVerified,
        profilePic: pic,
        userId: authState.userId);

    var postId = state.wootDetailModel.last.key;

    FeedModel reply = FeedModel(
      description: _textEditingController.text,
      user: commentedUser,
      createdAt: DateTime.now().toUtc().toString(),
      tags: tags,
      userId: commentedUser.userId,
      parentkey: postId,
    );
    state.addcommentToPost(reply);
    FocusScope.of(context).requestFocus(_focusNode);
    setState(() {
      _textEditingController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    print('video view page------');
    return Scaffold(body: _body());
  }
}
