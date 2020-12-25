import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wootter_x/helper/constant.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/model/feedModel.dart';
import 'package:wootter_x/widgets/woot/components/video_thumbnail.dart';
import 'package:wootter_x/widgets/woot/components/woot_pool.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/state/feedState.dart';
import 'package:wootter_x/widgets/newWidget/customUrlText.dart';
import 'package:wootter_x/widgets/newWidget/title_text.dart';
import 'package:wootter_x/widgets/woot/widgets/parentWoot.dart';
import 'package:wootter_x/widgets/woot/widgets/wootIconsRow.dart';
import 'package:provider/provider.dart';

import '../customWidgets.dart';
import 'widgets/rewootWidget.dart';
import 'widgets/wootImage.dart';

class Woot extends StatelessWidget {
  final FeedModel model;
  final Widget trailing;
  final WootType type;
  final bool isDisplayOnProfile;
  final bool isTop;
  final bool isDetailed;
  const Woot(
      {Key key,
      this.model,
      this.trailing,
      this.type = WootType.Woot,
      this.isDisplayOnProfile = false,
      this.isTop = false, this.isDetailed = false})
      : super(key: key);

  void onLongPressedWoot(BuildContext context) {
    if (type == WootType.Detail || type == WootType.ParentWoot) {
      var text = ClipboardData(text: model.description);
      Clipboard.setData(text);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: TwitterColor.black,
          content: Text(
            'Woot description is copied to clipboard',
          ),
        ),
      );
    }
  }

  void onTapWoot(BuildContext context) {
    var feedstate = Provider.of<FeedState>(context, listen: false);
    if (type == WootType.Detail || type == WootType.ParentWoot) {
      return;
    }
    if (type == WootType.Woot && !isDisplayOnProfile) {
      feedstate.clearAllDetailAndReplyWootStack();
    }
    feedstate.getpostDetailFromDatabase(null, model: model);
    Navigator.of(context).pushNamed('/FeedPostDetail/' + model.key);
  }

  @override
  Widget build(BuildContext context) {
    // var vidoeP = model.video != null ? 8.0 : 0.0;
    return Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        /// Left vertical bar of a woot
        type != WootType.ParentWoot
            ? SizedBox.shrink()
            : Positioned.fill(
                child: Container(
                  margin: EdgeInsets.only(
                    left: 38,
                    top: 75,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(width: 3.0, color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ),
        InkWell(
          onLongPress: () {
            onLongPressedWoot(context);
          },
          onTap: () {
            onTapWoot(context);
          },
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  top: type == WootType.Woot || type == WootType.Reply ? 10 : 0,
                ),
                child: type == WootType.Woot || type == WootType.Reply
                    ? _WootBody(
                        isDisplayOnProfile: isDisplayOnProfile,
                        model: model,
                        trailing: trailing,
                        type: type,
                        isDetailed: isDetailed,
                      )
                    : WootDetailBody(
                        isDisplayOnProfile: isDisplayOnProfile,
                        model: model,
                        trailing: trailing,
                        type: type,
                      ),
              ),
              Container(
                padding: EdgeInsets.only(left: 15),
                margin: EdgeInsets.only(right: type == WootType.Detail ? 15 : 25),
                child: WootImage(
                  model: model,
                  type: type,
                ),
              ),
              Container(
                padding: EdgeInsets.all(model.video != null ? 8.0 : 0.0),
                margin: EdgeInsets.symmetric(horizontal: type == WootType.Detail ? 7 : 0),
                child: model.video != null && type == WootType.Detail
                    ? VideoThumbnailWidget(
                        path: model.video,
                        model: model,
                        type: type,
                      )
                    : Container(),
              ),
              Padding(
                padding: EdgeInsets.all(model.pool != null ? 15.0 : 0),
                child: model.pool != null && type == WootType.Detail
                    ? WootPoll(
                        createrId: model.userId,
                        description: "",
                        poll: model.pool,
                        userId: context
                            .select<AuthState, String>((value) => value.userId),
                        wookKey: model.key,
                      )
                    : Container(),
              ),
              model.childRewootkey == null
                  ? SizedBox.shrink()
                  : RewootWidget(
                      childRetwetkey: model.childRewootkey,
                      type: type,
                      isDetailed: isDetailed,
                      isImageAvailable:
                          model.imagePath != null && model.imagePath.isNotEmpty
                      || model.video != null && model.video.isNotEmpty,
                    ),
              Padding(
                padding:
                    EdgeInsets.only(left: type == WootType.Detail ? 10 : 60),

                /// decrease 60
                child: WootIconsRow(
                  type: type,
                  model: model,
                  isWootDetail: type == WootType.Detail,

                  /// woot option color
                  iconColor:
                      Colors.grey /*Theme.of(context).textTheme.caption.color*/,
                  iconEnableColor: TwitterColor.dodgetBlue,
                  size: 19,
                ),
              ),
              type == WootType.ParentWoot
                  ? SizedBox.shrink()
                  : Divider(height: .5, thickness: .5)
            ],
          ),
        ),
      ],
    );
  }
}

