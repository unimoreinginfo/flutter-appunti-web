import 'package:appunti_web_frontend/platform.dart';
import 'io.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum ProvidedArg {
  id,
  data
}

class Note extends StatelessWidget {
  Note({@required this.name, @required this.downloadUrl, @required this.authorName, @required this.authorId, @required this.uploadedAt, this.userData, @required this.noteData});

  final String name;
  final String downloadUrl;
  final String authorName;
  final String authorId;
  final DateTime uploadedAt;
  final Map userData;
  final Map noteData;

  @override
  Widget build(context) {
    return ListTile(
      leading: Text(
        "${uploadedAt.day}/${uploadedAt.month}/${uploadedAt.year}",
        style: Theme.of(context).textTheme.overline,
      ),
      title: Text(name),
      subtitle: FlatButton(
        child: Text(authorName, style: Theme.of(context).textTheme.subtitle1),
        onPressed: () {
          Navigator.pushNamed(context, "/profile", arguments: userData == null ? [ProvidedArg.id, authorId] : [ProvidedArg.data, userData]);
        },
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NotePage(getNote(noteData["id"], httpClient)))
      )
    );
  }
}

class NotePage extends StatelessWidget {
  NotePage(this.noteDataFuture);

  final Future<Map> noteDataFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scarica file appunti")),
      body: FutureBuilder(
        future: noteDataFuture,
        builder: (context, snapshot) {
          if(!snapshot.data) return CircularProgressIndicator();
          Map noteData = snapshot.data;
          List files = noteData["files"];
          return Column(
            children: [
              Text(noteData["title"], style: Theme.of(context).textTheme.headline4),
              ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text(files[i]),
                  onTap:() => launch("${noteData['storage_url']}/${files[i]}"),
                )
              ),
            ],
          );
        }
      )
    );
  }
}