import 'package:appunti_web_frontend/io.dart';
import 'package:appunti_web_frontend/platform.dart';
import 'package:flutter/material.dart';

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
  
  Future<String> _logIn(String email, String password) async =>
    await LoginManager(httpClient, tokenStorage).logIn(email, password);

  @override
  Widget build(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        RaisedButton(
          color: Theme.of(context).primaryColor,
          child: Text("Registrati", style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/signup");
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
          onPressed: () async {
            String errorString = null;
            try {
              await _logIn(_emailController.text, _emailController.text);
            } on BackendError {
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
                Navigator.pushReplacementNamed(context, "/edit");
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

class SignupControls extends StatefulWidget {
  @override
  _SignupControlsState createState() => _SignupControlsState();
}

class _SignupControlsState extends State<SignupControls>  {
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _idController;
  TextEditingController _nameController;
  TextEditingController _surnameController;
  bool _signingUp;

  @override
  initState() {
    super.initState();

    _signingUp = false;
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _idController = TextEditingController();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
  }

  
  Future<bool> _signUp({String email, String password, String unimoreId, String name, String surname}) async =>
    await LoginManager(httpClient, tokenStorage).signUp(email, password, unimoreId, name, surname);

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
        _signingUp ? CircularProgressIndicator()
        : RaisedButton(
          color: Theme.of(context).primaryColor,
          child: Text("Registrati", style: TextStyle(color: Colors.white)),
          onPressed: () async {
            setState(() {
              _signingUp = true;
            });
            String errorString = null;
            try {
              bool success = await _signUp(
                name: _nameController.text,
                surname: _surnameController.text,
                email: _emailController.text,
                unimoreId: _idController.text,
                password: _passwordController.text
              );

              if(success)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerificationPage()
                  )
                );
              else errorString = "Si è verificato un errore sconosciuto";
            } on BackendError catch(e) {
              if(e.code == GENERIC_ERROR) errorString = "Si è veriricato un errore sconosciuto";
              if(e.code == USER_EXISTS) errorString = "Esiste già un utente registrato con quell'indirizzo email";
            } on NetworkError {
              errorString = "Si è verificato un errore durante la connessione al server";
            } catch(e) {
              errorString = "Si è verificato un errore sconosciuto";
            } finally {
              setState(() {
                _signingUp = false;
              }); 
            }
            if(errorString != null) {
              showDialog(
                context: context,
                child: AlertDialog(
                  title: Text(errorString),
                )
              );
            }
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
            Text("La registrazione è stata effettuata con successo, premi il tasto qui sotto per andare alla pagina di accesso"),
            FlatButton(color: Theme.of(context).primaryColor, textColor: Colors.white, child: Text("Accedi"), onPressed:() => Navigator.popAndPushNamed(context, "/login"),)
          ],
        )
      )
    );
}