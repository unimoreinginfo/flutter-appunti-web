import 'package:appunti_web_frontend/consts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart' show MultipartFile;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:mime/mime.dart' show lookupMimeType;

import 'io.dart';
import 'platform.dart' show tokenStorage;
import 'errors.dart' as errors;
import 'backend.dart' as backend;
import 'platform.dart' as platform;
import 'utils.dart';

const String fileTooBigTips =
    "Per ridurre le dimensioni del file, ti consigliamo di provare ad utilizzare qualche tipo di software di compressione. Per i PDF, ci sono molti strumenti online di compressione PDF, come quello di iLovePDF o quello di Adobe. Se non state caricando PDF potete usare software come 7-Zip per creare archivi compressi potendo scegliere tra molti formati ed algoritmi di compressione, a seconda delle dimensioni del file che volete comprimere e quindi del rapporto di compressione cercato, tenendo presente che il limite della piattaforma è di 20MB per ogni gruppo di appunti (non per ogni file, ma per ogni richiesta di caricamento file) che volete caricare.";

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
        title: SelectableText(
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
  int _subjectId = 1;
  List<MultipartFile> _files;
  bool _sendingNote;
  int _runningTotalSize;

  @override
  void initState() {
    super.initState();
    _files = [];
    _sendingNote = false;
    _runningTotalSize = 0;
  }

  void removeNote(int i) {
    setState(() {
      _files.removeAt(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 900.0,
        padding: EdgeInsets.all(15.0),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          FlatButton(
              onPressed: () {
                goToRouteAsap(context,
                    '/editProfile/${getPayload(widget.jwt)["user_id"]}');
              },
              child: SelectableText("voglio modificare il mio profilo")),
          FutureBuilder(
              future: backend.getSubjects(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  doItAsap(context, (context) {
                    showDialog(
                        context: context,
                        child: AlertDialog(
                            title: SelectableText(
                                "Si è verificato un errore durante l'accesso alle materie")));
                  });
                  return SelectableText("si è verificato un errore");
                }
                if (!snapshot.hasData) {
                  return SelectableText("aspettando le materie");
                }
                final subjects = snapshot.data as List<backend.Subject>;
                return DropdownButton(
                    value: _subjectId,
                    items: [
                      for (var subject in subjects)
                        DropdownMenuItem(
                            value: subject.id,
                            child: SelectableText(subject.name)),
                    ],
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
          for (var i = 0; i < _files.length; i++)
            Row(
              children: [
                SelectableText("Selezionato file ${_files[i].filename}"),
                IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      removeNote(i);
                    })
              ],
            ),
          FutureBuilder(
              future: backend.getSize(widget.jwt),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  if (snapshot.error is errors.ServerError) {
                    showDialog(
                        context: context,
                        child: AlertDialog(
                          title: SelectableText(
                              "Si è verificato un problema di connessione al server"),
                        ));
                    Navigator.pushNamed(context, "/");
                  }
                  if (snapshot.error is errors.BackendError) {
                    showDialog(
                        context: context,
                        child: AlertDialog(
                          title: SelectableText(
                              "Le credenziali sono scadute o corrotte"),
                        ));
                    LoginManager.logOut(tokenStorage);
                    Navigator.pushNamed(context, "/login");
                  }
                }
                if (!snapshot.hasData) return CircularProgressIndicator();

                backend.UserStorageStatus data = snapshot.data;
                return FlatButton(
                    onPressed: () async {
                      var res =
                          await FilePicker.platform.pickFiles(withData: true);
                      if (res != null && res.isSinglePick) {
                        if ((_runningTotalSize + res.files.single.size) >
                            20000) {
                          showDialog(
                              context: context,
                              child: AlertDialog(
                                title: SelectableText("Appunto troppo grande"),
                                content: SelectableText(fileTooBigTips),
                                actions: [
                                  FlatButton(
                                      onPressed: () {
                                        launch(
                                            "https://www.ilovepdf.com/compress_pdf");
                                      },
                                      child: SelectableText(
                                          "Compressione PDF iLovePDF")),
                                  FlatButton(
                                    onPressed: () {
                                      launch("https://www.7-zip.org/");
                                    },
                                    child: SelectableText("Home page 7-Zip"),
                                  )
                                ],
                              ));
                          return;
                        }
                        if ((_runningTotalSize + res.files.single.size) +
                                data.folder_size_kilobytes >
                            data.max_size_kilobytes) {
                          showDialog(
                              context: context,
                              child: AlertDialog(
                                title: SelectableText(
                                    "In totale ogni utente può caricare al massimo 2 GiB di appunti"),
                                content: SelectableText(
                                    "E tu, con questo file, saresti oltre il limite"),
                              ));
                          return;
                        }
                        var mimeType = lookupMimeType(res.files.single.name);
                        print("il file è $mimeType");
                        if (!allowedMimeTypes.contains(mimeType)) {
                          showDialog(
                              context: context,
                              child: AlertDialog(
                                title:
                                    SelectableText("Tipo di file non permesso"),
                                content: SelectableText(
                                    "Se stai cercando di caricare codice dovresti provare ad aggiungerlo nelle repo GitHub di unimoreinginfo."),
                                actions: [
                                  FlatButton(
                                      onPressed: () {
                                        launch(
                                            "https://github.com/unimoreinginfo");
                                      },
                                      child: SelectableText(
                                          "Vai al GitHub di unimoreinginfo"))
                                ],
                              ));
                          return;
                        }
                        String name = res.files.single.name
                            .split('/')
                            .last
                            .split('\\')
                            .last;
                        var bytes = res.files.single.bytes;

                        setState(() {
                          _runningTotalSize += res.files.single.size;
                          _files.add(MultipartFile.fromBytes(bytes,
                              filename: name,
                              contentType: MediaType.parse(mimeType)));
                        });
                      }
                    },
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: SelectableText("Aggiungi file"));
              }),
          if (_sendingNote)
            CircularProgressIndicator()
          else
            FlatButton(
                onPressed: () async {
                  setState(() {
                    _sendingNote = true;
                  });
                  try {
                    await backend.addNote(
                        widget.jwt, _title.text, "$_subjectId", _files);
                  } catch (e) {
                    setState(() {
                      _sendingNote = false;
                    });
                    showDialog(
                        context: context,
                        child: AlertDialog(
                          title: SelectableText("Si è verificato un errore"),
                          content: SelectableText("error: $e"),
                        ));
                    return;
                  }
                  Navigator.pushNamed(context, '/edit');
                  showDialog(
                      context: context,
                      child: AlertDialog(
                        title: SelectableText("Grazie mille."),
                      ));
                },
                color: Colors.green,
                textColor: Colors.white,
                child: SelectableText("Invia appunto"))
        ]),
      ),
    );
  }
}

