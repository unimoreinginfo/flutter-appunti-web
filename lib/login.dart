import 'package:appunti_web_frontend/consts.dart';
import 'package:appunti_web_frontend/platform.dart';
import 'package:flutter/material.dart';

import 'dart:convert' show json;
import 'edit.dart';
import 'errors.dart';

class LoginPage extends StatelessWidget {
  LoginPage();

  @override
  Widget build(context) =>
    Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            padding: constraints.maxWidth < 500 ? EdgeInsets.zero : const EdgeInsets.all(30.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 30.0, horizontal: 25.0
                ),
                constraints: BoxConstraints(
                  maxWidth: 500,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: LoginControls(),  
              ),
            )
          );
        }
      )
   );
}

class LoginControls extends StatelessWidget {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  Future _logIn(String email, String password) async {
    var res = await httpClient.post(
      "$baseUrl/auth/login",
      body: {
        "email": email,
        "password": password
      }
    );

    if(res.statusCode == INVALID_CREDENTIALS) throw InvalidCredentialsError();
    if(res.statusCode == SERVER_DOWN) throw ServerError();


    Map resBody = json.decode(res.body);

    tokenStorage.writeJson("token", resBody["auth_token"]);
  }

  @override
  Widget build(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        RaisedButton(
          color: Theme.of(context).primaryColor,
          child: Text("Registrati", style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.pushNamed(context, "/signup");
          }
        ),
        Text("oppure"),
        TextField(
          controller: _emailController,
            decoration: InputDecoration(
                labelText: "email"
            )
        ),
        TextField(
          controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
                labelText: "password"
            )
        ),
        RaisedButton(
          color: Theme.of(context).primaryColor,
          child: Text("Accedi", style: TextStyle(color: Colors.white)),
          onPressed: () {
            String errorString = null;
            try {
              _logIn(_emailController.text, _emailController.text);
            } on InvalidCredentialsError {
              errorString = "Le credenziali inserite sono sbagliate";
            } on NetworkError {
              errorString = "Si è verificato un errore durante la connessione al server";
            } catch (e) {
              errorString = "Si è verificato un errore sconosciuto";
            } finally {
              if(errorString != null) {
                showDialog(
                  context: context,
                  child: AlertDialog(
                    title: Text(errorString),
                  )
                );
              }
              else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPage()
                  )
                );
              }
            }
            
          }
        ),
      ]
    );
  }
}


class SignupPage extends StatelessWidget {
  SignupPage();

  @override
  Widget build(context) =>
    Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            padding: constraints.maxWidth < 500 ? EdgeInsets.zero : const EdgeInsets.all(30.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 30.0, horizontal: 25.0
                ),
                constraints: BoxConstraints(
                  maxWidth: 500,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: SignupControls(),  
              ),
            )
          );
        }
      )
   );
}

class SignupControls extends StatelessWidget {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  
  void _signUp() {
    // TODO: implement logIn
    
  }

  @override
  Widget build(context) {
    return ListView(
      children: [
        Text("Registrazione"),
        TextField(
          controller: _emailController,
            decoration: InputDecoration(
                labelText: "Indirizzo e-mail"
            )
        ),
        TextField(
          controller: _nameController,
            decoration: InputDecoration(
                labelText: "Nome"
            )
        ),
        TextField(
          controller: _surnameController,
            decoration: InputDecoration(
                labelText: "Cognome"
            )
        ),
        TextField(
          controller: _idController,
            decoration: InputDecoration(
                labelText: "ID esse3 unimore"
            )
        ),
        TextField(
          controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
                labelText: "password"
            )
        ),
        RaisedButton(
          color: Theme.of(context).primaryColor,
          child: Text("Registrati", style: TextStyle(color: Colors.white)),
          onPressed: () {
            // TODO: verify email
            _signUp();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationPage()
              )
            );
          }
        ),
      ]
    );
  }
}
class VerificationPage extends StatelessWidget {
  @override
  Widget build(context) =>
    Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Dovresti aver ricevuto la mail di conferma, premi il link nella mail e poi accedi col tasto qua sotto"),
            FlatButton(color: Theme.of(context).primaryColor, textColor: Colors.white, child: Text("Accedi"), onPressed:() => Navigator.popAndPushNamed(context, "/login"),)
          ],
        )
      )
    );
}