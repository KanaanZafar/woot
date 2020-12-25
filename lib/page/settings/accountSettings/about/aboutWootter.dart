import 'package:flutter/material.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/page/settings/widgets/headerWidget.dart';
import 'package:wootter_x/page/settings/widgets/settingsRowWidget.dart';
import 'package:wootter_x/widgets/customAppBar.dart';
import 'package:wootter_x/widgets/customWidgets.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          'About Wootter',
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          HeaderWidget(
            'Help',
            secondHeader: true,
          ),
          SettingRowWidget(
            "Help Centre",
            vPadding: 15,
            showDivider: false,
            onPressed: () {
//              launchURL("https://github.com/TheAlphamerc/wootter/issues");
            },
          ),
          HeaderWidget('Legal'),
          SettingRowWidget(
            "Terms of Service",
            showDivider: true,
          ),
          SettingRowWidget(
            "Privacy policy",
            showDivider: true,
          ),
          SettingRowWidget(
            "Cookie use",
            showDivider: true,
          ),
          SettingRowWidget(
            "Legal notices",
            showDivider: true,
            onPressed: () async {
//              showLicensePage(
//                context: context,
//                applicationName: 'Wootter',
//                applicationVersion: '1.0.0',
//                useRootNavigator: true,
//              );
            },
          )
        ],
      ),
    );
  }
}