class ModPage extends StatelessWidget {
  ModPage(this.jwt);

  final String jwt;

  Future<backend.User> getUser(uid) {
    var user = backend.getUser(uid);
    user.then((a) => print(a.toJson()));
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FlatButton(
          child: SelectableText(
              "Voglio aggiungere gli appunti come le persone normali"),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: SelectableText(
                              "Ci dia i suoi appunti, signor moderatore."),
                          actions: [LogoutButton()],
                        ),
                        body: PlebPage(jwt))));
          },
        ),
        FlatButton(
          child: SelectableText("Lista utenti"),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: SelectableText("Elenco degli utenti"),
                            actions: [LogoutButton()],
                          ),
                          body: UsersList(jwt),
                        )));
          },
        ),
        Expanded(
          child: ListView.builder(itemBuilder: (context, p) {
            return FutureBuilder<List>(
                future: backend.getNotes(p + 1),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final List<backend.Note> notes = snapshot.data;
                  return Column(
                      children: notes
                          .map((note) => ListTile(
                                leading: SelectableText(note.uploaded_at),
                                title: SelectableText(note.title),
                                subtitle: FutureBuilder(
                                    future: getUser(note.author_id),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData)
                                        return CircularProgressIndicator();
                                      final backend.User author = snapshot.data;
                                      return SelectableText(
                                          "${author.name} ${author.surname}<${author.email}, ${author.unimore_id}>");
                                    }),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            NoteEditPage(jwt, note))),
                              ))
                          .toList());
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
  final backend.Note note;

  @override
  _NoteEditPageState createState() => _NoteEditPageState(note);
}

