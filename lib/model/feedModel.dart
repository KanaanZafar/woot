import 'dart:typed_data';

import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:wootter_x/model/poolModel.dart';
import 'package:wootter_x/model/user.dart';

class FeedModel {
  String key;
  bool isImageAvailable = false;
  Uint8List uint8list;
  String parentkey;
  String childRewootkey;
  String description;
  String userId;
//  String userRating;
  int likeCount = 0;
  int dislikeCount = 0;
  int views = 0;
  List<String> likeList;
  List<String> dislikeList;
  int commentCount = 0;
  int rewootCount = 0;
  String createdAt;
  String imagePath;
  List<String> tags;
  List<String> replyWootKeyList = List<String>();
  List<String> viewsList = List<String>();
  MyUser user;
  String p;
  List<Pool> pool;
  Map<dynamic, dynamic> newPool;
  String video;
  FeedModel({
    this.key,
    this.description,
    this.userId,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.commentCount = 0,
    this.rewootCount = 0,
    this.createdAt,
    this.imagePath,
    this.likeList = const [],
    this.dislikeList = const [],
//      this.userRating,
    this.tags,
    this.user,
    this.replyWootKeyList,
    this.parentkey,
    this.childRewootkey,
    this.pool,
    this.video,
    this.views,
    this.viewsList,
  });
  toJson() {
    return {
      "userId": userId,
      "description": description,
      "likeCount": likeCount ?? 0,
      "dislikeCount": dislikeCount,
      "commentCount": commentCount ?? 0,
      "rewootCount": rewootCount ?? 0,
      /// not be set in parse server, because it has already immutable field,
      /// called createdAt....
      /// it is needed for firebase database....
      "createdAt": createdAt,
      "imagePath": imagePath,
      "likeList": likeList,
      "dislikeList": dislikeList,
      "tags": tags,
      'poll': newPool,
      "replyWootKeyList": replyWootKeyList,
      "user": user == null ? null : user.toJson(),
      "parentkey": parentkey,
      "childRewootkey": childRewootkey,
      'p': user.ratingPattern,
      'video': video,
    };
  }

  FeedModel.fromJson(var map) {
    key = map['key'] ?? 'nothing';
    description = map['description'];
    //  name = map['name'];
    //  profilePic = map['profilePic'];
    likeCount = map['likeCount'] ?? 0;
    dislikeCount = map['dislikeCount'] ?? 0;
    commentCount = map['commentCount'] ?? 0;
    rewootCount = map["rewootCount"] ?? 0;
    imagePath = map['imagePath'];
    createdAt = map['createdAt'].toString();
    //  username = map['username'];
    user = MyUser.fromJson(map['user']);
    userId = map['userId'];
    parentkey = map['parentkey'];
    childRewootkey = map['childRewootkey'];


    if (map['tags'] != null) {
      tags = List<String>();
      map['tags'].forEach((value) {
        tags.add(value);
      });
    }
    if (map["likeList"] != null) {
      likeList = List<String>();
      final list = map['likeList'];
      if (list is List) {
        map['likeList'].forEach((value) {
          likeList.add(value);
        });
        likeCount = likeList.length ?? 0;
      }
    } else {
      likeList = List<String>();
      likeCount = 0;
    }
    if (map["dislikeList"] != null) {
      dislikeList = List<String>();
      final list = map['dislikeList'] ?? List();
      if (list is List) {
        map['dislikeList'].forEach((value) {
          dislikeList.add(value);
        });
        dislikeCount = likeList?.length ?? 0;
      }
    } else {
      dislikeList = List<String>();
      dislikeCount = 0;
    }
    if (map['replyWootKeyList'] != null) {
      map['replyWootKeyList'].forEach((value) {
        replyWootKeyList = List<String>();
        map['replyWootKeyList'].forEach((value) {
          replyWootKeyList.add(value);
        });
      });
      commentCount = replyWootKeyList?.length ?? 0;
    } else {
      replyWootKeyList = List<String>();
      commentCount = 0;
    }
    if (map["poll"] != null) {
      pool = List<Pool>();
      Map<String, dynamic> _poll = Map<String, dynamic>.from(map['poll']);
      _poll.forEach((key, value) {
        List<String> _ids = List<String>.from(value);
        if (_ids.contains('value')) {
          _ids.remove('value');
        }
        pool.add(Pool(value: key, votes: _ids));
        print("Pool Added");
      });
    }
    video = map['video'] ?? null;
    if (map["viewsList"] != null) {
      viewsList = List<String>();
      final list = map['viewsList'];
      if (list is List) {
        map['viewsList'].forEach((value) => viewsList.add(value));
        views = viewsList.length ?? 0;
      }
    } else {
      viewsList = List<String>();
      views = 0;
    }
  }

  bool get isValidWoot {
    bool isValid = false;
    if (description != null &&
        description.isNotEmpty &&
        this.user != null &&
        this.user.userName != null &&
        this.user.userName.isNotEmpty) {
      isValid = true;
    } else {
      print("Invalid Woot found. description :- ${this.description}");
      print("Invalid Woot found of userId :) ${this.userId}");
    }
    return isValid;
  }

  ParseObject getParsedObject({String objectID}){
    ParseObject parseObject = ParseObject('woot');

    print('map to parseObject');
    // print(this.parentkey);
    // print("objectID = " + objectID);
    if(objectID != null)
      parseObject.objectId = objectID;


    Map<String, dynamic> mapData = Map.from(this.toJson());
    mapData.forEach ((key, value) {
      if(key != 'createdAt')
        parseObject.set(key, value);
    });
    // print("getParsedWootObject = " + parseObject.toString());
    return parseObject;
  }

  @override
  String toString() {
    return 'FeedModel{key: $key, isImageAvailable: $isImageAvailable, uint8list: $uint8list, parentkey: $parentkey, childRewootkey: $childRewootkey, description: $description, userId: $userId, likeCount: $likeCount, dislikeCount: $dislikeCount, views: $views, likeList: $likeList, dislikeList: $dislikeList, commentCount: $commentCount, rewootCount: $rewootCount, createdAt: $createdAt, imagePath: $imagePath, tags: $tags, replyWootKeyList: $replyWootKeyList, viewsList: $viewsList, user: $user, p: $p, pool: $pool, newPool: $newPool, video: $video}';
  }
}
