import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:printing/printing.dart';
import 'package:qms/screens/view_votes.dart';
import 'package:qms/screens/voting.dart';
import 'create_story.dart';
import 'dart:html' as html;

class SessionDetailScreen extends StatelessWidget {
  final String sessionId;
  final String userId;

  SessionDetailScreen({required this.sessionId, required this.userId});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference _sessionRef =
        FirebaseDatabase.instance.ref().child('sessions').child(sessionId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Session Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteSession(context),
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () => _generateSummary(context),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _sessionRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            Map<dynamic, dynamic> sessionData =
                (snapshot.data?.snapshot.value ?? {}) as Map<dynamic, dynamic>;
            Map<dynamic, dynamic> storiesData = sessionData['stories'] ?? {};
            bool isCreator = sessionData['created_by'] == userId;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: storiesData.length,
                    itemBuilder: (context, index) {
                      String key = storiesData.keys.elementAt(index);
                      return ListTile(
                        title: Text(storiesData[key]['name']),
                        trailing: !isCreator
                            ? ElevatedButton(
                                onPressed: () {
                                  _voteOnStory(context, sessionId, key);
                                },
                                child: Text('Vote'),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  _viewVotes(context, sessionId, key);
                                },
                                child: Text('View Votes'),
                              ),
                      );
                    },
                  ),
                ),
                if (isCreator) ...[
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CreateStoryScreen(sessionId: sessionId)),
                      );
                    },
                    child: Text('Create Story'),
                  ),
                ],
              ],
            );
          }
        },
      ),
    );
  }

  void _voteOnStory(BuildContext context, String sessionId, String storyId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return VotingScreen(
            sessionId: sessionId, storyId: storyId, userId: userId);
      },
    );
  }

  void _viewVotes(BuildContext context, String sessionId, String storyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ViewVotesScreen(sessionId: sessionId, storyId: storyId),
      ),
    );
  }

  void _deleteSession(BuildContext context) {
    final DatabaseReference _sessionRef =
        FirebaseDatabase.instance.ref().child('sessions').child(sessionId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Session'),
          content: Text('Are you sure you want to delete this session?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _sessionRef.remove().then((_) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to the previous screen
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete session: $error'),
                    ),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateSummary(BuildContext context) async {
    final DatabaseReference _sessionRef =
        FirebaseDatabase.instance.ref().child('sessions').child(sessionId);
    final DatabaseReference _storiesRef = _sessionRef.child('stories');

    DataSnapshot sessionSnapshot = await _sessionRef.get();
    DataSnapshot storiesSnapshot = await _storiesRef.get();

    Map<dynamic, dynamic>? sessionData =
        sessionSnapshot.value as Map<dynamic, dynamic>?;
    Map<dynamic, dynamic>? storiesData =
        storiesSnapshot.value as Map<dynamic, dynamic>?;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Session Summary', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text('Session ID: $sessionId'),
              pw.Text('Created by: ${sessionData?['created_by']}'),
              pw.Text('Created at: ${sessionData?['created_at']}'),
              pw.SizedBox(height: 20),
              pw.Text('Stories:', style: pw.TextStyle(fontSize: 18)),
              if (storiesData != null) ..._buildStoryList(storiesData),
            ],
          );
        },
      ),
    );

    if (kIsWeb) {
      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'summary.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }
  }

  List<pw.Widget> _buildStoryList(Map<dynamic, dynamic> storiesData) {
    List<pw.Widget> storyWidgets = [];

    storiesData.forEach((key, storyData) {
      Map<dynamic, dynamic> votesData = storyData['votes'] ?? {};
      List<pw.Widget> voteEntries = votesData.entries
          .map((entry) => pw.Text('${entry.key}: ${entry.value}'))
          .toList();

      storyWidgets.add(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Story: ${storyData['name']}',
                style: pw.TextStyle(fontSize: 16)),
            ...voteEntries,
            pw.SizedBox(height: 10),
          ],
        ),
      );
    });

    return storyWidgets;
  }
}
