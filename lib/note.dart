import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'consts.dart';

enum ProvidedArg {
  id,
  data
}

class Note extends StatelessWidget {
  Note({@required this.name, @required this.authorName, @required this.authorId, @required this.uploadedAt, this.userData, @required this.noteData});

  final String name;
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
        MaterialPageRoute(builder: (context) => NotePage(noteData: noteData,))
      )
    );
  }
}

class NotePage extends StatelessWidget {
  NotePage({this.noteDataFuture = null, this.noteData = null});

  final Future<Map> noteDataFuture;
  final Map noteData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scarica file appunti")),
      body: noteData == null ? FutureBuilder(
        future: noteDataFuture,
        builder: (context, snapshot) {
          if(!snapshot.data) return CircularProgressIndicator();
          Map noteData = snapshot.data;
          return NotePageBody(noteData);
        }
      ) : NotePageBody(noteData),
    );
  }
}

class NotePageBody extends StatelessWidget {
  NotePageBody(this.noteData);

  final Map noteData;
  
  @override
  Widget build(BuildContext context) {
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