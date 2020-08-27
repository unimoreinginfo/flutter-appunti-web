import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum ProvidedArg {
  id,
  data
}

class Note extends StatelessWidget {
  Note({@required this.name, @required this.downloadUrl, @required this.authorName, @required this.authorId, @required this.uploadedAt, this.userData, @required this.notesData});

  final String name;
  final String downloadUrl;
  final String authorName;
  final String authorId;
  final DateTime uploadedAt;
  final Map userData;
  final Map notesData;

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
      trailing: IconButton(
        icon: Icon(Icons.file_download),
        onPressed: () {
          launch(downloadUrl);
        },
      ),
    );
  }
}