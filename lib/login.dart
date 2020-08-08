import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';


class LoginPage extends StatelessWidget {
  LoginPage();

  @override
  Widget build(context) =>
    Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            color: Colors.lightBlue,
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

  @override
  Widget build(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text("Welcome to the app, please log in"),
        TextField(
          controller: _usernameController,
            decoration: InputDecoration(
                labelText: "username"
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
            color: Colors.blue,
            child: Text("Log in", style: TextStyle(color: Colors.white)),
            onPressed: () {}
        )
      ]
    );
  }
}