class _WootBody extends StatelessWidget {
  final FeedModel model;
  final Widget trailing;
  final WootType type;
  final bool isDisplayOnProfile;
  final bool isDetailed;
  _WootBody(
      {Key key, this.model, this.trailing, this.type, this.isDisplayOnProfile,
      this.isDetailed = false}) : super(key: key);

  double descriptionFontSize = 0.0;
  FontWeight descriptionFontWeight;

  @override
  Widget build(BuildContext context) {

    // if(model.description == 'today video')
    //   print(model.key + " key key");
    descriptionFontSize = type == WootType.Woot
        ? 15
        : type == WootType.Detail || type == WootType.ParentWoot
            ? 18
            : 14;
    descriptionFontWeight = type == WootType.Woot || type == WootType.Woot
        ? FontWeight.w400
        : FontWeight.w400;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: 10),
        Container(
//              color: Colors.blue,
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              // If woot is displaying on someone's profile then no need to navigate to same user's profile again.
              if (isDisplayOnProfile) {
                return;
              }
              Navigator.of(context)
                  .pushNamed('/ProfilePage/' + model?.userId);
            },
            child: customImage(context, model.user.profilePic),
          ),
        ),
        SizedBox(width: 15),
        Container(
          padding: EdgeInsets.zero,
          width: fullWidth(context) - 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth: 0,
                              maxWidth: fullWidth(context) * .5),
                          child: TitleText(model.user.displayName,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              overflow: TextOverflow.ellipsis),
                        ),
                        SizedBox(width: 3),
                        model.user.isVerified
                            ? customIcon(
                                context,
                                icon: AppIcon.blueTick,
                                istwitterIcon: true,
                                iconColor: TwitterColor.dodgetBlue,
                                size: 13,
                                paddingIcon: 3,
                              )
                            : SizedBox(width: 0),
                        SizedBox(
                          width: model.user.isVerified ? 5 : 0,
                        ),
                        _userRating(),
                        SizedBox(width: 4),
                        customText('· ${getChatTime(model.createdAt.toString())}',
                            style: userNameStyle),
                      ],
                    ),
                  ),
                  Container(
                      child: trailing == null ? SizedBox() : trailing),
                ],
              ),
              Container(
                child: customText(
                  '${model.user.userName}',
                  style: userNameStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              buildWootOnType(context, model, type)
            ],
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget buildWootOnType(BuildContext context, FeedModel feed, WootType type) {
    var _user = Provider.of<AuthState>(context, listen: false);
    if (feed.pool != null) {
      return WootPoll(
        createrId: feed.user.userId,
        description: feed.description,
        wookKey: feed.key,
        poll: feed.pool,
        userId: _user.userModel.userId,
      );
    } else if (feed.video != null && feed.video.length > 0) {
      return Padding(
        padding: isDetailed ? EdgeInsets.only(left: 25) : EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UrlText(
              text: model.description,
              onHashTagPressed: (tag) {
                cprint(tag);
              },
              style: TextStyle(
                color: Colors.black,
                fontSize: descriptionFontSize,
                fontWeight: descriptionFontWeight,
              ),
              urlStyle: TextStyle(
                color: Colors.blue,
                fontSize: descriptionFontSize,
                fontWeight: descriptionFontWeight,
              ),
            ),
            SizedBox(height: 8),
            VideoThumbnailWidget(
              path: feed.video,
              model: feed,
              type: type,
            ),
            SizedBox(height: 5),
            Text("${model.views??0} views", style: TextStyle(fontSize: 13))
          ],
        ),
      );
    }
    return UrlText(
      text: model.description,
      onHashTagPressed: (tag) {
        cprint(tag);
      },
      style: TextStyle(
        color: Colors.black,
        fontSize: descriptionFontSize,
        fontWeight: descriptionFontWeight,
      ),
      urlStyle: TextStyle(
        color: Colors.blue,
        fontSize: descriptionFontSize,
        fontWeight: descriptionFontWeight,
      ),
    );
  }

  Widget ratingStarBuild(IconData iconData) {
    return Icon(iconData, size: 16, color: TwitterColor.starColor);
  }

  Widget _userRating() {
    return StreamBuilder<Event>(
      stream: kDatabase.child('rating').child(model.user.userId).onValue,
      builder: ((BuildContext context, AsyncSnapshot<Event> as) {
        Widget showRating(
            {String pattern = '00000',
            isFatched = false,
            Map rateProfile = null}) {
          _post() {
            pattern = '00000';
            var starter = {
              'ratingPattern': pattern,
              'totalLikes': 0,
              'totalDisLikes': 0
            };
            kDatabase.child('rating').child(model.user.userId).update(starter);
          }

          if (rateProfile == null && isFatched) {
            _post();
          } else if (isFatched) {
            pattern = rateProfile['ratingPattern'];
            model.user.totalLikes = rateProfile['totalLikes'];
            model.user.totalDisLikes = rateProfile['totalDisLikes'];
          }
          model.user.ratingPattern = pattern;
          return Row(
            children: List.generate(5, (index) {
//                                print(model.user.ratingPattern[index]);
              switch (model.user.ratingPattern[index]) {
                case '0':
                  return ratingStarBuild(Icons.star_border);
                  break;
                case '1':
                  return ratingStarBuild(Icons.star_half);
                  break;
                default:
                  return ratingStarBuild(Icons.star);
                  break;
              }
            }).toList(),
          );
        }

        switch (as.connectionState) {
          case ConnectionState.waiting:
            return showRating();
            break;
//          case ConnectionState.done:
//            return showRating(pattern : '11111');
//            break;
          default:
            {
//            print("as = ${as.data.snapshot.value}");
              return showRating(
                  isFatched: true, rateProfile: as.data.snapshot.value);
            }
        }
      }),
    );
  }
}

