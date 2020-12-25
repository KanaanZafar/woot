import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/widgets/customWidgets.dart';

class VerifyMobilePage with ChangeNotifier {
  GlobalKey<ScaffoldState> _scaffoldKey;
  final FocusNode _emailPhoneNode = FocusNode();
  final TextEditingController _otpController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  var ktype = TextInputType.emailAddress;
  User _userModel;
  var verificationId;
  static BuildContext _context;
  String _phone;
  AuthState _state;
//  CustomLoader loader = CustomLoader();

  User get userModel => _userModel;

  Future<void> verifyPhone(
      {String phone,
      User userM,
      BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey,
      AuthState state,
      bool isNewUser: false}) async {
    _state = Provider.of<AuthState>(context, listen: false);
    _scaffoldKey = scaffoldKey;
    _context = context;
    _phone = phone;
//    loader.showLoader(context);
    await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(milliseconds: 0),
        codeSent: (String verificationId, [int code]) =>
            verificationCodeSent(verificationId, state, code),
        verificationCompleted: (AuthCredential credential) =>
            phoneVerified(credential, state),
        verificationFailed: verificationFailed,
        codeAutoRetrievalTimeout: (sta) =>
            print("sta = $sta")); // All the callbacks need to above this
  }

  /// define for create account and login with Phone number
  Future phoneVerified(AuthCredential credential, [AuthState state]) async {
    await _auth.signInWithCredential(credential).then((value) async {
      /// define for create account and login with Phone number
    }).catchError((verificationErr) {
      print(verificationErr);
    });
  }

  /// update mobile number for Existing User
  linkUserWithContactNumber(AuthCredential credential) async {
    try {
      print("linking");
      await _state.user.updatePhoneNumber(credential);

      print("Success");
//      _state.userModel.contact = _phone;
      _state.notifyListeners();
      var data = {'contact': _phone, 'isContactVerified': true};
      ParseObject parseObject = ParseObject('profile')
        ..objectId = _state.userModel.key?? _state.userModel.userParsedData.objectId
        ..set('contact', _phone)
        ..set('isContactVerified', true);

      ParseResponse response = await parseObject.update();
      if (response.success) {
        print('Contact updated on parse serever');

      }
      else {
        print('else __linkUserWithContactNumber__response.result == false__');
      }

      // kDatabase.child('profile').child(_state.user.uid).update(data);
      _otpController.clear();
      _state.userModel.contact = _phone;
      _state.userModel.isContactVerified = true;
      Navigator.pop(_context);
      customSnackBar(_scaffoldKey, "Contact number successfully updated");
    } catch (exp) {
      String errorMsg;
      print(exp);
      switch (exp.toString().split(',')[0]) {
        case 'PlatformException(ERROR_INVALID_VERIFICATION_CODE':
          errorMsg = 'Invalid verification code';
          break;
        case 'PlatformException(ERROR_CREDENTIAL_ALREADY_IN_USE':
          errorMsg =
              'Contact number is already associated with a different user account';
          break;
        default:
          errorMsg = 'Something went wrong, Please try again later or Contact us';
          break;
      }
      customSnackBar(_scaffoldKey, errorMsg.toString());
    }
  }

  verificationFailed(FirebaseAuthException authException) {
    print("verification failed 3 = ${authException.message}");
  }

  verificationCodeSent(String verificationId, AuthState state, [int code]) {
    this.verificationId = verificationId;
    Platform.isIOS ? iosDialog() : androidDialog();
  }

  Future<void> verifyCode() async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: _otpController.text);
      print(credential.toString());
      linkUserWithContactNumber(credential);
    } catch (verifyCodeE) {
      print("verifyCodeE = " + verifyCodeE.toString());
    }
  }

  iosDialog() {
    showCupertinoDialog(
        context: _context,
        builder: (context) => CupertinoAlertDialog(
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Calcel', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  child: Text('Verify',
                      style: TextStyle(color: TwitterColor.dodgetBlue)),
                  onPressed: () {
                    if (_otpController.text.length == 6) {
                      verifyCode();
                    }
                  },
                ),
              ],
              title: Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Text("Enter verification code"),
              ),
              content: CupertinoTextField(
                controller: _otpController,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: false, signed: false),
              ),
            ));
  }

  androidDialog() {
    showDialog(
        context: _context,
        builder: (context) => AlertDialog(
              title: Text("Enter code"),
              content: TextField(
                decoration: InputDecoration(hintText: 'Verification code'),
                controller: _otpController,
                keyboardType: TextInputType.numberWithOptions(
                    signed: false, decimal: true),
              ),
              actions: <Widget>[
                FlatButton(
                  padding: EdgeInsets.all(15),
                  child: Text("Cancel", style: TextStyle(fontSize: 18)),
                  onPressed: () => Navigator.pop(_context),
                ),
                FlatButton(
                    padding: EdgeInsets.all(15),
                    child: Text("Verify",
                        style: TextStyle(
                          fontSize: 18,
                          color: TwitterColor.dodgetBlue,
                        )),
                    onPressed: () {
                      if (_otpController.text.length == 6) {
                        verifyCode();
                      }
                    }),
              ],
            ));
  }
}
