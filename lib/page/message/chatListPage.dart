import 'package:flutter/material.dart';
import 'package:wootter_x/helper/constant.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/model/chatModel.dart';
import 'package:wootter_x/model/user.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/state/chats/chatState.dart';
import 'package:wootter_x/state/searchState.dart';
import 'package:wootter_x/widgets/customAppBar.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:wootter_x/widgets/newWidget/emptyList.dart';
import 'package:wootter_x/widgets/newWidget/rippleButton.dart';
import 'package:wootter_x/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class ChatListPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ChatListPage({Key key, this.scaffoldKey}) : super(key: key);
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    final chatState = Provider.of<ChatState>(context, listen: false);
    final state = Provider.of<AuthState>(context, listen: false);
    chatState.setIsChatScreenOpen = true;

    // chatState.databaseInit(state.profileUserModel.userId,state.userId);
    chatState.getUserchatList(state.user.uid);
    super.initState();
  }

  Widget _body() {
    final state = Provider.of<ChatState>(context);
    final searchState = Provider.of<SearchState>(context, listen: false);
    if (state.chatUserList == null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: EmptyList(
          'No message available ',
          subTitle:
              'When someone sends you message,User list\'ll show up here \n  To send message tap message button.',
        ),
      );
    } else {
      return ListView.separated(
        physics: BouncingScrollPhysics(),
        itemCount: state.chatUserList.length,
        itemBuilder: (context, index) => _userCard(
            searchState.userlist.firstWhere(
              (x) => x.userId == state.chatUserList[index].key,
              orElse: () => MyUser(userName: "Unknown"),
            ),
            state.chatUserList[index]),
        separatorBuilder: (context, index) {
          return Divider(
            height: 2,
          );
        },
      );
    }
  }

  Widget _userCard(MyUser model, ChatMessage lastMessage) {
    return Container(
      color: Colors.white,
      child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          onTap: () {
            final chatState = Provider.of<ChatState>(context, listen: false);
            final searchState =
                Provider.of<SearchState>(context, listen: false);
            chatState.setChatUser = model;
            if (searchState.userlist.any((x) => x.userId == model.userId)) {
              chatState.setChatUser = searchState.userlist
                  .where((x) => x.userId == model.userId)
                  .first;
            }
            Navigator.pushNamed(context, '/ChatScreenPage');
          },
          leading: RippleButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/ProfilePage/${model.userId}');
            },
            borderRadius: BorderRadius.circular(5),
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
//              border: Border.all(color: Colors.white, width: 0),
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                    image: customAdvanceNetworkImage(
                      model.profilePic ?? dummyProfilePic,
                    ),
                    fit: BoxFit.cover),
              ),
            ),
          ),
          title: TitleText(
            model.displayName,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: customText(
            getLastMessage(lastMessage.message) ?? '#${model.displayName}',
            style: onPrimarySubTitleText.copyWith(color: Colors.black54),
          ),
          trailing: Icon(Icons.near_me, color: TwitterColor.dodgetBlue)

//        lastMessage == null
//            ? SizedBox.shrink()
//            : Text(
//                getChatTime(lastMessage.createdAt).toString(),
//              ),
          ),
    );
  }

  void onSettingIconPressed() {
    Navigator.pushNamed(context, '/DirectMessagesPage');
  }

  String getLastMessage(String message) {
    if (message != null && message.isNotEmpty) {
      if (message.length > 100) {
        message = message.substring(0, 80) + '...';
        return message;
      } else {
        return message;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        scaffoldKey: widget.scaffoldKey,
        title: customTitleText(
          'Messages',
        ),
        icon: AppIcon.settings,
        onActionPressed: onSettingIconPressed,
      ),
      backgroundColor: TwitterColor.mystic,
      body: _body(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: 'newMessage',
        onPressed: () {
          Navigator.of(context).pushNamed('/NewMessagePage');
        },
        child: customIcon(
          context,
          icon: AppIcon.newMessage,
          istwitterIcon: true,
          iconColor: Theme.of(context).colorScheme.onPrimary,
          size: 25,
        ),
      ),
    );
  }
}
