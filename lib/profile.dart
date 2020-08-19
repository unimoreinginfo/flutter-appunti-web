import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show launch;
import 'dart:convert' show json;

import 'platform.dart' show httpClient;
import 'note.dart';
import 'consts.dart';

final requestUrlUser = "$baseUrl/utente";
final requestUrlNotes = "$baseUrl/appunti";



class ProfilePage extends StatelessWidget {
  ProfilePage(this.uid);

  static Future<Map<String, Object>> getUser(int uid) async {
    return json.decode(
      await httpClient.read("$requestUrlUser?uid=$uid")
    );
  }

  static Future<List<Map<String, Object>>> getNotes(int uid) async {
    return json.decode(
      await httpClient.read("$requestUrlNotes?uid=$uid")
    );
  }

  final int uid;
  @override
  Widget build(BuildContext context) {   
    final userFuture = getUser(uid);
    final notesFuture = getNotes(uid);

    return Scaffold(
      appBar: AppBar(title: Text("Pagina dell'autore")),
      body: FutureBuilder(
        future: userFuture,
        builder: (context, snapshot) {
          final Map user = snapshot.data;
          if(snapshot.hasError) {
            showDialog(
              context: context,
              child: AlertDialog(
                title: Text("Si è verificato un errore durante l'accesso ai dati dell'utente")
              )
            );
            return Text("Si è verificato un errore");
          }
          if(!snapshot.hasData) return CircularProgressIndicator();
          return Column(
            children: [
              Text("Utente ${user["name"]} ${user["surname"]}", style: Theme.of(context).textTheme.headline4,),
              Row(
                children: [
                  Text("Email: "),
                  FlatButton(
                    child: Text(user["email"]),
                    onPressed: () {launch("mailto:${user["email"]}");},
                  ),
                  FlatButton(
                    child: Text("/${user["unimore_id"]}@studenti.unimore.it"),
                    onPressed: () {launch("mailto:${user["unimore_id"]}@studenti.unimore.it");},
                  )
                ],
              ),
              Expanded(
                child: FutureBuilder(
                  future: notesFuture,
                  builder: (context, snapshot) {
                    final List<Map> notes = snapshot.data;
                    if(snapshot.hasError) {
                      showDialog(
                        context: context,
                        child: AlertDialog(
                          title: Text("Si è verificato un errore durante l'accesso agli appunti dell'utente")
                        )
                      );
                      return Text("Si è verificato un errore");
                    }
                    if(!snapshot.hasData) return CircularProgressIndicator();
                    return ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (context, i) {
                        return Note(
                          authorId: uid,
                          name: notes[i]["name"],
                          authorName: "${user["name"]} ${user["surname"]}",
                          downloadUrl: "$basePathNotes/${notes[i]["path"]}",
                          uploadedAt: DateTime.fromMillisecondsSinceEpoch(notes[i]["uploaded_at"]*1000),
                        );
                      }
                    );
                  }
                )
              )
            ],
          );
        }
      ),
    );
  }
}
