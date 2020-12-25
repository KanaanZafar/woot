import 'package:flutter/material.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/page/Auth/signup.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';
import '../homePage.dart';
import 'signin.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  var width = 250.0, height = 500.0;

  Widget _submitButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      width: MediaQuery.of(context).size.width,
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        color: TwitterColor.dodgetBlue,
        onPressed: () {
          var state = Provider.of<AuthState>(context, listen: false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Signup(loginCallback: state.getCurrentUser),
            ),
          );
        },
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: TitleText('Sign Up', color: Colors.white),
      ),
    );
  }

  Widget _body() {
    return SafeArea(
      child: ListView(
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.all(15),
        children: <Widget>[
          SizedBox(
            height: height / 5,
          ),
          Image(
              image: AssetImage('assets/images/icon-448.png'),
              height: height / 6),
          SizedBox(
            height: height / 8,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("W O O T T E R ",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Monteserrat',
                    fontSize: 45.0,
                    fontWeight: FontWeight.w500,
                    color: TwitterColor.dodgetBlue)),
          ),

          Text("CONNECT AND DISCOVER THE NEW RISING WORLD",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Monteserrat',
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)),
          SizedBox(
            height: height / 8,
          ),
          _submitButton(),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              TitleText(
                'Have an account already?',
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
              InkWell(
                onTap: () {
                  var state = Provider.of<AuthState>(context, listen: false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SignIn(loginCallback: state.getCurrentUser),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                  child: TitleText(
                    ' Log in',
                    fontSize: 14,
                    color: TwitterColor.dodgetBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ],
          ),
//          SizedBox(height: 20)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    var state = Provider.of<AuthState>(context, listen: false);
    return Scaffold(
      body: state.authStatus == AuthStatus.NOT_LOGGED_IN ||
              state.authStatus == AuthStatus.NOT_DETERMINED
          ? _body()
          : HomePage(),
    );
  }
}
