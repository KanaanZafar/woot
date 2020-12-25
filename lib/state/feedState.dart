import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:path/path.dart' as Path;
import 'package:provider/provider.dart';
import 'package:wootter_x/bloc/notifications_sender.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/model/feedModel.dart';
import 'package:wootter_x/model/user.dart';
import 'package:wootter_x/state/searchState.dart';

import 'appState.dart';
// import 'authState.dart';

class FeedState extends AppState {
  bool isBusy = false;
  Map<String, List<FeedModel>> wootReplyMap = {};
  FeedModel _wootToReplyModel;
  FeedModel get wootToReplyModel => _wootToReplyModel;
  set setWootToReply(FeedModel model) {
    _wootToReplyModel = model;
    notifyListeners();
  }

  List<FeedModel> _commentlist;

  List<FeedModel> _feedlist;
  dabase.Query _feedQuery;
  List<FeedModel> _wootDetailModelList;
  List<String> _userfollowingList;
  List<String> get followingList => _userfollowingList;

  List<FeedModel> get wootDetailModel => _wootDetailModelList;

  /// `feedlist` always [contain all woots] fetched from firebase database
  List<FeedModel> get feedlist {
    if (_feedlist == null) {
      return [];
    } else {
      return List.from(_feedlist.reversed);
    }
  }

  List<FeedModel> topOfFeed(MyUser userModel) {
    List<FeedModel> list;

    try {
      if (_feedlist != null) {
        print('__feedlist ' + _feedlist?.length.toString());

        // print(DateTime.now().toUtc().toString());

        /// fetch today's woot....
        list = _feedlist.where((x) {
          // cprint(DateTime.parse(x.createdAt).toLocal().toString());
          if (x.likeList == null)
            x.likeList = List<String>();
          if (x.dislikeList == null)
            x.dislikeList = List<String>();
          if (x.replyWootKeyList == null)
            x.replyWootKeyList = List<String>();
          if (x.user.contactsList == null)
            x.user.contactsList = List<String>();
          if (x.user.followersList == null)
            x.user.followersList = List<String>();


          DateTime wootDay = DateTime.parse(x.createdAt).toLocal();
          DateTime today = DateTime.now();

          if (today.day == wootDay.day && today.month == wootDay.month
              && today.year == today.year) {
            if (x.video != null || x.imagePath != null
                /*|| x.imagePath?.isNotEmpty || x.video?.isNotEmpty*/)
              return true;
          }

          return false;
        }).toList();

        /// sort based on like....
        list.sort((a, b) => a.likeList.length.compareTo(b.likeList.length));

        /// reverse = higher liked woot should be first....
        list = list.reversed.toList();

        /// one Top woot listing per account....
        List<String> wootUserIdList = List<String>();
        List<FeedModel> l = list.where((x) {
          if (!wootUserIdList.contains(x.userId)) {
            wootUserIdList.add(x.userId);
            return true;
          }
          return false;
        }).toList();
        return List.from(l);
      }
    }catch (e) {
      cprint(e.toString(), errorIn: '__topWoot__');
      print(e.toString());
    }
    return list;
  }

  /// fetch related  woots list for home page
  List<FeedModel> getWootList(MyUser userModel) {
    if (userModel == null) {
      print('return null -- usermodel = null ');
      return null;
    }

    List<FeedModel> list;


    if (!isBusy && _feedlist != null && _feedlist.isNotEmpty) {
      print('__getting related _feedlist__ ');
      list = _feedlist.where((x) {
        /// If Woot is a comment then no need to add it in woot list
        if (x.parentkey != null &&
            x.childRewootkey == null &&
            x.user.userId != userModel.userId) {
          // log(x.description);
          return false;
        }

        /// Only include Woots of logged-in user's and his following user's
        if (x.user.userId == userModel.userId ||
            (userModel.followingList != null &&
                userModel.followingList.contains(x.user.userId))) {
          // log(" TRUE -- " + x.description);
          return true;
        }

        return false;
      }).toList();
      if (list.isEmpty) {
        list = null;
      }
    }
    return List.from(list?.reversed ?? [])??[];
  }

  /// set woot for detail woot page
  /// Setter call when woot is tapped to view detail
  /// Add Woot detail is added in _wootDetailModelList
  /// It makes `Fwitter` to view nested Woots
  set setFeedModel(FeedModel model) {
    if (_wootDetailModelList == null) {
      _wootDetailModelList = [];
    }

    /// [Skip if any duplicate woot already present]
    if (_wootDetailModelList.length >= 0) {
      _wootDetailModelList.add(model);
      cprint("Detail Woot added. Total Woot: ${_wootDetailModelList.length}");
      notifyListeners();
    }
  }

