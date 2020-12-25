import 'package:flutter/material.dart';
import 'package:flutter_contact/contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/page/suggestion/SuggestionPage.dart';
import 'package:wootter_x/state/authState.dart';

class ContactsSyncScreen extends StatefulWidget {
  @override
  _ContactsSyncScreenState createState() => _ContactsSyncScreenState();
}

class _ContactsSyncScreenState extends State<ContactsSyncScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hasPermission;
  @override
  void initState() {
    super.initState();
    _askPermissions();
  }

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus;
    while (permissionStatus != PermissionStatus.granted) {
      try {
        permissionStatus = await _getContactPermission();
        if (permissionStatus != PermissionStatus.granted) {
          _hasPermission = false;
        } else {
          _hasPermission = true;
        }
      } catch (e) {
        var snackbar = SnackBar(content: Text("$e"));
        _scaffoldKey.currentState.showSnackBar(snackbar);
      }
    }
    setState(() {});
  }

  Future<PermissionStatus> _getContactPermission() async {
    final status = await Permission.contacts.status;
    if (!status.isGranted) {
      final result = await Permission.contacts.request();
      return result ?? PermissionStatus.undetermined;
    } else {
      return status;
    }
  }

  Future<bool> _syncContacts() async {
    try {
      var state = Provider.of<AuthState>(context, listen: false);
      String value;
      List<String> _contacts = [];
      await Contacts.streamContacts().forEach((contact) {
        contact.phones.forEach((element) {
          value = element.value;
          _contacts.add(value.replaceAll(' ', ''));
        });
      });
      await kDatabase
          .child('profile')
          .child(state.user.uid)
          .update({'contacts': _contacts});
    } catch (e) {
      var snackbar = SnackBar(content: Text("$e"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 20),
                height: 80,
                width: 80,
                child: Image.asset(
                  "assets/images/icon-48.png",
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Connect your address book to find people you may kow on Wootter",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.w800),
              ),
              Spacer(),
              Text(
                """Contact form your address book will be uploaded to Wootter on an ongoing basis to help connect you with your friends and personalize content, such as making suggestions for you and other. You can turn off syncing and removing previously uploaded contacts in your setting""",
              ),
              Container(
                width: double.infinity,
                child: RaisedButton(
                  color: TwitterColor.dodgetBlue,
                  onPressed: () async {
                    if (_hasPermission) {
                      await _syncContacts();
                      Route route = MaterialPageRoute(
                        builder: (_) => SuggestionPage(),
                      );
                      Navigator.push(context, route);
                    }
                    else _askPermissions();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Sync Contacts",
                    style: Theme.of(context).textTheme.button.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                ),
              ),
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Not Now"),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
