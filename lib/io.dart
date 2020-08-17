import 'dart:html';

import 'package:http/http.dart';

bool isLoggedIn(TokenStorage storage) => false;

class LoginManager {
  LoginManager(this.client);

  BaseClient client;

  Future<String> logIn(String username, String password) {
    // TODO: implement logIn
    throw UnimplementedError();
  }

  Future<String> signUp(String username, String password) {
    // TODO: implement signUp
    throw UnimplementedError();
  }
}

abstract class TokenStorage {
  Future<String> readJson(String name);
  Future<void> writeJson(String name, String value);
  Future<void> delete(String name);
}

class LocalStorageTokenStorage implements TokenStorage {
  @override
  Future<String> readJson(String name) async {
    String val = window.localStorage[name];
    if(val == null) {
      throw Exception("there's nothing");
    }
    else {
      return val;
    }
  }
  
  @override
  Future<void> writeJson(String name, String value) async {
    window.localStorage[name] = value;
  }

  Future<void> delete(String name) async {
    window.localStorage.remove(name);
  }
  
}