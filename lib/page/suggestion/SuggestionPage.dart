import 'package:flutter/material.dart';
import 'package:wootter_x/helper/constant.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/model/user.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/state/suggestionState.dart';
import 'package:wootter_x/widgets/customAppBar.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:wootter_x/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({Key key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<StatefulWidget> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  AuthState authState;
  List<String> _selected = [];
  @override
  void initState() {
    super.initState();
  }

  void onSettingIconPressed() {
    Navigator.pushNamed(context, '/TrendsPage');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SuggestionState>(
      builder: (context, state, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: CustomAppBar(
            scaffoldKey: widget.scaffoldKey,
            isBackButton: true,
            onSearchChanged: (text) {
              state.filterByUsername(text);
            },
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await state.fetchSuggestions(authState.userModel);
              return Future.value(true);
            },
            child: ListView.separated(
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) => _UserTile(
                user: state.suggestionsList[index],
                isSelected:
                    _selected.contains(state.suggestionsList[index].userId),
                onTap: (String uid) async {
                  await state.addFollowing(
                    authState.userModel,
                    state.suggestionsList[index],
                  );
                },
              ),
              separatorBuilder: (_, index) => Divider(
                height: 0,
              ),
              itemCount: state.suggestionsList.length,
            ),
          ),
          // bottomSheet: Container(
          //   color: Colors.white,
          //   padding: EdgeInsets.all(8),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       GestureDetector(
          //         child: Text(
          //           "Skip for now",
          //           style: TextStyle(color: Colors.blue),
          //         ),
          //         onTap: () {
          //           Navigator.pop(context);
          //         },
          //       ),
          //       RaisedButton(
          //         color: Colors.blue,
          //         shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(25)),
          //         onPressed: () async {
          //           _selected.addAll(authState.userModel.followingList);
          //           await kDatabase
          //               .child('profile')
          //               .child(authState.userModel.userId)
          //               .update({
          //             "followingList": _selected,
          //             'following': _selected.length
          //           });
          //           Navigator.pop(context);
          //         },
          //         child: Text(
          //           "Save",
          //           style: TextStyle(color: Colors.white),
          //         ),
          //       )
          //     ],
          //   ),
          // ),
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({Key key, this.user, this.isSelected, this.onTap})
      : super(key: key);
  final MyUser user;
  final bool isSelected;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTap(user.userId),
      leading:
          customImage(context, user.profilePic, height: 40, isBorder: true),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: TitleText(
              user.displayName,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 3),
          user.isVerified
              ? customIcon(
                  context,
                  icon: AppIcon.blueTick,
                  istwitterIcon: true,
                  iconColor: TwitterColor.dodgetBlue,
                  size: 13,
                  paddingIcon: 3,
                )
              : SizedBox(width: 0),
        ],
      ),
      subtitle: Text(user.userName),
      trailing: buildFollow(),
    );
  }

  Widget buildFollow() {
    return FittedBox(
      child: Container(
        margin: EdgeInsets.only(left: 10, top: 10),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: TwitterColor.dodgetBlue),
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? TwitterColor.dodgetBlue.withOpacity(0.8)
              : TwitterColor.white,
        ),
        child: Center(
          child: Text(
            isSelected ? "Following" : "Follow",
            style: TextStyle(color: isSelected ? Colors.white : Colors.blue),
          ),
        ),
      ),
    );
  }
}
