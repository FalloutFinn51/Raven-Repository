import 'package:flutter_raven/classes/auth.dart';
import 'package:flutter_raven/classes/firebase_api.dart';
import 'package:flutter/material.dart';

class Alert extends StatefulWidget {
  final meassage;
  final alertState;
  const Alert({Key? key, required this.meassage, required this.alertState})
      : super(key: key);

  @override
  _AlertState createState() => _AlertState();
}

enum AlertType { error, information, create }

class _AlertState extends State<Alert> {
  String title = "";
  final TextEditingController _c = TextEditingController();
  AlertType _state = AlertType.create;

  @override
  void initState() {
    setAlertType();
    super.initState();
  }

  void setAlertType() {
    if (widget.alertState == 1) {
      _state = AlertType.information;
      title = "Information";
    }
    if (widget.alertState == 2) {
      _state = AlertType.error;
      title = "Error";
    }
    if (widget.alertState == 3) {
      _state = AlertType.create;
      title = "Create Folder";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state == AlertType.error || _state == AlertType.information) {
      return AlertDialog(
        title: Text(title),
        content: Text(widget.meassage),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Ok"))
        ],
      );
    } else {
      return AlertDialog(
        title: const Text('Folder Name'),
        content: TextField(
          controller: _c,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('Create Folder'),
            onPressed: () {
              final currentUser = Auth().userUIDret();
              FirebaseAPI.createFolder(_c.text, currentUser);
              _c.clear();
              Navigator.pop(context);
            },
          ),
        ],
      );
    }
  }
}
