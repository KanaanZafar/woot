import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wootter_x/helper/constant.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/model/feedModel.dart';
import 'package:wootter_x/model/user.dart';
import 'package:wootter_x/page/Auth/widget/checkContactVerification.dart';
import 'package:wootter_x/page/profile/widgets/tabPainter.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/state/chats/chatState.dart';
import 'package:wootter_x/state/feedState.dart';
import 'package:wootter_x/state/searchState.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:wootter_x/widgets/newWidget/customLoader.dart';
import 'package:wootter_x/widgets/newWidget/emptyList.dart';
import 'package:wootter_x/widgets/newWidget/rippleButton.dart';
import 'package:wootter_x/widgets/woot/woot.dart';
import 'package:wootter_x/widgets/woot/widgets/wootBottomSheet.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.profileId}) : super(key: key);

  final String profileId;

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool isMyProfile = false;
  int pageIndex = 0;
  AuthState authState;
  FeedState feedState;
  List<FeedModel> list;
  List<FeedModel> likedList;
  MyUser myProfileUser;
  SearchState searchState;

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
      authState = Provider.of<AuthState>(context, listen: false);
      searchState = Provider.of<SearchState>(context, listen: false);
      var x;

      if (widget.profileId != authState.user.uid) {
        x = searchState.userlist.firstWhere(
                (element) => element.userId == widget.profileId);
        if (x.userId == widget.profileId) {
          authState..setProfileUserModel = x;
        } else
          authState.getProfileUser(userProfileId: widget.profileId);
      } else
        authState..setProfileUserModel = authState.userModel;
      _tabController = TabController(length: 4, vsync: this);

      // });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  SliverAppBar getAppbar() {
