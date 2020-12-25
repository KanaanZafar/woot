import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/page/Topics/topics.dart';
import 'package:wootter_x/state/authState.dart';

class TopicsPage extends StatefulWidget {
  @override
  _TopicsPageState createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  AuthState _state;
  static final topic = Topics().topics;
  var key = topic.keys;
  List<List<bool>> buttonEnabled;
  Map userSelected = Map();
  List<String> label = ["Follow", "Following"];
  List<TextStyle> ts = [
    TextStyle(color: TwitterColor.dodgetBlue),
    TextStyle(color: TwitterColor.white)
  ];
  Map databaseSelected = Map();

  @override
  void initState() {
    _state = Provider.of<AuthState>(context, listen: false);
    databaseSelected = _state.userModel.topics ?? Map();
    getLength();
    super.initState();
  }

  getLength() {
    var k = topic.keys.length;
    buttonEnabled = List();
    List ll;
    for (int i = 0; i < k; i++) {
      List<bool> temp = [];
      ll = databaseSelected["${topic.keys.elementAt(i)}"] ?? List();
      for (int j = 0; j < topic.values.elementAt(i).values.length; j++) {
        if (ll.length > 0 &&
            ll.contains(topic.values.elementAt(i).keys.elementAt(j)))
          temp.add(true);
        else
          temp.add(false);
      }
      buttonEnabled.add(temp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Topics"),
        actions: <Widget>[
          FlatButton(
            child: Text("Save"),
            textColor: TwitterColor.dodgetBlue,
            onPressed: () {
              setTopics();
              updateTopics();
            },
          )
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: key.length,
          itemBuilder: (BuildContext context, i1) {
            Map<String, Object> tt = topic.values.elementAt(i1);
            return Container(
              child: ExpansionTile(
                title: Text(key.elementAt(i1).toString()),
                children: List.generate(tt.values.length, (index) {
                  bool isEnabled = buttonEnabled[i1][index];
                  return StatefulBuilder(
                      builder: (BuildContext context, followingState) =>
                          ListTile(
                            title: Text(tt.keys.elementAt(index).toString()),
                            trailing: InkWell(
                              child: Container(
                                  width: 100,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: TwitterColor.dodgetBlue),
                                    borderRadius: BorderRadius.circular(20),
                                    color: isEnabled
                                        ? TwitterColor.dodgetBlue
                                        : TwitterColor.white,
                                  ),
                                  child: Center(
                                    child: isEnabled
                                        ? Text(label[1], style: ts[1])
                                        : Text(label[0], style: ts[0]),
                                  )),
                              onTap: () {
                                followingState(() {
                                  isEnabled = !isEnabled;
                                });
                                buttonEnabled[i1][index] = isEnabled;
                              },
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 30),
                          ));
                }),
              ),
            );
          },
        ),
      ),
//      floatingActionButton: FloatingActionButton(
//        child: Text("Show"),
//        onPressed: (){
//          getTopics();
//        },
//      ),
    );
  }

  setTopics() {
    var k = topic.keys.length;
    List<String> tt;
    for (int i = 0; i < k; i++) {
      Map temp = topic.values.elementAt(i);
      tt = List();
      for (int j = 0; j < topic.values.elementAt(i).values.length; j++)
        if (buttonEnabled[i][j]) tt.add(temp.keys.elementAt(j));
      userSelected.update("${topic.keys.elementAt(i)}", (value) => tt,
          ifAbsent: () => tt);
    }
  }

  updateTopics() async {
    List<String> _topics = [];
    userSelected.values.forEach((element) {
      if (element.length != 0) {
        _topics.addAll(element);
      }
    });
    await kDatabase
        .child('profile')
        .child(_state.user.uid)
        .update({"topics": userSelected.cast(), 'topicslist': _topics});
    _state.userModel.topics = userSelected.cast();
    _state.notifyListeners();
    Navigator.pop(context);
  }
}
