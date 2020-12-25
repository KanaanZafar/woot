import 'package:flutter/material.dart';
import 'package:wootter_x/helper/constant.dart';
import 'package:wootter_x/page/common/usersListPage.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:provider/provider.dart';

class FollowingListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context);
    print("${state.userModel.followingList}");
    return UsersListPage(
        pageTitle: 'Following',
        userIdsList: state.userModel.followingList,
        appBarIcon: AppIcon.follow,
        emptyScreenText: '${state.userModel.userName} isn\'t follow anyone',
        emptyScreenSubTileText: 'When they do they\'ll be listed here.');
  }
}
