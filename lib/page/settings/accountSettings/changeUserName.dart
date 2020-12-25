import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/state/feedState.dart';
import 'package:wootter_x/state/searchState.dart';

class ChangeUserNamePage extends StatefulWidget {
  @override
  _ChangeUserNamePageState createState() => _ChangeUserNamePageState();
}

class _ChangeUserNamePageState extends State<ChangeUserNamePage> {
  bool isValid = true;
  String userName;
  AuthState state;
  FeedState feedState;
  SearchState searchState;
  List<String> userNameList;
  TextEditingController oldUserName;
  TextEditingController newUserName;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    searchState = Provider.of<SearchState>(context, listen: false);
    feedState = Provider.of<FeedState>(context, listen: false);
    state = Provider.of<AuthState>(context, listen: false);
    userNameList = searchState.userlist.map((e) => e.userName).toList();
    userNameList.remove(state.userModel.userName);
    print(userNameList);
    print(state.userModel.userName);
    print(searchState.userlist.length);
    userName = state.userModel.userName;
    oldUserName = TextEditingController(text: userName);
    userName = userName.substring(1);

    newUserName = TextEditingController(text: userName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: TwitterColor.white,
        appBar: AppBar(
          title: Text(
            'Change username',
            style: TextStyle(fontSize: 20),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          actions: <Widget>[
            FlatButton(
              textColor: isValid
                  ? TwitterColor.dodgetBlue
                  : TwitterColor.dodgetBlue_50,
              child: Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                newUserName.text.replaceFirst('#', " ");
                print(newUserName.text);

                newUserName.text = "#" + newUserName.text;
                if (isValid) {
                  var data = {'userName': newUserName.text};

                  print(feedState.feedlist.length);
                  print(state.user.uid);

//                   for (int i = 0; i < feedState.feedlist.length; i++) {
// //                  print(feedState.feedlist.elementAt(i).user.userId);
//                     if (feedState.feedlist.elementAt(i).user.userId ==
//                         state.user.uid) {
//                       feedState.feedlist.elementAt(i).user.userName =
//                           newUserName.text;
//                     }
//                   }
                  for (int i = 0; i < searchState.userlist.length; i++) {
//                  print(searchState.userlist.elementAt(i).userId);
                    if (searchState.userlist.elementAt(i).userId ==
                        state.user.uid) {
                      searchState.userlist.elementAt(i).userName =
                          newUserName.text;
                      break;
                    }
                  }

                  state.changeUserAlias(newUserName.text);
                  // state.notifyListeners();
                  // kDatabase.child('profile').child(state.user.uid).update(data);
                  Navigator.pop(context);

                  /// searchState userList' user username is needed to update?....
                }
              },
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: Column(
            children: <Widget>[
              ListTile(
                  title: Text("Current"),
                  subtitle: TextField(
                    enabled: false,
                    controller: oldUserName,
                    style: TextStyle(color: AppColor.lightGrey),
                  )),
              Padding(
                padding: EdgeInsets.all(15),
              ),
              ListTile(
                title: Text("New"),
                subtitle: Form(
                  key: _formKey,
                  child: TextFormField(
                    maxLines: 1,
                    cursorColor: TwitterColor.dodgetBlue,
                    decoration: InputDecoration(
                        suffixIcon: isValid
                            ? Icon(Icons.check_circle_outline,
                                color: Colors.green)
                            : Icon(Icons.error_outline, color: Colors.red),
                        border: isValid
                            ? UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black))
                            : UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red))),
                    controller: newUserName,
                    onChanged: (newName) {
                      _formKey.currentState.validate();
                    },
                    validator: (value) => checkAvilabity(),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  String checkAvilabity() {
    RegExp uname = RegExp(r'(\d{1})');
//    newUserName.text
    if (newUserName.text.length < 4) {
      if (isValid)
        setState(() {
          isValid = false;
        });
      return 'username should be more than 4 characters';
    } else if (userNameList.contains(newUserName.text)) {
      if (isValid)
        setState(() {
          isValid = false;
        });
      return 'Username has already been taken';
    } else if (uname.stringMatch(newUserName.text) == null) {
      if (isValid)
        setState(() {
          isValid = false;
        });
      return 'Username is premium, to avial it contact us';
    } else if (newUserName.text.length > 15) {
      if (isValid)
        setState(() {
          isValid = false;
        });
      return 'Your username must be 15 characters or less and contails only letters,numbers, and underscores and no space';
    } else if (newUserName.text.contains(' ')) {
      if (isValid)
        setState(() {
          isValid = false;
        });
      return 'Your username must be 15 characters or less and contails only letters,numbers, and underscores and no space';
    }
    if (!isValid)
      setState(() {
        isValid = true;
      });
    return null;
  }
}
