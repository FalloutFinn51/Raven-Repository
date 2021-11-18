import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_raven/models/firebase_file.dart';

import 'auth.dart';

class FirebaseAPI {
  static Future<List<String>> _getDownloadUrls(List<Reference> refs) =>
      Future.wait(refs.map((ref) => ref.getDownloadURL()).toList());

  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putData(data);
    } on FirebaseException catch (e) {
      return null;
    }
  }

  static Future<void> deleteImage(FirebaseFile file) async {
    final ref = file.ref;
    return ref.delete();
  }

  Future<List> getFileData(FullMetadata data) async {
    final size = data.size;
    final timeCreated = data.timeCreated;
    return [size, timeCreated];
  }

  static Future<List<FirebaseFile>> listAll(String path) async {
    final ref = FirebaseStorage.instance.ref(path);
    final result = await ref.listAll();
    final urls = await _getDownloadUrls(result.items);

    return urls
        .asMap()
        .map((index, url) {
          final ref = result.items[index];
          final name = ref.name;
          final file = FirebaseFile(
              name: name,
              ref: ref,
              url: url,
              dateCreated: DateTime.now().toIso8601String());
          return MapEntry(index, file);
        })
        .values
        .toList();
  }

  static StreamSubscription setRecordValueChangedListener() {
    String currentUser = Auth().userUIDret();

    final database = FirebaseDatabase(
            databaseURL:
                "https://cloud-a8697-default-rtdb.europe-west1.firebasedatabase.app/")
        .reference();

    return database.child('users/$currentUser/photos').onValue.listen((event) {
      final data = new Map<String, dynamic>.from(event.snapshot.value);
      // final url = data['url'] as String;
      // final name = data['imageName'] as String;
      // final date = data['dateCreated'] as String;
      print(event.snapshot.value);
    });
  }
}
