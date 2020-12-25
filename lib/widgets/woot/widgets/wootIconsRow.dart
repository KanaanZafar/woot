import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wootter_x/bloc/notifications_sender.dart';
import 'package:wootter_x/helper/constant.dart';
import 'package:wootter_x/helper/customRoute.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/model/feedModel.dart';
import 'package:wootter_x/page/Auth/widget/checkContactVerification.dart';
import 'package:wootter_x/page/common/usersListPage.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/state/feedState.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:wootter_x/widgets/woot/widgets/wootBottomSheet.dart';
import 'package:provider/provider.dart';

class WootIconsRow extends StatelessWidget {
  AuthState authState;
  final FeedModel model;
  final Color iconColor;
  final Color iconEnableColor;
  final double size;
  final bool isWootDetail;
  final WootType type;
  final bool isTop;
  WootIconsRow(
      {Key key,
      this.model,
      this.iconColor,
      this.iconEnableColor,
      this.size,
      this.isWootDetail = false,
      this.type,
      this.isTop = false})
      : super(key: key);

  Widget _likeCommentsIcons(BuildContext context, FeedModel model) {
    var authState = Provider.of<AuthState>(context, listen: false);
    return Container(
//      color: Colors.blue,
      padding: EdgeInsets.only(bottom: 0, top: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          !isTop
              ? _iconWidget(
                  context,
                  text: isWootDetail ? '' : model.replyWootKeyList.length.toString(),///
                  icon: AppIcon.reply,
                  iconColor: iconColor,
                  size: size ?? 19,
                  sysIcon: Icons.mode_comment_rounded,
                  onPressed: () {
                    if (authState.userModel.isContactVerified) {
                      var state = Provider.of<FeedState>(context, listen: false);
                      state.setWootToReply = model;
                      Navigator.of(context).pushNamed('/ComposeWootPage');
                    }
                    else
                      ContactVerification(context).plateFormCheck();
                  },
                )
              : Container(),
          _iconWidget(
            context,
            text: isWootDetail ? '' : model.likeList.length.toString(),///
            sysIcon: Icons.thumb_up_alt_rounded,
            onPressed: () {
              print('1');
              if (authState.userModel.isContactVerified)
                addLikeToWoot(context);
              else
                ContactVerification(context).plateFormCheck();
            },
            iconColor:
                model.likeList.any((userId) => userId == authState.user.uid)///
                    ? iconEnableColor
                    : iconColor,
            size: size ?? 19,
          ),
          _iconWidget(
            context,
            text: isWootDetail ? '' : model.dislikeList.length.toString(), ///
            sysIcon: Icons.thumb_down_rounded,
            onPressed: () {
              if (authState.userModel.isContactVerified)
                addDisLikeToWoot(context);
              else
                ContactVerification(context).plateFormCheck();
            },
            iconColor:
                model.dislikeList.any((userId) => userId == authState.user.uid) ///
                    ? Colors.red
                    : iconColor,
            size: size ?? 19,
          ),
          !isTop
              ? _iconWidget(context,
                  text: isWootDetail ? '' : model.rewootCount.toString(),
                  icon: AppIcon.rewoot,
                  iconColor: iconColor,
                  sysIcon: Icons.repeat,
                  size: size ?? 19,
                  onPressed: () {
                    if (authState.userModel.isContactVerified)
                      WootBottomSheet().openRewootbottomSheet(context, type, model);
                    else
                      ContactVerification(context).plateFormCheck();
                  })
              : Container(),
          Container(
            padding: EdgeInsets.fromLTRB(15, 8, 28, 8),
            child: InkWell(
              onTap: () {
                share('${model.description}',
                    subject: '${model.user.displayName}\'s post');
              },
              child: Icon(Icons.share, color: iconColor, size: size),
            ),
          )
        ],
      ),
    );
  }

  Widget _iconWidget(BuildContext context,
      {String text,int icon,Function onPressed,IconData sysIcon,Color iconColor,
      double size = 20}) 
  {
    List<Color> cc = [Colors.greenAccent, Colors.red, Colors.purpleAccent, Colors.amber];
    return Expanded(
      child: InkWell(
        onTap: () {
//          print(onPressed);
//          if (onPressed != null)
          onPressed();
        },
        child: Container(
          // color: cc.elementAt(Random().nextInt(4)),
          padding: EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              sysIcon != null
                  ? Icon(sysIcon, color: iconColor, size: size)
                  : customIcon(
                      context,
                      size: size,
                      icon: icon,
                      istwitterIcon: true,
                      iconColor: iconColor,
                    ),
              SizedBox(
                width: 10,
              ),
              text != null
                  ? Expanded(
                      child: customText(
                        text,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                          fontSize: size - 5,
                        ),
                        context: context,
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeWidget(BuildContext context) {
//    print(Platform.operatingSystem);
    String text = Platform.isIOS ? 'IOS' : 'Android';
    return Column(
      children: <Widget>[
        SizedBox(height: 8),
        Row(
          children: <Widget>[
            SizedBox(width: 5),
            customText(getPostTime2(model.createdAt), style: textStyle14),
            SizedBox(width: 10),
            customText('Wootter for $text',
                style: TextStyle(color: Theme.of(context).primaryColor))
          ],
        ),
        SizedBox(height: 5),
      ],
    );
  }

  Widget _likeCommentWidget(BuildContext context) {
    bool isLikeAvailable = model.likeCount > 0;
    bool isRewootAvailable = model.rewootCount > 0;
    bool isLikeRewootAvailable = isRewootAvailable || isLikeAvailable;
    return Column(
      children: <Widget>[
        Divider(
          endIndent: 10,
          height: 0,
        ),
        AnimatedContainer(
          padding:
              EdgeInsets.symmetric(vertical: isLikeRewootAvailable ? 12 : 0),
          duration: Duration(milliseconds: 500),
          child: !isLikeRewootAvailable
              ? SizedBox.shrink()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    !isRewootAvailable
                        ? SizedBox.shrink()
                        : customText(model.rewootCount.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                    !isRewootAvailable ? SizedBox.shrink() : SizedBox(width: 5),
                    AnimatedCrossFade(
                      firstChild: SizedBox.shrink(),
                      secondChild: customText('Rewoots', style: subtitleStyle),
                      crossFadeState: !isRewootAvailable
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 800),
                    ),
                    !isRewootAvailable
                        ? SizedBox.shrink()
                        : SizedBox(width: 20),
                    InkWell(
                      onTap: () {
                        onLikeTextPressed(context);
                      },
                      child: AnimatedCrossFade(
                        firstChild: SizedBox.shrink(),
                        secondChild: Row(
                          children: <Widget>[
                            customSwitcherWidget(
                              duraton: Duration(milliseconds: 300),
                              child: customText(model.likeCount.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  key: ValueKey(model.likeCount)),
                            ),
                            SizedBox(width: 5),
                            customText('Likes', style: subtitleStyle)
                          ],
                        ),
                        crossFadeState: !isLikeAvailable
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: Duration(milliseconds: 300),
                      ),
                    )
                  ],
                ),
        ),
        !isLikeRewootAvailable
            ? SizedBox.shrink()
            : Divider(
                endIndent: 10,
                height: 0,
              ),
      ],
    );
  }

  void addLikeToWoot(BuildContext context) async {
    cprint('like- wooticonrow');
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    state.addLikeToWoot(model, authState.user.uid);
    await SendFCM().likePost(model.user, authState.userModel);
    // state.notifyListeners();
    // authState.notifyListeners();
  }

  void addDisLikeToWoot(BuildContext context) async {
    cprint('dislike - wooticonrow');
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    state.addDisLikeToWoot(model, authState.user.uid);
    await SendFCM().disLikePost(model.user, authState.userModel);
    // state.notifyListeners();
    // authState.notifyListeners();
  }

  void onLikeTextPressed(BuildContext context) {
    Navigator.of(context).push(
      CustomRoute<bool>(
        builder: (BuildContext context) => UsersListPage(
          pageTitle: "Liked by",
          userIdsList: model.likeList.map((userId) => userId).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    authState = Provider.of<AuthState>(context, listen: false);
    return Container(
        child: Column(
      children: <Widget>[
        isWootDetail ? _timeWidget(context) : SizedBox(),
        isWootDetail ? _likeCommentWidget(context) : SizedBox(),
        _likeCommentsIcons(context, model)
      ],
    ));
  }
}
