// import 'package:fancy_bottom_navigation/internal/tab_item.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wootter_x/helper/constant.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/state/appState.dart';
import 'package:wootter_x/widgets/bottomMenuBar/tabItem.dart';
import 'package:provider/provider.dart';
import '../customWidgets.dart';
// import 'customBottomNavigationBar.dart';

class BottomMenubar extends StatefulWidget {
  const BottomMenubar({this.pageController});
  final PageController pageController;
  _BottomMenubarState createState() => _BottomMenubarState();
}

class _BottomMenubarState extends State<BottomMenubar> {
  AppState state;
  GlobalKey _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    state = Provider.of<AppState>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
//      key: _bottomNavigationKey,
      index: 0,
      height: 50.0,
      items: <Widget>[
        Icon(Icons.home, size: 30, color: Colors.white),
        Icon(Icons.search, size: 30, color: Colors.white),
        Icon(Icons.chat_bubble_outline, size: 30, color: Colors.white),
        Icon(Icons.notifications_none, size: 30, color: Colors.white),
      ],
      color: TwitterColor.dodgetBlue,
      buttonBackgroundColor: TwitterColor.dodgetBlue,
      backgroundColor: TwitterColor.white,
      animationCurve: Curves.easeInOut,
      animationDuration: Duration(milliseconds: 500),
      onTap: (index) {
        setState(() {
          state.setpageIndex = index;
        });
      },
    );
  }
}

class _BottomMenubarPreviousState extends State<BottomMenubar> {
  PageController _pageController;
  int _selectedIcon = 0;
  @override
  void initState() {
    _pageController = widget.pageController;
    super.initState();
  }

  Widget _iconRow() {
    var state = Provider.of<AppState>(
      context,
    );
    return Container(
      height: 50,
      decoration:
          BoxDecoration(color: Theme.of(context).bottomAppBarColor, boxShadow: [
        BoxShadow(color: Colors.black12, offset: Offset(0, -.1), blurRadius: 0)
      ]),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _icon(null, 0,
              icon: 0 == state.pageIndex ? AppIcon.homeFill : AppIcon.home,
              isCustomIcon: true),
          _icon(null, 1,
              icon: 1 == state.pageIndex ? AppIcon.searchFill : AppIcon.search,
              isCustomIcon: true),
//                  _icon(Icons.add,2,isCustomIcon:false),
          _icon(null, 3,
              icon: 3 == state.pageIndex
                  ? AppIcon.notificationFill
                  : AppIcon.notification,
              isCustomIcon: true),
          _icon(null, 4,
              icon: 4 == state.pageIndex
                  ? AppIcon.messageFill
                  : AppIcon.messageEmpty,
              isCustomIcon: true),
        ],
      ),
    );
  }

  Widget _icon(IconData iconData, int index,
      {bool isCustomIcon = false, int icon}) {
    var state = Provider.of<AppState>(
      context,
    );
    return Expanded(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        child: AnimatedAlign(
          duration: Duration(milliseconds: ANIM_DURATION),
          curve: Curves.easeIn,
          alignment: Alignment(0, ICON_ON),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: ANIM_DURATION),
            opacity: ALPHA_ON,
            child: IconButton(
              color: Colors.deepOrangeAccent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              padding: EdgeInsets.all(0),
              alignment: Alignment(0, 0),
              icon: isCustomIcon
                  ? customIcon(context,
                      icon: icon,
                      size: 22,
                      istwitterIcon: true,
                      isEnable: index == state.pageIndex)
                  : Icon(
                      iconData,
                      color: index == state.pageIndex
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.caption.color,
                    ),
              onPressed: () {
                setState(() {
                  _selectedIcon = index;
                  state.setpageIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _iconRow();
  }
}
