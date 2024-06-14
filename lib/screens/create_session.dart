import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qms/screens/session_detail.dart';

class CreateSessionScreen extends StatefulWidget {
  final String userId;

  CreateSessionScreen({required this.userId});

  @override
  _CreateSessionScreenState createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sessionNameController = TextEditingController();
  late DatabaseReference _sessionsRef;

  @override
  void initState() {
    super.initState();
    _sessionsRef = FirebaseDatabase.instance.ref().child('sessions');
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _sessionNameController,
                decoration: InputDecoration(labelText: 'Session Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a session name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    String? sessionId = _sessionsRef.push().key;
                    if (sessionId != null) {
                      _sessionsRef.child(sessionId).set({
                        'name': _sessionNameController.text,
                        'created_by': widget.userId,
                        'created_at': DateTime.now().toIso8601String(),
                      }).then((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SessionDetailScreen(
                              sessionId: sessionId,
                              userId: widget.userId,
                            ),
                          ),
                        );
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to create session: $error'),
                          ),
                        );
                      });
                    }
                  }
                },
                child: Text('Create Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
