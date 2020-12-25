import 'package:flutter/material.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/model/chatModel.dart';
import 'package:wootter_x/model/user.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/state/chats/chatState.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:wootter_x/widgets/newWidget/customUrlText.dart';
import 'package:provider/provider.dart';

class ChatScreenPage extends StatefulWidget {
  ChatScreenPage({Key key, this.userProfileId}) : super(key: key);

  final String userProfileId;

  _ChatScreenPageState createState() => _ChatScreenPageState();
}

class _ChatScreenPageState extends State<ChatScreenPage> {
  final messageController = new TextEditingController();
  String senderId;
  String userImage;
  ChatState state;
  AuthState _authState;
  ScrollController _controller;
  GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void dispose() {
    messageController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _controller = ScrollController();
    final chatState = Provider.of<ChatState>(context, listen: false);
    final state = Provider.of<AuthState>(context, listen: false);
    _authState = Provider.of<AuthState>(context, listen: false);

    chatState.setIsChatScreenOpen = true;
    senderId = state.userId;
    chatState.databaseInit(chatState.chatUser.userId, state.userId);
    chatState.getchatDetailAsync();
    super.initState();
  }

  Widget _chatScreenBody() {
    final state = Provider.of<ChatState>(context);
    if (state.messageList == null || state.messageList.length == 0) {
      return Center(
        child: Text(
          'No message found',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 20,
      ),
      child: ListView.builder(
        controller: _controller,
        shrinkWrap: true,
        reverse: true,
        physics: BouncingScrollPhysics(),
        itemCount: state.messageList.length,
        itemBuilder: (context, index) => chatMessage(state.messageList[index]),
      ),
    );
  }

  Widget chatMessage(ChatMessage message) {
    if (senderId == null) {
      return Container();
    }
    if (message.senderId == senderId)
      return _message(message, true);
    else
      return _message(message, false);
  }

  Widget _message(ChatMessage chat, bool myMessage) {
    return Column(
      crossAxisAlignment:
          myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//      mainAxisAlignment:
//          myMessage ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: <Widget>[
        myMessage
            ? senderMessage(context, chat)
            : receiverMessage(context, chat)
//        Padding(
//          padding: EdgeInsets.only(right: 10, left: 10),
//          child: Text(
//            getChatTime(chat.createdAt),
//            style: Theme.of(context).textTheme.caption.copyWith(fontSize: 12),
//          ),
//        )
      ],
    );
  }

  receiverMessage(BuildContext context, ChatMessage chat) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: customAdvanceNetworkImage(userImage),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.76,
//          padding: EdgeInsets.all(12),
              padding: EdgeInsets.fromLTRB(12, 15, 12, 20),
//          height: MediaQuery.of(context).size.width * 0.20,
              child: Text(
                chat.message,
                style: TextStyle(
                    fontFamily: 'Monteserrat',
                    fontSize: 16,
                    color: Colors.black),
              ),
              decoration: BoxDecoration(
                  color: AppColor.extraLightGrey,
                  borderRadius: BorderRadius.all(Radius.circular(6))),
            ),
          ),
        ],
      ),
    );
  }

  senderMessage(BuildContext context, ChatMessage chat) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 7),
//      padding: EdgeInsets.only(left: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.76,
//          padding: EdgeInsets.all(12),
              padding: EdgeInsets.fromLTRB(12, 15, 12, 20),
