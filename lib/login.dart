import 'package:appunti_web_frontend/consts.dart';
import 'package:appunti_web_frontend/io.dart';
import 'package:appunti_web_frontend/platform.dart';
import 'package:flutter/material.dart';

import 'errors.dart';

class LoginPage extends StatelessWidget {
  LoginPage();

  @override
  Widget build(context) => Scaffold(
      appBar: AppBar(title: SelectableText("Accedi")),
      body: LayoutBuilder(builder: (context, constraints) {
        return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            padding: constraints.maxWidth < 500
                ? EdgeInsets.zero
                : const EdgeInsets.all(30.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 30.0, horizontal: 25.0),
                constraints: BoxConstraints(
                  maxWidth: 500,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: LoginControls(),
              ),
            ));
      }));
}

class LoginControls extends StatefulWidget {
  @override
  _LoginControlsState createState() => _LoginControlsState();
}

class _LoginControlsState extends State<LoginControls> {
  TextEditingController _emailController;
  TextEditingController _passwordController;
  bool _loggingIn;

  @override
  initState() {
    super.initState();

    _loggingIn = false;
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  Future<bool> _logIn(String email, String password) async =>
      await LoginManager(tokenStorage).logIn(email, password);

  void _signIn(String email, String password) async {
    if (email == null || password == null) {
      showDialog(
          context: context,
          child: AlertDialog(
            title:
                SelectableText("Inserisci un indirizzo email e una password!"),
          ));
      return;
    }
    setState(() {
      _loggingIn = true;
    });
    String errorString = null;
    try {
      bool success = await _logIn(email, password);

      if (success)
        Navigator.pushReplacementNamed(context, "/edit");
      else
        errorString = "Si è verificato un errore sconosciuto";
    } on BackendError catch (e) {
      if (e.code == GENERIC_ERROR)
        errorString = "Si è verificato un errore sconosciuto";
      else if (e.code == INVALID_CREDENTIALS)
        errorString = "Credenziali sbagliate";
    } on NetworkError {
      errorString =
          "Si è verificato un errore durante la connessione al server";
    } catch (e) {
      errorString = "Si è verificato un errore sconosciuto $e";
    } finally {
      setState(() {
        _loggingIn = false;
      });
    }
    if (errorString != null) {
      showDialog(
          context: context,
          child: AlertDialog(
            title: SelectableText(errorString),
          ));
    }
  }

  @override
  Widget build(context) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      SelectableText("Bentornato, accedi."),
      TextField(
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          controller: _emailController,
          decoration: InputDecoration(labelText: "email")),
      TextField(
          onSubmitted: (String pass) => _signIn(_emailController.text, pass),
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(labelText: "password")),
      _loggingIn
          ? CircularProgressIndicator()
          : RaisedButton(
              color: Theme.of(context).primaryColor,
              child: Text("Accedi", style: TextStyle(color: Colors.white)),
              onPressed: () =>
                  _signIn(_emailController.text, _passwordController.text)),
      SelectableText("oppure"),
      RaisedButton(
          color: Theme.of(context).primaryColor,
          child: Text("Registrati", style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.pushNamed(context, "/signup");
          }),
    ]);
  }
}

class SignupPage extends StatelessWidget {
  SignupPage();

  @override
  Widget build(context) => Scaffold(
      appBar: AppBar(title: SelectableText("Registrati")),
      body: LayoutBuilder(builder: (context, constraints) {
        return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            padding: constraints.maxWidth < 500
                ? EdgeInsets.zero
                : const EdgeInsets.all(30.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 30.0, horizontal: 25.0),
                constraints: BoxConstraints(
                  maxWidth: 500,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: SignupControls(),
              ),
            ));
      }));
}

class SignupControls extends StatefulWidget {
  @override
  _SignupControlsState createState() => _SignupControlsState();
}

class _SignupControlsState extends State<SignupControls> {
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _idController;
  TextEditingController _nameController;
  TextEditingController _surnameController;
  TextEditingController _passwordConfirmationController;
  bool _signingUp;
  bool _badEmail;
  bool _badPassword;
  bool _diffPass;

