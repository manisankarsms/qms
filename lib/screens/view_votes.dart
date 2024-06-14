import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ViewVotesScreen extends StatelessWidget {
  final String sessionId;
  final String storyId;

  ViewVotesScreen({required this.sessionId, required this.storyId});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference _votesRef = FirebaseDatabase.instance
        .ref()
        .child('sessions')
        .child(sessionId)
        .child('stories')
        .child(storyId)
        .child('votes');

    return Scaffold(
      appBar: AppBar(
        title: Text('View Votes'),
      ),
      body: StreamBuilder(
        stream: _votesRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            var data = snapshot.data?.snapshot.value;

            if (data == null) {
              return Center(child: Text('No votes available'));
            }

            if (data is int) {
              return Center(child: Text('No votes available'));
            }

            if (data is! Map<dynamic, dynamic>) {
              return Center(child: Text('Unexpected data format'));
            }

            Map<dynamic, dynamic> votesData = data;

            if (votesData.isEmpty) {
              return Center(child: Text('No votes available'));
            }

            Map<String, List<String>> voteCounts = {};
            votesData.forEach((userId, vote) {
              String voteValue = vote as String;
              if (!voteCounts.containsKey(voteValue)) {
                voteCounts[voteValue] = [];
              }
              voteCounts[voteValue]?.add(userId);
            });

            String mostCommonVote = voteCounts.entries
                .reduce((a, b) => a.value.length > b.value.length ? a : b)
                .key;

            List<Widget> voteTiles = [];
            voteCounts.forEach((voteValue, userIds) {
              voteTiles.add(
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vote: $voteValue',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: voteValue == mostCommonVote
                                ? Colors.green
                                : Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        ...userIds
                            .map((userId) => Text('User: $userId'))
                            .toList(),
                      ],
                    ),
                  ),
                ),
              );
            });

            return ListView(children: voteTiles);
          }
        },
      ),
    );
  }
}
