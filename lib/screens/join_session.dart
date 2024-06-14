import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qms/screens/session_detail.dart';

class JoinSessionScreen extends StatelessWidget {
  final String userId;

  JoinSessionScreen({required this.userId});

  final DatabaseReference _sessionsRef =
      FirebaseDatabase.instance.ref().child('sessions');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Session'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _sessionsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            List<Widget> sessionTiles = [];
            DataSnapshot dataSnapshot = snapshot.data!.snapshot;
            Map<dynamic, dynamic> sessions =
                dataSnapshot.value as Map<dynamic, dynamic>;

            sessions.forEach((key, value) {
              sessionTiles.add(ListTile(
                title: Text(value['name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SessionDetailScreen(
                        sessionId: key,
                        userId: userId,
                      ),
                    ),
                  );
                },
              ));
            });

            return ListView(children: sessionTiles);
          } else {
            return const Center(child: Text('No sessions available'));
          }
        },
      ),
    );
  }
}
