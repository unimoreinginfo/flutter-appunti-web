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

void updateToken(TokenStorage storage, String newTok) {
  storage.writeJson("token", newTok);
}

String getToken(TokenStorage storage) =>
  storage.readJson("token");

bool refreshTokenStillValid(TokenStorage storage) =>
  DateTime.parse(storage.readJson("expiry")).difference(DateTime.now()).inMinutes >= 60;


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


    if(res.statusCode == INVALID_CREDENTIALS) throw BackendError(INVALID_CREDENTIALS);
    if(res.statusCode == GENERIC_ERROR) throw BackendError(GENERIC_ERROR);
    if(res.statusCode == SERVER_DOWN) throw ServerError();


    Map resBody = json.decode(res.body);

    tokenStorage.writeJson("token", resBody["auth_token"]);
    tokenStorage.writeJson("ref_token_exp", resBody["refresh_token_expiry"]);

    return resBody["auth_token"];
  }

  static void logOut(TokenStorage storage) {
    storage.delete("token");
    storage.delete("expiry");
  }

  Future<bool> signUp(String email, String password, String unimoreId, String name, String surname) async {
    var res = await client.post(
      "$baseUrl/register",
      body: {
        "email": email,
        "password": password,
        "name": name,
        "surname": surname,
        "unimore_id": unimoreId
      }
    );

    if(res.statusCode == USER_EXISTS) throw BackendError(USER_EXISTS);
    if(res.statusCode == GENERIC_ERROR) throw BackendError(GENERIC_ERROR);
    if(res.statusCode == SERVER_DOWN) throw ServerError();

    return json.decode(res.body)["success"];
  }
}

abstract class TokenStorage {
  /// throws `NotFoundError` if it can't read the thing

  String readJson(String name);
  void writeJson(String name, String value);
  void delete(String name);
}

class LocalStorageTokenStorage implements TokenStorage {
  @override
  String readJson(String name) {
    String val = window.localStorage[name];
    if(val == null) {
      throw NotFoundError();
    }
    else {
      return val;
    }
  }

  @override
  void writeJson(String name, String value) {
    window.localStorage[name] = value;
  }

  @override
  void delete(String name) {
    window.localStorage.remove(name);
  }
  
}