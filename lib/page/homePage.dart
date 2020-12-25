import 'package:shared_preferences/shared_preferences.dart';
import 'package:wootter_x/bloc/notifications_sender.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/page/Topics/topicsFirstPage.dart';
import 'package:wootter_x/page/contact_sync/contact_sync_screen.dart';
import 'package:wootter_x/page/suggestion/SuggestionPage.dart';
import 'package:wootter_x/state/suggestionState.dart';
import 'common/sidebar.dart';
import 'search/SearchPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:wootter_x/helper/enum.dart';
import 'notification/notificationPage.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/state/appState.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/state/feedState.dart';
import 'package:wootter_x/state/searchState.dart';
import 'package:wootter_x/page/feed/feedPage.dart';
import 'package:wootter_x/state/chats/chatState.dart';
import 'package:wootter_x/state/notificationState.dart';
import 'package:wootter_x/page/message/chatListPage.dart';
import 'package:wootter_x/widgets/bottomMenuBar/bottomMenuBar.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initProfile();
      AuthState state = Provider.of<AuthState>(context, listen: false);
      state.setpageIndex = 0;
      initTweets();
      initSearch();
      initNotificaiton();
      initChat();
      initPreloaded();
    });
  }

  initPreloaded() async {
    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;
    SharedPreferences _pf = await SharedPreferences.getInstance();
    bool isShown = _pf.getBool('firstShowSuggustion') ?? false;
    // isShown = false;
    if (!isShown) {
      Route route = CupertinoPageRoute(
        builder: (_) => TopicsFirstPage(topics: {}),
      );
      await Navigator.push(context, route);
      await _pf.setBool('firstShowSuggustion', true);
    }
    String lastSeen = _pf.getString('lastseen') ??
        DateTime.now().subtract(Duration(days: 1)).toString();
    if (DateTime.now().difference(DateTime.parse(lastSeen)).inDays > 0) {
      Route route;
      bool contactsSync = _pf.getBool('contactsSync') ?? false;
      if (!contactsSync) {
        route = MaterialPageRoute(builder: (_) => ContactsSyncScreen());
        await _pf.setBool('contactsSync', true);
      } else {
        route = MaterialPageRoute(builder: (_) => SuggestionPage());
      }
      await Navigator.push(context, route);
      await _pf.setString('lastseen', DateTime.now().toString());
    }
  }

  void initTweets() async {
    var state = Provider.of<FeedState>(context, listen: false);
    state.databaseInit();
    state.getDataFromDatabase();
  }

  void initProfile() async {
    var state = Provider.of<AuthState>(context, listen: false);
    await state.databaseInit();
  }

  void initSearch() {
    var searchState = Provider.of<SearchState>(context, listen: false);
    searchState.getDataFromDatabase();
  }

  void initNotificaiton() {
    var state = Provider.of<NotificationState>(context, listen: false);
    var authstate = Provider.of<AuthState>(context, listen: false);
    state.databaseInit(authstate.userId);
    state.initfirebaseService();
    _checkNotification();
    SendFCM();
  }

  void initChat() {
    final chatState = Provider.of<ChatState>(context, listen: false);
    final state = Provider.of<AuthState>(context, listen: false);
    chatState.databaseInit(state.userId, state.userId);

    /// It will update fcm token in database
    /// fcm token is required to send firebase notification
    state.updateFCMToken();

    /// It get fcm server key
    /// Server key is required to configure firebase notification
    /// Without fcm server notification can not be sent
    chatState.getFCMServerKey();
  }

  /// On app launch it checks if app is launch by tapping on notification from notification tray
  /// If yes, it checks for  which type of notification is recieve
  /// If notification type is `NotificationType.Message` then chat screen will open
  /// If notification type is `NotificationType.Mention` then user profile will open who taged you in a tweet
  ///
  void _checkNotification() {
    final authstate = Provider.of<AuthState>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var state = Provider.of<NotificationState>(context, listen: false);

      /// Check if user recieve chat notification from firebase
      /// Redirect to chat screen
      /// `notificationSenderId` is a user id who sends you a message
      /// `notificationReciverId` is a your user id.
      if (state.notificationType == NotificationType.Message &&
          state.notificationReciverId == authstate.userModel.userId) {
        state.setNotificationType = null;
        state.getuserDetail(state.notificationSenderId).then((user) {
          cprint("Opening user chat screen");
          final chatState = Provider.of<ChatState>(context, listen: false);
          chatState.setChatUser = user;
          Navigator.pushNamed(context, '/ChatScreenPage');
        });
      }

      /// Checks for user tag tweet notification
      /// If you are mentioned in tweet then it redirect to user profile who mentioed you in a tweet
      /// You can check that tweet on his profile timeline
      /// `notificationSenderId` is user id who tagged you in a tweet
      else if (state.notificationType == NotificationType.Mention &&
          state.notificationReciverId == authstate.userModel.userId) {
        state.setNotificationType = null;
        Navigator.of(context)
            .pushNamed('/ProfilePage/' + state.notificationSenderId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: TwitterColor.white,
      key: _scaffoldKey,
      drawer: SidebarMenu(),
      // body: _body(),
      body: SafeArea(
        child: IndexedStack(
          children: [
            FeedPage(
              scaffoldKey: _scaffoldKey,
              refreshIndicatorKey: refreshIndicatorKey,
            ),
            SearchPage(scaffoldKey: _scaffoldKey),
            ChatListPage(scaffoldKey: _scaffoldKey),
            NotificationPage(scaffoldKey: _scaffoldKey)
          ],
          index: context.select<AppState, int>((value) => value.pageIndex),
        ),
      ),
//      floatingActionButton: _floatingActionButton(),
      bottomNavigationBar: BottomMenubar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
