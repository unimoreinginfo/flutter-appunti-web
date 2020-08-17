import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'edit.dart';

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

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  void accedi(String username, String password) {
    // TODO: implementa accedi
    
  }

  void registra(String username, String password) {
    // TODO: implementa registra
    
  }

  @override
  Widget build(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text("Signore gentilissimo, prego acceda"),
        TextField(
          controller: _usernameController,
            decoration: InputDecoration(
                labelText: "nome utente/email/numero di telefono"
            )
        ),
        TextField(
          controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
                labelText: "password"
            )
        ),
        Column(
          children: [
            RaisedButton(
              color: Theme.of(context).primaryColor,
              child: Text("Accedi", style: TextStyle(color: Colors.white)),
              onPressed: () {
                accedi(_usernameController.text, _usernameController.text);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPage()
                  )
                );
              }
            ),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              child: Text("Registrati", style: TextStyle(color: Colors.white)),
              onPressed: () {
                registra(_usernameController.text, _usernameController.text);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerificationPage()
                  )
                );
              }
            ),
          ],
        )
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
            FlatButton(child: Text("Accedi"), onPressed:() => Navigator.popAndPushNamed(context, "/login"),)
          ],
        )
      )
    );
}