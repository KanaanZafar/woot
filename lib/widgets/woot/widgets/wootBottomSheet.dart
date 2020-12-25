import 'package:flutter/material.dart';
import 'package:wootter_x/helper/constant.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/model/feedModel.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/state/feedState.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class WootBottomSheet {
  Widget wootOptionIcon(BuildContext context, FeedModel model, WootType type) {
    return customInkWell(
      radius: BorderRadius.circular(20),
      context: context,
      onPressed: () {
        _openbottomSheet(context, type, model);
      },
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: customIcon(
          context,
          icon: AppIcon.arrowDown,
          istwitterIcon: true,
          iconColor: AppColor.lightGrey,
        ),
      ),
    );
  }

  void _openbottomSheet(
      BuildContext context, WootType type, FeedModel model) async {
    var authState = Provider.of<AuthState>(context, listen: false);
    bool isMyWoot = authState.userId == model.userId;
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        print("Bootom SHeet of woot");
        return Container(
            padding: EdgeInsets.only(top: 5, bottom: 0),
            height: fullHeight(context) *
                (type == WootType.Woot
                    ? (isMyWoot ? .25 : .44)
                    : (isMyWoot ? .38 : .52)),
            width: fullWidth(context),
            decoration: BoxDecoration(
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: type == WootType.Woot
                ? _wootOptions(context, isMyWoot, model, type)
                : _wootDetailOptions(context, isMyWoot, model, type));
      },
    );
  }

  Widget _wootDetailOptions(
      BuildContext context, bool isMyWoot, FeedModel model, WootType type) {
    return Column(
      children: <Widget>[
        Container(
          width: fullWidth(context) * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.link,
          text: 'Copy link to woot',
        ),
        isMyWoot
            ? _widgetBottomSheetRow(
                context,
                AppIcon.unFollow,
                text: 'Pin to profile',
              )
            : _widgetBottomSheetRow(
                context,
                AppIcon.unFollow,
                text: 'Unfollow ${model.user.userName}',
              ),
        isMyWoot
            ? _widgetBottomSheetRow(
                context,
                AppIcon.delete,
                text: 'Delete Woot',
                onPressed: () {
                  _deleteWoot(
                    context,
                    type,
                    model.key,
                    parentkey: model.parentkey,
                  );
                },
                isEnable: true,
              )
            : Container(),
        isMyWoot
            ? Container()
            : _widgetBottomSheetRow(
                context,
                AppIcon.mute,
                text: 'Mute ${model.user.userName}',
              ),
        _widgetBottomSheetRow(
          context,
          AppIcon.mute,
          text: 'Mute this convertion',
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.viewHidden,
          text: 'View hidden replies',
        ),
        isMyWoot
            ? Container()
            : _widgetBottomSheetRow(
                context,
                AppIcon.block,
                text: 'Block ${model.user.userName}',
              ),
        isMyWoot
            ? Container()
            : _widgetBottomSheetRow(
                context,
                AppIcon.report,
                text: 'Report Woot',
              ),
      ],
    );
  }

  Widget _wootOptions(
      BuildContext context, bool isMyWoot, FeedModel model, WootType type) {
    return Column(
      children: <Widget>[
        Container(
          width: fullWidth(context) * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.link,
          text: 'Copy link to woot',
        ),
        isMyWoot
            ? _widgetBottomSheetRow(
                context,
                AppIcon.thumbpinFill,
                text: 'Pin to profile',
              )
            : _widgetBottomSheetRow(
                context,
                AppIcon.sadFace,
                text: 'Not interested in this',
              ),
        isMyWoot
            ? _widgetBottomSheetRow(
                context,
                AppIcon.delete,
                text: 'Delete Woot',
                onPressed: () {
                  _deleteWoot(
                    context,
                    type,
                    model.key,
                    parentkey: model.parentkey,
                  );
                },
                isEnable: true,
              )
            : Container(),
        isMyWoot
            ? Container()
            : _widgetBottomSheetRow(
                context,
                AppIcon.unFollow,
                text: 'Unfollow ${model.user.userName}',
              ),
        isMyWoot
            ? Container()
            : _widgetBottomSheetRow(
                context,
                AppIcon.mute,
                text: 'Mute ${model.user.userName}',
              ),
        isMyWoot
            ? Container()
            : _widgetBottomSheetRow(
                context,
                AppIcon.block,
                text: 'Block ${model.user.userName}',
              ),
        isMyWoot
            ? Container()
            : _widgetBottomSheetRow(
                context,
                AppIcon.report,
                text: 'Report Woot',
              ),
      ],
    );
  }

  Widget _widgetBottomSheetRow(BuildContext context, int icon,
      {String text, Function onPressed, bool isEnable = false}) {
    return Expanded(
      child: customInkWell(
        context: context,
        onPressed: () {
          if (onPressed != null)
            onPressed();
          else {
            Navigator.pop(context);
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: <Widget>[
              customIcon(
                context,
                icon: icon,
                istwitterIcon: true,
                size: 25,
                paddingIcon: 8,
                iconColor: isEnable ? AppColor.darkGrey : AppColor.lightGrey,
              ),
              SizedBox(
                width: 15,
              ),
              customText(
                text,
                context: context,
                style: TextStyle(
                  color: isEnable ? AppColor.secondary : AppColor.lightGrey,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _deleteWoot(BuildContext context, WootType type, String wootId,
      {String parentkey}) {
    var state = Provider.of<FeedState>(context, listen: false);
    state.deleteWoot(wootId, type, parentkey: parentkey);
    // CLose bottom sheet
    Navigator.of(context).pop();
    if (type == WootType.Detail) {
      // Close Woot detail page
      Navigator.of(context).pop();
      // Remove last woot from woot detail stack page
      state.removeLastWootDetail(wootId);
    }
  }

  void openRewootbottomSheet(
      BuildContext context, WootType type, FeedModel model) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
            padding: EdgeInsets.only(top: 5, bottom: 0),
            height: 130,
            width: fullWidth(context),
            decoration: BoxDecoration(
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: _rewoot(context, model, type));
      },
    );
  }

  Widget _rewoot(BuildContext context, FeedModel model, WootType type) {
    return Column(
      children: <Widget>[
        Container(
          width: fullWidth(context) * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.rewoot,
          text: 'Rewoot',
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.edit,
          text: 'Rewoot with comment',
          isEnable: true,
          onPressed: () {
            var state = Provider.of<FeedState>(context, listen: false);
            // Prepare current Woot model to reply
            state.setWootToReply = model;
            Navigator.pop(context);

            /// `/ComposeWootPage/rewoot` route is used to identify that woot is going to be rewoot.
            /// To simple reply on any `Woot` use `ComposeWootPage` route.
            Navigator.of(context).pushNamed('/ComposeWootPage/rewoot');
          },
        )
      ],
    );
  }
}
