import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CreateStoryScreen extends StatefulWidget {
  final String sessionId;

  CreateStoryScreen({required this.sessionId});

  @override
  _CreateStoryScreenState createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storyNameController = TextEditingController();
  late DatabaseReference _storiesRef;

  @override
  void initState() {
    super.initState();
    _storiesRef = FirebaseDatabase.instance
        .reference()
        .child('sessions')
        .child(widget.sessionId)
        .child('stories');
  }

  @override
  void dispose() {
    _storyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Story'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _storyNameController,
                decoration: InputDecoration(labelText: 'Story Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a story name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    String? storyId = _storiesRef.push().key;
                    if (storyId != null) {
                      _storiesRef.child(storyId).set({
                        'name': _storyNameController.text,
                        'votes': 0,
                      }).then((_) {
                        Navigator.pop(context);
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to create story: $error')),
                        );
                      });
                    }
                  }
                },
                child: Text('Create Story'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
