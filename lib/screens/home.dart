import 'package:flutter/material.dart';
import 'create_session.dart';
import 'join_session.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  HomeScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sprint Poker'),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCard(
              context,
              'Sessions',
              Icons.group,
              JoinSessionScreen(userId: userId),
              Colors.blueAccent,
            ),
            _buildCard(
              context,
              'Create Session',
              Icons.add,
              CreateSessionScreen(userId: userId),
              Colors.greenAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon,
      Widget screen, Color bgColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: Colors.white)),
        trailing: Icon(icon, color: Colors.white),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
      ),
    );
  }
}
