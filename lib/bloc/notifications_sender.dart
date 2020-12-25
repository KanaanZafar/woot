import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/model/feedModel.dart';
import 'package:wootter_x/model/user.dart';

class SendFCM {
  static get instance => _singleton;
  static final SendFCM _singleton = SendFCM._internal();

  factory SendFCM() {
    return _singleton;
  }
  SendFCM._internal() {
    getFCMServerKey();
  }

  String serverToken;

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  void getFCMServerKey() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    await remoteConfig.fetch(expiration: const Duration(hours: 5));
    await remoteConfig.activateFetched();
    var data = remoteConfig.getString('FcmServerKey');
    if (data != null && data.isNotEmpty) {
      serverToken = jsonDecode(data)["key"];
    } else {
      cprint("Please configure Remote config in firebase",
          errorIn: "getFCMServerKey");
    }
  }

  Future<void> sendToFollower(MyUser follower, MyUser user) async {
    String _title = "New Follower";
    String _body = follower.displayName + " starts following you";
    var data = {
      'type': NotificationType.Follow.toString(),
      'id': follower.userId
    };
    await _sendNotification(_title, _body, data, [user.fcmToken]);
  }

  Future<void> commentOnPost(
      FeedModel feedModel, MyUser postUser, MyUser user) async {
    String _title = "New Comment";
    String _body = user.displayName + " comment on your post";
    var data = {'type': NotificationType.Comment.toString(), 'id': user.userId};
    await _sendNotification(_title, _body, data, [postUser.fcmToken]);
    kDatabase.child('notification').child(postUser.userId).push().set(data);
  }

  Future<void> newWootCreated(MyUser user, List<MyUser> users) async {
    String _title = "New Woot Created";
    String _body = user.displayName + " create a new woot";
    var data = {'type': NotificationType.Woot.toString(), 'id': user.userId};
    List<String> _tokens = [];
    users.forEach((user) {
      if (user.followingList.contains(user.userId)) {
        _tokens.add(user.fcmToken);
      }
    });
    await _sendNotification(_title, _body, data, _tokens);
    users.forEach((user) {
      if (user.followingList.contains(user.userId)) {
        kDatabase.child('notification').child(user.userId).push().set(data);
      }
    });
  }

  Future<void> sharePost(MyUser postUser, MyUser user) async {
    String _title = "Share your woot";
    String _body = user.displayName + " share's your woot";
    var data = {'type': NotificationType.Share.toString(), 'id': user.userId};
    await _sendNotification(_title, _body, data, [postUser.fcmToken]);
    kDatabase.child('notification').child(postUser.userId).push().set(data);
  }

  Future<void> likePost(MyUser postUser, MyUser user) async {
    String _title = "Like your woot";
    String _body = user.displayName + " like's your  woot";
    var data = {'type': NotificationType.Like.toString(), 'id': user.userId};
    await _sendNotification(_title, _body, data, [postUser.fcmToken]);
    kDatabase.child('notification').child(postUser.userId).push().set(data);
  }

  Future<void> disLikePost(MyUser postUser, MyUser user) async {
    String _title = "Dislike your woot";
    String _body = user.displayName + " Dislike's your  woot";
    var data = {'type': NotificationType.DisLike.toString(), 'id': user.userId};
    await _sendNotification(_title, _body, data, [postUser.fcmToken]);
    kDatabase.child('notification').child(postUser.userId).push().set(data);
  }

  Future<void> newJoinWooter(MyUser postUser, MyUser user) async {
    String _title = user.displayName + " is on wootter";
    String _body = "Say welcome on wotter";
    await _sendNotification(_title, _body, {}, [postUser.fcmToken]);
  }

  Future<void> _sendNotification(String title, String body,
      Map<String, dynamic> data, List<String> tokens) async {
    /// on noti
    print("FCM Server : $serverToken ");
    await firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );
    Map<String, dynamic> _data = <String, dynamic>{
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
    };
    _data.addAll(data);
    var notification = jsonEncode(<String, dynamic>{
      'notification': <String, dynamic>{'body': body, 'title': title},
      'priority': 'high',
      'data': _data,
      'registration_ids': tokens
    });
    print("Notification $notification");
    var response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: notification,
    );
    print(response.body.toString());
  }
}
