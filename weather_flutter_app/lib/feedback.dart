import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class FeedbackPage extends StatefulWidget {
  final List<String> options = [
    'Noxious',
    'Musty',
    'Sticky',
    'Shortness of Breath',
    'Humid',
    'Fresh',
    'Cool',
    'Smoky',
    'Foggy'
  ];
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  File _image = null;
  List<String> selectedChoices = [];

  _buildChoiceList() {
    List<Widget> choices = [];
    widget.options.forEach((name) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: RawChip(
          avatar: CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.crop_square),
          ),
          label: Text(name),
          selectedColor: Colors.teal,
          selected: selectedChoices.contains(name),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(name)
                  ? selectedChoices.remove(name)
                  : selectedChoices.add(name);
              print(selectedChoices);
            });
          },
        ),
      ));
    });
    return choices;
  }

  Future chooseFile() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.perm_media),
              iconSize: 35,
              onPressed: () async {
                var image =
                    await ImagePicker.pickImage(source: ImageSource.gallery);
                setState(() {
                  _image = image;
                });

                Navigator.of(context).pop();
                _showUploadDialog();
              },
            ),
            IconButton(
              icon: Icon(Icons.camera),
              iconSize: 35,
              onPressed: () async {
                var image =
                    await ImagePicker.pickImage(source: ImageSource.camera);
                setState(() {
                  _image = image;
                });

                Navigator.of(context).pop();
                _showUploadDialog();
              },
            )
          ],
        ),
      ),
    );
  }

  void _showUploadDialog() {
    if (_image != null)
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type
          return AlertDialog(
            title: Text("Upload this Image"),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Image.file(_image),
                    height: 300,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              RaisedButton(
                textColor: Colors.white,
                child: Text("No"),
                onPressed: () {
                  _image = null;
                  Navigator.of(context).pop();
                },
              ),
              RaisedButton(
                textColor: Colors.white,
                child: Text("select"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
  }

  void _uploadFile() async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(
        'images/${Path.basename(DateTime.now().toIso8601String() + selectedChoices.toString())}}'); //use basename(_image.path) if dont want duplicate
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    prefix0.Navigator.of(context).pop();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FeedBack'),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _image == null
                  ? Container()
                  : Container(
                      height: 300,
                      child: Image.file(_image),
                    ),
              Center(
                child: RaisedButton(
                  color: Colors.teal,
                  child: Icon(Icons.camera_alt),
                  onPressed: () {
                    chooseFile();
                  },
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                color: Colors.white30,
                height: 4,
                width: 200,
              ),
              SizedBox(
                height: 15,
              ),
              Text('How are you feeling?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              Wrap(
                children: _buildChoiceList(),
              ),
              SizedBox(
                height: 10,
              ),
              RaisedButton(
                child: Text('Submit'),
                color: Colors.teal,
                onPressed: () {_uploadFile();},
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
