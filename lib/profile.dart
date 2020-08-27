import 'package:appunti_web_frontend/io.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show launch;
import 'dart:convert' show json;

import 'platform.dart' show httpClient, tokenStorage;
import 'note.dart';
import 'consts.dart';
import 'utils.dart';


class ProfilePage extends StatelessWidget {
  ProfilePage(this.uid, {this.userData = null});


  static Future<Map<String, Object>> getUser(uid) async {
    return json.decode(
      await httpClient.read("$baseUrl/users/$uid")
    );
  }

  static Future<List<Map<String, Object>>> getNotes(uid) async {
    return json.decode(
      await httpClient.read("$baseUrl/notes?authorId=$uid}")
    );
  }

  final String uid;
  final Map userData;

  @override
  Widget build(BuildContext context) {  
    var userFuture; 
    if(userData == null) userFuture  = getUser(uid);
    final notesFuture = getNotes(uid);

    return Scaffold(
      appBar: AppBar(title: Text("Pagina dell'autore")),
      body: userData == null ?
      FutureBuilder(
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
          return ProfilePageBody(user, notesFuture);
        }
      ) : ProfilePageBody(userData, notesFuture),
    );
  }
}

class ProfilePageBody extends StatelessWidget {
  ProfilePageBody(this.user, this.notesFuture);

  final Map user;
  final Future<List<Map>> notesFuture;

  @override
  Widget build(BuildContext context) {
    bool isUser;
    String token;
    try {
      token = getToken(tokenStorage);
      if(getPayload(token)["id"] == user["id"]) isUser = true;
      else isUser = false;
    } catch(_) {
      isUser = false;
    }
    return Column(
      children: [
        Text("Utente ${user["name"]} ${user["surname"]}", style: Theme.of(context).textTheme.headline4,),
        Row(
          mainAxisSize: MainAxisSize.min,
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
        if(isUser)
          FlatButton(child: Text("Modifica profilo",), onPressed: () {
            goToRouteAsap(context, "/editProfile", arguments: user);
          },)
        else
          FutureBuilder(
            future: isMod(token),
            builder: (context, snapshot) {
              if(!snapshot.hasData || snapshot.data == false) return Divider();
              return FlatButton(child: Text("Modifica profilo",), onPressed: () {
                goToRouteAsap(context, "/editProfile", arguments: user);
              },);
            }
          ),
        Expanded(
          child: FutureBuilder(
            future: notesFuture,
            builder: (context, snapshot) {
              final List<Map> notes = snapshot.data;
              if(snapshot.hasError) {
                doItAsap(context, (context) =>
                  showDialog(
                    context: context,
                    child: AlertDialog(
                      title: Text("Si è verificato un errore durante l'accesso agli appunti dell'utente")
                    )
                  )
                );
                return Text("Si è verificato un errore");
              }
              if(!snapshot.hasData) return CircularProgressIndicator();
              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, i) {
                  return Note(
                    authorId: user["id"],
                    name: notes[i]["title"],
                    authorName: "${user["name"]} ${user["surname"]}",
                    downloadUrl: "$baseUrl/${notes[i]["storage_url"]}",
                    uploadedAt: DateTime.parse(notes[i]["uploaded_at"]*1000),
                    notesData: notes[i],
                  );
                }
              );
            }
          )
        )
      ],
    );
  }
}

class EditProfile extends StatelessWidget {
  EditProfile(this.userData);

  final Map userData;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}