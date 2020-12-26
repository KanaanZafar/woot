import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wootter_x/bloc/suggestion_bloc.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/model/feedModel.dart';
import 'package:wootter_x/model/user.dart';
import 'package:wootter_x/page/Auth/widget/checkContactVerification.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/state/feedState.dart';
import 'package:wootter_x/state/searchState.dart';
import 'package:wootter_x/state/suggestionState.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:wootter_x/widgets/newWidget/customLoader.dart';
import 'package:wootter_x/widgets/newWidget/emptyList.dart';
import 'package:wootter_x/widgets/newWidget/rippleButton.dart';
import 'package:wootter_x/widgets/woot/woot.dart';
import 'package:wootter_x/widgets/woot/widgets/wootBottomSheet.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatelessWidget {
  FeedPage({Key key, this.scaffoldKey, this.refreshIndicatorKey})
      : super(key: key);
  SearchState searchState;
  AuthState state;

  final GlobalKey<ScaffoldState> scaffoldKey;

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;

  _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
        heroTag: 'wootButton',
        onPressed: () {
          if (state.userModel.isContactVerified) {
            Navigator.of(context).pushNamed('/CreateFeedPage/woot');
          } else {
            print("Contact number needed");
            ContactVerification(context).plateFormCheck();
          }
        },
        child: Text("W+",
            style: TextStyle(fontWeight: FontWeight.bold), textScaleFactor: 1));
  }

  @override
  Widget build(BuildContext context) {
    state = Provider.of<AuthState>(context, listen: false);

    /// DR....
    // searchState = Provider.of<SearchState>(context, listen: false);
    // searchState.getDataFromDatabase();
//    searchState.getuserDetail(userIds);
    return Scaffold(
      backgroundColor: TwitterColor.white,
      body: SafeArea(
        child: Container(
          height: fullHeight(context),
          width: fullWidth(context),
          child: RefreshIndicator(
            key: refreshIndicatorKey,
            onRefresh: () async {
              /// refresh home page feed
              var feedState = Provider.of<FeedState>(context, listen: false);
              feedState.getDataFromDatabase();
              return Future.value(true);
            },
            child: _FeedPageBody(
              refreshIndicatorKey: refreshIndicatorKey,
              scaffoldKey: scaffoldKey,
              searchState: searchState,
            ),
          ),
        ),
      ),
      floatingActionButton: _floatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _FeedPageBody extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  final SearchState searchState;

  _FeedPageBody(
      {Key key, this.scaffoldKey, this.refreshIndicatorKey, this.searchState})
      : super(key: key);

  @override
  __FeedPageBodyState createState() => __FeedPageBodyState();
}

class __FeedPageBodyState extends State<_FeedPageBody>
    with AutomaticKeepAliveClientMixin {
  List<FeedModel> topWoots = List();
  List<FeedModel> list = List<FeedModel>();
  int noTopWoots;

  SuggestionBloc _suggestionBloc;
  AuthState authState;

  @override
  bool get wantKeepAlive => true;

  @override
  initState() {
    authState = Provider.of<AuthState>(context, listen: false);
    super.initState();
  }

  @override
  dispose() {
    _suggestionBloc?.dispose();
    super.dispose();
  }

  Widget _getUserAvatar(BuildContext context) {
//    var authState = Provider.of<AuthState>(context);
    return Padding(
      padding: EdgeInsets.all(10),
      child: customInkWell(
          context: context,
          onPressed: () {
            /// Open up sidebaar drawer on user avatar tap
            widget.scaffoldKey.currentState.openDrawer();
          },
          child: Icon(
            Icons.dehaze,
            color: TwitterColor.dodgetBlue,
          )
//            customImage(context, authState.userModel?.profilePic, height: 30),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedState>(
      builder: (context, state, child) {
        if (authState.userModel == null) {
          CustomLoader();
        }
        cprint('__building__feedPage__consumer');
        list = state.getWootList(authState.userModel) ?? List<FeedModel>();
        topWoots = state.topOfFeed(authState.userModel) ?? List<FeedModel>();

        log(list.length.toString());
        if (topWoots != null && topWoots.length > 10)
          noTopWoots = 10;
        else if (topWoots == null)
          noTopWoots = 0;
        else
          noTopWoots = topWoots.length;
//        print(topWoots);
        return CustomScrollView(
          slivers: <Widget>[
            child,
            SliverAppBar(
              floating: true,
              stretch: true,
              elevation: 12,
              leading: _getUserAvatar(context),
              title: Image.asset('assets/images/icon-48.png',
                  height: 40, width: 40),
              centerTitle: true,
              iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
              backgroundColor: Colors.white,
            ),
            topWoots.length != 0
                ? SliverAppBar(
                    automaticallyImplyLeading: false,
                    elevation: 8,
                    backgroundColor: TwitterColor.dodgetBlue.withOpacity(.15),
                    flexibleSpace:
                        topWoots == null ? Container() : headerWoots(context),
                    expandedHeight: topWoots.length != 0 ? 210 : 0,
//              bottom:  PreferredSize(
//                child: topWoots == null ? Container() : headerWoots(),
//                preferredSize: Size.fromHeight(200),
//              ),
                  )
                : SliverToBoxAdapter(),
            state.isBusy &&
                    list == null &&
                    widget.searchState?.userlist?.length != null
                ? SliverToBoxAdapter(
                    child: Container(
                      height: fullHeight(context) - 135,
                      child: CustomScreenLoader(
                        height: double.infinity,
                        width: fullWidth(context),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  )
                : /*!state.isBusy && */ list.length == 0
                    ? SliverToBoxAdapter(
                        child: EmptyList('No Woot in your Feed',
                            subTitle: "When New Woot Created,"
                                " they'll be visible here. Click the woot button to add New woot."),
                      )
                    : SliverList(
                        delegate: SliverChildListDelegate(
                          list.map((model) {
                            if (widget.searchState?.userlist != null &&
                                widget.searchState?.userlist.length > 0) {
                              MyUser userN = widget.searchState?.userlist
                                  .firstWhere((element) =>
                                      element.userId == model.user.userId);
                              model.user = userN;
                            }

                            // print(model.key.toString() + " - ${model.parentkey} " + model.childRewootkey.toString());
                            return Container(
                              color: Colors.white,
                              child: Woot(
                                model: model,
                                trailing: WootBottomSheet().wootOptionIcon(
                                  context,
                                  model,
                                  WootType.Woot,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
          ],
        );
      },
      child: SliverToBoxAdapter(),
    );
  }

  headerWoots(BuildContext context) {
    var suggestionState = Provider.of<SuggestionState>(context);

    return FlexibleSpaceBar(
      background: Padding(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
//            Container(
//              height: 50,
//              color: TwitterColor.white,
//            ),
            Text(
              "Trending Woots",
              textScaleFactor: 1,
              style: TextStyle(
                  color: TwitterColor.dodgetBlue, fontWeight: FontWeight.w400),
            ),
//             SingleChildScrollView(
//               padding: EdgeInsets.all(8.0),
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: topWoots.getRange(0, noTopWoots).map((topModel) {
// //                print("in");
//                   return InkWell(
//                     child: Container(
//                       padding: EdgeInsets.symmetric(horizontal: 8),
//                       child: Column(
//                         children: <Widget>[
//                           Container(
// //                            color: Colors.pink,
//                             height: 55,
//                             width: 55,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(50),
//                               child: customNetworkImage(
//                                 topModel.user.profilePic,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
// //                          customNetworkImage(
// //                              topModel.user.profilePic
// //                          ),
//                           SizedBox(height: 10),
//                           Text(
//                             topModel.user.displayName,
//                             style: TextStyle(
//                               fontFamily: "Monteserrat",
//                               fontSize: 18.0,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.black,
//                             ),
//                             overflow: TextOverflow.clip,
//                           ),
//                         ],
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.of(context)
//                           .pushNamed('/ProfilePage/' + topModel.userId);
//                     },
//                   );
//                 })?.toList(),
//               ),
//             ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: topWoots.getRange(0, noTopWoots).map((topModel) {
//                  print("in");
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          onTapWoot(context, topModel, WootType.Woot);
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(6, 6, 6, 0),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: <Widget>[
                              Container(
//                            color: Colors.pink,
                                height: 120,
                                width: fullWidth(context) / 3.8,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: customNetworkImage(
                                      topModel.user.profilePic,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 90),
                                child: Container(
                                  // color: Colors.cyan,
                                  // padding: EdgeInsets.all(4),
                                  width: fullWidth(context) / 3.8,
                                  height: 70,
                                  child: Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  8, 8, 8, 0),
                                              child: Text(
                                                "${topModel.description} ",
                                                style: TextStyle(
                                                  fontFamily: "Monteserrat",
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),
//                                    SizedBox(height: 2,),
//                                     Padding(
//                                       padding: EdgeInsets.symmetric(
//                                           vertical: 8, horizontal: 2),
//                                       child: WootIconsRow(
//                                         isTop: true,
//                                         type: WootType.Woot,
//                                         model: topModel,
//                                         isWootDetail:
//                                             false /*type == WootType.Detail*/,
//
//                                         /// woot option color
//                                         iconColor: Colors
//                                             .grey /*Theme.of(context).textTheme.caption.color*/,
//                                         iconEnableColor:
//                                             TwitterColor.dodgetBlue,
//                                         size: 18,
//                                       ),
//                                     ),
//                                    SizedBox(
//                                      height: 5,
//                                    )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(4, 0, 2, 2),
                          width: fullWidth(context) / 3.8,
                          child: Text(
                            topModel.user.displayName,
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  );
                })?.toList(),
              ),
            ),
            suggestionState.suggestionsList.length == 0
                ? Container()
                : ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 0, maxHeight: 230),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: suggestionState.suggestionsList.length,
                      itemBuilder: (context, index) {
                        return FeedFollowTile(
                          user: suggestionState.suggestionsList[index],
                          callback: () async {
                            await suggestionState.addFollowing(
                              authState.userModel,
                              suggestionState.suggestionsList[index],
                            );
                          },
                        );
                      },
                    ),
                  )
          ],
        ),
      ),
    );
  }

  void onTapWoot(BuildContext context, FeedModel model, WootType type) {
    var feedstate = Provider.of<FeedState>(context, listen: false);
    if (type == WootType.Detail || type == WootType.ParentWoot) {
      return;
    }
    if (type == WootType.Woot) {
      feedstate.clearAllDetailAndReplyWootStack();
    }
    feedstate.getpostDetailFromDatabase(null, model: model);
    Navigator.of(context).pushNamed('/FeedPostDetail/' + model.key);
  }
}

class FeedFollowTile extends StatelessWidget {
  const FeedFollowTile({Key key, this.user, this.callback}) : super(key: key);

  final MyUser user;
  final Function callback;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        margin: EdgeInsets.only(
          left: 20,
          top: 20,
          bottom: 20,
        ),
        padding: EdgeInsets.all(20),
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50,
              width: 50,
              child: customImage(
                context,
                user.profilePic,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "${user.displayName}",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "${user.userName}",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10),
            RippleButton(
              onPressed: () async {
                final authState =
                    Provider.of<AuthState>(context, listen: false);
                List<String> _selected = [user.userId];
                _selected.addAll(authState.userModel.followingList);
                await kDatabase
                    .child('profile')
                    .child(authState.userModel.userId)
                    .update({
                  "followingList": _selected,
                  'following': _selected.length
                });
                callback();
              },
              splashColor: TwitterColor.dodgetBlue_50.withAlpha(100),
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: TwitterColor.dodgetBlue, width: 1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'Follow',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
