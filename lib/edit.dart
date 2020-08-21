import 'package:flutter/material.dart';

import 'consts.dart';
import 'io.dart';
import 'platform.dart' show httpClient, tokenStorage;
import 'profile.dart' show ProfilePage;

import 'dart:convert' show json;

class EditPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getToken(tokenStorage),
      builder: (context, snapshot)  {
        if(!snapshot.hasData) return CircularProgressIndicator();
        final String token = snapshot.data;
        if(snapshot.hasError) { // TODO: controllo scadenza refresh token
          Navigator.pushReplacementNamed(context, '/login');
        }        
        return FutureBuilder<bool>(
          future: isMod(token),
          builder: (context, snapshot) {
            final bool mod = snapshot.data;
            if(!snapshot.hasData) return CircularProgressIndicator();
            return Scaffold(
              appBar: AppBar(title: Text(mod ? "Aggiungi o modera i contenuti" : "Mandaci i tuoi appunti!"),),
              body: Scaffold(
                body: mod ? ModPage(token) : PlebPage(token),
              ),
            );
          }
        );
      }
    );
  }
}

class PlebPage extends StatelessWidget {
  PlebPage(this.jwt);

  final String jwt;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class ModPage extends StatelessWidget {
  ModPage(this.jwt);

  final String jwt;

  Future<List> get notesFuture async => json.decode(await httpClient.read("$baseUrl/notes"));
  Future<Map> getUser(uid) async => ProfilePage.getUser(uid);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FlatButton(
          child: Text("Voglio aggiungere gli appunti come le persone normali"),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => 
              Scaffold(
                appBar: AppBar(title: Text("Ci dia i suoi appunti, signor moderatore.")),
                body: PlebPage(jwt))
              )
            );
          },
        ),

        Expanded(
          child: FutureBuilder<List>(
            future: notesFuture,
            builder: (context, snapshot) {
              final List<Map> notes = snapshot.data;
              return ListView.builder(itemBuilder: (context, i) {
                final Map note = notes[i];
                return ListTile(
                  leading: Text(note["uploaded_at"]),
                  title: Text(note["title"]),
                  subtitle: FutureBuilder(
                    future: getUser(note["author_id"]),
                    builder: (context, snapshot) {
                      if(!snapshot.hasData) return CircularProgressIndicator();
                      final author = snapshot.data;
                      return Text("${author["name"]} ${author["surname"]}<${author["email"]}, ${author["unimore_id"]}>");
                    }
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NoteEditPage(jwt, note))),
                );
              });
            }
          ),
        )
      ],
    );
  }
}

class NoteEditPage extends StatefulWidget {
  NoteEditPage(this.jwt, this.note);

  final String jwt;
  final Map note;


  @override
  _NoteEditPageState createState() => _NoteEditPageState();


}

class _NoteEditPageState extends State<NoteEditPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}