import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:wootter_x/helper/constant.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/model/user.dart';
import 'package:wootter_x/page/Auth/widget/signInProviersButton.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:wootter_x/widgets/newWidget/customLoader.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  final VoidCallback loginCallback;

  const Signup({Key key, this.loginCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool codeSended = false;
  var verificationId;
  CustomLoader loader;
  var width = 250.0, height = 500.0;
  TextEditingController _nameController;
  TextEditingController _emailPhoneController;
  TextEditingController _passwordController;
  TextEditingController _confirmController;
  TextEditingController _dobController;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ValueNotifier<String> emailPhoneType =
      ValueNotifier('Enter email or phone number');
  ValueNotifier<String> emailPhoneSwap = ValueNotifier(null);
  final FocusNode _emailPhoneNode = FocusNode();
  final TextEditingController _otpController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  var ktype = TextInputType.emailAddress;
  String dob;

  MyUser _userModel;
  MyUser get userModel => _userModel;

  @override
  void initState() {
    loader = CustomLoader();
    _nameController = TextEditingController();
    _emailPhoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    _dobController = TextEditingController();
    super.initState();
  }

  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmController.dispose();
    emailPhoneType.dispose();
    emailPhoneSwap.dispose();
    _emailPhoneNode.dispose();
    _dobController.dispose();
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
      _emailPhoneNode.consumeKeyboardToken();
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: height / 20),
          Image(image: AssetImage('assets/images/icon-448.png'), height: 100),
          SizedBox(height: height / 30),
          _entryFeild('Name', Icons.person_outline, _nameController),
//            _entryFeild('Enter email or phone number',
//                controller: _emailPhoneController, isEmail: true),
          // _entryFeild('Mobile no',controller: _mobileController),
          _emailPhoneFeild(),
          GestureDetector(
            onTap: showCalender,
            child: _dobField(
                "Date of Birth", Icons.calendar_today, _dobController),
          ),
          _submitButton(context),
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

  Widget _entryFeild(
      String _labelValue, IconData iconData, TextEditingController controller,
      {bool isPassword = false, bool isEmail = true}) {
    return Container(
      margin: EdgeInsets.only(top: height / 50),
      child: TextField(
        controller: controller,
        keyboardType: isEmail ? TextInputType.text : TextInputType.number,
        style: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
        autocorrect: false,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: _labelValue,
          prefixIcon: Icon(iconData, color: TwitterColor.dodgetBlue),
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
              margin: EdgeInsets.only(top: height / 50),
              child: TextFormField(
                focusNode: _emailPhoneNode,
                controller: _emailPhoneController,
                keyboardType: ktype,
                style: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.normal,
                ),
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
                ? _entryFeild('password', Icons.lock_open, _passwordController,
                    isPassword: true)
                : _entryFeild(
                    'Verification code', Icons.lock_open, _passwordController,
                    isEmail: false),
            emailPhoneType.value != ' Phone '
                ? _entryFeild(
                    'Confirm password', Icons.lock_outline, _confirmController,
                    isPassword: true)
                : _labelButton('Send verification code', onPressed: () {
                    sendVerificationCode();
                  })
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
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Text(
          title,
          style: TextStyle(
              color: TwitterColor.dodgetBlue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      width: MediaQuery.of(context).size.width,
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        color: Color(0xFF2D7A98),
        onPressed: _submitForm,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Text('Sign up', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _dobField(
      String _labelValue, IconData iconData, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.only(top: height / 50),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
        autocorrect: false,
        decoration: InputDecoration(
          labelText: _labelValue,
          enabled: false,
          prefixIcon: Icon(iconData, color: TwitterColor.dodgetBlue),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(color: TwitterColor.dodgetBlue, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
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

  void showCalender() async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, DateTime.now().month, DateTime.now().day),
      firstDate: DateTime(1950, DateTime.now().month, DateTime.now().day + 3),
      lastDate: DateTime.now().add(Duration(days: 7)),
    );
    if (picked != null)
      if (DateTime.now().year - picked.year >= 14) {
        dob = picked.toString();
        _dobController.text = getdob(dob);
        setState(() {});
      }
      else
        customSnackBar(_scaffoldKey, 'You must be 14 years old');
  }

  void _submitForm() {
    if (_nameController.text.isEmpty) {
      customSnackBar(_scaffoldKey, 'Please enter name');
      return;
    }
    if (_nameController.text.length < 5) {
      customSnackBar(_scaffoldKey, 'Please enter full  name');
      return;
    }
    if (_dobController.text.length < 6) {
      customSnackBar(_scaffoldKey, 'Please select date of birth');
      return;
    }

    bool isValid = false;
    var state = Provider.of<AuthState>(context, listen: false);
    Random random = new Random();
    int randomNumber = random.nextInt(8);

    if (emailPhoneType.value != ' Phone ') {
      isValid = validateCredentials(
          _scaffoldKey, _emailPhoneController.text, _passwordController.text);

      if (isValid) {
        emailCreateUser(state, randomNumber);
      } else
        return;
    } else if (emailPhoneType.value == ' Phone ') {
      isValid = validatePhoneCredentials(
          _scaffoldKey, _emailPhoneController.text, _passwordController.text);

      if (isValid && codeSended) {
        if (verificationId == null) {
          codeSended = false;
          customSnackBar(_scaffoldKey, 'Click on Send verification code first');
          return;
        } else {
          print('all done');
          phoneCreateUser(state, randomNumber);
        }
      } else if (!codeSended) {
        print('something went wrong @phone validation');
        customSnackBar(_scaffoldKey, 'Click on Send verification code first');
        return;
      }
    } else {
      isValid = validateCredentials(
          _scaffoldKey, _emailPhoneController.text, _passwordController.text,
          isEmpty: true);
    }
  }

  void sendVerificationCode() {
    var state = Provider.of<AuthState>(context, listen: false);

    if (state.isbusy) {
      return;
    }
    bool isValid = false;
    if (emailPhoneType.value == ' Phone ') {
      isValid = validatePhoneCredentials(
          _scaffoldKey, _emailPhoneController.text, _passwordController.text);

      if (isValid && !codeSended) {
        MyUser userM = MyUser(
          contact: "+91" + _emailPhoneController.text,
        );
        print('sending code');
        verifyPhone(userM, context, _scaffoldKey, state).catchError((err) {
          print("verify starting error = " + err.toString());
        });
      } else
        return;
    }
  }

  emailCreateUser(AuthState state, int randomNumber) {
    loader.showLoader(context);
    MyUser user = MyUser(
        email: _emailPhoneController.text.toLowerCase(),
        bio: 'Edit profile to update bio',
        // contact:  _mobileController.text,
        /// contact no. needs to be handle....
        displayName: _nameController.text + " ",
        dob: dob,
        location: 'Somewhere in universe',
        profilePic: dummyProfilePicList[randomNumber],
        isVerified: false,
        contact: "+91",
        isContactVerified: false);

    print("going to signUp");
    state
        .signUp(
      user,
      password: _passwordController.text,
      scaffoldKey: _scaffoldKey,
    )
        .then((status) {
      print(status);
    }).whenComplete(
      () {
        loader.hideLoader();
        if (state.authStatus == AuthStatus.LOGGED_IN) {
          Navigator.pop(context);
          widget.loginCallback();
        }
      },
    );
  }

  phoneCreateUser(AuthState state, int randomNumber) {
    MyUser user = MyUser(
      contact: "+91" + _emailPhoneController.text.toLowerCase(),
      bio: 'Edit profile to update bio',
      displayName: _nameController.text,
      dob: dob,
      location: 'Somewhere in universe',
      profilePic: dummyProfilePicList[randomNumber],
      isVerified: false,
      email: ""
    );
    if (!codeSended) {
      sendVerificationCode();
      return;
    } else if (verificationId != null) {
      if (_passwordController.text.length != 6)
        customSnackBar(_scaffoldKey, 'Please enter proper verification code');
      else {
        print(_passwordController.text);
        loader.showLoader(context);

        print("Verifying code and so on....");

        AuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: _passwordController.text);
        print(credential.toString());
        phoneVerified(credential, state, createUserData: user);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            _body(context),
            Align(
              alignment: Alignment.bottomLeft,
              child: ValueListenableBuilder(
                valueListenable: emailPhoneSwap,
                builder: (context, _hintValue, child) {
                  if (emailPhoneSwap.value == null)
                    return SizedBox(
                      height: 0,
                      width: 0,
                    );
                  return Container(
                    color: TwitterColor.white,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FlatButton(
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
            phoneVerified(credential, state, createUserData: userM),
        verificationFailed: verificationFailed,
        codeAutoRetrievalTimeout: (sta) =>
            print("timeout = $sta")); // All the callbacks need to above this
  }

  Future phoneVerified(AuthCredential credential, AuthState state,
      {MyUser createUserData}) async {
    await _auth.signInWithCredential(credential).then((value) async {
      if (!value.additionalUserInfo.isNewUser) {
        customSnackBar(_scaffoldKey, "You are an existing user, Please login.");
        _passwordController.clear();
        loader.hideLoader();
        print("already");
        state.logoutCallback();
        return;
      } else {
        loader.hideLoader();

        User user = value.user;
        if (user != null) {
          Navigator.pop(context);
          _passwordController.clear();
          print("user provider data... = ${user.providerData}");
          kAnalytics.logSignUp(signUpMethod: 'register_phone');
          createUserData.isContactVerified = true;
          _userModel = createUserData;
//          _userModel.isContactVerified = true;
          _userModel.key = user.uid;
          _userModel.userId = user.uid;
          _userModel.totalDisLikes = 0;
          _userModel.totalLikes = 0;
          // Create username by the combination of name and id
          _userModel.userName =
              getUserName(id: user.uid, name: _userModel.displayName);
          kAnalytics.logEvent(name: 'phone_user_created');

          /// Time at which user is created
          /// needed for firebase realtime database, no need for parse server....
          // _userModel.createdAt = DateTime.now().toUtc().toString();

          /// realtime database use-case....
          // kDatabase.child('profile').child(user.uid).update(_userModel.toJson());

          try {

            var result = await _userModel.getParsedObject().create();

            if(result.success){
              print('updated on parse server');
              _userModel.key = result.results.first['objectId'];
              ParseObject object = ParseObject('profile')
              ..objectId = _userModel.key;

              await object.save();
              // print(result.results);
            }
            else{
              print("__error @user.getParsedObject().create()__");
              print(result.error.message.toString());
            }
          }

          catch (e) {
            print("error = "+e.toString());
          }
          print("CREATED_PHONE");

          state.authStatus = AuthStatus.LOGGED_IN;
          loader.hideLoader();
          widget.loginCallback();
        } else {
          print("Failed");
          _passwordController.clear();
        }
      }
    }).catchError((verificationErr) {
      loader.hideLoader();
      state.authStatus = AuthStatus.NOT_LOGGED_IN;
      _passwordController.clear();

      print(" cred error $verificationErr");
      String errorMsg;
      switch (verificationErr.toString().split(',')[0]) {
        case 'PlatformException(ERROR_INVALID_VERIFICATION_CODE':
          errorMsg = 'Invalid verification code';
          break;
        case 'PlatformException(error':
          errorMsg = 'First click on send verification code and then try again';
          codeSended = false;
          verificationId = null;
          break;
        default:
          errorMsg = 'Something went wrong, Please Resend verification code '
              'again...Still getting error, Restart the App/Contact us';
          codeSended = false;
          verificationId = null;
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
    print(this.verificationId);
    this.codeSended = true;
  }

/*  iosDialog(String verificationId, [int code]) {
    showCupertinoDialog(
        context: context,
        builder: (context) =>
            CupertinoAlertDialog(
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Cancel', style: TextStyle(color: Colors.deepOrange),),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  child: Text('Verify',style: TextStyle(color: Colors.green)),
                  onPressed: () async => verifyOtp(verificationId),
                )
              ],
              title: Text("Enter verification code"),
              content: CupertinoTextField(
                controller: _otpController,
              ),
            )
    );
  }

  androidDialog(String verificationId, [int code]) {
    loader.hideLoader();
    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.deepOrange),),
                  onPressed: () => Navigator.pop(context),
                ),
                RaisedButton(
                  color: Colors.green,
                  child: Text('Verify',style: TextStyle(color: Colors.white)),
                  onPressed: () async{
                    print("0");
                    verifyOtp(verificationId);
                  },
                )
              ],
              title: Text("Enter verification code"),
              content: TextFormField(
                controller: _otpController,
              ),
            )
    );
  }*/
}
