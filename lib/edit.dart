import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'io.dart';
import 'note.dart' show ProvidedArg;
import 'platform.dart' show tokenStorage;
import 'errors.dart' as errors;
import 'backend.dart' as backend;
import 'platform.dart' as platform;

class LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.logout),
      tooltip: "Esci",
      onPressed: () {
        LoginManager.logOut(platform.tokenStorage);
        Navigator.pushNamed(context, "/");
      },
    );
  }
}

class EditPage extends StatelessWidget {
  EditPage(this.mod, this.token);

  final String token;
  final bool mod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            mod ? "Aggiungi o modera i contenuti" : "Mandaci i tuoi appunti!"),
        actions: [LogoutButton()],
      ),
      body: Scaffold(
        body: mod ? ModPage(token) : PlebPage(token),
      ),
    );
  }
}

class PlebPage extends StatefulWidget {
  PlebPage(this.jwt);

  final String jwt;

  @override
  _PlebPageState createState() => _PlebPageState();
}

class _PlebPageState extends State<PlebPage> {
  TextEditingController _title = TextEditingController();
  int _subjectId = 0;
  String _selectedFilename = null;
  List _fileData;
  bool _sendingNote = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 900.0,
        padding: EdgeInsets.all(15.0),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          FutureBuilder<List<Map>>(
              future: backend.getSubjects(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  showDialog(
                      context: context,
                      child: AlertDialog(
                          title: Text(
                              "Si è verificato un errore durante l'accesso alle materie")));
                  return Text("si è verificato un errore");
                }
                if (!snapshot.hasData) {
                  return Text("aspettando le materie");
                }
                final subjects = snapshot.data;
                return DropdownButton(
                    value: _subjectId,
                    items: subjects
                        .map((subject) => DropdownMenuItem(
                            value: subject["id"], child: Text(subject["name"])))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _subjectId = value;
                      });
                    });
              }),
          TextField(
            controller: _title,
            decoration: InputDecoration(labelText: "Titolo appunto"),
          ),
          if (_selectedFilename == null)
            FlatButton(
                onPressed: () async {
                  var res = await FilePicker.platform.pickFiles();
                  if (res != null && res.isSinglePick)
                    setState(() {
		      _fileData.clear();
                      _selectedFilename = res.files.single.name;
		      _fileData = res.files.single.bytes;
                    });
                },
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text("Aggiungi file"))
          else
            Row(
              children: [
                Text("Selezionato file ${_selectedFilename}"),
                IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      setState(() {
		        _fileData.clear();
                        _selectedFilename = null;
                      });
                    })
              ],
            ),
          if (_sendingNote)
            CircularProgressIndicator()
          else
            FlatButton(
                onPressed: () async {
                  setState(() {
                    _sendingNote = true;
                  });
                  try {
                    await backend.addNote(widget.jwt, _title.text,
                        "$_subjectId", _selectedFilename, _fileData);
                  } catch (e) {
                    setState(() {
                      _sendingNote = false;
                    });
                    showDialog(
                        context: context,
                        child: AlertDialog(
                          title: Text("Si è verificato un errore"),
                          content: Text("error: $e"),
                        ));
                    return;
                  }
                  Navigator.pushNamed(context, '/edit');
                  showDialog(
                      context: context,
                      child: AlertDialog(
                        title: Text("Grazie mille."),
                      ));
                },
                color: Colors.green,
                textColor: Colors.white,
                child: Text("Invia appunto"))
        ]),
      ),
    );
  }
}

class ModPage extends StatelessWidget {
  ModPage(this.jwt);

  final String jwt;

