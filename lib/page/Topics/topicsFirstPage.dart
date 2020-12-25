import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/page/Topics/topics.dart';
import 'package:wootter_x/state/authState.dart';

class TopicsFirstPage extends StatefulWidget {
  final Map<dynamic, dynamic> topics;

  const TopicsFirstPage({Key key, this.topics}) : super(key: key);

  @override
  _TopicsFirstPageState createState() => _TopicsFirstPageState();
}

class _TopicsFirstPageState extends State<TopicsFirstPage> {
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
    databaseSelected = widget.topics;
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.all(15),
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    width: 80,
                    height: 80,
                    child: Image.asset(
                      "assets/images/icon-48.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  Text(
                    "Topics you may interested in",
                    style: Theme.of(context).textTheme.headline6.copyWith(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Lets choose some Topics of your personal Interest or by finding people to follow.",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  buildSearch()
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: key.length,
                  itemBuilder: (context, i) {
                    Map<String, Object> tt = topic.values.elementAt(i);
                    return Container(
                      padding: EdgeInsets.all(15),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key.elementAt(i).toString(),
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Wrap(
                            children: List.generate(
                              tt.values.length,
                              (index) => buildTile(
                                  tt, i, index, buttonEnabled[i][index]),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              child: Text(
                "Skip for now",
                style: TextStyle(color: TwitterColor.dodgetBlue),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            RaisedButton(
              color: TwitterColor.dodgetBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              onPressed: () async {
                setTopics();
                await updateTopics();
              },
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white, ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTile(
      Map<String, Object> tt, int topicIndex, int itemIndex, bool isEnabled) {
    return FittedBox(
      child: InkWell(
        child: Container(
          margin: EdgeInsets.only(left: 10, top: 10),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: TwitterColor.dodgetBlue),
            borderRadius: BorderRadius.circular(20),
            color: isEnabled
                ? TwitterColor.dodgetBlue.withOpacity(0.8)
                : TwitterColor.white,
          ),
          child: Center(
            child: Text(
              tt.keys.elementAt(itemIndex).toString(),
              style: TextStyle(color: isEnabled ? Colors.white : TwitterColor.dodgetBlue),
            ),
          ),
        ),
        onTap: () {
          setState(() {
            isEnabled = !isEnabled;
          });
          buttonEnabled[topicIndex][itemIndex] = isEnabled;
        },
      ),
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

    ParseObject authO = ParseObject('profile')..objectId = _state.userModel.key;
    authO.set('topics', userSelected.cast());
    authO.setAddAll('topicslist', _topics);

    authO.save().then((response) async{
      if (response.success) {
        print('updated topiclist');
        var pf = await SharedPreferences.getInstance();
        await pf.setBool('firstShowSuggustion', true);
      }
    });

    // await kDatabase
    //     .child('test')
    //     .child('userProfile')
    //     .update({"topics": userSelected.cast(), 'topicslist': _topics});
    
    _state.userModel.topics = userSelected.cast();
    _state.notifyListeners();

    Navigator.pop(context);
  }

  Widget buildSearch() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: TextField(
        style: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
        autocorrect: false,
        expands: false,
        decoration: InputDecoration(
          labelText: "Search",
          prefixIcon: Icon(Icons.search, color: TwitterColor.dodgetBlue),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: TwitterColor.dodgetBlue, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: TwitterColor.dodgetBlue,
              width: 1.0,
            ),
          ),
          fillColor: Colors.grey.shade400,
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        ),
      ),
    );
  }
}
