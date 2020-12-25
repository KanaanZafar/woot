import 'package:flutter/material.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/model/feedModel.dart';
import 'package:wootter_x/state/feedState.dart';
import 'package:wootter_x/widgets/woot/woot.dart';
import 'package:wootter_x/widgets/woot/widgets/unavailableWoot.dart';
import 'package:provider/provider.dart';

class ParentWootWidget extends StatelessWidget {
  ParentWootWidget(
      {Key key,
      this.childRetwetkey,
      this.type,
      this.isImageAvailable,
      this.trailing})
      : super(key: key);

  final String childRetwetkey;
  final WootType type;
  final Widget trailing;
  final bool isImageAvailable;

  void onWootPressed(BuildContext context, FeedModel model) {
    var feedstate = Provider.of<FeedState>(context, listen: false);
    feedstate.getpostDetailFromDatabase(null, model: model);
    Navigator.of(context).pushNamed('/FeedPostDetail/' + model.key);
  }

  @override
  Widget build(BuildContext context) {
    var feedstate = Provider.of<FeedState>(context, listen: false);
    return FutureBuilder<FeedModel>(
      future: feedstate.fetchWoot(childRetwetkey),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Woot(
              model: snapshot.data,
              type: WootType.ParentWoot,
              trailing: trailing);
        }
        if ((snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.waiting) &&
            !snapshot.hasData) {
          return UnavailableWoot(
            snapshot: snapshot,
            type: type,
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
