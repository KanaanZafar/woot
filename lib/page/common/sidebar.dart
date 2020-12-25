import 'package:flutter/material.dart';
import 'package:wootter_x/helper/constant.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:wootter_x/widgets/newWidget/customUrlText.dart';
import 'package:provider/provider.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({Key key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {

  AuthState state;

  @override
  void initState() {
    state = Provider.of<AuthState>(context,listen: false);
    super.initState();
  }

  Widget _menuHeader() {
    if (state.userModel == null) {
      return customInkWell(
        context: context,
        onPressed: () {
          //  Navigator.of(context).pushNamed('/signIn');
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 200, minHeight: 100),
          child: Center(
            child: Text(
              'Login to continue',
              style: onPrimaryTitleText,
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 56,
              width: 56,
              margin: EdgeInsets.only(left: 17, top: 10),
              decoration: BoxDecoration(
//                border: Border.all(color: Colors.white, width: 0),
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                  image: customAdvanceNetworkImage(
                    state.userModel.profilePic ?? dummyProfilePic,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                _navigateTo('ProfilePage/'+ state.user.uid);
              },
              title: Row(
                children: <Widget>[
                  UrlText(
                    text: state.userModel.displayName ?? "",
                    style: onPrimaryTitleText.copyWith(
                        color: Colors.black, fontSize: 20),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  state.userModel.isVerified ?? false
                      ? customIcon(context,
                          icon: AppIcon.blueTick,
                          istwitterIcon: true,
                          iconColor: TwitterColor.dodgetBlue,
                          size: 18,
                          paddingIcon: 3)
                      : SizedBox(
                          width: 0,
                        ),
                ],
              ),
              subtitle: customText(
                state.userModel.userName,
                style: onPrimarySubTitleText.copyWith(
                    color: Colors.black54, fontSize: 15),
              ),
              trailing: customIcon(context,
                  icon: AppIcon.arrowDown,
                  iconColor: TwitterColor.dodgetBlue,
                  paddingIcon: 20),
            ),
            Container(
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 17,
                  ),
                  _tappbleText(context, '${state.userModel.getFollower()}',
                      ' Followers', 'FollowerListPage'),
                  SizedBox(width: 10),
                  _tappbleText(context, '${state.userModel.getFollowing()}',
                      ' Following', 'FollowingListPage'),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _tappbleText(
      BuildContext context, String count, String text, String navigateTo) {
    return InkWell(
      onTap: () {
        var authstate = Provider.of<AuthState>(context, listen: false);
        // authstate.profileFollowingList = [];
        /// check whether getProfileUser() is needed or not?....
        // authstate.getProfileUser();
        print(navigateTo);
        _navigateTo(navigateTo);
      },
      child: Row(
        children: <Widget>[
          customText(
            '$count ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          customText(
            '$text',
            style: TextStyle(color: AppColor.darkGrey, fontSize: 17),
          ),
        ],
      ),
    );
  }

  ListTile _menuListRowButton(String title, IconData i,
      {Function onPressed, int icon, bool isEnable = false}) {
    return ListTile(
      onTap: () {
        if (onPressed != null) {
          onPressed();
        }
      },
      leading: icon == null
          ? null
          : Padding(
              padding: EdgeInsets.only(top: 5),
              child: customIcon(
                context,
                icon: icon,
                size: 27,
                icondata: i,
                iconColor: isEnable ? AppColor.darkGrey : AppColor.lightGrey,
              ),
            ),
      title: customText(
        title,
        style: TextStyle(
          fontSize: 20,
          color: isEnable ? AppColor.secondary : AppColor.lightGrey,
        ),
      ),
    );
  }

  Positioned _footer() {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Column(
        children: <Widget>[
          Divider(height: 0),
          Row(
            children: <Widget>[
              SizedBox(
                width: 10,
                height: 45,
              ),
              customIcon(context,
                  icon: AppIcon.bulbOn,
                  istwitterIcon: true,
                  size: 25,
                  iconColor: TwitterColor.dodgetBlue),
              Spacer(),
              Image.asset(
                "assets/images/qr.png",
                height: 25,
              ),
              SizedBox(
                width: 10,
                height: 45,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _logOut() {
    final state = Provider.of<AuthState>(context, listen: false);
    Navigator.pop(context);
    state.logoutCallback();
  }

  void _navigateTo(String path) {
    Navigator.pop(context);
    Navigator.of(context).pushNamed('/$path');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 45),
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  Container(
                    child: _menuHeader(),
                  ),
                  Divider(),
                  _menuListRowButton('Profile', Icons.person_outline,
                      icon: AppIcon.profile, isEnable: true, onPressed: () {
                    print(state.user.uid);
                    _navigateTo('ProfilePage/'+ state.user.uid);
                  }),
//                  _menuListRowButton('Lists', Icons.list,icon: AppIcon.lists, ),
                  _menuListRowButton('Topics', Icons.add_circle_outline,
                      isEnable: true, icon: AppIcon.lists, onPressed: () {
                    _navigateTo('TopicsPage');
                  }),
                  _menuListRowButton('Bookamrks', Icons.bookmark_border,
                      icon: AppIcon.bookmark),
//                  _menuListRowButton('Moments', Icons.event,icon: AppIcon.moments),
                  _menuListRowButton('Wootter ads', Icons.add_to_home_screen,
                      icon: AppIcon.twitterAds),
                  Divider(),
                  _menuListRowButton('Settings and privacy', Icons.settings,
                      isEnable: true, onPressed: () {
                    _navigateTo('SettingsAndPrivacyPage');
                  }),
//                  _menuListRowButton('Help Center',Icons.help_outline ),
                  Divider(),
                  _menuListRowButton('Logout', Icons.power_settings_new,
                      icon: null, onPressed: _logOut, isEnable: true),
                ],
              ),
            ),
            _footer()
          ],
        ),
      ),
    );
  }
}
