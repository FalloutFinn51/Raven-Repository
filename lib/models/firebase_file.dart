class FirebaseFile {
  final String path;
  final String name;
  final String url;
  final String dateCreated;
  final String dateModified;
  final String id;
  final String extention;

  const FirebaseFile(
      {required this.name,
      required this.path,
      required this.url,
      required this.dateCreated,
      required this.dateModified,
      required this.extention,
      required this.id});
}
