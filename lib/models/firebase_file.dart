import 'package:firebase_storage/firebase_storage.dart';

class FirebaseFile {
  final Reference ref;
  final String name;
  final String url;
  final Future<Set<int?>> size;
  final Future<Set<DateTime?>> createdTime;

  const FirebaseFile(
      {required this.name,
      required this.ref,
      required this.url,
      required this.createdTime,
      required this.size});
}
