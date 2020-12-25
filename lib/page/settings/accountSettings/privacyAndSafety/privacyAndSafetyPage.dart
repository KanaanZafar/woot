import 'package:flutter/material.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/model/user.dart';
import 'package:wootter_x/page/settings/widgets/headerWidget.dart';
import 'package:wootter_x/page/settings/widgets/settingsAppbar.dart';
import 'package:wootter_x/page/settings/widgets/settingsRowWidget.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:provider/provider.dart';

class PrivacyAndSaftyPage extends StatelessWidget {
  const PrivacyAndSaftyPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthState>(context).userModel ?? MyUser();
    return Scaffold(
      backgroundColor: TwitterColor.white,
      appBar: SettingsAppBar(
        title: 'Privacy and policy',
        subtitle: user.userName,
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          HeaderWidget('Woots'),
          SettingRowWidget(
            "Protect your woots",
            subtitle:
                'Only current followers and people you approve in future will be able to see your woots.',
            vPadding: 15,
            showDivider: false,
            visibleSwitch: true,
          ),
          SettingRowWidget(
            "Photo tagging",
            subtitle: 'Anyone can tag you',
          ),
          HeaderWidget(
            'Direct Message',
            secondHeader: true,
          ),
          SettingRowWidget(
            'Direct Message',
            navigateTo: 'DirectMessagesPage',
          ),
          HeaderWidget(
            'Live Video',
            secondHeader: true,
          ),
          SettingRowWidget(
            "Connect to Periscope",
            subtitle:
                'If selected, you can go live and comment on Periscope broadcasts, and people will be able to see when you\'re watching. if this setting is off, people won\'t be able comment or broadcast live.',
            vPadding: 15,
            showDivider: false,
            visibleSwitch: true,
          ),
          HeaderWidget(
            'Discoverability and contacts',
            secondHeader: true,
          ),
          SettingRowWidget(
            "Discoverability and contacts",
            vPadding: 15,
            showDivider: false,
          ),
          SettingRowWidget(
            null,
            subtitle:
                'Learn more about how this data is used to connect you with people',
            vPadding: 15,
            showDivider: false,
          ),
          HeaderWidget(
            'Safety',
            secondHeader: true,
          ),
          SettingRowWidget(
            "Display media that may contain sensitive content",
            vPadding: 15,
            showDivider: false,
            visibleSwitch: true,
          ),
          SettingRowWidget(
            "Mark media you woots as containing material that may be sensitive",
            vPadding: 15,
            showDivider: false,
            visibleSwitch: true,
          ),
          SettingRowWidget(
            "Blocked Accounts",
            showDivider: false,
          ),
          SettingRowWidget(
            "Muted Accounts",
            showDivider: false,
          ),
          SettingRowWidget(
            "Muted Words",
            showDivider: false,
          ),
          HeaderWidget(
            'Location',
            secondHeader: true,
          ),
          SettingRowWidget(
            "Precise location",
            subtitle:
                'Disabled \n\n\nIf enabled, Wootter will collect, store, and use your device\'s precise location, such as your GPS information. This lets Wootter improve your experience - for example, showing you more local content, ads, and recommendations.',
          ),
          HeaderWidget(
            'Personalisation and data',
            secondHeader: true,
          ),
          SettingRowWidget(
            "Personalisation and data",
            subtitle: "Allow all",
          ),
          SettingRowWidget(
            "See your Wootter data",
            subtitle:
                "Review and edit your profile information and data associated with your account.",
          ),
        ],
      ),
    );
  }
}