//          height: MediaQuery.of(context).size.width * 0.20,
              child: Text(
                chat.message,
                style: TextStyle(
                    fontFamily: 'Monteserrat',
                    fontSize: 16,
                    color: Colors.white),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 0, 125, 151),
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(10.0),
                  bottomRight: const Radius.circular(10.0),
                  topRight: const Radius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          Container(
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage:
                  customAdvanceNetworkImage(_authState.userModel.profilePic),
            ),
          ),
        ],
      ),
    );
  }

  BorderRadius getBorder(bool myMessage) {
    return BorderRadius.only(
      topLeft: myMessage ? Radius.circular(8) : Radius.circular(0),
      topRight: myMessage ? Radius.circular(8) : Radius.circular(12),
      bottomLeft: myMessage ? Radius.circular(8) : Radius.circular(12),
      bottomRight: myMessage ? Radius.circular(8) : Radius.circular(12),
    );
  }

  Widget _bottomEntryField() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10),
            alignment: Alignment.bottomLeft,
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              color: Color.fromARGB(255, 0, 125, 151),
              child: Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type message here...',
                          hintStyle: TextStyle(color: TwitterColor.white),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    GestureDetector(
                        child: Icon(Icons.send, color: Colors.white),
                        onTap: submitMessage),
//                    GestureDetector(
//                      child: Icon(Icons.send, color: Colors.white,),
//                      onTap: () {}
//                    ),
                  ],
                ),
              ),
            ),
          ),

//          TextField(
//            onSubmitted: (val) async {
//              submitMessage();
//            },
//            controller: messageController,
//            decoration: InputDecoration(
//              fillColor: TwitterColor.dodgetBlue,
//              contentPadding:
//                  EdgeInsets.symmetric(horizontal: 10, vertical: 13),
//              alignLabelWithHint: true,
//              hintText: 'Start with a message...',
//              suffixIcon:
//                  IconButton(icon: Icon(Icons.send), onPressed: submitMessage),
//              border: OutlineInputBorder(
//                borderSide: BorderSide(color: TwitterColor.dodgetBlue),
//                borderRadius: BorderRadius.circular(25)
//              )
//              // fillColor: Colors.black12, filled: true
//            ),
//          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    // final chatState = Provider.of<ChatState>(context,listen: false);
    state.setIsChatScreenOpen = false;
    state.dispose();
    return true;
  }

  void submitMessage() {
    // var state = Provider.of<ChatState>(context, listen: false);
    var authstate = Provider.of<AuthState>(context, listen: false);
    ChatMessage message;
    message = ChatMessage(
        message: messageController.text,
        createdAt: DateTime.now().toUtc().toString(),
        senderId: authstate.userModel.userId,
        receiverId: state.chatUser.userId,
        seen: false,
        timeStamp: DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
        senderName: authstate.user.displayName);
    if (messageController.text == null || messageController.text.isEmpty) {
      return;
    }
    MyUser myUser = MyUser(
        displayName: authstate.userModel.displayName,
        userId: authstate.userModel.userId,
        userName: authstate.userModel.userName,
        profilePic: authstate.userModel.profilePic);
    MyUser secondUser = MyUser(
      displayName: state.chatUser.displayName,
      userId: state.chatUser.userId,
      userName: state.chatUser.userName,
      profilePic: state.chatUser.profilePic,
    );
    state.onMessageSubmitted(message, myUser: myUser, secondUser: secondUser);
    Future.delayed(Duration(milliseconds: 50)).then((_) {
      messageController.clear();
    });
    try {
      // final state = Provider.of<ChatState>(context,listen: false);
      if (state.messageList != null &&
          state.messageList.length > 1 &&
          _controller.offset > 0) {
        _controller.animateTo(
          0.0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      }
    } catch (e) {
      print("[Error] $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    state = Provider.of<ChatState>(context, listen: false);
    userImage = state.chatUser.profilePic;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              UrlText(
                text: state.chatUser.displayName,
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                state.chatUser.userName,
                style: TextStyle(color: AppColor.darkGrey, fontSize: 15),
              )
            ],
          ),
//          iconTheme: IconThemeData(color: Colors.blue),
          backgroundColor: Colors.white,
//          actions: <Widget>[
//            IconButton(
//                icon: Icon(Icons.info, color: AppColor.primary),
//                onPressed: () {
//                  Navigator.pushNamed(context, '/ConversationInformation');
//                })
//          ],
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: _chatScreenBody(),
                ),
              ),
              _bottomEntryField()
            ],
          ),
        ),
      ),
    );
  }
}