class WootDetailBody extends StatelessWidget {
  final FeedModel model;
  final Widget trailing;
  final WootType type;
  final bool isDisplayOnProfile;
  final bool isTop;
  const WootDetailBody(
      {Key key,
      this.model,
      this.trailing,
      this.type,
      this.isTop = false,
      this.isDisplayOnProfile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double descriptionFontSize = type == WootType.Woot || type == WootType.Pool
        ? getDimention(context, 15)
        : type == WootType.Detail
            ? getDimention(context, 18)
            : type == WootType.ParentWoot
                ? getDimention(context, 14)
                : 10;

    FontWeight descriptionFontWeight = FontWeight.w400;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        model.parentkey != null &&
                model.childRewootkey == null &&
                type != WootType.ParentWoot
            ? ParentWootWidget(
                childRetwetkey: model.parentkey,
                isImageAvailable: false,
                trailing: trailing)
            : SizedBox.shrink(),
        Container(
          width: fullWidth(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              !isTop
                  ? ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      leading: GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed('/ProfilePage/' + model?.userId);
                        },
                        child: customImage(context, model.user.profilePic),
                      ),
                      title: Row(
                        children: <Widget>[
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                minWidth: 0, maxWidth: fullWidth(context) * .5),
                            child: TitleText(model.user.displayName,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                overflow: TextOverflow.ellipsis),
                          ),
                          SizedBox(width: 3),
                          model.user.isVerified
                              ? customIcon(
                                  context,
                                  icon: AppIcon.blueTick,
                                  istwitterIcon: true,
                                  iconColor: AppColor.primary,
                                  size: 13,
                                  paddingIcon: 3,
                                )
                              : SizedBox(width: 0),
                          SizedBox(
                            width: model.user.isVerified ? 5 : 0,
                          ),
                        ],
                      ),
                      subtitle: customText('${model.user.userName}',
                          style: userNameStyle),
                      trailing: trailing,
                    )
                  : Container(),
              Padding(
                padding: type == WootType.ParentWoot
                    ? EdgeInsets.only(left: 80, right: 16)
                    : EdgeInsets.symmetric(horizontal: 16),
                child: UrlText(
                  text: model.description,
                  onHashTagPressed: (tag) {
                    cprint(tag);
                  },
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: descriptionFontSize,
                    fontWeight: descriptionFontWeight,
                  ),
                  urlStyle: TextStyle(
                    color: Colors.blue,
                    fontSize: descriptionFontSize,
                    fontWeight: descriptionFontWeight,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
