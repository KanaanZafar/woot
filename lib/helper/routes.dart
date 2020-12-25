import 'package:flutter/material.dart';
import 'package:wootter_x/page/Auth/welcomePage.dart';
import 'package:wootter_x/page/Auth/verifyEmail.dart';
import 'package:wootter_x/page/Topics/topicsPage.dart';
import 'package:wootter_x/page/common/splash.dart';
import 'package:wootter_x/page/feed/composeWoot/composeWoot.dart';
import 'package:wootter_x/page/feed/composeWoot/state/composeWootState.dart';
import 'package:wootter_x/page/feed/videoViewPage.dart';
import 'package:wootter_x/page/message/conversationInformation/conversationInformation.dart';
import 'package:wootter_x/page/message/newMessagePage.dart';
import 'package:wootter_x/page/profile/follow/followerListPage.dart';
import 'package:wootter_x/page/profile/follow/followingListPage.dart';
import 'package:wootter_x/page/profile/profileImageView.dart';
import 'package:wootter_x/page/search/SearchPage.dart';
import 'package:wootter_x/page/settings/accountSettings/about/aboutWootter.dart';
import 'package:wootter_x/page/settings/accountSettings/accessibility/accessibility.dart';
import 'package:wootter_x/page/settings/accountSettings/accountSettingsPage.dart';
import 'package:wootter_x/page/settings/accountSettings/changeUserName.dart';
import 'package:wootter_x/page/settings/accountSettings/contentPrefrences/contentPreference.dart';
import 'package:wootter_x/page/settings/accountSettings/contentPrefrences/trends/trendsPage.dart';
import 'package:wootter_x/page/settings/accountSettings/dataUsage/dataUsagePage.dart';
import 'package:wootter_x/page/settings/accountSettings/displaySettings/displayAndSoundPage.dart';
import 'package:wootter_x/page/settings/accountSettings/notifications/notificationPage.dart';
import 'package:wootter_x/page/settings/accountSettings/privacyAndSafety/directMessage/directMessage.dart';
import 'package:wootter_x/page/settings/accountSettings/privacyAndSafety/privacyAndSafetyPage.dart';
import 'package:wootter_x/page/settings/accountSettings/proxy/proxyPage.dart';
import 'package:wootter_x/page/settings/settingsAndPrivacyPage.dart';
import 'package:provider/provider.dart';
import '../page/Auth/signin.dart';
import '../helper/customRoute.dart';
import '../page/feed/imageViewPage.dart';
import '../page/Auth/forgetPasswordPage.dart';
import '../page/Auth/signup.dart';
import '../page/feed/feedPostDetail.dart';
import '../page/profile/EditProfilePage.dart';
import '../page/message/chatScreenPage.dart';
import '../page/profile/profilePage.dart';
import '../widgets/customWidgets.dart';

class Routes {
  static dynamic route() {
    return {
      'SplashPage': (BuildContext context) => SplashPage(),
    };
  }

  static void sendNavigationEventToFirebase(String path) {
    if (path != null && path.isNotEmpty) {
      // analytics.setCurrentScreen(screenName: path);
    }
  }

  static Route onGenerateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name.split('/');
    if (pathElements[0] != '' || pathElements.length == 1) {
      return null;
    }
    switch (pathElements[1]) {
      case "ComposeWootPage":
        bool isRetweet = false;
        bool isWoot = false;
        if (pathElements.length == 3 && pathElements[2].contains('rewoot')) {
          isRetweet = true;
        } else if (pathElements.length == 3 &&
            pathElements[2].contains('woot')) {
          isWoot = true;
        }
        return CustomRoute<bool>(
          builder: (BuildContext context) =>
              ChangeNotifierProvider<ComposeWootState>(
            create: (_) => ComposeWootState(),
            child: ComposeWootPage(isRewoot: isRetweet, isWoot: isWoot),
          ),
        );
      case "FeedPostDetail":
        var postId = pathElements[2];
        return SlideLeftRoute<bool>(
            builder: (BuildContext context) => FeedPostDetail(
                  postId: postId,
                ),
            settings: RouteSettings(name: 'FeedPostDetail'));
      case "ProfilePage":
        String profileId;
        print(pathElements);
        if (pathElements.length > 2) {
          profileId = pathElements[2];
        }
        return CustomRoute<bool>(
            builder: (BuildContext context) => ProfilePage(
                  profileId: profileId,
                ));
      case "CreateFeedPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) =>
                ChangeNotifierProvider<ComposeWootState>(
                  create: (_) => ComposeWootState(),
                  child: ComposeWootPage(isRewoot: false, isWoot: true),
                ));
      case "WelcomePage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => WelcomePage());
      case "SignIn":
        return CustomRoute<bool>(builder: (BuildContext context) => SignIn());
      case "SignUp":
        return CustomRoute<bool>(builder: (BuildContext context) => Signup());
      case "ForgetPasswordPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => ForgetPasswordPage());
      case "SearchPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => SearchPage());
      case "ImageViewPge":
        return CustomRoute<bool>(
            builder: (BuildContext context) => ImageViewPge());
      case "VideoViewPge":
        return CustomRoute<bool>(
            builder: (BuildContext context) => VideoViewPge());
      case "EditProfile":
        return CustomRoute<bool>(
            builder: (BuildContext context) => EditProfilePage());
      case "ProfileImageView":
        return SlideLeftRoute<bool>(
            builder: (BuildContext context) => ProfileImageView());
      case "ChatScreenPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => ChatScreenPage());
      case "NewMessagePage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => NewMessagePage(),
        );
      case "SettingsAndPrivacyPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => SettingsAndPrivacyPage(),
        );
      case "TopicsPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => TopicsPage(),
        );
      case "AccountSettingsPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => AccountSettingsPage(),
        );
      case "ChangeUserNamePage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => ChangeUserNamePage(),
        );
      case "PrivacyAndSaftyPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => PrivacyAndSaftyPage(),
        );
      case "NotificationPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => NotificationPage(),
        );
      case "ContentPrefrencePage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => ContentPrefrencePage(),
        );
      case "DisplayAndSoundPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => DisplayAndSoundPage(),
        );
      case "DirectMessagesPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => DirectMessagesPage(),
        );
      case "TrendsPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => TrendsPage(),
        );
      case "DataUsagePage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => DataUsagePage(),
        );
      case "AccessibilityPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => AccessibilityPage(),
        );
      case "ProxyPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => ProxyPage(),
        );
      case "AboutPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => AboutPage(),
        );
      case "ConversationInformation":
        return CustomRoute<bool>(
          builder: (BuildContext context) => ConversationInformation(),
        );
      case "FollowingListPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => FollowingListPage(),
        );
      case "FollowerListPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => FollowerListPage(),
        );
      case "VerifyEmailPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => VerifyEmailPage(),
        );
//       case "VerifyContactPage":return CustomRoute<bool>(builder:(BuildContext context)=> VerifyMobilePage(),);
      default:
        return onUnknownRoute(RouteSettings(name: '/Feature'));
    }
  }

  static Route onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: customTitleText(settings.name.split('/')[1]),
          centerTitle: true,
        ),
        body: Center(
          child: Text('${settings.name.split('/')[1]} Comming soon..'),
        ),
      ),
    );
  }
}
