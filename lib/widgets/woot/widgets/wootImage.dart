import 'package:flutter/material.dart';
import 'package:wootter_x/helper/enum.dart';
import 'package:wootter_x/model/feedModel.dart';
import 'package:wootter_x/state/feedState.dart';
import 'package:wootter_x/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class WootImage extends StatelessWidget {
  const WootImage(
      {Key key,
      this.model,
      this.type,
      this.isRewootImage = false,
      this.isTop = false})
      : super(key: key);

  final FeedModel model;
  final WootType type;
  final bool isRewootImage;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      alignment: Alignment.centerRight,
      child: model.imagePath == null
          ? SizedBox.shrink()
          : Padding(
              padding: EdgeInsets.only(
                top: 8,
              ),
              child: InkWell(
                borderRadius: BorderRadius.all(
                  Radius.circular(isRewootImage ? 0 : 20),
                ),
                onTap: () {
                  if (type == WootType.ParentWoot) {
                    return;
                  }
                  var state = Provider.of<FeedState>(context, listen: false);
                  state.getpostDetailFromDatabase(model.key);
                  state.setWootToReply = model;
                  Navigator.pushNamed(context, '/ImageViewPge');
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(isRewootImage ? 10 : 20),
                  ),
                  child: Container(
                    width: fullWidth(context) *
                            (type == WootType.Detail ? .95 : .8) -
                        8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                    ),
                    child: AspectRatio(
                      aspectRatio: isTop ? 1 : 4 / 3,
                      child: customNetworkImage(
                          model.imagePath,
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