//    var authstate = Provider.of<AuthState>(context);
    return SliverAppBar(
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: TwitterColor.white,
      title: Text("Profile"),
    );
  }

  _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
        // heroTag: 'wootButton',
        onPressed: () {
          var x = authState.userModel?.contact?.length??0;
          if (authState.userModel.isContactVerified &&
               x > 9) {
            print("creating woot");
            Navigator.of(context).pushNamed('/CreateFeedPage/woot');
          } else {
            print("Contact number needed");
            ContactVerification(context).plateFormCheck();
          }
        },
        child: Text("W+",
            style: TextStyle(fontWeight: FontWeight.bold), textScaleFactor: 1));
  }

  Widget _emptyBox() {
    return SliverToBoxAdapter(child: SizedBox.shrink());
  }


  /// This meathod called when user pressed back button
  /// When profile page is about to close
  /// Maintain minimum user's profile in profile page list
  Future<bool> _onWillPop() async {
    try {
      final state = Provider.of<AuthState>(context, listen: false);
      /// It will remove last user's profile from profileUserModelList
      state.removeLastUser();
    } catch (e) {
      cprint(e.toString(), errorIn: '__willPop@profilePage__');
    }
    return true;
  }

  TabController _tabController;

  @override
  build(BuildContext context) {
    isMyProfile =
        widget.profileId == null || widget.profileId == authState.userId;

    feedState = Provider.of<FeedState>(context);
    var authstate = Provider.of<AuthState>(context);
    String id = widget.profileId ?? authstate.userId;

    log(widget.profileId);

    /// Filter user's woot among all woots available in home page woots list
    if (feedState.feedlist != null && feedState.feedlist.length > 0) {
      list = feedState.feedlist.where((x) => x.userId == id).toList();
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        floatingActionButton:
            !isMyProfile ? null : _floatingActionButton(context),
        backgroundColor: TwitterColor.mystic,
        body: SafeArea(
          child: NestedScrollView(
            // controller: _scrollController,
            headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
              return <Widget>[
//                SliverToBoxAdapter(
//                  child: Container(
//                    height: 20,
////                    color: Colors.pinkAccent,
////                    child: Text("aa"),
//                  ),
//                ),
                authstate.isbusy
                    ? _emptyBox()
                    : SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    child: authstate.isbusy
                        ? SizedBox.shrink()
                        : UserNameRowWidget(
                      user: authstate.profileUserModel,
                      isMyProfile: isMyProfile,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        color: TwitterColor.white,
                        child: TabBar(
                          indicator: TabIndicator(),
                          isScrollable: true,
                          controller: _tabController,
                          tabs: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: fullWidth(context) / 15),
                              child: Text("Woots"),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: fullWidth(context) / 15),
                              child: Text("Woots & replies"),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: fullWidth(context) / 15),
                              child: Text("Media"),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: fullWidth(context) / 15),
                              child: Text("Liked"),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                /// Display all independent woot list
                _wootList(context, authstate, list, false, false),

                /// Display all reply woot list
                _wootList(context, authstate, list, true, false),

                /// Display all media list
                _wootList(context, authstate, list, false, true),

                /// Display all liked woots
                _wootList(context, authstate, list, true, true, isLiked: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _wootList(BuildContext context, AuthState authstate,
      List<FeedModel> wootsList, bool isreply, bool isMedia,
      {bool isLiked = false}) {
    List<FeedModel> list;

    if (isLiked && !(wootsList == null)) {
      // print(widget.profileId);
      list = feedState?.feedlist.where((x) {
        /// ? for not getting error screen...after error it will dispose once we
        /// get the requested user's profile data....
        if (x.likeList.contains(authstate.profileUserModel?.userId)) return true;
        return false;
      }).toList();
    } else {
      /// If user hasn't wooted yet
      if (wootsList == null) {
        cprint('No Woot avalible');
      } else if (isMedia) {
        /// Display all Woots with media file

        list = wootsList.where((x) => x.imagePath != null || x.video != null).toList();
      } else if (!isreply) {
        /// Display all independent Woots
        /// No comments Woot will display

        list = wootsList
            .where((x) => x.parentkey == null || x.childRewootkey != null)
            .toList();
      } else {
        /// Display all reply Woots
        /// No intependent woot will display
        list = wootsList
            .where((x) => x.parentkey != null && x.childRewootkey == null)
            .toList();
      }
    }

    /// if [authState.isbusy] is true then an loading indicator will be displayed on screen.
    return authstate.isbusy
        ? Container(
            height: fullHeight(context) - 180,
            child: CustomScreenLoader(
              height: double.infinity,
              width: fullWidth(context),
              backgroundColor: Colors.white,
            ),
          )

        /// if woot list is empty or null then need to show user a message
        : list == null || list.length < 1
            ? Container(
                padding: EdgeInsets.only(top: 50, left: 30, right: 30),
                child: NotifyText(
                  title: isMyProfile
                      ? 'You haven\'t ${isLiked ? 'liked any Woot yet' : isreply ? 'reply to any Woot' : isMedia ? 'post any media Woot yet' : 'post any Woot yet'}'
                      : '${authstate?.profileUserModel.userName} hasn\'t ${isLiked ? 'liked any Woot yet' : isreply ? 'reply to any Woot' : isMedia ? 'post any media Woot yet' : 'post any Woot yet'}',
                  subTitle:
                      "    " /*isMyProfile
            ? 'Tap woot button to add new'
            : 'Once he\'ll do, they will be shown up here'*/
                  ,
                ),
              )

            /// If woots available then woot list will displayed
            : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 0),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  // print(' building woots--');
                  return Container(
                    color: TwitterColor.white,
                    child: Woot(
                      model: list[index],
                      isDisplayOnProfile: true,
                      trailing: WootBottomSheet().wootOptionIcon(
                        context,
                        list[index],
                        WootType.Woot,
                      ),
                    ),
                  );
                },
              );
  }
}

class UserNameRowWidget extends StatelessWidget {
  UserNameRowWidget({
    Key key,
    @required this.user,
    @required this.isMyProfile,
  }) : super(key: key);

  final bool isMyProfile;
  final MyUser user;
  AuthState authState;

  String getBio(String bio) {
    if (isMyProfile) {
      return bio;
    } else if (bio == "Edit profile to update bio") {
      return "No bio available";
    } else {
      return bio;
    }
  }