  Future<void> passwordsDontMatch() async {
    setState(() {
      _diffPass = true;
    });

    while (_passwordConfirmationController.text != _passwordController.text) {
      await Future.delayed(Duration(milliseconds: 500));
    }

    setState(() {
      _diffPass = false;
    });
  }

  @override
  initState() {
    super.initState();

    _badEmail = false;
    _badPassword = false;
    _signingUp = false;
    _diffPass = false;

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordConfirmationController = TextEditingController();
    _idController = TextEditingController();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
  }

  Future<bool> _signUp(
          {String email,
          String password,
          String unimoreId,
          String name,
          String surname}) async =>
      await LoginManager(tokenStorage)
          .signUp(email, password, unimoreId, name, surname);

  @override
  Widget build(context) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      SelectableText("Benvenuto, registrati."),
      TextField(
          keyboardType: TextInputType.emailAddress,
          controller: _emailController,
          decoration: InputDecoration(
            labelText: "Indirizzo e-mail",
            errorText: _badEmail ? "Email non valida" : null,
          )),
      TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "password",
            errorText: _badPassword ? "Password non valida" : null,
          )),
      TextField(
          controller: _passwordConfirmationController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "password",
            errorText: _diffPass ? "Le password non corrispondono" : null,
          )),
      TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: "Nome",
          )),
      TextField(
          controller: _surnameController,
          decoration: InputDecoration(labelText: "Cognome")),
      TextField(
          keyboardType: TextInputType.number,
          controller: _idController,
          decoration: InputDecoration(labelText: "ID esse3 unimore")),
      _signingUp
          ? CircularProgressIndicator()
          : RaisedButton(
              color: Theme.of(context).primaryColor,
              child: Text("Registrati", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                if (_passwordConfirmationController.text !=
                    _passwordController.text) {
                  passwordsDontMatch();
                  return;
                }
                if (!RegExp(emailRegex).hasMatch(_emailController.text)) {
                  setState(() {
                    _badEmail = true;
                  });
                  return;
                }
                if (!RegExp(passwordRegex).hasMatch(_passwordController.text)) {
                  setState(() {
                    _badPassword = true;
                  });
                  return;
                }
                if (_idController.text == null) {
                  showDialog(
                      context: context,
                      child: AlertDialog(
                        title: SelectableText(
                            "Ci serve un UNIMORE ID per verificare che tu sia uno studente."),
                      ));
                  return;
                }
                if (_nameController.text == null ||
                    _surnameController.text == null) {
                  showDialog(
                      context: context,
                      child: AlertDialog(
                        title:
                            SelectableText("Inserisci un nome ed un cognome"),
                      ));
                }
                setState(() {
                  _badEmail = false;
                  _signingUp = true;
                });
                String errorString = null;
                try {
                  bool success = await _signUp(
                      name: _nameController.text,
                      surname: _surnameController.text,
                      email: _emailController.text,
                      unimoreId: _idController.text,
                      password: _passwordController.text);

                  if (success)
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VerificationPage()));
                  else
                    errorString = "Si è verificato un errore sconosciuto";
                } on BackendError catch (e) {
                  if (e.code == GENERIC_ERROR)
                    errorString = "Si è verificato un errore sconosciuto";
                  else if (e.code == USER_EXISTS)
                    errorString =
                        "Esiste già un utente registrato con quell'indirizzo email";
                } on NetworkError {
                  errorString =
                      "Si è verificato un errore durante la connessione al server";
                } catch (e) {
                  errorString = "Si è verificato un errore sconosciuto";
                } finally {
                  setState(() {
                    _signingUp = false;
                  });
                }
                if (errorString != null) {
                  showDialog(
                      context: context,
                      child: AlertDialog(
                        title: SelectableText(errorString),
                      ));
                }
              }),
    ]);
  }
}

class VerificationPage extends StatelessWidget {
  @override
  Widget build(context) => Scaffold(
          body: Center(
              child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SelectableText(
              "La registrazione è stata effettuata con successo, controlla la mail unimore per verificarla prima di provare a caricare appunti."),
          FlatButton(
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            child: Text("Accedi"),
            onPressed: () => Navigator.popAndPushNamed(context, "/login"),
          )
        ],
      )));
}
