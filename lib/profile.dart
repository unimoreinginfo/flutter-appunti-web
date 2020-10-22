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
              return ProfilePageBody(user);
            }));
  }
}

class ProfilePageBody extends StatelessWidget {
  ProfilePageBody(this.user);

  final backend.User user;

  @override
  Widget build(BuildContext context) {
    bool canEdit;
    String token;
    try {
      token = getToken(tokenStorage);
      bool mod = isMod(token);
      canEdit = mod || getPayload(token)["id"] == user.id;
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
                "Utente ${user.name} ${user.surname}",
                style: Theme.of(context).textTheme.headline4,
              ),
              SelectableText("Email: "),
              FlatButton(
                child: SelectableText(user.email),
                onPressed: () {
                  launch("mailto:${user.email}");
                },
              ),
              FlatButton(
                child: SelectableText("${user.unimore_id}@studenti.unimore.it"),
                onPressed: () {
                  launch("mailto:${user.unimore_id}@studenti.unimore.it");
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
                      "/editProfile/${user.id}",
                    );
                  },
                ),
              FutureBuilder<Tuple2<int, List<backend.Note>>>(
                  future: backend.getNotesFirstPage(author: user.id),
                  builder: (context, bigSnapshot) {
                    if (bigSnapshot.connectionState == ConnectionState.waiting)
                      return CircularProgressIndicator();
                    return ListView.builder(
                        itemCount: bigSnapshot.data.item1,
                        itemBuilder: (context, p) {
                          return FutureBuilder(
                              future: p == 0
                                  ? bigSnapshot.data.item2
                                  : backend.getNotes(p + 1, author: user.id),
                              builder: (context, snapshot) {
                                // TODO: better error handling
                                if (snapshot.hasError) {
                                  doItAsap(
                                      context,
                                      (context) => showDialog(
                                          context: context,
                                          child: AlertDialog(
                                              title: SelectableText(
                                                  "Si è verificato un errore durante l'accesso agli appunti dell'utente"))));
                                  return SelectableText(
                                      "Si è verificato un errore");
                                }
                                if (!snapshot.hasData)
                                  return CircularProgressIndicator();
                                final List<backend.Note> notes = snapshot.data;
                                return Container(
                                  height: MediaQuery.of(context).size.height *
                                      70 /
                                      100,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: notes.length,
                                      itemBuilder: (context, i) {
                                        print(
                                            "creando nota $i (${notes[i].title})");
                                        var date = DateTime.parse(
                                            notes[i].uploaded_at);
                                        return ListTile(
                                            leading: Icon(Icons.note),
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          NotePage(
                                                              "${notes[i].subject_id}",
                                                              notes[i].note_id,
                                                              noteDataFuture:
                                                                  backend
                                                                      .getNote(
                                                                "${notes[i].subject_id}",
                                                                notes[i]
                                                                    .note_id,
                                                              ))));
                                            },
                                            trailing: SelectableText(
                                                "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}"),
                                            title:
                                                SelectableText(notes[i].title));
                                      }),
                                );
                              });
                        });
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