  Widget _tappbleText(
      BuildContext context, String count, String text, [String navigateTo]) {
    return InkWell(
      onTap: () {
        if (navigateTo != null)
          Navigator.pushNamed(context, '/$navigateTo');
      },
      child: Row(
        children: <Widget>[
          customText(
            '$count ',
            style: TextStyle(
                color: AppColor.darkGrey,
                fontWeight: FontWeight.w400,
                fontSize: 18),
          ),
          SizedBox(width: 2),
          customText(
            '$text',
            style: TextStyle(
                color: TwitterColor.dodgetBlue,fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget userRating() {
    return FutureBuilder<DataSnapshot>(
      future: kDatabase.reference().child('rating').child(user.userId).once(),
      builder: (BuildContext context, ds) {
        Widget showRating({String pattern = '00000'}) {
          return Row(
            children: List.generate(5, (index) {
              switch (pattern[index]) {
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

        switch (ds.connectionState) {
          case ConnectionState.waiting:
            return showRating();
            break;
          case ConnectionState.done:
            if (ds.data.value != null)
              return showRating(pattern: ds.data.value['ratingPattern']);
            return showRating();
            break;
          default:
            {
              return showRating(pattern: '00000');
            }
        }
      },
    );
  }

  Widget ratingStarBuild(IconData iconData) {
    return Icon(iconData, size: 18, color: TwitterColor.starColor);
  }

  isFollower(BuildContext context) {
    var authstate = Provider.of<AuthState>(context, listen: false);
    if (authstate.profileUserModel.followersList != null &&
        authstate.profileUserModel.followersList.isNotEmpty) {
      return (authstate.profileUserModel.followersList
          .any((x) => x == authstate.user.uid));
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    authState = Provider.of<AuthState>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: FittedBox(
            child: Row(
              children: <Widget>[
                AnimatedContainer(
                  padding: EdgeInsets.all(5),
                  duration: Duration(milliseconds: 500),
//                padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 0),
                      shape: BoxShape.rectangle),
                  child: RippleButton(
                    child: customImage(
                        context, authState.profileUserModel.profilePic,
                        height: 80, isBorder: true),
                    borderRadius: BorderRadius.circular(5),
                    onPressed: () {
                      Navigator.pushNamed(context, "/ProfileImageView");
                    },
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          user.displayName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                          textScaleFactor: 1,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        user.isVerified
                            ? customIcon(context,
                                icon: AppIcon.blueTick,
                                istwitterIcon: true,
                                iconColor: TwitterColor.dodgetBlue,
                                size: 13,
                                paddingIcon: 3)
                            : SizedBox(width: 0),
                        userRating(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(9, 0, 20, 0),
                          child: customText(
                            '${user.userName}',
                            style: subtitleStyle.copyWith(fontSize: 13),
                          ),
                        ),
                        SizedBox(width: 10),
                        isMyProfile
                            ? Container()
                            : RippleButton(
                                splashColor: TwitterColor.dodgetBlue_50,
//                              .withAlpha(100),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),

                                onPressed: () {
                                  if (!isMyProfile) {
                                    final chatState = Provider.of<ChatState>(
                                        context,
                                        listen: false);
                                    chatState.setChatUser =
                                        authState.profileUserModel;
                                    Navigator.pushNamed(
                                        context, '/ChatScreenPage');
                                  }
                                },
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  padding: EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: isMyProfile
                                              ? Colors.black87.withAlpha(180)
                                              : TwitterColor.dodgetBlue,
                                          width: 1),
                                      shape: BoxShape.circle),
                                  child: Icon(
                                    Icons.mail_outline,
                                    color: TwitterColor.dodgetBlue,
                                    size: 17.5,
                                  ),
                                  // customIcon(context, icon:AppIcon.messageEmpty, iconColor: TwitterColor.dodgetBlue, paddingIcon: 8)
                                ),
                              ),
                        SizedBox(
                          width: 20,
                        ),
                        RippleButton(
                          splashColor:
                              TwitterColor.dodgetBlue_50.withAlpha(100),
                          borderRadius: BorderRadius.all(Radius.circular(60)),
                          onPressed: () {
                            if (isMyProfile) {
                              Navigator.pushNamed(context, '/EditProfile');
                            } else {
                              print('follow/unFollow');
                              cprint(authState.profileUserModel.key);
                              authState.followUser(
                                removeFollower: isFollower(context),
                              );
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isFollower(context)
                                  ? TwitterColor.dodgetBlue
                                  : TwitterColor.white,
                              border: Border.all(
                                  color: isMyProfile
                                      ? Colors.black87.withAlpha(180)
                                      : TwitterColor.dodgetBlue,
                                  width: 1),
                              borderRadius: BorderRadius.circular(20),
                            ),

                            /// If [isMyProfile] is true then Edit profile button will display
                            // Otherwise Follow/Following button will be display
                            child: Text(
                              isMyProfile
                                  ? 'Edit Profile'
                                  : isFollower(context)
                                      ? 'Following'
                                      : 'Follow',
                              style: TextStyle(
                                color: isMyProfile
                                    ? Colors.black87.withAlpha(180)
                                    : isFollower(context)
                                        ? TwitterColor.white
                                        : TwitterColor.dodgetBlue,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),

//        Padding(
//          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//          child: customText(
//            getBio(user.bio),
//          ),
//        ),
        /// wrap for location, joined date, website url....
        Wrap(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
//                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  customIcon(context,
                      icon: AppIcon.locationPin,
                      size: 15,
                      istwitterIcon: true,
                      paddingIcon: 5,
                      iconColor: AppColor.darkGrey),
                  SizedBox(width: 10),
                  customText(
                    user.location,
                    style: TextStyle(color: AppColor.darkGrey, fontSize: 16),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  customIcon(context,
                      icon: AppIcon.calender,
                      size: 14,
                      istwitterIcon: true,
                      paddingIcon: 5,
                      iconColor: AppColor.darkGrey),
                  SizedBox(width: 10),
                  customText(
                    getJoiningDate(user.createdAt.toString()),
                    style: TextStyle(color: AppColor.darkGrey, fontSize: 16),
                  ),
                ],
              ),
            ),
            user.webSite != null && user.webSite.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: <Widget>[
                        customIcon(context,
                            icon: AppIcon.link,
//                  icondata: Icons.link,
                            size: 14,
                            istwitterIcon: true,
                            paddingIcon: 5,
                            iconColor: AppColor.darkGrey),
                        SizedBox(width: 10),
                        customText(
                          user.webSite,
                          style: TextStyle(color: AppColor.primary),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),

        /// followers, following and social Profile Icons....
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
//            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _tappbleText(context, ' Followers', '${user.getFollower()}',
                  /*'FollowerListPage'*/),
              SizedBox(width: 20),
              _tappbleText(context, ' Following', '${user.getFollowing()}',
                  /*'FollowingListPage'*/),
              isMyProfile ? Container() : _socialProfileLink(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _socialProfileLink(BuildContext context) {
    List socialIcons = ['fac', 'insta', 'tweet', 'linked'];
    var socialLinks = user.profiles;
    print(socialLinks == null);
    if (socialLinks == null) return Container();
    return Container(
      padding: EdgeInsets.only(left: 5),
      child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          ///spacing or padding for container....
//          spacing: MediaQuery.of(context).size.width/45,
            runAlignment: WrapAlignment.end,
          direction: Axis.horizontal,
          children: List.generate(socialLinks.keys.length, (ii) {
            if (socialLinks.values.elementAt(ii) != "") {
              return InkWell(
                child: Container(
                  margin: EdgeInsets.symmetric( horizontal: 4),
                  decoration: BoxDecoration(
                      border: Border.all(color: TwitterColor.dodgetBlue),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 3, vertical: 2),
                  child: Image.asset(
                      "assets/images/" + socialIcons[ii] + "Theme64.png",
                      height: 20,
                      width: 20),
                ),
                onTap: () {
                  launcher
                      .launch(socialLinks.values.elementAt(ii));
                },
              );
            } else
              return Container();
          }).toList()),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final IconData icon;
  final String title;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Share', icon: Icons.directions_car),
  const Choice(title: 'Draft', icon: Icons.directions_bike),
  const Choice(title: 'View Lists', icon: Icons.directions_boat),
  const Choice(title: 'View Moments', icon: Icons.directions_bus),
  const Choice(title: 'QR code', icon: Icons.directions_railway),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.bodyText1;
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(choice.icon, size: 128.0, color: textStyle.color),
            Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}
