import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Note extends StatelessWidget {
  Note({@required this.name, @required this.downloadUrl, @required this.authorName, @required this.authorId, @required this.uploadedAt});

  final String name;
  final String downloadUrl;
  final String authorName;
  final int authorId;
  final DateTime uploadedAt;

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
          Navigator.pushNamed(context, "/profile", arguments: authorId);
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