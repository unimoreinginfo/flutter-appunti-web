import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'consts.dart';

enum ProvidedArg {
  id,
  data
}

class NotePage extends StatelessWidget {
  NotePage({this.noteDataFuture = null});

  final Future<Map> noteDataFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scarica file appunti")),
      body: FutureBuilder(
        future: noteDataFuture,
        builder: (context, snapshot) {
          // TODO: error handling
          if(!snapshot.hasData) return CircularProgressIndicator();
          var noteData = snapshot.data;
          return NotePageBody(noteData);
        }
      ),
    );
  }
}

class NotePageBody extends StatelessWidget {
  NotePageBody(this.noteData);

  final Map noteData;
  
  @override
  Widget build(BuildContext context) {
    print("notedata: $noteData");
    // TODO: add link to profile
    List files = noteData["files"];
    return Column(
      children: [
        Text(noteData["info"]["title"], style: Theme.of(context).textTheme.headline4),
        Container(
          height: MediaQuery.of(context).size.height*80/100,
          child: ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(files[i]),
              onTap:() => launch("$baseUrl${noteData["info"]['storage_url']}/${files[i]}"),
            )
          ),
        ),
      ],
    );
  }
}