  /// `remove` last Woot from woot detail page stack
  /// Function called when navigating back from a Woot detail
  /// `_wootDetailModelList` is map which contain lists of commment Woot list
  /// After removing Woot from Woot detail Page stack its commnets woot is also removed from `_wootDetailModelList`
  void removeLastWootDetail(String wootKey) {
    if (_wootDetailModelList != null && _wootDetailModelList.length > 0) {
      // var index = _wootDetailModelList.in
      FeedModel removeWoot =
          _wootDetailModelList.lastWhere((x) => x.key == wootKey);
      _wootDetailModelList.remove(removeWoot);
      wootReplyMap.removeWhere((key, value) => key == wootKey);
      cprint(
          "Last Woot removed from stack. Remaining Woot: ${_wootDetailModelList.length}");
    }
  }

  /// [clear all woots] if any woot present in woot detail page or comment woot
  void clearAllDetailAndReplyWootStack() {
    if (_wootDetailModelList != null) {
      _wootDetailModelList.clear();
    }
    if (wootReplyMap != null) {
      wootReplyMap.clear();
    }
    cprint('Empty woots from stack');
  }

  /// [Subscribe Woots] firebase Database
  Future<bool> databaseInit() {
    try {
      if (_feedQuery == null) {
        // _feedQuery = kDatabase.child("woot");
        // _feedQuery.onChildAdded.listen(_onWootAdded);
        // _feedQuery.onValue.listen(_onWootChanged);
        // _feedQuery.onChildRemoved.listen(_onWootRemoved);
      }

      return Future.value(true);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return Future.value(false);
    }
  }

