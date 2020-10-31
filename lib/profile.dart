import 'package:appunti_web_frontend/io.dart';
import 'package:appunti_web_frontend/note.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart' show launch;

import 'platform.dart' show tokenStorage;
import 'utils.dart';
import 'errors.dart' as errors;
import 'backend.dart' as backend;
import 'edit.dart' show LogoutButton;

class ProfilePage extends StatelessWidget {
  ProfilePage(this.uid);

  final String uid;

  @override
  Widget build(BuildContext context) {
    var userFuture;
    userFuture = backend.getUser(uid);

    return Scaffold(
        appBar: AppBar(
            title: SelectableText("Pagina dell'autore"),
            actions: getUserIdOrNull(tokenStorage) == null
                ? null
                : [LogoutButton()]),
        body: FutureBuilder(
            future: userFuture,
            builder: (context, snapshot) {
              final backend.User user = snapshot.data;
              // TODO: better error handling
              if (snapshot.hasError) {
                showDialog(
                    context: context,
                    child: AlertDialog(
                        title: SelectableText(
                            "Si è verificato un errore durante l'accesso ai dati dell'utente")));
                return SelectableText("Si è verificato un errore");
              }
              if (!snapshot.hasData) return CircularProgressIndicator();
              return ProfilePageBody(
                  user, backend.getNotesFirstPage(author: user.id));
            }));
  }
}

class ProfilePageBody extends StatefulWidget {
  ProfilePageBody(this.user, this.firstNotePage);

  final backend.User user;
  final Future<Tuple2<int, List<backend.Note>>> firstNotePage;

  @override
  _ProfilePageBodyState createState() => _ProfilePageBodyState();
}

class _ProfilePageBodyState extends State<ProfilePageBody> {
  List<Future<List<backend.Note>>> otherNotePages = [];

