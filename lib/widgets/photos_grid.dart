import 'package:flutter_raven/models/firebase_file.dart';
import 'package:flutter_raven/pages/image_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PictureGrid extends StatelessWidget {
  final String currentUser;
  const PictureGrid({Key? key, required this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final database = FirebaseDatabase(
            databaseURL:
                "https://project-2---raven-default-rtdb.europe-west1.firebasedatabase.app/")
        .reference();
    late List<FirebaseFile> streamList;

    return StreamBuilder(
      stream: database.child('users/$currentUser/photos').onValue,
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
              if (dataEventValues != null) {
                final data = Map<String, dynamic>.from(dataEventValues);

                streamList = data
                    .map((key, value) {
                      final id = key;
                      final name = value["imageName"] as String;
                      final date = value["dateCreated"] as String;
                      final url = value["url"] as String;
                      final path = value["path"] as String;
                      final file = FirebaseFile(
                          name: name,
                          dateCreated: date,
                          url: url,
                          id: id,
                          path: path);
                      return MapEntry(key, file);
                    })
                    .values
                    .toList();

                return GridView.builder(
                    shrinkWrap: true,
                    itemCount: streamList.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            crossAxisSpacing: 20,
                            childAspectRatio: 3 / 2,
                            mainAxisSpacing: 20),
                    itemBuilder: (context, index) {
                      final file = streamList[index];
                      return buildGrid(context, file);
                    });
              } else {
                return const Center(
                  child: Text("You have no files"),
                );
              }
            } else {
              return const Center(
                child: Text("You have no files"),
              );
            }
        }
      },
    );
  }

  Widget buildGrid(BuildContext context, FirebaseFile file) {
    return Draggable(
      child: GridTile(
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
      ),
      feedback: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Image.asset('assets/images/placeholder.png'),
          ],
        ),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        width: 48,
        height: 48,
      ),
    );
  }
}
