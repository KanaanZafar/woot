import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart';
import 'package:wootter_x/bloc/notifications_sender.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import '../widgets/newWidget/customLoader.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/model/user.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as Path;
import 'appState.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';

class AuthState extends AppState {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  bool isSignInWithGoogle = false;
  User user;
  String userId;
  CustomLoader loader = CustomLoader();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookLogin _facebookLogin = FacebookLogin();
  TextEditingController _otpController = TextEditingController();

  String lastSeenOnAppStart = DateTime.now().toUtc().toString();

  dabase.Query _profileQuery;
  List<MyUser> _profileUserModelList;
  MyUser _userModel;

  MyUser get userModel => _userModel;

  MyUser get profileUserModel {
    if (_profileUserModelList != null && _profileUserModelList.length > 0) {
      // print(_profileUserModelList.length);
      print(_profileUserModelList.last.userId);
      return _profileUserModelList.last;
    } else return null;
  }

  set setProfileUserModel(MyUser profileUser) {
    _profileUserModelList.add(profileUser);
  }
  
  

  void removeLastUser() {
    _profileUserModelList.removeLast();
  }

  /// Logout from device
  void logoutCallback() {
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = '';
    _userModel = null;
    user = null;
    _profileUserModelList = null;
    if (isSignInWithGoogle) {
      _googleSignIn.signOut();
      logEvent('google_logout');
    }
    _firebaseAuth.signOut();
    notifyListeners();
  }

  /// Alter select auth method, login and sign up page
  void openSignUpPage() {
    authStatus = AuthStatus.NOT_LOGGED_IN;
    userId = '';
    notifyListeners();
  }

  databaseInit() {
    try {
      if (_profileQuery == null) {
        _profileQuery = kDatabase.child("profile").child(user.uid);
        _profileQuery.onValue.listen(_onProfileChanged);
      }
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
    }
  }

