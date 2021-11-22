import 'package:flutter_raven/pages/home_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FolderBar extends StatefulWidget {
  final currentUser;
  const FolderBar({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<FolderBar> createState() => _FolderBarState();
}

class _FolderBarState extends State<FolderBar> {
  String currentFolder = "";
  @override
  Widget build(BuildContext context) {
    final database = FirebaseDatabase(
            databaseURL:
                "https://project-2---raven-default-rtdb.europe-west1.firebasedatabase.app/")
        .reference();
    late Iterable<String> streamList;

    return StreamBuilder(
        stream: database.child('users/${widget.currentUser}').onValue,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              const CircularProgressIndicator();
              break;
            default:
              final snapDataEvent = snapshot.data as Event;
              final dataEventValues = snapDataEvent.snapshot.value;
              if (dataEventValues != null) {
                final data = Map<String, dynamic>.from(dataEventValues);
                streamList = data.keys;
                ScrollController _c = ScrollController();
                return SizedBox(
                  child: GridView.builder(
                      shrinkWrap: true,
                      controller: _c,
                      itemCount: streamList.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              crossAxisSpacing: 5,
                              childAspectRatio: 10 / 2,
                              mainAxisSpacing: 5),
                      itemBuilder: (context, index) {
                        final folderName = streamList.elementAt(index);
                        return buildGrid(context, folderName, index);
                      }),
                  height: 75,
                );
              } else {
                return Container();
              }
          }
          return Container();
        });
  }

  Widget buildGrid(BuildContext context, String foldername, int index) {
    return GridTile(
        child: Container(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
          onPressed: () {
            HomePage.of(context)!.setCurrentFolder(foldername);
          },
          icon: const Icon(Icons.folder_rounded),
          label: Text(foldername)),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
    ));
  }
}
