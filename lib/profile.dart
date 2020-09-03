import 'package:appunti_web_frontend/io.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show launch;

import 'platform.dart' show httpClient, tokenStorage;
import 'consts.dart';
import 'utils.dart';
import 'errors.dart' as errors;
import 'backend.dart' as backend;


class ProfilePage extends StatelessWidget {
  ProfilePage(this.uid, {this.userData = null});

  final String uid;
  final Map userData;

  @override
  Widget build(BuildContext context) {  
    var userFuture; 
    if(userData == null) userFuture  = backend.getUser(uid, httpClient);
    final notesFuture = backend.getNotes(httpClient, author: uid);

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
    bool canEdit;
    String token;
    try {
      token = getToken(tokenStorage);
      bool mod = isMod(token);
      if(mod || getPayload(token)["id"] == user["id"]) canEdit = true;
      else canEdit = false;
    } catch(_) {
      canEdit = false;
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
              child: Text("${user["unimore_id"]}@studenti.unimore.it"),
              onPressed: () {launch("mailto:${user["unimore_id"]}@studenti.unimore.it");},
            )
          ],
        ),
        if(canEdit)
          FlatButton(child: Text("Modifica profilo",), onPressed: () {
            goToRouteAsap(context, "/editProfile", arguments: user);
          },),
        FutureBuilder(
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
                // TODO: far diventare listtile cliccabile ecc. ec., insomma fixare sta cosa
                return ListTile(title: Text(notes[i]["name"]));
              }
            );
          }
        )
      ],
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
    _userSurname = widget.userData["surname"];
    _userUnimoreId = widget.userData["unimore_id"];
    _deletionInProgress = false;
  }

  Future<void> editProfile(int id, String jwt, {@required Map data}) async {
    // TODO: handle more errors
    try {
      backend.editProfile(id, jwt, data, httpClient);
    }

    on errors.BackendError catch(e) {
      if(e.code == errors.INVALID_CREDENTIALS) {
        LoginManager.logOut(tokenStorage);
        showDialog(
          context: context,
          child: AlertDialog(
            title: Text("La sessione potrebbe essere scaduta o corrotta"),
            content: Text("Verrai riportato alla pagina di accesso"),
          )
        );
        Navigator.pushReplacementNamed(context, "/login");
      }
      return;
    }
  }

  Future<void> deleteUser(int id, String jwt) async {
  // TODO: what if this fails?
  // TODO:move out of here

    setState(() {_deletionInProgress = true;});

    var res = await httpClient.delete("$baseUrl/users/$id", headers: {"Authorization": "Bearer $jwt"});

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
        TextField(
          controller: _userName,
          decoration: InputDecoration(
            labelText: "Nome"
          ),
        ),
        TextField(
          controller: _userSurname,
          decoration: InputDecoration(
            labelText: "Cognome"
          ),
        ),
        TextField(
          controller: _userUnimoreId,
          decoration: InputDecoration(
            labelText: "ID Unimore"
          ),
        ),
        FlatButton(
          onPressed: () {
            editProfile(widget.userData["id"], _jwt, data: {
              "unimore_id": _userUnimoreId.text,
              "name": _userName.text,
              "surname": _userSurname.text
            });
          },
          child: Text("Modifica profilo")
        ),
        Divider(),
        FlatButton(
          color: Colors.redAccent,
          textColor: Colors.white,
          onPressed: () {deleteUser(widget.userData["id"], _jwt);},
          child: _deletionInProgress ? CircularProgressIndicator() : Text("ELIMINA UTENTE")
        )
      ],
    );
  }
}


