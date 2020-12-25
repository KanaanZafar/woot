import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:wootter_x/bloc/notifications_sender.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/model/user.dart';

class SuggestionState with ChangeNotifier {
  List<MyUser> _suggestionsList;
  List<MyUser> _persistantList;

  bool isUiBsy = false;

  SuggestionState() {
    _suggestionsList = [];
    _persistantList = [];
  }

  List<MyUser> get suggestionsList => _suggestionsList;

  fetchSuggestions(MyUser user) async {
    try {
      List<dynamic> _myTopics = [];
      user.topics.cast().forEach((key, value) {
        _myTopics.addAll(value);
      });
      kDatabase.child('profile').limitToFirst(50).once().then(
        (DataSnapshot snapshot) {
          _suggestionsList = List<MyUser>();
          if (snapshot.value != null) {
            var map = snapshot.value;
            if (map != null) {
              map.forEach((key, value) {
                var model = MyUser.fromJson(value);
                if (user.contactsList.contains(model.contact) &&
                    model.userId != user.userId) {
                  model.key = key;
                  _suggestionsList.add(model);
                }
                if (model.topics != null && model.userId != user.userId) {
                  model.topics.cast().forEach((key, value) {
                    if (value.length > 0) {
                      _myTopics.forEach((element) {
                        if (value.contains(element)) {
                          model.key = key;
                          _suggestionsList.add(model);
                        }
                      });
                    }
                  });
                }
              });
              user.followingList.forEach((follower) =>
                  _suggestionsList.removeWhere((e) => e.userId == follower));
              _suggestionsList = _suggestionsList.toSet().toList();
              _suggestionsList
                  .sort((x, y) => y.followers.compareTo(x.followers));
            }
          } else {
            _suggestionsList = [];
          }
        },
      );
      _persistantList = _suggestionsList;
      isUiBsy = false;
    } catch (error) {
      cprint("$error");
      isUiBsy = false;
    }
    notifyListeners();
  }

  Future<void> addFollowing(MyUser user, MyUser following) async {
    List<String> followingList = List.from(user.followingList);
    followingList.add(following.userId);
    followingList = followingList.toSet().toList();
    List<String> followerList = List.from(following.followersList);
    followerList.add(following.userId);
    followerList = followerList.toSet().toList();
    await kDatabase.child('profile').child(user.userId).update(
        {"followingList": followingList, 'following': followingList.length});
    await kDatabase
        .child('profile')
        .child(following.userId)
        .update({"followerList": followerList});
    _suggestionsList
        .removeWhere((element) => element.userId == following.userId);
    notifyListeners();
    await SendFCM().sendToFollower(following, user);
  }

  Future<void> removeFollowing(MyUser user, String followingId) async {
    List<String> _selected = List.from(user.followersList);
    _selected.remove(followingId);
    await kDatabase
        .child('profile')
        .child(user.userId)
        .update({"followingList": _selected, 'following': _selected.length});
  }

  void filterByUsername(String name) {
    if (name.trim().isEmpty) {
      _suggestionsList = _persistantList;
    } else {
      _suggestionsList = _suggestionsList
          .where((x) =>
              x.userName != null &&
              x.userName.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}
