import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show launch;
import 'dart:convert' show json;

import 'platform.dart' show httpClient;
import 'note.dart';
import 'consts.dart';

final requestUrlUser = "$baseUrl/users";



class ProfilePage extends StatelessWidget {
  // TODO: implement conditional remote fetching, use `userData` if provided
  // TODO: remember to check the suer fetching url
  ProfilePage(this.uid, {this.userData});


  static Future<Map<String, Object>> getUser(uid) async {
    return json.decode(
      await httpClient.read("$requestUrlUser?id=$uid")
    );
  }

  static Future<List<Map<String, Object>>> getNotes(uid) async {
    return json.decode(
      await httpClient.read("$baseUrl/notes?authorId=$uid}")
    );
  }

  final int uid;
  final Map userData;

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
                          name: notes[i]["title"],
                          authorName: "${user["name"]} ${user["surname"]}",
                          downloadUrl: "$baseUrl/${notes[i]["storage_url"]}",
                          uploadedAt: DateTime.parse(notes[i]["uploaded_at"]*1000),
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
