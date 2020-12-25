import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/model/feedModel.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/state/authState.dart';
import 'package:wootter_x/state/feedState.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:wootter_x/widgets/woot/woot.dart';
import 'package:wootter_x/widgets/woot/widgets/wootBottomSheet.dart';
import 'package:provider/provider.dart';

class FeedPostDetail extends StatefulWidget {
  FeedPostDetail({Key key, this.postId}) : super(key: key);
  final String postId;

  _FeedPostDetailState createState() => _FeedPostDetailState();
}

class _FeedPostDetailState extends State<FeedPostDetail> {
  String postId;
  @override
  void initState() {
    postId = widget.postId;
    // var state = Provider.of<FeedState>(context, listen: false);
    // state.getpostDetailFromDatabase(postId);
    super.initState();
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        var state = Provider.of<FeedState>(context, listen: false);
        state.setWootToReply = state.wootDetailModel?.last;
        Navigator.of(context).pushNamed('/ComposeWootPage/' + postId);
      },
      child: Icon(Icons.messenger_rounded),
    );
  }

  Widget _commentRow(FeedModel model) {
    print('_commentRow');
    return Woot(
      model: model,
      type: WootType.Reply,
      trailing:
          WootBottomSheet().wootOptionIcon(context, model, WootType.Reply),
    );
  }

  Widget _wootDetail(FeedModel model) {
    print('getting detailed woot');
    return Woot(
      model: model,
      type: WootType.Detail,
      isDetailed: true,
      trailing:
          WootBottomSheet().wootOptionIcon(context, model, WootType.Detail),
    );
  }

  void addLikeToComment(String commentId) {
    var state = Provider.of<FeedState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    state.addLikeToWoot(state.wootDetailModel.last, authState.user.uid);
  }

  void openImage() async {
    Navigator.pushNamed(context, '/ImageViewPge');
  }

  void deleteWoot(WootType type, String wootId, {String parentkey}) {
    var state = Provider.of<FeedState>(context, listen: false);
    state.deleteWoot(wootId, type, parentkey: parentkey);
    Navigator.of(context).pop();
    if (type == WootType.Detail) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<FeedState>(context);
    print(state.wootReplyMap);
    return WillPopScope(
      onWillPop: () async {
        Provider.of<FeedState>(context, listen: false)
            .removeLastWootDetail(postId);
        return Future.value(true);
      },
      child: Scaffold(
        floatingActionButton: _floatingActionButton(),
        backgroundColor: Theme.of(context).backgroundColor,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              title: customTitleText('Thread'),
              iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
              backgroundColor: Theme.of(context).appBarTheme.color,
              bottom: PreferredSize(
                child: Container(
                  color: Colors.grey.shade200,
                  height: 1.0,
                ),
                preferredSize: Size.fromHeight(0.0),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  state.wootDetailModel == null ||
                          state.wootDetailModel.length == 0
                      ? Container()
                      : _wootDetail(state.wootDetailModel?.last),
                  Container(
                    height: 6,
                    width: fullWidth(context),
                    color: TwitterColor.mystic,
                  )
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                state.wootReplyMap == null ||
                        state.wootReplyMap.length == 0 ||
                        state.wootReplyMap[postId] == null
                    ? [
                        Container(
                          // padding: EdgeInsets.all(10),
                          child: Center(
                            child: LinearProgressIndicator(
                              // value: 70,
                            )
                          ),
                        )
                      ]
                    : state.wootReplyMap[postId]
                        .map((x) => _commentRow(x))
                        .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