  Future<Map> getUser(uid) => backend.getUser(uid);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FlatButton(
          child: Text("Voglio aggiungere gli appunti come le persone normali"),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Scaffold(
                        appBar: AppBar(
                          title:
                              Text("Ci dia i suoi appunti, signor moderatore."),
                          actions: [LogoutButton()],
                        ),
                        body: PlebPage(jwt))));
          },
        ),
        FlatButton(
          child: Text("Lista utenti"),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: Text("Elenco degli utenti"),
                            actions: [LogoutButton()],
                          ),
                          body: UsersList(jwt),
                        )));
          },
        ),
        Expanded(
          child: FutureBuilder<List>(
              future: backend.getNotes(),
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
                          if (!snapshot.hasData)
                            return CircularProgressIndicator();
                          final author = snapshot.data;
                          return Text(
                              "${author["name"]} ${author["surname"]}<${author["email"]}, ${author["unimore_id"]}>");
                        }),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NoteEditPage(jwt, note))),
                  );
                });
              }),
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
    _subjectsFuture = backend.getSubjects();
  }

  void _setFieldsToDefault() {
    _noteTitle = TextEditingController(text: widget.note["title"]);
    _subjectId = note["subject_id"];
    _deletionInProgress = false;
  }

  Future<void> editNote(String id, String sub_id, String jwt,
      {@required Map data}) async {
    // TODO: what if this fails?

    try {
      await backend.editNote(id, sub_id, jwt, data);
      Navigator.pop(context);
    } on errors.BackendError catch (_) {
      LoginManager.logOut(tokenStorage);
      Navigator.pushReplacementNamed(context, "/login");
      showDialog(
          context: context,
          child: AlertDialog(
            title: Text("La sessione potrebbe essere scaduta o corrotta"),
            content: Text("Verrai riportato alla pagina di accesso"),
          ));
    } catch (e) {
      Navigator.pushReplacementNamed(context, "/edit");
      showDialog(
          context: context,
          child: AlertDialog(
            title: Text("Si è verificato un errore sconosciuto"),
          ));
    }
  }

  Future<void> deleteNote(String id, String sub_id, String jwt) async {
    // TODO: what if this fails?
    setState(() {
      _deletionInProgress = true;
    });
    try {
      await backend.deleteNote(id, sub_id, jwt);
      Navigator.pop(context);
    } on errors.BackendError {
      Navigator.pushReplacementNamed(context, "/login");
      LoginManager.logOut(tokenStorage);
      showDialog(
          context: context,
          child: AlertDialog(
            title: Text("La sessione potrebbe essere scaduta o corrotta"),
            content: Text("Verrai riportato alla pagina di accesso"),
          ));
    } catch (_) {
      Navigator.pushReplacementNamed(context, "/login");
      showDialog(
          context: context,
          child: AlertDialog(
            title: Text("Si è verificato un errore sconosciuto"),
            content: Text("Verrai riportato alla pagina di accesso"),
          ));
    } finally {
      setState(() {
        _deletionInProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Modifica appunto")),
        body: Center(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                width: 900.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                        onPressed: () {
                          setState(_setFieldsToDefault);
                        },
                        child: Text("Resetta campi")),
                    FutureBuilder<List<Map>>(
                        future: _subjectsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            showDialog(
                                context: context,
                                child: AlertDialog(
                                    title: Text(
                                        "Si è verificato un errore durante l'accesso alle materie")));
                            return Text("si è verificato un errore");
                          }
                          if (!snapshot.hasData) {
                            return Text("aspettando le materie");
                          }
                          final subjects = snapshot.data;
                          return DropdownButton(
                              // select subject
                              value: _subjectId,
                              items: subjects
                                  .map((subject) => DropdownMenuItem(
                                      value: subject["id"],
                                      child: Text(subject["name"])))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _subjectId = value;
                                });
                              });
                        }),
                    TextField(
                      controller: _noteTitle,
                      decoration: InputDecoration(labelText: "Titolo appunto"),
                    ),
                    FlatButton(
                        onPressed: () {
                          try {
                            editNote(note["note_id"], '${note['subject_id']}',
                                widget.jwt, data: {
                              "new_subject_id": _subjectId,
                              "title": _noteTitle.text
                            });
                          } catch (e) {
                            print("Error: $e");
                            showDialog(
                                context: context,
                                child: AlertDialog(
                                    title: Text("Errore"),
                                    content: Text("$e")));
                          }
                        },
                        child: Text("Modifica valori appunto")),
                    Divider(),
                    FlatButton(
                        color: Colors.redAccent,
                        textColor: Colors.white,
                        onPressed: () {
                          deleteNote(note["note_id"], '${note["subject_id"]}',
                              widget.jwt);
                        },
                        child: _deletionInProgress
                            ? CircularProgressIndicator()
                            : Text("Non mi piace questo file, ELIMINA ORA"))
                  ],
                ))));
  }
}

class UsersList extends StatelessWidget {
  UsersList(this.jwt);
  final String jwt;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: backend.getUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          var users = snapshot.data;
          return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, i) => ListTile(
                  leading: Icon(Icons.person),
                  title: Text('${users[i]["name"]} ${users[i]["surname"]}'),
                  onTap: () {
                    Navigator.pushNamed(context, "/profile",
                        arguments: [ProvidedArg.data, users[i]]);
                  }));
        });
  }
}
