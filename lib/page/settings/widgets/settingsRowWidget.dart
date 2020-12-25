import 'package:flutter/material.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/widgets/newWidget/customUrlText.dart';

class SettingRowWidget extends StatelessWidget {
  const SettingRowWidget(
    this.title, {
    Key key,
    this.navigateTo,
    this.subtitle,
    this.textColor = Colors.black,
    this.onPressed,
    this.vPadding = 0,
    this.showDivider = true,
    this.visibleSwitch = false,
    this.showCheckBox = false,
  }) : super(key: key);
  final bool visibleSwitch, showDivider, showCheckBox;
  final String navigateTo;
  final String subtitle, title;
  final Color textColor;
  final Function onPressed;
  final double vPadding;

  @override
  Widget build(BuildContext context) {
    print(subtitle);
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding:
              EdgeInsets.symmetric(vertical: vPadding, horizontal: 18),
          onTap: () {
            if (onPressed != null) {
              onPressed();
              return;
            }
            if (navigateTo == null) {
              return;
            }
            Navigator.pushNamed(context, '/$navigateTo');
          },
          title: title == null
              ? null
              : UrlText(
                  text: title ?? '',
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
          subtitle: subtitle == null
              ? null
              : UrlText(
                  text: subtitle,
                  style: TextStyle(
                      color: TwitterColor.dodgetBlue, fontWeight: FontWeight.w400),
                ),
          trailing: showCheckBox
              ? !showCheckBox
                  ? SizedBox()
                  : Checkbox(value: true, onChanged: (val) {})
              : !visibleSwitch
                  ? null
                  : Switch(
                      onChanged: (val) {},
                      value: false,
                    ),
        ),
        !showDivider ? SizedBox() : Divider(height: 0)
      ],
    );
  }
}
