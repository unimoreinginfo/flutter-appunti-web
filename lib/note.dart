import 'package:appunti_web_frontend/backend.dart';
import 'package:appunti_web_frontend/errors.dart';
import 'package:appunti_web_frontend/io.dart';
import 'package:appunti_web_frontend/platform.dart';
import 'package:appunti_web_frontend/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:appunti_web_frontend/edit.dart' show LogoutButton;

import 'consts.dart';

enum ProvidedArg { id, data }

class NotePage extends StatelessWidget {
  NotePage(this.subjectId, this.noteId, {this.noteDataFuture = null});

  final Future<Map> noteDataFuture;
  final String subjectId;
  final String noteId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SelectableText("Scarica file appunti"),
        actions:
            getUserIdOrNull(tokenStorage) == null ? null : [LogoutButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
            future: noteDataFuture != null
                ? noteDataFuture
                : getNote(subjectId, noteId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              if (snapshot.hasError) {
                if (snapshot.error is BackendError) {
                  goToRouteAsap(context, "/");
                  showDialog(
                      context: context,
                      child: AlertDialog(
                        title: SelectableText(
                            "Non è stato possibile ottenere i dati dell'appunto"),
                        content: SelectableText(
                            "Error ${(snapshot.error as BackendError).code}"),
                      ));
                } else {
                  showDialog(
                      context: context,
                      child: AlertDialog(
                          title:
                              SelectableText("C'è un problema con i server")));
                }
              }
              var noteData = snapshot.data;
              return NotePageBody(noteData);
            }),
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
    List files = noteData["files"];
    DateTime date = DateTime.parse(noteData["info"]["uploaded_at"]);
    return Column(
      children: [
        SelectableText(noteData["info"]["title"],
            style: Theme.of(context).textTheme.headline4),
        SizedBox(height: 10.0),
        FutureBuilder(
            future: getUser(noteData["info"]["author_id"]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              return FlatButton(
                  child: Text("${snapshot.data.name} ${snapshot.data.surname}"),
                  onPressed: () => Navigator.pushNamed(
                      context, "/users/${snapshot.data['id']}"));
            }),
        SelectableText(
            "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}"),
        Expanded(
          child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, i) => ListTile(
                    leading: Icon(Icons.file_download),
                    title: Text(files[i]),
                    onTap: () => launch(
                        "$baseUrl${noteData["info"]['storage_url']}/${files[i]}"),
                  )),
        ),
      ],
    );
  }
}