class _NoteEditPageState extends State<NoteEditPage> {
  _NoteEditPageState(this.note);

  bool _deletionInProgress;
  TextEditingController _noteTitle;
  int _subjectId;
  backend.Note note;

  Future<List<backend.Subject>> _subjectsFuture;

  @override
  initState() {
    super.initState();
    _setFieldsToDefault();
    _subjectsFuture = backend.getSubjects();
  }

  void _setFieldsToDefault() {
    _noteTitle = TextEditingController(text: widget.note.title);
    _subjectId = note.subject_id;
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
            title: SelectableText(
                "La sessione potrebbe essere scaduta o corrotta"),
            content: SelectableText("Verrai riportato alla pagina di accesso"),
          ));
    } catch (e) {
      Navigator.pushReplacementNamed(context, "/edit");
      showDialog(
          context: context,
          child: AlertDialog(
            title: SelectableText("Si è verificato un errore sconosciuto"),
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
            title: SelectableText(
                "La sessione potrebbe essere scaduta o corrotta"),
            content: SelectableText("Verrai riportato alla pagina di accesso"),
          ));
    } catch (_) {
      Navigator.pushReplacementNamed(context, "/login");
      showDialog(
          context: context,
          child: AlertDialog(
            title: SelectableText("Si è verificato un errore sconosciuto"),
            content: SelectableText("Verrai riportato alla pagina di accesso"),
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
        appBar: AppBar(title: SelectableText("Modifica appunto")),
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
                        child: SelectableText("Resetta campi")),
                    FutureBuilder<List<backend.Subject>>(
                        future: _subjectsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            showDialog(
                                context: context,
                                child: AlertDialog(
                                    title: SelectableText(
                                        "Si è verificato un errore durante l'accesso alle materie")));
                            return SelectableText("si è verificato un errore");
                          }
                          if (!snapshot.hasData) {
                            return SelectableText("aspettando le materie");
                          }
                          final List<backend.Subject> subjects = snapshot.data;
                          return DropdownButton(
                              // select subject
                              value: _subjectId,
                              items: subjects
                                  .map((subject) => DropdownMenuItem(
                                      value: subject.id,
                                      child: SelectableText(subject.name)))
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
                            editNote(
                                note.note_id, '${note.subject_id}', widget.jwt,
                                data: {
                                  "new_subject_id": _subjectId,
                                  "title": _noteTitle.text
                                });
                          } catch (e) {
                            print("Error: $e");
                            showDialog(
                                context: context,
                                child: AlertDialog(
                                    title: SelectableText("Errore"),
                                    content: SelectableText("$e")));
                          }
                        },
                        child: SelectableText("Modifica valori appunto")),
                    Divider(),
                    FlatButton(
                        color: Colors.redAccent,
                        textColor: Colors.white,
                        onPressed: () {
                          deleteNote(
                              note.note_id, '${note.subject_id}', widget.jwt);
                        },
                        child: _deletionInProgress
                            ? CircularProgressIndicator()
                            : SelectableText(
                                "Non mi piace questo file, ELIMINA ORA"))
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
        future: backend.getUsers(jwt),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          var users = snapshot.data;
          return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, i) => ListTile(
                  leading: Icon(Icons.person),
                  title: SelectableText(
                      '${users[i]["name"]} ${users[i]["surname"]}'),
                  onTap: () {
                    Navigator.pushNamed(context, "/users/${users[i]['id']}");
                  }));
        });
  }
}
