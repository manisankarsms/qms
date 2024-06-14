import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class VotingScreen extends StatelessWidget {
  final String sessionId;
  final String storyId;
  final String userId;

  VotingScreen({
    required this.sessionId,
    required this.storyId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final DatabaseReference _storyRef = FirebaseDatabase.instance
        .ref()
        .child('sessions')
        .child(sessionId)
        .child('stories')
        .child(storyId);

    void _vote(String cardValue) {
      _storyRef.child('votes').child(userId).set(cardValue);
      Navigator.pop(context); // Close the bottom sheet after voting
    }

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select your vote',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildVoteButton('1', _vote),
                _buildVoteButton('2', _vote),
                _buildVoteButton('3', _vote),
                _buildVoteButton('5', _vote),
                _buildVoteButton('8', _vote),
                _buildVoteButton('13', _vote),
                _buildVoteButton('20', _vote),
                _buildVoteButton('40', _vote),
                _buildVoteButton('100', _vote),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton(String cardValue, Function(String) voteFunction) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () => voteFunction(cardValue),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5.0,
                spreadRadius: 2.0,
                offset: Offset(2.0, 2.0),
              ),
            ],
            border: Border.all(color: Colors.black, width: 2.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cardValue,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5.0),
              Text(
                'Points',
                style: TextStyle(
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
