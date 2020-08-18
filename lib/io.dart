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
  static Future<String> readJson(String name) {throw Error();}
  static Future<void> writeJson(String name, String value) {throw Error();}
  static Future<void> delete(String name) {throw Error();}
}

class LocalStorageTokenStorage implements TokenStorage {
  @override
  static Future<String> readJson(String name) async {
    String val = window.localStorage[name];
    if(val == null) {
      throw Exception("there's nothing");
    }
    else {
      return val;
    }
  }
  
  @override
  static Future<void> writeJson(String name, String value) async {
    window.localStorage[name] = value;
  }

  static Future<void> delete(String name) async {
    window.localStorage.remove(name);
  }
  
}