import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/model/user.dart';
import 'package:wootter_x/page/Auth/widget/signInProviersButton.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:wootter_x/widgets/newWidget/customLoader.dart';
import 'package:wootter_x/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';

class SignIn extends StatefulWidget {
  final VoidCallback loginCallback;

  const SignIn({Key key, this.loginCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  MyUser _userModel;
  bool codeSended = false;
  var verificationId;
  CustomLoader loader;
  var width = 250.0, height = 500.0;
  var ktype = TextInputType.emailAddress;
  TextEditingController _passwordController;
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _emailPhoneController;
  final FocusNode _emailPhoneNode = FocusNode();
  ValueNotifier<String> emailPhoneSwap = ValueNotifier(null);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ValueNotifier<String> emailPhoneType =
      ValueNotifier('Enter email or phone number');

  MyUser get userModel => _userModel;

  @override
  void initState() {
    _emailPhoneController = TextEditingController();
    _passwordController = TextEditingController();
    loader = CustomLoader();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailPhoneController.dispose();
    emailPhoneType.dispose();
    emailPhoneSwap.dispose();
    _emailPhoneNode.dispose();
    ktype = TextInputType.emailAddress;
    super.dispose();
  }

  keyboardType(String labelValue) {
//    print(labelValue);
//    print(emailPhoneSwap.value);
    if (labelValue == ' Email ' &&
        labelValue != emailPhoneSwap.value &&
        emailPhoneSwap.value != null) {
      _emailPhoneNode.unfocus();
      ktype = TextInputType.emailAddress;
      _emailPhoneController.text = " ";
      Future.delayed(Duration(microseconds: 0), () {
        FocusScope.of(context).requestFocus(_emailPhoneNode);
        _emailPhoneController.clear();
        _passwordController.clear();
      });
    } else if (labelValue == ' Phone ' && labelValue != emailPhoneSwap.value) {
      _emailPhoneController.text = " ";
      _emailPhoneNode.unfocus();
      ktype = TextInputType.number;
      Future.delayed(Duration(microseconds: 0), () {
        FocusScope.of(context).requestFocus(_emailPhoneNode);
        _emailPhoneController.clear();
        _passwordController.clear();
      });
    }
  }

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: height / 30),
          Image(image: AssetImage('assets/images/icon-448.png'), height: 100),
          SizedBox(height: height / 15),
//            SizedBox(height: height/40),
          _emailPhoneFeild(),
          _emailLoginButton(context),
          Divider(),
          SizedBox(height: height / 30),
          signInProviderButton(
            loginCallback: widget.loginCallback,
            loader: loader,
          ),
          SizedBox(height: height / 15),
        ],
      ),
    );
  }

  Widget _entryFeild(String label, bool isPassword) {
    return Container(
      margin: EdgeInsets.only(top: height / 50),
      child: TextField(
        controller: _passwordController,
        keyboardType:
            label == 'Password' ? TextInputType.text : TextInputType.number,
        style: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.lock_outline, color: TwitterColor.dodgetBlue),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(color: TwitterColor.dodgetBlue, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(
              color: TwitterColor.dodgetBlue,
              width: 1.0,
            ),
          ),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        ),
      ),
    );
  }

  Widget _emailPhoneFeild() {
    return ValueListenableBuilder(
      valueListenable: emailPhoneType,
      builder: (context, _labelValue, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              child: TextFormField(
                focusNode: _emailPhoneNode,
                controller: _emailPhoneController,
                keyboardType: ktype,
                style: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.normal,
                ),
                cursorColor: TwitterColor.dodgetBlue,
                decoration: InputDecoration(
                  labelText: _labelValue,
                  prefixIcon: Icon(
                      _labelValue != ' Phone '
                          ? Icons.alternate_email
                          : Icons.phone,
                      color: TwitterColor.dodgetBlue),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide:
                        BorderSide(color: TwitterColor.dodgetBlue, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: TwitterColor.dodgetBlue,
                      width: 1.0,
                    ),
                  ),
                  contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                ),
                onTap: () {
                  if (emailPhoneType.value == 'Enter email or phone number') {
                    emailPhoneType.value = ' Email ';
                    emailPhoneSwap.value = ' Phone ';
                  }
                },
              ),
            ),
            emailPhoneType.value != ' Phone '
                ? _entryFeild('Password', true)
                : _entryFeild('Verification code', false),
            emailPhoneType.value != ' Phone '
                ? _labelButton('Forget password?', onPressed: () {
                    Navigator.of(context).pushNamed('/ForgetPasswordPage');
                  })
                : _labelButton('Send verification code', onPressed: () {
                    sentVerificationCode();
                  }),
          ],
        );
      },
    );
  }

  Widget _labelButton(String title, {Function onPressed}) {
    return InkWell(
      onTap: () {
        if (onPressed != null) {
          onPressed();
        }
      },
      splashColor: TwitterColor.dodgetBlue_50,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          title,
          style: TextStyle(
              color: TwitterColor.dodgetBlue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _emailLoginButton(BuildContext context) {
    return Container(
      width: fullWidth(context),
      margin: EdgeInsets.symmetric(vertical: height / 30),
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        color: Color(0xFF2D7A98),
        onPressed: _emailPhoneLogin,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: TitleText('Submit', color: Colors.white),
      ),
    );
  }

  void _emailPhoneLogin() {
    var state = Provider.of<AuthState>(context, listen: false);
    if (state.isbusy) {
      print('busy state....try again');
      return;
    }
    bool isValid = false;
    if (emailPhoneType.value != ' Phone ')
      isValid = validateCredentials(
          _scaffoldKey, _emailPhoneController.text, _passwordController.text);

    if (isValid && emailPhoneType.value != ' Phone ') {
      loader.showLoader(context);
      state
          .signIn(_emailPhoneController.text, _passwordController.text,
              scaffoldKey: _scaffoldKey)
          .then((status) {
        if (state.user != null) {
          widget.loginCallback();
          loader.hideLoader();
          Navigator.pop(context);
        } else {
          cprint('Unable to login', errorIn: '_emailLoginButton');
          loader.hideLoader();
        }
      });
    } else if (emailPhoneType.value == ' Phone ') {
      isValid = validatePhoneCredentials(
          _scaffoldKey, _emailPhoneController.text, _passwordController.text);
      if (codeSended && _passwordController.text.length != 6)
        customSnackBar(
            _scaffoldKey, "verification code is always 6 numbers long");
      else if (isValid && verificationId != null) {
        AuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: _passwordController.text);
        print(credential.toString());
        phoneVerified(credential, state);
      } else if (!codeSended) {
        customSnackBar(_scaffoldKey, "Click on Send verification code first");
      } else {
        print('something went wrong @phone validation');
        return;
      }
    } else {
      isValid = validateCredentials(
          _scaffoldKey, _emailPhoneController.text, _passwordController.text,
          isEmpty: true);
    }
  }

  void sentVerificationCode() {
    var state = Provider.of<AuthState>(context, listen: false);

    if (state.isbusy) {
      return;
    }

    bool isValid = false;
    if (emailPhoneType.value == ' Phone ') {
      isValid = validatePhoneCredentials(
          _scaffoldKey, _emailPhoneController.text, _passwordController.text);

      if (isValid) {
        MyUser userM = MyUser(
          contact: "+91" + _emailPhoneController.text,
        );
        if (!codeSended)
          verifyPhone(userM, context, _scaffoldKey, state).catchError((err) {
            print(" err" + err.toString());
          });
        else {
          customSnackBar(_scaffoldKey,
              "Code already sent... \nStill getting error?. Restart App or Contact us.");
        }
      } else
        return;
    }
  }

  @override
  Widget build (BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold (
      key: _scaffoldKey,
      body: SafeArea (
        child: Stack (
          alignment: Alignment.center,
          children: <Widget>[
            _body(context),
            Align (
              alignment: Alignment.bottomLeft,
              child: ValueListenableBuilder (
                valueListenable: emailPhoneSwap,
                builder: (context, _labelValue, child) {
                  if (emailPhoneSwap.value == null)
                    return SizedBox (
                      height: 0,
                      width: 0,
                    );
                  return Container (
                    color: TwitterColor.white,
                    child: Row (
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FlatButton (
                          textColor: TwitterColor.dodgetBlue,
                          child: Text(
                            "Use ${emailPhoneSwap.value.toLowerCase()} instead",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                            textScaleFactor: 1,
                          ),
                          onPressed: () {
                            emailPhoneSwap.value = emailPhoneType.value;
                            if (emailPhoneType.value == ' Email ') {
                              emailPhoneType.value = ' Phone ';
                              keyboardType(emailPhoneType.value);
                            } else {
                              emailPhoneType.value = ' Email ';
                              keyboardType(emailPhoneType.value);
                            }
                          },
                        ),
                        FlatButton(
                          textColor: TwitterColor.dodgetBlue,
                          child: Text(
                            "Done",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                            textScaleFactor: 1,
                          ),
                          onPressed: () => _emailPhoneNode.unfocus(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> verifyPhone(MyUser userM, BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey, AuthState state,
      {bool isNewUser: false}) async {
    print(userM.contact);
    await _auth.verifyPhoneNumber(
        phoneNumber: userM.contact,
        timeout: Duration(milliseconds: 0),
        codeSent: (String verificationId, [int code]) =>
            verifyOtp(verificationId, state, code),
        verificationCompleted: (AuthCredential credential) =>
            phoneVerified(credential, state),
        verificationFailed: verificationFailed,
        codeAutoRetrievalTimeout: (sta) =>
            print("sta = $sta")); // All the callbacks need to above this
  }

  Future phoneVerified(AuthCredential credential, AuthState state) async {
    await _auth.signInWithCredential(credential).then((value) async {
      print(value.additionalUserInfo.isNewUser);
      if (value.additionalUserInfo.isNewUser) {
        customSnackBar(_scaffoldKey,
            "You are not an existing user, Please create account");
        _passwordController.clear();
        print("notSignedUpUser_signIN");
        value.user.delete().then((value) {
          print("deleted user.");
          state.logoutCallback();
          state.authStatus = AuthStatus.NOT_LOGGED_IN;
        });
        return;
      }
      loader.hideLoader();
      print("");
      User user = value.user;
      if (user != null) {
        print("user provider data.... = ${user.providerData}");
        print("signIN");
        kAnalytics.logLogin(loginMethod: 'PhoneAuth');
        kDatabase.child('profile').child(user.uid).once().then((ds) {
          print(ds.value);
          var map = ds.value;
          _userModel = MyUser.fromJson(map);

          print(_userModel);
          if (_userModel != null) {
            state.authStatus = AuthStatus.LOGGED_IN;
            Navigator.pop(context);
            widget.loginCallback();
            print("LOGGED_IN");
          } else
            customSnackBar(_scaffoldKey,
                "Something went wrong, please contact us via mail");
        });
      } else {
        print("Failed @firebase user/getting user from database");
        _passwordController.clear();
      }
    }).catchError((verificationErr) {
      _passwordController.clear();
      print(" cred error $verificationErr");
      String errorMsg;
      switch (verificationErr.toString().split(',')[0]) {
        case 'PlatformException(ERROR_INVALID_VERIFICATION_CODE':
          errorMsg = 'Invalid verification code';
          break;
        case 'PlatformException(error':
          errorMsg = 'First click on send verification code and then try again';
          break;
        default:
          errorMsg = 'Something went wrong, Please try again or Contact us';
          break;
      }
      customSnackBar(_scaffoldKey, errorMsg.toString());
    });
  }

  void verificationFailed(FirebaseAuthException authException) {
    print("verification failed 3 = ${authException.message}");
  }

  Future verifyOtp(String verificationId, AuthState state, [int code]) async {
    this.verificationId = verificationId;
    this.codeSended = true;
  }
}
