import 'dart:convert' show json, base64, ascii;
import 'dart:html';

import 'package:http/http.dart';

Map getPayload(String token) => json.decode(
  ascii.decode(
    base64.decode(base64.normalize(token.split(".")[1]))
  )
);



Future<bool> isLoggedIn(TokenStorage storage) async {
  try {
    await storage.readJson("token");
    return true;
  } catch(e) {
    return false;
  }
}

Future<bool> isMod(TokenStorage storage) async {
  // we suppose the user is logged in
  if(getPayload(await storage.readJson("token"))["isAdmin"] == true) return true;
  else return false;

}

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
  /// throws `Exception` if it can't read the thing
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

  @override
  Future<void> delete(String name) async {
    window.localStorage.remove(name);
  }
  
}