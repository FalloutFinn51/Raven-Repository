import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseAPI {
  final database = FirebaseDatabase(
          databaseURL:
              "https://project-2---raven-default-rtdb.europe-west1.firebasedatabase.app/")
      .reference();

  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putData(data);
    } on FirebaseException {
      return null;
    }
  }

  static Future<void> deleteImage(String key, String currentUser) async {
    final database = FirebaseDatabase(
            databaseURL:
                "https://project-2---raven-default-rtdb.europe-west1.firebasedatabase.app/")
        .reference();
    return database.child('users/$currentUser/root/$key').remove();
  }

  static Future<void> deleteImageStorage(String path) {
    final ref = FirebaseStorage.instance.ref(path);
    return ref.delete();
  }

  static Future<void> pushPhotoToDatabase(
      Map<String, dynamic> record, String currentUser) async {
    final database = FirebaseDatabase(
            databaseURL:
                "https://project-2---raven-default-rtdb.europe-west1.firebasedatabase.app/")
        .reference();
    final childNode = database.child('users/$currentUser/root');
    await childNode.push().set(record);
  }

  static Future<void> updateCurrentImage(
      String newname, String currentUser, String key) async {
    final database = FirebaseDatabase(
            databaseURL:
                "https://project-2---raven-default-rtdb.europe-west1.firebasedatabase.app/")
        .reference();
    final dateMod = DateTime.now().toIso8601String();
    final childNode = database.child("users/$currentUser/root");
    await childNode.update({'imageName': newname, 'dateModified': dateMod});
  }

  static Future<void> createFolder(String folder, currentUser) async {
    final database = FirebaseDatabase(
            databaseURL:
                "https://project-2---raven-default-rtdb.europe-west1.firebasedatabase.app/")
        .reference();
    final childNode = database.child('users/$currentUser/$folder');
    await childNode.set("blankFolder");
  }
}
