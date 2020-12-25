import 'package:flutter/material.dart';
import 'package:wootter_x/helper/constant.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/page/common/usersListPage.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:provider/provider.dart';

class FollowerListPage extends StatelessWidget {
  FollowerListPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    cprint(state.userModel.followersList.toString());
    return UsersListPage(
      pageTitle: 'Followers',
      userIdsList: state.userModel.followersList,
      appBarIcon: AppIcon.follow,
      emptyScreenText:
          '${state?.profileUserModel?.userName ?? state.userModel.userName} doesn\'t have any followers',
      emptyScreenSubTileText:
          'When someone follow them, they\'ll be listed here.',
    );
  }
}
