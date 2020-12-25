import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wootter_x/helper/constant.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/model/feedModel.dart';
import 'package:wootter_x/state/feedState.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:wootter_x/widgets/newWidget/customUrlText.dart';
import 'package:wootter_x/widgets/newWidget/rippleButton.dart';
import 'package:wootter_x/widgets/newWidget/title_text.dart';
import 'package:wootter_x/widgets/woot/components/video_thumbnail.dart';
import 'package:wootter_x/widgets/woot/widgets/wootImage.dart';
import 'package:wootter_x/widgets/woot/widgets/unavailableWoot.dart';
import 'package:provider/provider.dart';

class RewootWidget extends StatelessWidget {
  const RewootWidget(
      {Key key, this.childRetwetkey, this.type, this.isImageAvailable = false, bool isDetailed})
      : super(key: key);

  final String childRetwetkey;
  final bool isImageAvailable;
  final WootType type;

  Widget _woot(BuildContext context, FeedModel model) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          width: fullWidth(context) - 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                width: 25,
                height: 25,
                child: customImage(context, model.user.profilePic),
              ),
              SizedBox(width: 10),
              ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: 0, maxWidth: fullWidth(context) * .5),
                child: TitleText(
                  model.user.displayName,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  overflow: TextOverflow.ellipsis,
                ),
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
              Flexible(
                child: customText(
                  '${model.user.userName}',
                  style: userNameStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 4),
              customText('· ${getChatTime(model.createdAt)}',
                  style: userNameStyle),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: UrlText(
            text: model.description,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            urlStyle:
                TextStyle(color: Colors.blue, fontWeight: FontWeight.w400),
          ),
        ),
        SizedBox(height: model.imagePath == null ? 8 : 0),

        model.imagePath != null && model.imagePath.isNotEmpty ? ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          child: Container(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
            // color: TwitterColor.dodgetBlue_50,
            child: WootImage(model: model, type: type, isRewootImage: true),
          ),
        ) : Container(),

        model.video != null && model.video.isNotEmpty ? Container(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
          // color: TwitterColor.dodgetBlue_50,
          child: VideoThumbnailWidget(
            path: model.video,
            model: model,
            type: WootType.Reply,
          ),
        ) : Container()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var feedstate = Provider.of<FeedState>(context, listen: false);
    return FutureBuilder<FeedModel>(
      future: feedstate.fetchWoot(childRetwetkey),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(
                left: type == WootType.Woot || type == WootType.ParentWoot
                    ? 70
                    : 16,
                right: 16,
                top: isImageAvailable ? 8 : 5),
            alignment: Alignment.topCenter,
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.extraLightGrey, width: .5),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: RippleButton(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              onPressed: () {
                feedstate.getpostDetailFromDatabase(null, model: snapshot.data);
                Navigator.of(context)
                    .pushNamed('/FeedPostDetail/' + snapshot.data.key);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: _woot(context, snapshot.data),
              ),
            ),
          );
        }
        if ((snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.waiting) &&
            !snapshot.hasData) {
          return UnavailableWoot(
            snapshot: snapshot,
            type: type,
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
