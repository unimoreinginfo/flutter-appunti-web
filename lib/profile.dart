import 'package:appunti_web_frontend/io.dart';
import 'package:appunti_web_frontend/note.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show launch;

import 'platform.dart' show tokenStorage;
import 'utils.dart';
import 'errors.dart' as errors;
import 'backend.dart' as backend;
import 'edit.dart' show LogoutButton;

class ProfilePage extends StatelessWidget {
  ProfilePage(this.uid, {this.userData = null});

  final String uid;
  final Map userData;

  @override
  Widget build(BuildContext context) {
    var userFuture;
    if (userData == null) userFuture = backend.getUser(uid);
    final notesFuture = backend.getNotes(author: uid);

    return Scaffold(
      appBar: AppBar(
          title: Text("Pagina dell'autore"),
          actions:
              getUserIdOrNull(tokenStorage) == null ? null : [LogoutButton()]),
      body: userData == null
          ? FutureBuilder(
              future: userFuture,
              builder: (context, snapshot) {
                final Map user = snapshot.data;
                // TODO: better error handling
                if (snapshot.hasError) {
                  showDialog(
                      context: context,
                      child: AlertDialog(
                          title: Text(
                              "Si è verificato un errore durante l'accesso ai dati dell'utente")));
                  return Text("Si è verificato un errore");
                }
                if (!snapshot.hasData) return CircularProgressIndicator();
                return ProfilePageBody(user, notesFuture);
              })
          : ProfilePageBody(userData, notesFuture),
    );
  }
}

class ProfilePageBody extends StatelessWidget {
  ProfilePageBody(this.user, this.notesFuture);

  final Map user;
  final Future<List<Map>> notesFuture;

  @override
  Widget build(BuildContext context) {
    bool canEdit;
    String token;
    try {
      token = getToken(tokenStorage);
      bool mod = isMod(token);
      canEdit = mod || getPayload(token)["id"] == user["id"];
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
              Text(
                "Utente ${user["name"]} ${user["surname"]}",
                style: Theme.of(context).textTheme.headline4,
              ),
              Text("Email: "),
              FlatButton(
                child: Text(user["email"]),
                onPressed: () {
                  launch("mailto:${user["email"]}");
                },
              ),
              FlatButton(
                child: Text("${user["unimore_id"]}@studenti.unimore.it"),
                onPressed: () {
                  launch("mailto:${user["unimore_id"]}@studenti.unimore.it");
                },
              ),
              if (canEdit)
                FlatButton(
                  child: Text(
                    "Modifica profilo",
                  ),
                  onPressed: () {
                    goToRouteAsap(
                      context,
                      "/editProfile/${user['id']}",
                    );
                  },
                ),
              FutureBuilder(
                  future: notesFuture,
                  builder: (context, snapshot) {
                    // TODO: better error handling
                    if (snapshot.hasError) {
                      doItAsap(
                          context,
                          (context) => showDialog(
                              context: context,
                              child: AlertDialog(
                                  title: Text(
                                      "Si è verificato un errore durante l'accesso agli appunti dell'utente"))));
                      return Text("Si è verificato un errore");
                    }
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    final List<Map<String, String>> notes = snapshot.data;
                    return Container(
                      height: MediaQuery.of(context).size.height * 70 / 100,
                      child: ListView.builder(
                          itemCount: notes.length,
                          itemBuilder: (context, i) {
                            print("creando nota $i (${notes[i]["title"]})");
                            var date = DateTime.parse(notes[i]["uploaded_at"]);
                            return ListTile(
                                leading: Icon(Icons.note),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => NotePage(
                                              "${notes[i]["subject_id"]}",
                                              notes[i]["note_id"],
                                              noteDataFuture: backend.getNote(
                                                "${notes[i]["subject_id"]}",
                                                notes[i]["note_id"],
                                              ))));
                                },
                                trailing: Text(
                                    "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}"),
                                title: Text(notes[i]["title"]));
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
        if (!snapshot.hasData) return CircularProgressIndicator();
        return EditProfilePage(snapshot.data);
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
  String _jwt;

  @override
  initState() {
    super.initState();
    _setFieldsToDefault();
    _jwt = getToken(tokenStorage);
  }

  void _setFieldsToDefault() {
    _userName = TextEditingController(text: widget.userData["name"]);
    _userSurname = TextEditingController(text: widget.userData["surname"]);
    _userUnimoreId = TextEditingController(text: widget.userData["unimore_id"]);
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
            content: Text("Verrai riportato alla pagina di accesso"),
          ));
    } catch (_) {
      LoginManager.logOut(tokenStorage);
      Navigator.pushReplacementNamed(context, "/login");
      showDialog(
          context: context,
          child: AlertDialog(
            title: Text("Si è verificato un errore sconosciuto"),
            content: Text("Verrai riportato alla pagina di accesso"),
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
            content: Text("Verrai riportato alla pagina di accesso"),
          ));
      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      LoginManager.logOut(tokenStorage);
      showDialog(
          context: context,
          child: AlertDialog(
            title: Text("Si è verificato un errore sconosciuto"),
            content: Text("Verrai riportato alla pagina di accesso"),
          ));
      Navigator.pushReplacementNamed(context, "/login");
    } finally {
      setState(() {
        _deletionInProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Modifica dati utente")),
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
                  child: Text("Resetta campi")),
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
              FlatButton(
                  onPressed: () {
                    editProfile(widget.userData["id"], _jwt, data: {
                      "unimore_id": _userUnimoreId.text,
                      "name": _userName.text,
                      "surname": _userSurname.text
                    });
                  },
                  child: Text("Modifica profilo")),
              Divider(),
              FlatButton(
                  color: Colors.redAccent,
                  textColor: Colors.white,
                  onPressed: () {
                    deleteUser(widget.userData["id"], _jwt);
                  },
                  child: _deletionInProgress
                      ? CircularProgressIndicator()
                      : Text("ELIMINA UTENTE"))
            ],
          ),
        ),
      ),
    );
  }
}
