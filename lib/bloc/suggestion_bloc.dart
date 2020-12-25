import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/model/user.dart';

class SuggestionBloc {
  StreamController<List<MyUser>> _stream;
  Stream<List<MyUser>> get suggetionStream => _stream.stream;
  List<MyUser> _userlist;

  SuggestionBloc({MyUser user}) {
    _stream = StreamController<List<MyUser>>.broadcast();
    if (user != null) {
      startStream(user);
    }
  }

  startStream(MyUser user) async {
    try {
      List<dynamic> _myTopics = [];
      user.topics.cast().forEach((key, value) {
        _myTopics.addAll(value);
      });
      kDatabase.child('profile').limitToFirst(50).once().then(
        (DataSnapshot snapshot) {
          _userlist = List<MyUser>();
          if (snapshot.value != null) {
            var map = snapshot.value;
            if (map != null) {
              map.forEach((key, value) {
                var model = MyUser.fromJson(value);
                if (user.contactsList.contains(model.contact) &&
                    model.userId != user.userId) {
                  model.key = key;
                  _userlist.add(model);
                }
                if (model.topics != null && model.userId != user.userId) {
                  model.topics.cast().forEach((key, value) {
                    if (value.length > 0) {
                      _myTopics.forEach((element) {
                        if (value.contains(element)) {
                          model.key = key;
                          _userlist.add(model);
                        }
                      });
                    }
                  });
                }
              });
              user.followingList.forEach((follower) =>
                  _userlist.removeWhere((e) => e.userId == follower));
              _userlist = _userlist.toSet().toList();
              _userlist.sort((x, y) => y.followers.compareTo(x.followers));
              _stream.sink.add(_userlist);
            }
          } else {
            _stream.sink.add(null);
          }
        },
      );
    } catch (error) {
      _stream.sink.addError(error);
    }
  }

  void filterByUsername(String name) {
    if (name.isEmpty) {
      _stream.sink.add(_userlist);
    }
    List<MyUser> _list = _userlist
        .where((x) =>
            x.userName != null &&
            x.userName.toLowerCase().contains(name.toLowerCase()))
        .toList();
    _stream.sink.add(_list);
  }

  dispose() {
    _stream.close();
  }
}
