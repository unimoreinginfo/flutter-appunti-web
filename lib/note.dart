import 'package:appunti_web_frontend/errors.dart';
import 'package:appunti_web_frontend/utils.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: noteDataFuture,
          builder: (context, snapshot) {
            // TODO: error handling
            if(!snapshot.hasData) return CircularProgressIndicator();
            if(snapshot.hasError) {
              if(snapshot.error is NotFoundError) {
                goToRouteAsap(context, "/");
                showDialog(
                  context: context,
                  child: AlertDialog(
                    title: Text("Non è stato possibile ottenere i dati dell'appunto")
                  )
                );
              }
            }
            var noteData = snapshot.data;
            return NotePageBody(noteData);
          }
        ),
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