  /// get [Woot list] from firebase realtime database
  void getDataFromDatabase() async{
    try {
      isBusy = true;
      notifyListeners();

      ParseResponse parseResponse = await ParseObject('woot').getAll();

      if (parseResponse.success) {

        if(parseResponse.results == null ){
          return ;
        }
        _feedlist = List<FeedModel>();

        print(' woots length from parse = ' + parseResponse.results.length.toString());

        parseResponse.results.forEach((element) {
          var map = element;
          var model = FeedModel.fromJson(map);
          model.key = element['objectId'];
          // if(model.likeList == null)
          //   model.likeList = List<String>();
          // if(model.dislikeList == null)
          //   model.dislikeList = List<String>();
          // if(model.replyWootKeyList == null)
          //   model.replyWootKeyList = List<String>();
          // if(model.user.contactsList == null)
          //   model.user.contactsList = List<String>();
          // if(model.user.followersList == null)
          //   model.user.followersList = List<String>();
          // if(model.user.contactsList == null)
          //   model.dislikeList = List<String>();
          // print(model.key.toString() + " -- " + element['objectId'].toString());
          if (model.isValidWoot)
            _feedlist.add(model);
          // else
          // print('invalid woot__' + model.description ?? 'no description');
        });

        _feedlist.sort((x, y) => DateTime.parse(x.createdAt)
            .compareTo(DateTime.parse(y.createdAt)));
      }
      else {
        print('__else__parseResponse.success__@feedState.dart');
      }

      isBusy = false;
      notifyListeners();

      /// fetch all woots from realtime database....
      /*
      kDatabase.child('woot').once().then((DataSnapshot snapshot) {
        _feedlist = List<FeedModel>();
        if (snapshot.value != null) {
          var map = snapshot.value;
          if (map != null) {
            map.forEach ((key, value) {
              var model = FeedModel.fromJson(value);
              model.key = key;
              if (model.isValidWoot) {
                _feedlist.add(model);
              }
            });

            /// Sort Woot by time
            /// It helps to display newest Woot first.
            _feedlist.sort((x, y) => DateTime.parse(x.createdAt)
                .compareTo(DateTime.parse(y.createdAt)));
          }
        } else {
          _feedlist = null;
        }
        isBusy = false;
        notifyListeners();
      }); */
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: '__getDataFromDatabase__');
      notifyListeners();
    }
  }

  /// get [Woot Detail] from firebase realtime kDatabase
  /// If model is null then fetch woot from firebase
  /// [getpostDetailFromDatabase] is used to set prepare Wooter to display Woot detail
  /// After getting woot detail fetch woot coments from firebase
  void getpostDetailFromDatabase(String postID, {FeedModel model}) async {
    try {
      FeedModel _wootDetail;
      if (model != null) {
        /// set woot data from woot list data.
        /// No need to fetch woot from firebase db if data already present in woot list
        _wootDetail = model;
        setFeedModel = _wootDetail;
        postID = model.key;
      } else {

        ParseResponse parentWootResponse = await ParseObject('woot').getObject(postID);
        if (parentWootResponse.success) {

          _wootDetail = FeedModel.fromJson(parentWootResponse.results.first);
          // _wootDetail.key = fetchWootResponse.results.first['objectId'];
          setFeedModel = _wootDetail;
        }
        /// Fetch woot data from firebase realtime database
        // kDatabase.child('woot').child(postID).once().then((DataSnapshot snapshot) {
        //   if (snapshot.value != null) {
        //     var map = snapshot.value;
        //     _wootDetail = FeedModel.fromJson(map);
        //     _wootDetail.key = snapshot.key;
        //     setFeedModel = _wootDetail;
        //   }
        // });
      }

      if (_wootDetail != null) {
        /// Fetch comment woots
        _commentlist = List<FeedModel>();
        // Check if parent woot has reply woots or not
        if (_wootDetail.replyWootKeyList != null &&
            _wootDetail.replyWootKeyList.length > 0) {
          _wootDetail.replyWootKeyList.forEach((x) {
            print('fetching comments -- $x');
            if (x == null) return;

            ParseObject('woot').getObject(x).then ((commentResponse) {
              var commentModel = FeedModel.fromJson( commentResponse.results.first);
              /// add comment woot to list if woot is not present in [comment woot ]list
              /// To reduce duplicacy
              if (!_commentlist.any((x) => x.key == commentModel.key))
                _commentlist.add(commentModel);
              if (x == _wootDetail.replyWootKeyList.last) {
                /// Sort comment by time
                /// It helps to display newest Woot first.
                _commentlist.sort((x, y) => DateTime.parse(y.createdAt)
                    .compareTo(DateTime.parse(x.createdAt)));
                wootReplyMap.putIfAbsent(postID, () => _commentlist);
                notifyListeners();
              }
            }).catchError( (e) => print(e.toString() + " "));


            /// fetch one by comment from firebase realtime database....
            /*kDatabase.child('woot').child(x).once().then((DataSnapshot snapshot) {
              if (snapshot.value != null) {
                var commentmodel = FeedModel.fromJson(snapshot.value);
                commentmodel.key = snapshot.key;

                /// add comment woot to list if woot is not present in [comment woot ]list
                /// To reduce duplicacy
                if (!_commentlist.any((x) => x.key == snapshot.key)) {
                  _commentlist.add(commentmodel);
                }
              } else {}
              if (x == _wootDetail.replyWootKeyList.last) {
                /// Sort comment by time
                /// It helps to display newest Woot first.
                _commentlist.sort((x, y) => DateTime.parse(y.createdAt)
                    .compareTo(DateTime.parse(x.createdAt)));
                wootReplyMap.putIfAbsent(postID, () => _commentlist);
                notifyListeners();
              }
            });*/
          });
        } else {
          wootReplyMap.putIfAbsent(postID, () => _commentlist);
          notifyListeners();
        }
      }
    } catch (error) {
      cprint(error, errorIn: '__getpostDetailFromDatabase__');
    }
  }

  /// Fetch `Rewoot` model from firebase realtime kDatabase.
  /// Rewoot itself  is a type of `Woot`
  Future<FeedModel> fetchWoot(String postID) async {
    FeedModel _wootDetail;

    /// If woot is available in feedlist then no need to fetch it from firebase
    if (feedlist.any((x) => x.key == postID)) {
      print('already in feedlist__');
      _wootDetail = feedlist.firstWhere((x) => x.key == postID);
    }

    /// If woot is not available in feedlist then need to fetch it from firebase
    else {
      cprint("Fetched from DB: " + postID);
      var model = await kDatabase.child('woot').child(postID).once().then(
        (DataSnapshot snapshot) {
          if (snapshot.value != null) {
            var map = snapshot.value;
            _wootDetail = FeedModel.fromJson(map);
            _wootDetail.key = snapshot.key;
            print(_wootDetail.description);
          }
        },
      );
      if (model != null) {
        _wootDetail = model;
      } else {
        cprint("Fetched null value from  DB");
      }
    }
    return _wootDetail;
  }

  /// create [New Woot]
  Future<void> createWoot(FeedModel model) async {
    ///  Create woot in [Firebase kDatabase]
    isBusy = true;
    notifyListeners();
    try {
      // print(model.user.toJson()); ///
      print('started creating woot');

      ParseResponse response = await model.getParsedObject().create();

      if (response.success){
        print('woot created on parse server');
        model.key = response.results.first['objectId'];
        ParseObject object = ParseObject('woot')..objectId = model.key;

        object.set('key', model.key);
        object.save();
        model.key = model.key;
        /// no need to add in [_feedlist] when we have liveQuery on woot class....
        _feedlist.add(model);
      }
      else {
        print('else__response.success__');
        print(response.error.toString());
      }

      /// woot added to firebase realtime database....
      // await kDatabase.child('woot').push().set(model.toJson());
    } catch (error) {
      cprint(error, errorIn: '__createWoot__');
    }
    isBusy = false;
    notifyListeners();
  }

  ///  It will create woot in [Firebase kDatabase] just like other normal woot.
  ///  update rewoot count for rewooted model
  createReWoot(FeedModel model) {
    try {

      createWoot(model);
      _wootToReplyModel.rewootCount += 1;
      updateWoot(_wootToReplyModel, childRewootkey: model.childRewootkey, rewootKey: _feedlist.last.key);
    } catch (error) {
      cprint(error, errorIn: 'createReWoot');
    }
  }

  /// Add [new comment woot] to any woot
  /// Comment is a Woot itself
  addcommentToPost(FeedModel replyWoot) async{
    try {
      isBusy = true;
      notifyListeners();
      print(replyWoot.parentkey);

      if (_wootToReplyModel != null) {
        FeedModel parentWoot =
        _feedlist.firstWhere((x) => x.key == _wootToReplyModel.key);
        // var commentJson = replyWoot.toJson();

        ParseResponse postResponse = await replyWoot.getParsedObject().create();

        if (postResponse.success){
          print(postResponse.results.first['objectId']);
          replyWoot.key = postResponse.results.first['objectId'];
          ParseObject object = ParseObject('woot')..objectId = replyWoot.key;

          print(replyWoot.key);
          object.set('key', replyWoot.key);
          object.update();

          print("comment posted success__--");
          parentWoot.replyWootKeyList.add(replyWoot.key);

          ParseObject wootUpdate = ParseObject('woot')
            ..objectId = replyWoot.parentkey
            // ..setAdd('replyWootKeyList', replyWoot.key)
            ..setAddUnique('replyWootKeyList', replyWoot.key)
            ..setIncrement('commentCount', 1);

          ParseResponse updateResponse = await wootUpdate.update();

          if (updateResponse.success) {
            print('commentCount update, key added success');
            _feedlist.add(replyWoot);
          }
          else {
            print('__else__updateResponse.success__@addcommentToPost__');
          }
        }
        else {
          print('__else__postResponse.success__@addcommentToPost__');
        }
        /// firebase realtime database approach....
        // kDatabase.child('woot').push().set(commentJson).then((value) async {
        //   parentWoot.replyWootKeyList.add(_feedlist.last.key);
        //   await kDatabase.child('woot').child(parentWoot.key).update({
        //     "replyWootKeyList": parentWoot.replyWootKeyList,
        //     'commentCount': parentWoot.commentCount + 1
        //   });
        // });
      }
    } catch (error) {
      cprint(error, errorIn: 'addcommentToPost');
    }
    isBusy = false;
    notifyListeners();
  }

  /// [Delete woot] in Firebase kDatabase
  /// Remove Woot if present in home page Woot list
  /// Remove Woot if present in Woot detail page or in comment
  deleteWoot(String wootId, WootType type, {String parentkey}) {
    try {
      /// Delete woot if it is in nested woot detail page
      kDatabase.child('woot').child(wootId).remove().then((_) {
        if (type == WootType.Detail &&
            _wootDetailModelList != null &&
            _wootDetailModelList.length > 0) {
          // var deletedWoot =
          //     _wootDetailModelList.firstWhere((x) => x.key == wootId);
          _wootDetailModelList.remove(_wootDetailModelList);
          if (_wootDetailModelList.length == 0) {
            _wootDetailModelList = null;
          }
          cprint('Woot deleted from nested woot detail page woot');
        }
      });
    } catch (error) {
      cprint(error, errorIn: 'deleteWoot');
    }
  }

  /// upload [file] to firebase storage and return its  path url
  Future<String> uploadFile(File file) async {
    try {
      isBusy = true;
      notifyListeners();
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('wootImage${Path.basename(file.path)}');
      StorageUploadTask uploadTask = storageReference.putFile(file);
      var snapshot = await uploadTask.onComplete;
      if (snapshot != null) {
        var url = await storageReference.getDownloadURL();
        if (url != null) {
          return url;
        }
      }
    } catch (error) {
      cprint(error, errorIn: 'uploadFile');
      return null;
    }
  }

  /// [Delete file] from firebase storage
  Future<void> deleteFile (String url, String baseUrl) async {
    try {
      String filePath = url.replaceAll(
          new RegExp(
              r'https://firebasestorage.googleapis.com/v0/b/wootter.appspot.com/o/'),
          '');
      filePath = filePath.replaceAll(new RegExp(r'%2F'), '/');
      filePath = filePath.replaceAll(new RegExp(r'(\?alt).*'), '');
      //  filePath = filePath.replaceAll('wootImage/', '');
      //  cprint('[Path]'+filePath);
      StorageReference storageReference = FirebaseStorage.instance.ref();
      await storageReference.child(filePath).delete().catchError((val) {
        cprint('[Error]' + val);
      }).then((_) {
        cprint('[Sucess] Image deleted');
      });
    } catch (error) {
      cprint(error, errorIn: 'deleteFile');
    }
  }

  /// [update] woot
  updateWoot (FeedModel model, {String childRewootkey, String rewootKey}) async {
    ParseObject rewootedObject = ParseObject('woot')
      ..objectId = childRewootkey
      /// ....
      // ..setAddUnique('replyWootKeyList', rewootKey)
      ..setIncrement('rewootCount', 1);

    await rewootedObject.update();
    
    /// firebase realtime database update....
    // await kDatabase.child('woot').child(model.key).update(model.toJson());
  }

  calculateStar (FeedModel woot) {
    var diff = woot.user.totalLikes - woot.user.totalDisLikes;
    if (diff < 0 /*|| woot.user.totalLikes == 0*/) {
      woot.user.ratingPattern = '00000';
    } else if (diff == 0) {
      woot.user.ratingPattern = '10000';
    } else {
      var percentage = (diff / woot.user.totalLikes ?? 1) * 100;
      if (percentage > 0 && percentage <= 10.0)
        woot.user.ratingPattern = '10000';
      if (percentage > 10.0 && percentage <= 20.0)
        woot.user.ratingPattern = '20000';
      else if (percentage > 20.0 && percentage <= 30.0)
        woot.user.ratingPattern = '21000';
      else if (percentage > 30.0 && percentage <= 40.0)
        woot.user.ratingPattern = '22000';
      else if (percentage > 40.0 && percentage <= 50.0)
        woot.user.ratingPattern = '22100';
      else if (percentage > 50.0 && percentage <= 60.0)
        woot.user.ratingPattern = '22200';
      else if (percentage > 60.0 && percentage <= 70.0)
        woot.user.ratingPattern = '22210';
      else if (percentage > 70.0 && percentage <= 80.0)
        woot.user.ratingPattern = '22220';
      else if (percentage > 80.0 && percentage <= 90.0)
        woot.user.ratingPattern = '22221';
      else if (percentage > 90.0 && percentage <= 100.0)
        woot.user.ratingPattern = '22222';
    }
    return woot.user.ratingPattern;
   print('pattern = '+woot.user.ratingPattern);
  }

  updateTotals (FeedModel woot, {bool isLike, bool isBoth = false, bool isAdd}) async {
    cprint('updateStar');
    kDatabase.child('rating').child(woot.user.userId).once().then((data) async{
//       print("l = " + woot.user.totalLikes.toString());
//       print("d = " + woot.user.totalDisLikes.toString());
      woot.user.totalLikes = data.value['totalLikes'] ?? 0;
      woot.user.totalDisLikes = data.value['totalDisLikes'] ?? 0;

//       print("feedlist.length = ${feedlist.length}");
//       print("_feedlist.length = ${_feedlist.length}");
      if (isLike && isBoth) {
        if (isAdd) {
          woot.user.totalLikes += 1;
          woot.user.totalDisLikes -= 1;
        }
        else {
          woot.user.totalDisLikes += 1;
          woot.user.totalLikes -= 1;
        }
      }
      else if (!isLike && isBoth) {
        if (isAdd) {
          woot.user.totalDisLikes += 1;
          woot.user.totalLikes -= 1;
        }
        else {
          woot.user.totalLikes += 1;
          woot.user.totalDisLikes -= 1;
        }
      }
      else if (isLike)
        if (isAdd) woot.user.totalLikes += 1;
        else woot.user.totalLikes -= 1;
      else
        if (isAdd) woot.user.totalDisLikes += 1;
        else woot.user.totalDisLikes -= 1;

//       print("l = " + woot.user.totalLikes.toString());
//       print("d = " + woot.user.totalDisLikes.toString());

      var updateLikes = {
        "totalLikes": woot.user.totalLikes,
        "totalDisLikes": woot.user.totalDisLikes,
        'ratingPattern': calculateStar(woot)
      };

      kDatabase.child('rating').child(woot.user.userId).update(updateLikes);
    });
  }

  /// Add/Remove like on a Woot
  /// [postId] is woot id, [userKeyId] is user's id who like/unlike Woot
  addLikeToWoot (FeedModel woot, String userKeyId, [bool isAlreadyUpdated = false]) async{
    try {
      int index = feedlist.indexOf(woot);
      if (woot.likeList != null &&
          woot.likeList.length > 0 &&
          woot.likeList.any((id) => id == userKeyId)) {
        /// If user wants to undo/remove his like on woot
        _feedlist.firstWhere((element) => element.key == woot.key)
            .likeList.removeWhere((id) => id == userKeyId);
        _feedlist.firstWhere((element) => element.key == woot.key).likeCount -= 1;
        // if (_feedlist.elementAt(index).key == woot.key) {
        //   print('__match__');
        //   _feedlist[index].likeList.removeWhere((id) => id == userKeyId);
        //   _feedlist[index].likeCount -= 1;
        // }

        updateTotals(woot, isLike: true, isAdd: false);
        updateLike(wootId: woot.key, userKeyId: userKeyId, isAdd: false);
      } else {
        /// If user like Woot
        if (woot.likeList == null) {
          _feedlist.firstWhere((element) => element.key == woot.key).likeList = [];
          woot.likeList = [];
        }
        _feedlist.firstWhere((element) => element.key == woot.key).likeList.add(userKeyId);
        _feedlist.firstWhere((element) => element.key == woot.key).likeCount += 1;

        notifyListeners();
        updateLike(wootId: woot.key, userKeyId: userKeyId, isAdd: true);
        // if (!isAlreadyUpdated)
        //   await updateTotals(woot, isLike: true, isBoth: true, isAdd: true);

        if (!isAlreadyUpdated && woot.dislikeList.any((id) => id == userKeyId)) {
          addDisLikeToWoot(woot, userKeyId, true);
          updateTotals(woot, isLike: true, isBoth: true, isAdd: true);
        }
        else updateTotals(woot, isLike: true, isAdd: true);
      }

      /// calculate star rating for profile

      /// update likelist of a woot on firebase realtime database....
      // kDatabase.child('woot').child(woot.key).child('likeList')
      // .set(woot.likeList);

      /// Sends notification to user who created woot
      /// User owner can see notification on notification page
      kDatabase.child('notification').child(woot.userId).child(woot.key).set({
        'type':
            woot.likeList.length == 0 ? null : NotificationType.Like.toString(),
        'updatedAt': woot.likeList.length == 0
            ? null
            : DateTime.now().toUtc().toString(),
      });
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: '__addLikeToWoot__');
      notifyListeners();
    }
  }

  addDisLikeToWoot (FeedModel woot, String userKeyId, [bool isAlreadyUpdated = false]) async{
    try {

      if (woot.dislikeList != null && woot.dislikeList.length > 0 &&
          woot.dislikeList.any((id) => id == userKeyId)) {
        /// If user wants to undo/remove his dislike on woot
        _feedlist.firstWhere((element) => element.key == woot.key)
            .dislikeList.removeWhere((id) => id == userKeyId);
        _feedlist.firstWhere((element) => element.key == woot.key).dislikeCount -= 1;
        // if (_feedlist.elementAt(index).key == woot.key) {
        //   _feedlist[index].dislikeList.removeWhere((id) => id == userKeyId);
        //   _feedlist[index].dislikeCount -= 1;
        // }
        // notifyListeners();
        updateTotals(woot, isLike: false, isAdd: false );
        updateDisLike(wootId: woot.key, userKeyId: userKeyId, isRemove: true);
      } else {
        /// If user dislike Woot
        if (woot.dislikeList == null) {
          _feedlist.firstWhere((element) => element.key == woot.key).dislikeList = [];
          woot.dislikeList = [];
        }
        _feedlist.firstWhere((element) => element.key == woot.key).dislikeList.add(userKeyId);
        _feedlist.firstWhere((element) => element.key == woot.key).dislikeCount += 1;

        updateDisLike(wootId: woot.key, userKeyId: userKeyId, isRemove: false);
        // if (!isAlreadyUpdated) {
        //   updateTotals(woot, isLike: false, isBoth: true, isAdd: false);
        // }
        if (!isAlreadyUpdated && woot.likeList.any((id) => id == userKeyId)) {
          addLikeToWoot(woot, userKeyId, true);
          updateTotals(woot, isLike: false, isBoth: true, isAdd: true);
        }
        else {
          updateTotals(woot, isLike: false, isAdd: true);
        }
      }

      /// update dislikelist of a woot in firebase realtime database
      // kDatabase.child('woot').child(woot.key).child('dislikeList')
      //     .set(woot.dislikeList);

      /// Sends notification to user who created woot
      /// User owner can see notification on notification page
      kDatabase.child('notification').child(woot.userId).child(woot.key).set({
        'type': woot.dislikeList.length == 0
            ? null
            : NotificationType.Like.toString(),
        'updatedAt': woot.dislikeList.length == 0
            ? null
            : DateTime.now().toUtc().toString(),
      });
      notifyListeners();

    } catch (error) {
      cprint(error, errorIn: 'addDisLikeToWoot');
      notifyListeners();

    }
  }

  ///update likeList and count on parse server
  updateLike ({ @required String wootId, @required String userKeyId,
    @required bool isAdd, }) async
  {
    log(userKeyId);
    log(wootId);
    ParseObject updateObject = ParseObject('woot')..objectId = wootId;
    if (isAdd)
      updateObject.setAddUnique('likeList', userKeyId);
    else
      updateObject.setRemove('likeList', userKeyId);
    await updateObject.save()
        .then((value) => print(value.results))
        .catchError((onError) => print('__error__:) ${onError.toString()}'));

    cprint("__update__likeList");
  }

  ///update  disLikeList and count on parse server
  updateDisLike ({ @required String wootId, @required String userKeyId,
    @required bool isRemove }) async
  {
    cprint(wootId);
    ParseObject updateObject = ParseObject('woot')..objectId = wootId;
    if (isRemove)
      updateObject.setRemove('dislikeList', userKeyId);
    else
      updateObject.setAddUnique('dislikeList', userKeyId);
    await updateObject.save()
        .then((value) => print(value.results))
        .catchError((onError) => print('__error__:) ${onError.toString()}'));

    cprint("__update__dislikeList");
  }

  /// Trigger when any woot changes or update
  /// When any woot changes it update it in UI
  /// No matter if Woot is in home page or in detail page or in comment section.
  _onWootChanged(Event event) {
    var model = FeedModel.fromJson(event.snapshot.value);
    model.key = event.snapshot.key;
    if (_feedlist.any((x) => x.key == model.key)) {
      var oldEntry = _feedlist.lastWhere((entry) {
        return entry.key == event.snapshot.key;
      });
      _feedlist[_feedlist.indexOf(oldEntry)] = model;
    }

    if (_wootDetailModelList != null && _wootDetailModelList.length > 0) {
      if (_wootDetailModelList.any((x) => x.key == model.key)) {
        var oldEntry = _wootDetailModelList.lastWhere((entry) {
          return entry.key == event.snapshot.key;
        });
        _wootDetailModelList[_wootDetailModelList.indexOf(oldEntry)] = model;
      }
      if (wootReplyMap != null && wootReplyMap.length > 0) {
        if (true) {
          var list = wootReplyMap[model.parentkey];
          //  var list = wootReplyMap.values.firstWhere((x) => x.any((y) => y.key == model.key));
          if (list != null && list.length > 0) {
            var index =
                list.indexOf(list.firstWhere((x) => x.key == model.key));
            list[index] = model;
          } else {
            list = [];
            list.add(model);
          }
        }
      }
    }
    if (event.snapshot != null) {
      cprint('Woot updated');
      isBusy = false;
      notifyListeners();
    }
  }

  /// Trigger when new woot added
  /// It will add new Woot in home page list.
  /// IF Woot is comment it will be added in comment section too.
  _onWootAdded(Event event) {
    FeedModel woot = FeedModel.fromJson(event.snapshot.value);
    woot.key = event.snapshot.key;

    /// Check if Woot is a comment
    _onCommentAdded(woot);
    woot.key = event.snapshot.key;
    if (_feedlist == null) {
      _feedlist = List<FeedModel>();
    }
    if ((_feedlist.length == 0 || _feedlist.any((x) => x.key != woot.key)) &&
        woot.isValidWoot) {
      _feedlist.add(woot);
      cprint('Woot Added');
    }
    isBusy = false;
    notifyListeners();
  }

  /// Trigger when comment woot added
  /// Check if Woot is a comment
  /// If Yes it will add woot in comment list.
  /// add [new woot] comment to comment list
  _onCommentAdded(FeedModel woot) {
    if (woot.childRewootkey != null) {
      /// if Woot is a type of rewoot then it can not be a comment.
      return;
    }
    if (wootReplyMap != null && wootReplyMap.length > 0) {
      if (wootReplyMap[woot.parentkey] != null) {
        wootReplyMap[woot.parentkey].add(woot);
      } else {
        wootReplyMap[woot.parentkey] = [woot];
      }
      cprint('Comment Added');
    }
    isBusy = false;
    notifyListeners();
  }

  /// Trigger when Woot `Deleted`
  /// It removed Woot from home page list, Woot detail page list and from comment section if present
  _onWootRemoved(Event event) async {
    FeedModel woot = FeedModel.fromJson(event.snapshot.value);
    woot.key = event.snapshot.key;
    var wootId = woot.key;
    var parentkey = woot.parentkey;

    ///  Delete woot in [Home Page]
    try {
      FeedModel deletedWoot;
      if (_feedlist.any((x) => x.key == wootId)) {
        /// Delete woot if it is in home page woot.
        deletedWoot = _feedlist.firstWhere((x) => x.key == wootId);
        _feedlist.remove(deletedWoot);

        if (deletedWoot.parentkey != null &&
            _feedlist.isNotEmpty &&
            _feedlist.any((x) => x.key == deletedWoot.parentkey)) {
          // Decrease parent Woot comment count and update
          var parentModel =
              _feedlist.firstWhere((x) => x.key == deletedWoot.parentkey);
          parentModel.replyWootKeyList.remove(deletedWoot.key);
          parentModel.commentCount = parentModel.replyWootKeyList.length;
          updateWoot(parentModel);
        }
        if (_feedlist.length == 0) {
          _feedlist = List<FeedModel>();
        }
        cprint('Woot deleted from home page woot list');
      }

      /// [Delete woot] if it is in nested woot detail comment section page
      if (parentkey != null &&
          parentkey.isNotEmpty &&
          wootReplyMap != null &&
          wootReplyMap.length > 0 &&
          wootReplyMap.keys.any((x) => x == parentkey)) {
        // (type == WootType.Reply || wootReplyMap.length > 1) &&
        deletedWoot =
            wootReplyMap[parentkey].firstWhere((x) => x.key == wootId);
        wootReplyMap[parentkey].remove(deletedWoot);
        if (wootReplyMap[parentkey].length == 0) {
          wootReplyMap[parentkey] = null;
        }

        if (_wootDetailModelList != null &&
            _wootDetailModelList.isNotEmpty &&
            _wootDetailModelList.any((x) => x.key == parentkey)) {
          var parentModel =
              _wootDetailModelList.firstWhere((x) => x.key == parentkey);
          parentModel.replyWootKeyList.remove(deletedWoot.key);
          parentModel.commentCount = parentModel.replyWootKeyList.length;
          cprint('Parent woot comment count updated on child woot removal');
          updateWoot(parentModel);
        }

        cprint('Woot deleted from nested woot detail comment section');
      }

      /// Delete woot image from firebase storage if exist.
      if (deletedWoot.imagePath != null && deletedWoot.imagePath.length > 0) {
        deleteFile(deletedWoot.imagePath, 'wootImage');
      }

      /// If a rewoot is deleted then rewootCount of original woot should be decrease by 1.
      if (deletedWoot.childRewootkey != null) {
        await fetchWoot(deletedWoot.childRewootkey).then((rewootModel) {
          if (rewootModel == null) {
            return;
          }
          if (rewootModel.rewootCount > 0) {
            rewootModel.rewootCount -= 1;
          }
          updateWoot(rewootModel);
        });
      }

      /// Delete notification related to deleted Woot.
      if (deletedWoot.likeCount > 0) {
        kDatabase.child('notification').child(woot.userId).child(woot.key).remove();
      }
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: '_onWootRemoved');
    }
  }

  updateViews(FeedModel model, String authUserId) {
    ParseObject wootO = ParseObject('woot')..objectId = model.key;
    /// need to change count in feedPage
    wootO.setAddUnique('viewsList', authUserId);
    wootO.get('views');
    wootO.save().then((response) {
      if (response.success) {
        log('view added');

      }
    });
  }
}
