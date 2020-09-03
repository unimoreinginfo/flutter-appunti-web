import 'package:flutter/material.dart';

import 'consts.dart';
import 'io.dart';
import 'platform.dart' show httpClient, tokenStorage;
import 'errors.dart' as errors;
import 'backend.dart' as backend;

class EditPage extends StatelessWidget {
  EditPage(this.mod, this.token);

  final String token;
  final bool mod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(mod ? "Aggiungi o modera i contenuti" : "Mandaci i tuoi appunti!"),),
      body: Scaffold(
        body: mod ? ModPage(token) : PlebPage(token),
      ),
    );
  }
}

class PlebPage extends StatelessWidget {
  PlebPage(this.jwt);

  final String jwt;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text(
      "L'accesso è stato eseguito con succeso, ma la pagina per l'aggiunta degli appunti ancora non è stata implementata",
    );
  }
}

class ModPage extends StatelessWidget {
  ModPage(this.jwt);

  final String jwt;

  Future<List> get notesFuture => backend.getNotes(httpClient);

  Future<Map> getUser(uid) => backend.getUser(uid, httpClient);
  
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
  _NoteEditPageState createState() => _NoteEditPageState(note);


}

class _NoteEditPageState extends State<NoteEditPage> {
  _NoteEditPageState(this.note);

  bool _deletionInProgress;
  TextEditingController _noteTitle;
  int _subjectId;
  Map note;
  
  Future<List> _subjectsFuture;

  @override
  initState() {
    super.initState();
    _setFieldsToDefault();
    _subjectsFuture = backend.getSubjects(httpClient);
  }

  void _setFieldsToDefault() {
    _noteTitle = TextEditingController(text: widget.note["title"]);
    _subjectId = note["subject_id"];
    _deletionInProgress = false;
  }

  Future<void> editNote(int id, String jwt, {@required Map data}) async {
    // TODO: what if this fails?
    // TODO: call the backend thing
  
    var res = await httpClient.post(
      "$baseUrl/notes/$id",
      body: data,
      headers: {
        "Authorization": "Bearer $jwt"
      }
    );

    if(res.statusCode == errors.INVALID_CREDENTIALS) {
      LoginManager.logOut(tokenStorage);
      showDialog(
        context: context,
        child: AlertDialog(
          title: Text("La sessione potrebbe essere scaduta o corrotta"),
          content: Text("Verrai riportato alla pagina di accesso"),
        )
      );
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }
    getAndUpdateToken(res, tokenStorage);
  }

  Future<void> deleteNote(int id, String jwt) async {
    // TODO: what if this fails?
    // TODO: move out of here
    setState(() {_deletionInProgress = true;});
    var res = await httpClient.delete("$baseUrl/notes/$id", headers: {"Authorization": "Bearer $jwt"});
    setState(() {_deletionInProgress = false;});
    if(res.statusCode == errors.INVALID_CREDENTIALS) {
      LoginManager.logOut(tokenStorage);
      showDialog(
        context: context,
        child: AlertDialog(
          title: Text("La sessione potrebbe essere scaduta o corrotta"),
          content: Text("Verrai riportato alla pagina di accesso"),
        )
      );
      Navigator.pushReplacementNamed(context, "/login");
    } else {
      getAndUpdateToken(res, tokenStorage);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FlatButton(
          onPressed: () {setState(_setFieldsToDefault);},
          child: Text("Resetta campi")
        ),
        FutureBuilder<List<Map>>(
          future: _subjectsFuture,
          builder: (context, snapshot) {
            if(snapshot.hasError) {
              showDialog(
                context: context,
                child: AlertDialog(
                  title: Text("Si è verificato un errore durante l'accesso alle materie")
                )
              );
              return Text("si è verificato un errore");
            }
            if(!snapshot.hasData) {
              return Text("aspettando le materie");
            }
            final subjects = snapshot.data;
            return DropdownButton( // select subject
              value: _subjectId,
              items: subjects.map(
                (subject) => DropdownMenuItem(
                  value: subject["id"], 
                  child: Text(subject["name"])
                )
              ).toList(),
              onChanged: (value) {
                setState(() {
                  _subjectId = value;
                });
              }
            );
          }
        ),
        TextField(
          controller: _noteTitle,
          decoration: InputDecoration(
            labelText: "Titolo appunto"
          ),
        ),
        FlatButton(
          onPressed: () {
            try {
              editNote(note["note_id"], widget.jwt, data: {
                "subject_id": _subjectId,
                "title": _noteTitle.text
              });
            } catch(e) {
              print("Error: $e");
              showDialog(
                context: context,
                child: AlertDialog(
                  title: Text("Errore"),
                  content: Text("$e")
                )
              );
            }
          },
          child: Text("Modifica valori appunto")
        ),
        Divider(),
        FlatButton(
          color: Colors.redAccent,
          textColor: Colors.white,
          onPressed: () {deleteNote(note["note_id"], widget.jwt);},
          child: _deletionInProgress ? CircularProgressIndicator() : Text("Non mi piace questo file, ELIMINA ORA")
        )
      ],
    );
  }
}