  @override
  void initState() {
    super.initState();
    widget.firstNotePage.then((value) {
      for (int i = 1; i < value.item1; i++) {
        otherNotePages.add(backend.getNotes(i + 1, author: widget.user.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool canEdit;
    String token;
    try {
      token = getToken(tokenStorage);
      bool mod = isMod(token);
      canEdit = mod || getPayload(token)["id"] == widget.user.id;
    } catch (e) {
      print("errore $e");
      canEdit = false;
    }

    if (canEdit)
      print("can edit");
    else
      print("can't edit");
    return Center(
      child: Container(
        width: 900.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SelectableText(
                "Utente ${widget.user.name} ${widget.user.surname}",
                style: Theme.of(context).textTheme.headline4,
              ),
              SelectableText("Email: "),
              FlatButton(
                child: SelectableText(widget.user.email),
                onPressed: () {
                  launch("mailto:${widget.user.email}");
                },
              ),
              FlatButton(
                child: SelectableText(
                    "${widget.user.unimore_id}@studenti.unimore.it"),
                onPressed: () {
                  launch(
                      "mailto:${widget.user.unimore_id}@studenti.unimore.it");
                },
              ),
              if (canEdit)
                FlatButton(
                  child: SelectableText(
                    "Modifica profilo",
                  ),
                  onPressed: () {
                    goToRouteAsap(
                      context,
                      "/editProfile/${widget.user.id}",
                    );
                  },
                ),
              FutureBuilder<Tuple2<int, List<backend.Note>>>(
                  future: widget.firstNotePage,
                  builder: (context, firstSnapshot) {
                    if (firstSnapshot.connectionState ==
                        ConnectionState.waiting)
                      return Container(
                          height: 50.0,
                          width: 50.0,
                          child: Center(child: CircularProgressIndicator()));
                    return Expanded(
                      child: ListView.builder(
                          itemCount: firstSnapshot.data.item1,
                          itemBuilder: (context, p) {
                            return FutureBuilder<List<backend.Note>>(
                                future: p == 0
                                    ? Future.value(firstSnapshot.data.item2)
                                    : otherNotePages[p - 1],
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting)
                                    return Container(
                                        height: 50.0,
                                        width: 50.0,
                                        child: Center(
                                            child:
                                                CircularProgressIndicator()));
                                  final List<backend.Note> notes =
                                      snapshot.data;
                                  if (notes == []) {
                                    return Divider();
                                  }
                                  return Column(
                                      children: notes.map((note) {
                                    var date = DateTime.parse(note.uploaded_at)
                                        .toLocal();
                                    return ListTile(
                                        leading: Icon(Icons.note),
                                        title: Text(note.title),
                                        trailing: Text(
                                            "${date.day}/${date.month}${date.year}"),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NotePage(
                                                          "${note.subject_id}",
                                                          note.note_id,
                                                          noteDataFuture:
                                                              backend.getNote(
                                                            "${note.subject_id}",
                                                            note.note_id,
                                                          ))));
                                        });
                                  }).toList());
                                });
                          }),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  EditProfilePage(this.userId);

  final String userId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: backend.getUser(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          showDialog(
              context: context,
              child: AlertDialog(
                  title: SelectableText("Si è verificato un errore")));
          print(snapshot.error);
        }
        if (!snapshot.hasData) return CircularProgressIndicator();
        return EditProfile(snapshot.data);
      },
    );
  }
}

class EditProfile extends StatefulWidget {
  EditProfile(this.userData);

  final Map userData;

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool _deletionInProgress;
  TextEditingController _userName;
  TextEditingController _userSurname;
  TextEditingController _userUnimoreId;
  bool _userIsAdmin;
  String _jwt;
  bool isAdmin;

  @override
  initState() {
    super.initState();
    _setFieldsToDefault();
    _jwt = getToken(tokenStorage);
    isAdmin = isMod(_jwt);
  }

  void _setFieldsToDefault() {
    _userName = TextEditingController(text: widget.userData["name"]);
    _userSurname = TextEditingController(text: widget.userData["surname"]);
    _userUnimoreId = TextEditingController(text: widget.userData["unimore_id"]);
    _userIsAdmin = widget.userData["admin"] == 1;
    _deletionInProgress = false;
  }

  Future<void> editProfile(String id, String jwt, {@required Map data}) async {
    try {
      await backend.editProfile(id, jwt, data);
      Navigator.pop(context);
    } on errors.BackendError {
      LoginManager.logOut(tokenStorage);
      Navigator.pushReplacementNamed(context, "/login");
      showDialog(
          context: context,
          child: AlertDialog(
            title: Text("La sessione potrebbe essere scaduta o corrotta"),
            content: SelectableText("Verrai riportato alla pagina di accesso"),
          ));
    } catch (_) {
      LoginManager.logOut(tokenStorage);
      Navigator.pushReplacementNamed(context, "/login");
      showDialog(
          context: context,
          child: AlertDialog(
            title: Text("Si è verificato un errore sconosciuto"),
            content: SelectableText("Verrai riportato alla pagina di accesso"),
          ));
    }
  }

  Future<void> deleteUser(int id, String jwt) async {
    setState(() {
      _deletionInProgress = true;
    });

    try {
      await backend.deleteUser(id, jwt);
      Navigator.pop(context);
    } on errors.BackendError catch (_) {
      LoginManager.logOut(tokenStorage);
      showDialog(
          context: context,
          child: AlertDialog(
            title: Text("La sessione potrebbe essere scaduta o corrotta"),
            content: SelectableText("Verrai riportato alla pagina di accesso"),
          ));
      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      LoginManager.logOut(tokenStorage);
      showDialog(
          context: context,
          child: AlertDialog(
            title: Text("Si è verificato un errore sconosciuto"),
            content: SelectableText("Verrai riportato alla pagina di accesso"),
          ));
      Navigator.pushReplacementNamed(context, "/login");
    } finally {
      setState(() {
        _deletionInProgress = false;
      });
    }
  }

  void setUserState(bool admin) {
    setState(() {
      _userIsAdmin = admin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: SelectableText("Modifica dati utente")),
      body: Center(
        child: Container(
          width: 900.0,
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton(
                  onPressed: () {
                    setState(_setFieldsToDefault);
                  },
                  child: SelectableText("Resetta campi")),
              TextField(
                controller: _userName,
                decoration: InputDecoration(labelText: "Nome"),
              ),
              TextField(
                controller: _userSurname,
                decoration: InputDecoration(labelText: "Cognome"),
              ),
              TextField(
                controller: _userUnimoreId,
                decoration: InputDecoration(labelText: "ID Unimore"),
              ),
              if (isAdmin)
                Checkbox(value: _userIsAdmin, onChanged: setUserState),
              FlatButton(
                  onPressed: () {
                    editProfile(widget.userData["id"], _jwt,
                        data: isAdmin
                            ? {
                                "unimore_id": _userUnimoreId.text,
                                "name": _userName.text,
                                "surname": _userSurname.text,
                                "admin": _userIsAdmin == true ? "1" : "0"
                              }
                            : {
                                "unimore_id": _userUnimoreId.text,
                                "name": _userName.text,
                                "surname": _userSurname.text
                              });
                  },
                  child: SelectableText("Modifica profilo")),
              Divider(),
              FlatButton(
                  color: Colors.redAccent,
                  textColor: Colors.white,
                  onPressed: () {
                    deleteUser(widget.userData["id"], _jwt);
                  },
                  child: _deletionInProgress
                      ? CircularProgressIndicator()
                      : SelectableText("ELIMINA UTENTE"))
            ],
          ),
        ),
      ),
    );
  }
}
