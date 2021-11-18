import 'dart:typed_data';
import 'package:flutter_raven/classes/firebase_api.dart';
import 'package:flutter_raven/models/firebase_file.dart';
import 'package:flutter_raven/pages/image_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_raven/classes/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<FirebaseFile>> futureFiles;
  UploadTask? task;

  @override
  void initState() {
    super.initState();
    futureFiles = FirebaseAPI.listAll('photos/');
  }

  void _signOut(BuildContext context) async {
    try {
      var auth = AuthProvider.of(context)!.auth;
      await auth!.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future selectFile() async {
    try {
      //Check Into Uploading Multiple Files now.
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(allowMultiple: true);

      if (result != null) {
        Uint8List? fileBytes = result.files.first.bytes;
        String fileName = result.files.first.name;

        uploadFile(fileBytes, fileName);
      }
    } catch (e) {
      print(e);
    }
  }

  Future uploadFile(Uint8List? photo, String name) async {
    if (photo == null) return;
    final destination = 'photos/$name';

    task = FirebaseAPI.uploadBytes(destination, photo);
    setState(() {});

    if (task == null) return;
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapsot) {
          if (snapsot.hasData) {
            final snap = snapsot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);
            return Text("$percentage %");
          } else {
            return Container();
          }
        },
      );

  Widget buildGrid(BuildContext context, FirebaseFile file) => GridTile(
        child: GestureDetector(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.center,
              child: Image.network(file.url),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            ),
          ),
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ImagePage(file: file))),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cloud Data"),
        actions: <Widget>[
          task != null ? buildUploadStatus(task!) : Container(),
        ],
      ),
      body: FutureBuilder<List<FirebaseFile>>(
          future: futureFiles,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              default:
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Some Errors"),
                  );
                } else {
                  final files = snapshot.data;

                  return GridView.builder(
                      itemCount: files!.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              crossAxisSpacing: 20,
                              childAspectRatio: 3 / 2,
                              mainAxisSpacing: 20),
                      itemBuilder: (context, index) {
                        final file = files[index];
                        return buildGrid(context, file);
                      });
                }
            }
          }),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: Text("Header")),
            ListTile(
              title: const Text("Upload Image"),
              leading: const Icon(Icons.upload_rounded),
              onTap: () {
                selectFile();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Logout"),
              leading: const Icon(Icons.logout_rounded),
              onTap: () {
                Navigator.pop(context);
                _signOut(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
