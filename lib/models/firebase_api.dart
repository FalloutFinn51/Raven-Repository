import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_raven/models/firebase_file.dart';

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
          final size = ref.getMetadata().then((value) => {value.size});
          final timeCreated =
              ref.getMetadata().then((value) => {value.timeCreated});
          final file = FirebaseFile(
              name: name,
              ref: ref,
              url: url,
              createdTime: timeCreated,
              size: size);
          return MapEntry(index, file);
        })
        .values
        .toList();
  }
}