  /// Verify user's credentials for login
  Future<String> signIn(String email, String password,
      {GlobalKey<ScaffoldState> scaffoldKey}) async {
    try {
      loading = true;
      var result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
      userId = user.uid;
      // authStatus = AuthStatus.LOGGED_IN;
      return user.uid;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'signIn');
      kAnalytics.logLogin(loginMethod: 'email_login');
      customSnackBar(scaffoldKey, error.message);
      // logoutCallback();
      authStatus = AuthStatus.NOT_LOGGED_IN;
      return null;
    }
  }

  /// Create user from `google login`
  /// If user is new then it create a new user
  /// If user is old then it just `authenticate` user and return firebase user data
  Future<User> handleGoogleSignIn() async {
    try {
      /// Record log in firebase kAnalytics about Google login
      kAnalytics.logLogin(loginMethod: 'google_login');
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google login cancelled by user');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
      user = (await _firebaseAuth.signInWithCredential(credential)).user;
      authStatus = AuthStatus.LOGGED_IN;
      userId = user.uid;
      isSignInWithGoogle = true;
      createUserFromGoogleSignIn(user);
      notifyListeners();
      return user;
    } on PlatformException catch (error) {
      user = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleGoogleSignIn');
      return null;
    } on Exception catch (error) {
      user = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleGoogleSignIn');
      return null;
    } catch (error) {
      user = null;
      authStatus = AuthStatus.NOT_LOGGED_IN;
      cprint(error, errorIn: 'handleGoogleSignIn');
      return null;
    }
  }

  /// Create user profile from google login
  createUserFromGoogleSignIn (User user) async {
    var diff = DateTime.now().difference(user.metadata.creationTime);
    // Check if user is new or old
    // If user is new then add new user to firebase realtime kDatabase
    if (diff < Duration(seconds: 15)) {
      MyUser model = MyUser(
        bio: 'Edit profile to update bio',
        dob: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
            .toString(),
        location: 'Somewhere in universe',
        profilePic: user.photoURL,
        displayName: user.displayName,
        email: user.email,
        key: user.uid,
        userId: user.uid,
        contact: user?.phoneNumber ?? "+91",
        isVerified: false,
        isContactVerified: false,
      );
      createUser(model, newUser: true);
    } else {
      cprint('Last login at: ${user.metadata.lastSignInTime}');
    }
  }

  Future<User> handleFacebookSignIn() async {
    try {
      kAnalytics.logLogin(loginMethod: 'facebook_login');
      final result = await _facebookLogin.logIn(['email']);

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final AuthCredential credential =
              FacebookAuthProvider.credential(result.accessToken.token);
          user = (await _firebaseAuth.signInWithCredential(credential)).user;
          print("User verified by Facebook");
          _createUserFromFacebookLogin(user, result.accessToken.token);
          return user;
          break;
        case FacebookLoginStatus.cancelledByUser:
          print("Canceled");
          loader.hideLoader();
          return null;
          break;
        default:
          loader.hideLoader();
          print("Not facebook logined");
          return null;
          break;
      }
    } catch (error) {
      loader.hideLoader();
      print("Error catched ${error.toString()}");
      return null;
    }
  }

  /// create app user from Facebook login
  _createUserFromFacebookLogin (User user, String token) async {
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=hometown&access_token=$token');
    final profile = jsonDecode(graphResponse.body);
    print("profile = ${profile.toString()}");

    var diff = DateTime.now().difference(user.metadata.creationTime);
    // Check if user is new or old
    // If user is new then add new user to firebase realtime kDatabase
    if (diff < Duration(seconds: 15)) {
      MyUser model = MyUser(
        bio: 'Edit profile to update bio',
        dob: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
            .toString(),
        location: profile['hometown']['name'],
        profilePic: user.photoURL,
        displayName: user.displayName,
        email: user.email,
        key: user.uid,
        userId: user.uid,
        contact: user?.phoneNumber ?? "+91",
        isVerified: false,
        isContactVerified: false,
      );
      createUser(model, newUser: true);
    } else {
      cprint('Last login at: ${user.metadata.lastSignInTime}');
    }
  }

  Future<User> handleTwitterSignIn () async {
    try {
      kAnalytics.logLogin(loginMethod: 'twitter_login');
      print("1");
      var twitterLogin = TwitterLogin(
        consumerKey: 'eU48NN5uRKo6OSsew7m6l2bz6',
        consumerSecret: 'eroR4IyCVVGaG2JTM4BtbooETCNepYagSRXaX4qrzGRA5x4la2',
      );
      print("2");

      final TwitterLoginResult result = await twitterLogin.authorize();
      print("3");

      switch (result.status) {
        case TwitterLoginStatus.loggedIn:
          var session = result.session;

          final AuthCredential credential = TwitterAuthProvider.credential(
              accessToken: result.session.token, secret: result.session.secret);
          user = (await _firebaseAuth.signInWithCredential(credential)).user;
          print("User verified by Twitter");
          _createUserFromTwitterLogin(user, result.session.token);
          return user;
          break;
        case TwitterLoginStatus.cancelledByUser:
          return null;
          break;
        case TwitterLoginStatus.error:
          print("Error ${result.errorMessage}");
          return null;
          break;
      }
    } catch (error) {
      print("Error catched ${error.toString()}");
      return null;
    }
    return null;
  }

  _createUserFromTwitterLogin (User user, String token) {
    var diff = DateTime.now().difference(user.metadata.creationTime);

    /// Check if user is new or old
    /// If user is new then add new user to firebase realtime kDatabase
    if (diff < Duration(seconds: 15)) {
      MyUser model = MyUser(
        bio: 'Edit profile to update bio',
        dob: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
            .toString(),
        location: 'Somewhere in universe',
        profilePic: user.photoURL,
        displayName: user.displayName,
        email: user.email,
        key: user.uid,
        userId: user.uid,
        contact: user?.phoneNumber ?? "+91",
        isVerified: false,
        isContactVerified: false,
      );
      createUser(model, newUser: true);
    } else {
      cprint('Last login at: ${user.metadata.lastSignInTime}');
    }
  }

  /// Create new user's profile in db
  Future<String> signUp (MyUser userModel,
      {GlobalKey<ScaffoldState> scaffoldKey, String password}) async {
    try {
      loading = true;
      var result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: password,
      );
      user = result.user;
      kAnalytics.logSignUp(signUpMethod: 'register');
      result.user.updateProfile(
          displayName: userModel.displayName, photoURL: userModel.profilePic);

      _userModel = userModel;
      // _userModel.key = user.uid;
      _userModel.userId = user.uid;
      createUser(_userModel, newUser: true);
      // await user.delete();
      // print('user deleted from Firebase Auth');
      authStatus = AuthStatus.LOGGED_IN;
      return user.uid;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'signUp');
      customSnackBar(scaffoldKey, error.message);
      return null;
    }
  }

  /// `Create` and `Update` user
  /// IF `newUser` is true new user is created
  /// Else existing user will update with new values
  createUser(MyUser myUser, {bool newUser = false}) async {
    if (newUser) {
      myUser.totalDisLikes = 0;
      myUser.totalLikes = 0;
      myUser.isContactVerified = false;
      // myUser.key = "";
      var p = {'fac': "", 'insta': "", 'tweet': "", 'linked': ""};
      if (myUser.contact == null) myUser.contact = "+91";
      myUser.profiles = p;
      // Create username by the combination of name and id
      myUser.userName = getUserName(id: myUser.userId, name: myUser.displayName);
      kAnalytics.logEvent(name: 'create_newUser');

      /// Time at which user is created needed for Firebase....No need for parse-serve
      // myUsercreatedAt = DateTime.now().toUtc().toString();
      myUser.lastSeen =
          DateTime.now().toUtc().toString();
    } else
      myUser.lastSeen = DateTime.now().toUtc().toString(); // else

    try {

      /// traditional way of doing API post....
      /// but has some error- json Data are not sent properly :) need to be handle....

      // Map<String, dynamic> data = Map.from(myUsertoJson());
      // Response response = await post(serverUrl,
      //      headers: <String, String>{
      //        "Content-Type": "application/json",
      //        "X-Parse-Master-Key": "KLOUDBOY456",
      //        "X-Parse-Application-Id": "KLOUDBOY123"
      //      },
      //      body: jsonEncode(data)
      // );
      // print(jsonEncode(myUsertoJson()));
      // print(response.statusCode);
      // print(jsonDecode(response.body).toString());

      /// Firebase realtime database approach....
      // await kDatabase.child('profile').child(myUseruserId).update(myUsertoJson());
      // _userModel = myUser;

      ParseResponse result;
      if (newUser) {
        print('__newUser__');
        result = await myUser.getParsedObject().create();
      }
      else
        result = await myUser.getParsedObject(objectID: myUser.key).save();

      if (result.success && user.uid == myUser.userId){
        log(result.results.first['objectId']);
        /// see if this method is called everyTime for AuthUser or not....
        _userModel = myUser;
        _userModel.key = result.results.first['objectId'];
        _userModel.userParsedData = myUser.userParsedData;
        ParseObject object = ParseObject('profile')
          ..objectId = result.results.first['objectId'] ?? _userModel.key;
        object.set('key', _userModel.key);

        await object.save().then((value) {
          if (!value.success) {
            cprint(value.error.message , errorIn: "!signUp_key-saving");
          }
        });
        cprint('fetch data from parse server for STATE.AUTHUSER || for update details');
        // print(result.results);
      }
      else{
        print("__error @myUsergetParsedObject().create()__");
        print(result.error.message.toString());
      }
    }
    catch (e) {
      print("error = "+e.toString());
    }

    if (_profileUserModelList != null) {
      /// for facebook this need to be handle while creating first time
//      _profileUserModelList.last = _userModel;
    }
    loading = false;
    notifyListeners();
  }

  _checkRate(String userId) {
    print("checking");
    kDatabase.child('userRate').child(userId).once().then((value) {
      if (value.key == userId)
        print("isExist");
      else print("not exist");
    });
  }

  /// Fetch current user profile
  Future<User> getCurrentUser() async {
    try {
      loading = true;
      user = _firebaseAuth.currentUser;
      if (user != null) {
        userId = user.uid;
        await getUserDetail(user.uid);
        authStatus = AuthStatus.LOGGED_IN;
        lastSeenOnAppStart = _userModel?.lastSeen;
      } else {
        authStatus = AuthStatus.NOT_LOGGED_IN;
      }
      loading = false;
      // notifyListeners();
      return user;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getCurrentUser');
      authStatus = AuthStatus.NOT_LOGGED_IN;
      notifyListeners();
      return null;
    }
  }

  /// Reload user to get refresh user data
  reloadUser() async {
    await user.reload();
    user = _firebaseAuth.currentUser;
    if (user.emailVerified) {
      userModel.isVerified = true;
      // If user verifed his email
      // Update user in firebase realtime kDatabase
      await createUser(userModel);
      cprint('User email verification complete');
      logEvent('email_verification_complete',
          parameter: {userModel.userName: user.email});
    }
  }

  /// Send email verification link to email2
  Future<void> sendEmailVerification(
      GlobalKey<ScaffoldState> scaffoldKey) async {
    User user = _firebaseAuth.currentUser;
    user.sendEmailVerification().then((_) {
      logEvent('email_verifcation_sent',
          parameter: {userModel.displayName: user.email});
      customSnackBar(
        scaffoldKey,
        'An email verification link is send to your email.',
      );
    }).catchError((error) {
      cprint(error.message, errorIn: 'sendEmailVerification');
      logEvent('email_verifcation_block',
          parameter: {userModel.displayName: user.email});
      customSnackBar(
        scaffoldKey,
        error.message,
      );
    });
  }

  /// Check if user's email is verified
  Future<bool> isEmailVerified() async {
    User user = _firebaseAuth.currentUser;
    return user.emailVerified;
  }

  /// Send password reset link to email
  Future<void> forgetPassword(String email,
      {GlobalKey<ScaffoldState> scaffoldKey}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email).then((value) {
        customSnackBar(scaffoldKey,
            'A reset password link is sent yo your mail.You can reset your password from there');
        logEvent('forgot+password');
      }).catchError((error) {
        cprint(error.message);
        return false;
      });
    } catch (error) {
      customSnackBar(scaffoldKey, error.message);
      return Future.value(false);
    }
  }

  /// `Update user` profile
  Future<void> updateUserProfile(MyUser userModel, {File image}) async {
    try {
      if (image == null) {
        createUser(userModel);
      } else {
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child('user/profile/${Path.basename(image.path)}');
        StorageUploadTask uploadTask = storageReference.putFile(image);
        await uploadTask.onComplete.then((value) {
          storageReference.getDownloadURL().then((fileURL) async {
            print(fileURL);
            await user.updateProfile(
                displayName: userModel?.displayName ?? user.displayName,
                photoURL: fileURL);

            if (userModel != null) {
              userModel.profilePic = fileURL;
              createUser(userModel);
            } else {
              _userModel.profilePic = fileURL;
              createUser(_userModel);
            }
          });
        });
      }
      notifyListeners();

      logEvent('update_user');
    } catch (error) {
      cprint(error, errorIn: 'updateUserProfile');
    }
  }

  /// `Fetch` user `detail` whose userId is passed
  Future<MyUser> getUserDetail(String userProfileId) async {
    MyUser myUser;

    loading = true;
    try {
      if (_profileUserModelList == null)
        _profileUserModelList = [];

      /// firebase realtime database .once();
      // var snapshot = await kDatabase.child('profile').child(userId).once();
      // if (snapshot.value != null) {
      //   var map = snapshot.value;
      //   myUser = MyUser.fromJson(map);
      //   myUser.key = snapshot.key;
      //   return myUser;
      // } else {
      //   return null;
      // }

      ParseObject profileObject = ParseObject('profile');
      var profileQuery = QueryBuilder(profileObject)
        ..whereEqualTo('userId', userProfileId);

      var response = await profileQuery.query();

      if (response.success && response.results.length > 0) {
        // print(response.results.first);
        var responseData = response.results.first;

        // print(responseData['userId']);
        // print(responseData['displayName']);
        // print(responseData['userName']);
        print(responseData['email']);

        myUser = MyUser.fromJson(responseData);

        if (responseData != null) {
          if (userProfileId == user.uid) {
            _userModel = myUser;
            _userModel.userParsedData = response.results.first;
            _userModel.key = _userModel.userParsedData.objectId;
            print('objectID = ' + _userModel.key);
            // _profileUserModelList.add(myUser);

            /// need to be handled....
            // _userModel.isVerified = user.emailVerified;
            // if (!user.emailVerified) {
            //   // Check if logged in user verified his email address or not
            //   await reloadUser();
            // }
            if (_userModel.fcmToken == null)
              updateFCMToken();
          }
          logEvent('get_profile');
        }
      }
      else {
        print('__else profileQuery response == false || length == 0__return -> null');
        return null;
      }
    } catch (e) {
      print("__error__@getuserDetail__ return -> null");
      print(e.toString());
      loading = false;
      return null;
    }
    loading = false;
    return myUser;
  }

  /// Fetch user profile
  /// If `userProfileId` is null then logged in user's profile will fetched
  getProfileUser({String userProfileId}) async {
    print('getting profileUserData');
    if (userProfileId == null)
      print("__userProfileId@getProfileUser provided is null\nneed to be handled in call__");
    if (userProfileId == user.uid && _userModel != null)
      _profileUserModelList.add(_userModel);
    else
      _profileUserModelList.add(await getUserDetail(userProfileId));

    return _profileUserModelList.last;
  }

  /// if firebase token not available in profile
  /// Then get token from firebase and save it to profile
  /// When someone sends you a message FCM token is used
  void updateFCMToken() async {
    if (_userModel == null)
      return;
    // await getProfileUser();
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      _userModel.fcmToken = token;

      // createUser(_userModel);
    });
  }

  /// Follow / Unfollow user
  ///
  /// If `removeFollower` is true then remove user from follower list
  ///
  /// If `removeFollower` is false then add user to follower list
  followUser({bool removeFollower = false}) async {
    /// `userModel` is user who is looged-in app.
    /// `profileUserModel` is user whose profile is open in app.
    try {
      log('message');
      log(profileUserModel.key);
      ParseObject authUO = ParseObject('profile')..objectId = _userModel.key;
      ParseObject profileUO = ParseObject('profile')
        ..objectId = profileUserModel.key;
      if (removeFollower) {
        /// If logged-in user `already follow `profile user then
        /// 1.Remove logged-in user from profile user's `follower` list
        /// 2.Remove profile user from logged-in user's `following` list
        profileUserModel.followersList.remove(userModel.userId);

        /// Remove profile user from logged-in user's following list
        _userModel.followingList.remove(profileUserModel.userId);
        authUO.setRemove('followingList', profileUserModel.userId);
        profileUO.setRemove('followerList', user.uid);

      } else {
        /// if logged in user is `not following` profile user then
        /// 1. Add logged in user to profile user's `follower` list
        /// 2. Add profile user to logged in user's `following` list
        // if (profileUserModel.followersList == null) {
        //   profileUserModel.followersList = [];
        // }
        profileUserModel.followersList.add(user.uid);
        // Adding profile user to logged-in user's following list
        // if (userModel.followingList == null) {
        //   userModel.followingList = [];
        // }
        authUO.setAdd('followingList', profileUserModel.userId);
        profileUO.setAdd('followerList', user.uid);
        _userModel.followingList.add(profileUserModel.userId);
        SendFCM().sendToFollower(profileUserModel, userModel);
      }
      authUO.save().then((response) {
        cprint('ProfileUser removed from following list', event: 'remove_follow');
      });
      profileUO.save().then((response) {
        cprint('ProfileUser removed from following list', event: 'remove_follow');
      });
      // update profile user's user follower count
      profileUserModel.followers = profileUserModel.followersList.length;
      // update logged-in user's following count
      userModel.following = userModel.followingList.length;

      /// firebase realtime database update....
      /*kDatabase.child('profile').child(profileUserModel.userId)
          .child('followerList').set(profileUserModel.followersList);
      kDatabase.child('profile').child(userModel.userId)
          .child('followingList').set(userModel.followingList);*/
      cprint('user added to following list', event: 'add_follow');
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: '___@followUser___');
    }
  }

  /// Trigger when logged-in user's profile change or updated
  /// Firebase event callback for profile update
  void _onProfileChanged(Event event) async {
    if (event.snapshot != null) {
      final updatedUser = MyUser.fromJson(event.snapshot.value);
      if (updatedUser.userId == user.uid) {
        _userModel = updatedUser;
      }
      cprint('User Updated');
      notifyListeners();
    }
  }

  void changeUserAlias(String userName) {
    ParseObject authO = ParseObject('profile')..objectId = userModel.key
      ..set('userName', userName);

    authO.save().then((response) {
      if (response.success) {
        _userModel.userName = userName;
        userModel.userName = userName;
        log('userName updated');
      }
      else {
        /// handle if response.success = false;
      }
      notifyListeners();
    });
  }
}
