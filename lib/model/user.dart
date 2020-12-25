import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:wootter_x/helper/utility.dart';

class MyUser {
  String key;
  String email;
  String userId;
  String displayName;
  String ratingPattern;
  String userName;
  String webSite = "";
  String profilePic;
  String contact;
  String occupation;
  String bio;
  String location;
  String dob;
  String createdAt;
  bool isVerified;
  bool isContactVerified;
  int totalLikes;
  int totalDisLikes;
  int followers;
  int following;
  String fcmToken;
  List<String> followersList = List();
  List<String> followingList = List();
  List<String> contactsList = List();
  Map profiles;
  Map<dynamic, dynamic> topics;
  String lastSeen;
  ParseObject userParsedData;
  MyUser({
    this.email,
    this.userId,
    this.displayName,
    this.ratingPattern,
    this.totalLikes,
    this.totalDisLikes,
    this.profilePic,
    this.profiles,
    this.key,
    this.contact,
    this.bio,
    this.dob,
    this.location,
    this.createdAt,
    this.userName,
    this.followers,
    this.following,
    this.webSite = "",
    this.isVerified,
    this.isContactVerified,
    this.fcmToken,
    this.followersList,
    this.occupation,
    this.followingList,
    this.topics,
    this.lastSeen,
    this.contactsList,
    this.userParsedData
  });

  MyUser.fromJson(var map) {
    if (map == null) {
      return;
    }
    if (followersList == null) {
      followersList = List();
    }
    if (followingList == null) {
      followingList = List();
    }

    if (contactsList == null) {
      contactsList = List();
    }

    topics = map['topics'] ?? null;

    profiles = map['profiles'] ?? null;
    email = map['email'];
    userId = map['userId'];
    displayName = map['displayName'];
    profilePic = map['profilePic'];
    key = map['key'];
    dob = map['dob'].toString();
    bio = map['bio'];
    location = map['location'];
    contact = map['contact'] ?? "+91";
    createdAt = map['createdAt'].toString();
    followers = map['followers'];
    following = map['following'];
    userName = map['userName'];
    webSite = map['webSite'];
    fcmToken = map['fcmToken'];
    isVerified = map['isVerified'] ?? false;
    occupation = map['occupation'];
    isContactVerified = map['isContactVerified'] ?? false;
    lastSeen = map['lastSeen'] ?? DateTime.now().toUtc().toString();
    contact = map['contact'];
    if (map['followerList'] != null) {
      followersList = List<String>();
      map['followerList'].forEach((value) {
        followersList.add(value);
      });
    }
    followers = followersList != null ? followersList.length : null;
    if (map['followingList'] != null) {
      followingList = List<String>();
      map['followingList'].forEach((value) {
        followingList.add(value);
      });
    }
    if (map['contacts'] != null) {
      map['contacts'].forEach((value) {
        contactsList.add(value);
      });
    } else {
      contactsList = [];
    }
    following = followingList != null ? followingList.length : null;
  }

   toJson() => {
      "key": key,
      "userId": userId,
      "email": email,
      "displayName": displayName,
      "totalLikes": totalLikes ?? 0,
      "totalDisLikes": totalDisLikes ?? 0,
      "profilePic": profilePic,
      "contact": contact ?? "+91",
      "isContactVerified": isContactVerified ?? false,
      "dob": dob,
      "bio": bio,
      "location": location,
      // "createdAt": createdAt,
      "followers": followersList != null ? followersList.length : null,
      "following": followingList != null ? followingList.length : null,
      "userName": userName,
      "webSite": webSite,
      "isVerified": isVerified ?? false,
      "fcmToken": fcmToken,
      "followerList": followersList,
      "followingList": followingList,
      "occupation": occupation,
      "ratingPattern": ratingPattern ?? "00000",
      "profiles": profiles,
      "topics": topics,
      "lastSeen": lastSeen,
      "contacts": contactsList,
    };


  MyUser copyWith({
    String email,
    String userId,
    String displayName,
    String profilePic,
    String key,
    String contact,
    String bio,
    String dob,
    String location,
    DateTime createdAt,
    String userName,
    int followers,
    int following,
    int totalLikes,
    int totalDisLikes,
    String webSite,
    bool isVerified,
    bool isContactVerified,
    String fcmToken,
    List<String> followingList,
    List<String> followersList,
    String occupation,
    String ratingPattern,
    Map profiles,
  }) {
    return MyUser(
        email: email ?? this.email,
        bio: bio ?? this.bio,
        contact: contact ?? this.contact,
        createdAt: createdAt ?? this.createdAt,
        displayName: displayName ?? this.displayName,
        dob: dob ?? this.dob,
        totalLikes: totalLikes ?? this.totalLikes,
        totalDisLikes: totalDisLikes ?? this.totalDisLikes,
        followers: followersList != null ? followersList.length : null,
        following: following ?? this.following,
        isVerified: isVerified ?? this.isVerified,
        isContactVerified: isContactVerified ?? this.isContactVerified,
        key: key ?? this.key,
        location: location ?? this.location,
        profilePic: profilePic ?? this.profilePic,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        webSite: webSite ?? this.webSite,
        fcmToken: fcmToken ?? this.fcmToken,
        followersList: followersList ?? this.followersList,
        followingList: followingList ?? this.followingList,
        occupation: occupation ?? this.occupation,
        ratingPattern: ratingPattern ?? this.ratingPattern,
        profiles: profiles ?? this.profiles,
        topics: this.topics);
  }

  String getFollower() {
    return "${this.followers ?? 0}";
  }

  String getFollowing() {
    return "${this.following ?? 0}";
  }

  ParseObject getParsedObject({String objectID}) {
    ParseObject parseObject = ParseObject('profile');

    print('__creating UserParseObject__');
    if(objectID != null)
      parseObject.objectId = objectID;

    Map<String, dynamic> mapData = Map.from(this.toJson());
    mapData.forEach((key, value) {
      parseObject.set(key, value);
    });
    cprint("getParsedUserObject = " + parseObject.toString());

    return parseObject;
  }
}
