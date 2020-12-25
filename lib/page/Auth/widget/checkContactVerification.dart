import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wootter_x/helper/theme.dart';

class ContactVerification {
  BuildContext context;
  ContactVerification(this.context);

  void plateFormCheck() {
    if (Platform.isIOS)
      iosContactSheet();
    else
      androidContactSheet();
  }

  iosContactSheet() {
    showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: Text('Add contact number',
                      style: TextStyle(color: Colors.green)),
                  onPressed: () {
//                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/EditProfile');
                  },
                )
              ],
              title: Text("Contact number is mandatory"),
              message: Text(
                "Add contact number for create/like/dislike woot",
              ),
              cancelButton: CupertinoActionSheetAction(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
            ));
  }

  androidContactSheet() {
    showModalBottomSheet(
        isDismissible: true,
        backgroundColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        context: context,
        builder: (context) => Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                  Container(
                      height: 80,
                      child: Center(
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: 'Contact number is mandatory',
                              style: TextStyle(
                                height: 2,
                                color: TwitterColor.dodgetBlue,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                                text:
                                    '\nAdd contact number for create/ like/ dislike woot',
                                style: TextStyle(
                                  height: 2,
                                  color: TwitterColor.dodgetBlue_50,
                                )),
                          ]),
                          textScaleFactor: 1,
                          textAlign: TextAlign.center,
                        ),
                      )),
                  Divider(
                    thickness: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  FlatButton(
                      padding: EdgeInsets.all(15),
                      child: Text("Update Contact number",
                          style: TextStyle(
                            fontSize: 18,
                            color: TwitterColor.dodgetBlue,
                          )),
                      onPressed: () {
//                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/EditProfile');
                      }),
                  FlatButton(
                    padding: EdgeInsets.all(15),
                    child: Text("Cancel", style: TextStyle(fontSize: 18)),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ));
  }
}
