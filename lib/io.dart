import 'dart:convert' show json, base64, ascii;
import 'dart:html';

import 'consts.dart' show baseUrl;
import 'errors.dart';
import 'package:http/http.dart';


/// Get payload from the base64 JWT token string
Map getPayload(String token) => json.decode(
  ascii.decode(
    base64.decode(base64.normalize(token.split(".")[1]))
  )
);

/// Get the token, however we're supposed to do that
Future<String> getToken(TokenStorage storage) async =>
  await storage.readJson("token");

// TODO: implement refreshTokenStillValid
Future<bool> refreshTokenStillValid(BaseClient client) => Future.value(true);

Future<bool> isMod(String token) async {
  // we suppose the user is logged in
  if(getPayload(token)["isAdmin"] == true) return true;
  else return false;

}


/// We call this class for login purposes so that we are at least
/// a tiny little bit testable.
class LoginManager {
  LoginManager(this.client, this.tokenStorage);

  BaseClient client;
  TokenStorage tokenStorage;

  Future<String> logIn(String email, String password) async {
    var res = await client.post(
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

    return resBody["auth_token"];
  }

  Future<bool> signUp(String email, String password, String unimoreId, String name, String surname) {
    // TODO: implement signUp, waiting for backend progress
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