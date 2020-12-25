import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/page/Auth/widget/verifyMobile.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:provider/provider.dart';
import 'package:wootter_x/widgets/newWidget/customLoader.dart';
import 'package:geolocator/geolocator.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key key}) : super(key: key);
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File _image;
  TextEditingController _name, _bio, _location, _contact, _dob, _website;
  TextEditingController _cntl0, _cntl1, _cntl2, _cntl3;
  CustomLoader loader = CustomLoader();
  var newOccupation;
  AuthState authState;
  TextEditingController _occupation;
  final List<String> occupationType = [
    "Politician",
    "Social worker",
    "Engineer",
    "Business",
    "Consultant",
    "Doctor",
    "Teacher",
    "Motivator",
    "Coach",
    "Sports",
    "Other",
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String dob;
  @override
  void initState() {
    _name = TextEditingController();
    _bio = TextEditingController();
    _location = TextEditingController();
    _contact = TextEditingController();
    _dob = TextEditingController();
    _occupation = TextEditingController();
    _website = TextEditingController();
    _cntl0 = TextEditingController();
    _cntl1 = TextEditingController();
    _cntl2 = TextEditingController();
    _cntl3 = TextEditingController();
    var state = Provider.of<AuthState>(context, listen: false);
    _name.text = state?.userModel?.displayName;
    _bio.text = state?.userModel?.bio;
    _location.text = state?.userModel?.location;
//    print(state.userModel.contact);
    _contact.text = state.userModel.contact ?? "+91";

    _dob.text = getdob(state?.userModel?.dob.toString());
    _occupation.text = state?.userModel?.occupation ?? 'Define occupation here';
    _website.text = state.userModel.webSite;
    newOccupation =
        occupationType.contains(_occupation.text) ? _occupation.text : 'Other';
    Map temp = state.userModel.profiles;
//    print(temp);
    if (temp != null) {
      _cntl0.text = state.userModel.profiles['fac'] ?? "";
      _cntl1.text = state.userModel?.profiles['insta'] ?? "";
      _cntl2.text = state.userModel.profiles['tweet'] ?? "";
      _cntl3.text = state.userModel?.profiles['linked'] ?? "";
    }
    super.initState();
  }

  void dispose() {
    _name.dispose();
    _bio.dispose();
    _location.dispose();
    _dob.dispose();
    _occupation.dispose();
    _contact.dispose();
    _cntl0.dispose();
    _cntl1.dispose();
    _cntl2.dispose();
    _cntl3.dispose();
    super.dispose();
  }

  Widget _body() {
    authState = Provider.of<AuthState>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
//        Container(
//          height: 180,
//          child: Stack(
//            children: <Widget>[
////              Container(
////                height: 180,
////                padding: EdgeInsets.only(bottom: 50),
////                child: customNetworkImage(
////                    'https://pbs.twimg.com/profile_banners/457684585/1510495215/1500x500',
////                    fit: BoxFit.fill),
////              ),
//              Align(
//                alignment: Alignment.topLeft,
//                child: ,
//              ),
//            ],
//          ),
//        ),
        Center(child: _userImage(authState)),
        _entry('Name', controller: _name),
        _entry('Bio', controller: _bio, maxLine: null),
        _entryContact(),
        _entryLocation(),
//        _entry('Location', controller: _location),
        _entry('Website', controller: _website),
        _entryOccupation(),
        InkWell(
          onTap: showCalender,
          child: _entry('Date of birth', isenable: false, controller: _dob),
        ),
        _socialProfileLinks()
      ],
    );
  }

  Widget _userImage(AuthState authstate) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      height: 110,
      width: 110,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 0),
