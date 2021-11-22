import 'package:flutter_raven/classes/auth.dart';
import 'package:flutter_raven/classes/firebase_api.dart';
import 'package:flutter_raven/models/firebase_file.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImagePage extends StatefulWidget {
  final FirebaseFile file;
  const ImagePage({Key? key, required this.file}) : super(key: key);

  @override
  State<ImagePage> createState() => _ImagePageState();
}

enum Formtype { edit, view }

class ImageNameValidator {
  static String? validate(String value) {
    return value == "" ? "New Name Required" : null;
  }
}

class _ImagePageState extends State<ImagePage> {
  late String currentUser;
  String _newImageName = "";
  final _formKey = GlobalKey<FormState>();
  Formtype _formType = Formtype.view;

  bool baseState = true;
  @override
  Widget build(BuildContext context) {
    if (_formType == Formtype.edit) {
      return editState(context);
    } else {
      return baseEntry();
    }
  }

  void setUserUID() {
    currentUser = Auth().userUIDret();
  }

  @override
  void initState() {
    setUserUID();
    super.initState();
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        await FirebaseAPI.updateCurrentImage(
          _newImageName,
          currentUser,
          widget.file.id,
        );
        moveToBase();
      } catch (e) {
        print('Login Error $e');
        // Handle errors here
      }
    }
  }

  void moveToEditState() {
    _formKey.currentState!.reset();
    setState(() {
      _formType = Formtype.edit;
    });
  }

  void moveToBase() {
    _formKey.currentState!.reset();
    setState(() {
      _formType = Formtype.view;
    });
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Scaffold baseEntry() {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                moveToEditState();
              },
              icon: const Icon(Icons.edit_rounded)),
          IconButton(
              onPressed: () async {
                _launchURL(widget.file.url);
              },
              icon: const Icon(Icons.download_rounded)),
          IconButton(
              onPressed: () {
                FirebaseAPI.deleteImage(widget.file.id, Auth().userUIDret());
                FirebaseAPI.deleteImageStorage(widget.file.path);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_forever)),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.network(
              widget.file.url,
              fit: BoxFit.contain,
            ),
            Form(
              key: _formKey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Image Name",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(widget.file.name),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Date Created",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(widget.file.dateCreated),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Date Modified",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(widget.file.dateModified),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _launchURL(final urlString) async {
    if (await canLaunch(urlString)) {
      await launch(urlString);
    }
  }

  Widget editState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                validateAndSubmit();
              },
              icon: const Icon(Icons.save_outlined)),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.network(
              widget.file.url,
              fit: BoxFit.contain,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Edit Image Name",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: "New Image Name"),
                          onSaved: (value) =>
                              _newImageName = value! + widget.file.extention,
                          validator: (value) =>
                              ImageNameValidator.validate(value!),
                        ),
                      ),
                      width: 150,
                      height: 50,
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
