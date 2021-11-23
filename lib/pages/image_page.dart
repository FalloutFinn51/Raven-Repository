import 'package:flutter_raven/classes/auth.dart';
import 'package:flutter_raven/classes/firebase_api.dart';
import 'package:flutter_raven/models/firebase_file.dart';
import 'package:flutter_raven/models/user.dart';
import 'package:flutter_raven/widgets/alert_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImagePage extends StatefulWidget {
  final String currentFolder;
  final FirebaseFile file;
  const ImagePage({Key? key, required this.file, required this.currentFolder})
      : super(key: key);

  @override
  State<ImagePage> createState() => _ImagePageState();
}

enum Formtype { edit, view, search }

class ImageNameValidator {
  static String? validate(String value) {
    return value == "" ? "New Name Required" : null;
  }
}

class _ImagePageState extends State<ImagePage> {
  late List<User> users;
  late String currentUser;
  String _searchFunctionString = "";

  String _newImageName = "";
  final _formKey = GlobalKey<FormState>();
  Formtype _formType = Formtype.view;
  final database = FirebaseDatabase(
          databaseURL:
              "https://project-2---raven-default-rtdb.europe-west1.firebasedatabase.app/")
      .reference();

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
            _newImageName, currentUser, widget.file.id, widget.currentFolder);
        // moveToBase(); //Navigate back to current file but get new ref to file.
        Navigator.pop(context);
      } catch (e) {
        _displayTextInputDialog(context, 2, "Edit Error $e");
      }
    }
  }

  Future<void> _displayTextInputDialog(
      BuildContext context, int newState, String message) async {
    return showDialog(
        context: context,
        builder: (context) {
          return Alert(
            meassage: message,
            alertState: newState,
          );
        });
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

  void moveToSearch() {
    _formKey.currentState!.reset();
    setState(() {
      _formType = Formtype.search;
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

  AppBar buildAppBar() {
    if (_formType == Formtype.search) {
      return AppBar(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: GestureDetector(
            child: TextFormField(
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(), hintText: "Search ..."),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                print(value);
              },
            ),
          ),
        ),
      );
    } else {
      return AppBar(
        actions: [
          IconButton(
              onPressed: () {
                moveToEditState();
              },
              icon: const Icon(Icons.edit_rounded)),
          IconButton(
              onPressed: () {
                moveToSearch();
              },
              icon: const Icon(Icons.share_outlined)),
          IconButton(
              onPressed: () async {
                _launchURL(widget.file.url);
              },
              icon: const Icon(Icons.download_rounded)),
          IconButton(
              onPressed: () {
                FirebaseAPI.deleteImage(
                    widget.file.id, currentUser, widget.currentFolder);
                // FirebaseAPI.deleteImageStorage(widget.file.path);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete_forever)),
        ],
      );
    }
  }

  Widget basEntryBody() {
    String fileName = "";
    if (widget.file.name.lastIndexOf(' | ') != -1) {
      fileName =
          widget.file.name.substring(widget.file.name.lastIndexOf(' | ') + 3);
    } else {
      fileName = widget.file.name;
    }

    if (_formType == Formtype.search) {
      final childNode;
      if (_searchFunctionString == "") {
        childNode = database.child('usersList/').onValue;
      } else {
        childNode =
            database.child('usersList/').startAt(_searchFunctionString).onValue;
      }
      print(childNode);

      return StreamBuilder<Object>(
          stream: childNode,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              default:
                if (snapshot.hasData) {
                  final snapDataEvent = snapshot.data as Event;
                  final dataEventValues = snapDataEvent.snapshot.value;
                  if (dataEventValues != null &&
                      dataEventValues != "blankFolder") {
                    final data = Map<String, dynamic>.from(dataEventValues);

                    users = data
                        .map((key, value) {
                          final email = value['email'] as String;
                          final uid = key;
                          final user = User(email: email, uid: uid);
                          return MapEntry(key, user);
                        })
                        .values
                        .toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          child: ListView.builder(
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                if (user.uid != currentUser) {
                                  return buildList(context, user);
                                }
                                return Container();
                              }),
                          height: 100,
                        ),
                        Expanded(
                          child: Image.network(
                            widget.file.url,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                } else {
                  return Container();
                }
            }
          });
    } else {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Image.network(
                widget.file.url,
              ),
            ),
            Expanded(
              child: Form(
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
                        Text(fileName),
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
              ),
            )
          ],
        ),
      );
    }
  }

  Widget buildList(BuildContext context, User user) {
    return ListTile(
        title: Text(user.email),
        onTap: () {
          shareFile(user.uid);
          _displayTextInputDialog(context, 1, "Shared file to ${user.email}");
        });
  }

  Future shareFile(String uid) async {
    final photoRecord = <String, dynamic>{
      'path': widget.file.path,
      'imageName': widget.file.name,
      'url': widget.file.url,
      'extention': widget.file.extention,
      'dateCreated': widget.file.dateCreated,
      'dateModified': widget.file.dateModified
    };
    await FirebaseAPI.pushPhotoToDatabase(photoRecord, uid, "root");
  }

  Widget baseEntry() {
    return Scaffold(appBar: buildAppBar(), body: basEntryBody());
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
