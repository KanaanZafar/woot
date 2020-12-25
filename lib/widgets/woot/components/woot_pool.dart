import 'package:flutter/material.dart';
import 'package:polls/polls.dart';
import 'package:wootter_x/helper/theme.dart';
import 'package:wootter_x/helper/utility.dart';
import 'package:wootter_x/model/poolModel.dart';

class WootPoll extends StatelessWidget {
  final List<Pool> poll;
  final String description;
  final String userId;
  final String createrId;
  final String wookKey;

  const WootPoll({
    Key key,
    this.poll,
    this.description,
    this.userId,
    this.createrId,
    this.wookKey,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Map<dynamic, dynamic> map = {};
    poll.forEach((element) {
      element.votes.forEach((ids) {
        map[ids] = 1;
      });
    });
    return GestureDetector(
      onTap: () {},
      child: Polls(
        children: poll
            .map(
              (e) => Polls.options(
                title: '${e.value}',
                value: e.votes.length.toDouble(),
              ),
            )
            .toList(),
        question: Text(description, style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400),
            textScaleFactor: 1),
        voteData: map,
        currentUser: userId,
        creatorID: createrId,
        allowCreatorVote: true,
        leadingBackgroundColor: TwitterColor.dodgetBlue,
        leadingPollStyle: TextStyle(color: Colors.white),
        onVote: (choice) async {
          List<String> _choices = poll[choice - 1].votes;
          _choices.add(userId);
          _choices = _choices.toSet().toList();
          // await kDatabase.child('woot').child(wookKey).child('poll')
          //     .child(poll[choice - 1].value)
          //     .set(_choices);
        },
      ),
    );
  }
}
