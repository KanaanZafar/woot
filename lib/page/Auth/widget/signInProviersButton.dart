import 'package:flutter/material.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/widgets/newWidget/customLoader.dart';
import 'package:provider/provider.dart';

class signInProviderButton extends StatelessWidget {
  signInProviderButton({Key key, @required this.loader, this.loginCallback});
  final CustomLoader loader;
  final Function loginCallback;
  List<String> signInProviders = [
    "assets/images/google_login.png",
    "assets/images/facebook_login.png",
    "assets/images/twitter_login.png"
  ];

  void _googleLogin(context) {
    var state = Provider.of<AuthState>(context, listen: false);
    loader.showLoader(context);
    state.handleGoogleSignIn().then((status) {
      // print(status)
      if (state.user != null) {
        loader.hideLoader();
        Navigator.pop(context);
        loginCallback();
      } else {
        loader.hideLoader();
        cprint('Unable to login', errorIn: '_googleLoginButton');
      }
    });
  }

  void _facebookLogin(context) {
    var state = Provider.of<AuthState>(context, listen: false);
    loader.showLoader(context);
    state.handleFacebookSignIn().then((status) {
        // print("fbstatus ${status.providerData}");
      if (state.user != null) {
        loader.hideLoader();
        Navigator.pop(context);
        loginCallback();
      } else {
        loader.hideLoader();
        cprint('Unable to login from FaceBook');
      }
    });
  }

  void _twitterLogin(context) {
    var state = Provider.of<AuthState>(context, listen: false);
    loader.showLoader(context);
    state.handleTwitterSignIn().then((status) {
      // print(status)
      if (state.user != null) {
        loader.hideLoader();
        Navigator.pop(context);
        loginCallback();
      } else {
        loader.hideLoader();
        cprint('Unable to login', errorIn: '_twitterLoginButton');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 60,
      height: 50,
      child: Wrap(
//        spacing: 10,
        alignment: WrapAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            child: InkWell(
              child: CircleAvatar(
                radius: 23,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(signInProviders[0]),
                child: Container(),
              ),
              onTap: () {
                _googleLogin(context);
              },
            ),
          ),
          Container(
            width: 46,
            height: 46,
            child: InkWell(
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(signInProviders[1]),
                child: Container(),
              ),
              onTap: () {
                _facebookLogin(context);
              },
            ),
          ),
          Container(
            width: 46,
            height: 46,
            child: InkWell(
              child: CircleAvatar(
                radius: 23,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(signInProviders[2]),
                child: Container(),
              ),
              onTap: () {
                _twitterLogin(context);
              },
            ),
          )
        ],
      ),
    );
  }
}