//        shape: BoxShape.circle,
        borderRadius: BorderRadius.circular(5),
        image: DecorationImage(
            image: customAdvanceNetworkImage(authstate.userModel.profilePic),
            fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
//            shape: BoxShape.circle,
          borderRadius: BorderRadius.circular(5),
          color: Colors.black38,
        ),
        child: Center(
          child: IconButton(
            onPressed: uploadImage,
            icon: Icon(Icons.camera_alt, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _entry(String title,
      {TextEditingController controller,
      int maxLine = 1,
      bool isenable = true,
      bool isOccupation}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          customText(title, style: TextStyle(color: Colors.black54)),
          TextField(
              enabled: isenable,
              controller: controller,
              maxLines: maxLine,
              cursorColor: TwitterColor.dodgetBlue,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              ))
        ],
      ),
    );
  }

  Widget _entryContact() {
//    bool isEnabled = true;
    String errorTxt = null;
    return StatefulBuilder(builder: (BuildContext context, contactState) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            customText('Contact number',
                style: TextStyle(color: Colors.black54)),
            TextFormField(
//                  enabled: isEnabled,
              controller: _contact,
              maxLines: 1,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                  errorText: errorTxt,
                  suffix: errorTxt != null && errorTxt != ''
                      ? Icon(
                          Icons.error_outline,
                          color: Colors.red,
                        )
                      : null),
              onChanged: (str) {
                if (str.length == 13)
                  contactState(() => errorTxt = null);
                else if (str.length > 13)
                  contactState(() => errorTxt = 'Correct contact number');
                else if (str.length == 12) contactState(() {});
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                errorTxt == null &&
                        _contact.text.length == 13 &&
                        _contact.text != authState.userModel.contact
                    ? InkWell(
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text('Verify ',
                              style: TextStyle(
                                  color: TwitterColor.dodgetBlue,
                                  fontSize: 18)),
                        ),
                        onTap: () {
                          FocusNode().unfocus();
                          if (_contact.text.contains('+91') &&
                              _contact.text.length == 13) {
                            VerifyMobilePage().verifyPhone(
                                phone: _contact.text,
                                scaffoldKey: _scaffoldKey,
                                context: context);
                          } else
                            customSnackBar(_scaffoldKey,
                                "Correct the contact number with country code +91");
                        },
                      )
                    : Container(),
              ],
            )
          ],
        ),
      );
    });
  }

  Widget _entryLocation() {
    String locationPermission = 'Not determined';
    bool isEnable = true;
    int permissionCode = 0;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: StatefulBuilder(builder: (BuildContext context, locationState) {
        if (isEnable && locationPermission == 'Not determined') {
          Geolocator.checkPermission().then((value) {
            getLocation() {
              if (isEnable)
                try {
                  Geolocator.getCurrentPosition(
                          desiredAccuracy: LocationAccuracy.medium)
                      .then((Position position) {
                    // Geolocator.placemarkFromPosition(position)
                    //     .then((placeIdentity) {
                    //   Placemark base = placeIdentity[0];
                    //   locationState(() {
                    //     _location.text = base.locality + ", " + base.country;
                    //     isEnable = false;
                    //     locationPermission = 'Permission Granted';
                    //   });
                    // });
                  });
                } catch (e) {
                  print("position error " + e.toString());
                }
              else
                customSnackBar(_scaffoldKey,
                    "Something went wrong while detemining location");
            }

//             permissionCode = value.value;

//             if (value != GeolocationStatus.granted) {
//               print("getting");
//               getLocation();
//             } else if (value == GeolocationStatus.granted) {
//               getLocation();
//             } else {
//               locationPermission = 'Not determined';
//               switch (permissionCode) {
//                 case 0:
//                   locationPermission = 'Permission Denied';
//                   locationState(() => isEnable = true);
//                   break;
//                 case 1:
//                   locationPermission = 'Permission is Disabled';
//                   locationState(() => isEnable = true);
//                   break;
//                 case 2:
// //                  //                if(locationPermission == 'Not determined')
//                   locationPermission = 'Permission Granted';
// //                    getLocation();
//                   break;
//                 default:
//                   locationState(() => isEnable = true);
//                   locationPermission = 'Permission restricted';
//               }
//             }
          });
        }
        return Column(
          children: <Widget>[
            InkWell(
              child: Row(
                children: <Widget>[
                  customText('Location ($locationPermission)',
                      style: TextStyle(color: Colors.black54)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Icon(Icons.autorenew, size: 18),
                  ),
                ],
              ),
              onTap: () {
                print("referesh");
                locationState(() {
                  isEnable = true;
                  locationPermission = 'Not determined';
                });
              },
            ),
            TextField(
                enabled: isEnable,
                controller: _location,
                maxLines: 1,
                cursorColor: TwitterColor.dodgetBlue,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                )),
          ],
        );
      }),
    );
  }

  Widget _entryOccupation() {
    return StatefulBuilder(
        builder: (BuildContext context, occupationState) => Container(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  customText('Occupation',
                      style: TextStyle(color: Colors.black54)),
                  Wrap(
                    children: <Widget>[
                      DropdownButtonFormField<String>(
                        value: newOccupation,
                        items: occupationType.map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(
                              value,
                            ),
                          );
                        }).toList(),
                        onChanged: (_) {
                          print(_);
                          if (_ == 'Other' && _ == newOccupation) {
                            occupationState(() {
                              newOccupation = 'Other';
                            });
                          } else
                            occupationState(() {
                              newOccupation = _;
                            });
                        },
                      ),
                      newOccupation == 'Other'
                          ? TextField(
                              enabled: true,
                              controller: _occupation,
                              maxLines: 1,
                              cursorColor: TwitterColor.dodgetBlue,
                              decoration: InputDecoration(
                                hintText: 'Specify occupation here',
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 0),
                              ),
                            )
                          : Container(),
                    ],
                  )
                ],
              ),
            ));
  }

  void showCalender() async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, DateTime.now().month, DateTime.now().day),
      firstDate: DateTime(1950, DateTime.now().month, DateTime.now().day + 3),
      lastDate: DateTime.now().add(Duration(days: 7)),
    );
    setState(() {
      if (picked != null) {
        if (DateTime.now().year - picked.year >= 14) {
          dob = picked.toString();
          _dob.text = getdob(dob);
          setState(() {});
        }
        else
          customSnackBar(_scaffoldKey, 'You must be 14 years old');
      }
    });
  }

  Widget _socialProfileLinks() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          customText('Social profile links (Optional)',
              style: TextStyle(color: Colors.black54)),
          TextField(
              enabled: true,
              controller: _cntl0,
              maxLines: 1,
              cursorColor: TwitterColor.dodgetBlue,
              decoration: InputDecoration(
                hintText: 'Facebook',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              )),
          TextField(
              enabled: true,
              controller: _cntl1,
              maxLines: 1,
              cursorColor: TwitterColor.dodgetBlue,
              decoration: InputDecoration(
                hintText: 'Instagram',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              )),
          TextField(
              enabled: true,
              controller: _cntl2,
              maxLines: 1,
              cursorColor: TwitterColor.dodgetBlue,
              decoration: InputDecoration(
                hintText: 'Twitter',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              )),
          TextField(
              enabled: true,
              controller: _cntl3,
              maxLines: 1,
              cursorColor: TwitterColor.dodgetBlue,
              decoration: InputDecoration(
                hintText: 'LinkedIn',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 0),
              ))
        ],
      ),
    );
  }

  void _submitButton() {
    if (_name.text.length > 27) {
      customSnackBar(_scaffoldKey, 'Name length cannot exceed 27 character');
      return;
    }
    var state = Provider.of<AuthState>(context, listen: false);
    print(state.userModel.key);
    // print(state.userModel.userParsedData.objectId);
    var model = state.userModel.copyWith(
      /// key id objectId for parse server....
        key: state.userModel.userParsedData?.objectId ?? state.userModel.key,
        displayName: state.userModel.displayName,
        bio: state.userModel.bio,
//      contact: state.userModel.contact,
        dob: state.userModel.dob,
        email: state.userModel.email,
        location: state.userModel.location,
        profilePic: state.userModel.profilePic,
        userId: state.userModel.userId,
        occupation: state.userModel.occupation,
        followingList: state.userModel.followingList,
        following: state.userModel.following,
        followersList: state.userModel.followersList,
        followers: state.userModel.followers,
        webSite: state.userModel.webSite,
        totalDisLikes: state.userModel.totalDisLikes,
        totalLikes: state.userModel.totalLikes,
        profiles: state.userModel.profiles);
    if (_name.text != null && _name.text.isNotEmpty) {
      model.displayName = _name.text;
    }
    if (_bio.text != null && _bio.text.isNotEmpty) {
      model.bio = _bio.text;
    }
    if (_location.text != null && _location.text.isNotEmpty) {
      model.location = _location.text;
      print(_location.text);
    }
    if (dob != null) {
      model.dob = dob.toString();
    }
    if (_website.text != null) {
      model.webSite = _website.text;
    }
    var updatedProfiles = {
      'fac': _cntl0.text,
      'insta': _cntl1.text,
      'tweet': _cntl2.text,
      'linked': _cntl3.text,
    };
//    print(updatedProfiles);
    model.profiles = updatedProfiles;
    model.occupation =
        newOccupation != 'Other' ? newOccupation : _occupation.text;
    state.updateUserProfile(model, image: _image);
    Navigator.pop(context);
    Navigator.pop(context);
//    Navigator.pushAndRemoveUntil(
//        context,
//        MaterialPageRoute(
//            builder: (context) => HomePage()),
//        ModalRoute.withName('/'));
  }

  void uploadImage() {
    openImagePicker(context, (file) {
      // print('1f');

      setState(() {
        _image = file;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
//        iconTheme: IconThemeData(color: Colors.blue),
        title: customTitleText('Profile Edit'),
        leading: InkWell(
          child: Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          InkWell(
            onTap: _submitButton,
            child: Center(
              child: Text(
                'Save',
                style: TextStyle(
                  color: TwitterColor.dodgetBlue,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: _body(),
      ),
    );
  }
}
