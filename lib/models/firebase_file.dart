class FirebaseFile {
  final String path;
  final String name;
  final String url;
  final String dateCreated;
  final String id;

  const FirebaseFile(
      {required this.name,
      required this.path,
      required this.url,
      required this.dateCreated,
      required this.id});
}
