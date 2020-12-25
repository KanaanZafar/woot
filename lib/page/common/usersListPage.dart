import 'package:flutter/material.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/model/user.dart';
import 'package:wootter_x/page/common/widget/userListWidget.dart';
import 'package:wootter_x/page/suggestion/SuggestionPage.dart';
import 'package:wootter_x/state/searchState.dart';
import 'package:wootter_x/widgets/customAppBar.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:wootter_x/widgets/newWidget/emptyList.dart';
import 'package:provider/provider.dart';

class UsersListPage extends StatelessWidget {
  UsersListPage({
    Key key,
    this.pageTitle = "",
    this.appBarIcon,
    this.emptyScreenText,
    this.emptyScreenSubTileText,
    this.userIdsList,
  }) : super(key: key);

  final String pageTitle;
  final String emptyScreenText;
  final String emptyScreenSubTileText;
  final int appBarIcon;
  final List<String> userIdsList;

  @override
  Widget build(BuildContext context) {
    List<MyUser> userList;
    return Scaffold(
      backgroundColor: TwitterColor.mystic,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(pageTitle),
        icon: appBarIcon,
        onActionPressed: () {
          if (pageTitle.toLowerCase() == 'following') {
            Route route = MaterialPageRoute(builder: (_) => SuggestionPage());
            Navigator.push(context, route);
          }
        },
      ),
      body: Consumer<SearchState>(
        builder: (context, state, child) {
          if (userIdsList != null) {
            userList = state.getuserDetail(userIdsList);
          }
          else{
            return Text("Something went wrong ");
          }
          return (userIdsList.isEmpty)
              ? Container(
                  width: fullWidth(context),
                  padding: EdgeInsets.only(top: 0, left: 30, right: 30),
                  child: NotifyText(
                    title: emptyScreenText,
                    subTitle: emptyScreenSubTileText,
                  ),
                )
              : UserListWidget(
                  list: userList,
                  emptyScreenText: emptyScreenText,
                  emptyScreenSubTileText: emptyScreenSubTileText,
                );
        },
      ),
    );
  }
}
