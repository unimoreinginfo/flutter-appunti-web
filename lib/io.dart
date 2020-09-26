import 'dart:convert' show json, base64, ascii;

import 'consts.dart' show baseUrl;
import 'package:http/http.dart' as http;
import 'errors.dart';

/// Get payload from the base64 JWT token string
Map getPayload(String token) => json
    .decode(ascii.decode(base64.decode(base64.normalize(token.split(".")[1]))));

bool isMod(String token) {
  // we suppose the user is logged in
  Map decodedToken = getPayload(token);
  if (decodedToken["is_admin"] == 1)
    return true;
  else
    return false;
}

void updateToken(TokenStorage storage, String newTok) {
  storage.writeJson("token", newTok);
}

String getUserIdOrNull(TokenStorage storage) {
  try {
    return json.decode(storage.readJson("token"))["id"];
  } catch (_) {
    return null;
  }
}

String getToken(TokenStorage storage) => storage.readJson("token");

bool refreshTokenStillValid(TokenStorage storage) =>
    DateTime.parse(storage.readJson("expiry"))
        .difference(DateTime.now())
        .inMinutes >=
    60;

void getAndUpdateToken(http.Response res, TokenStorage storage) {
  try {
    var newTok = res.headers["Authorization"].split(" ")[1];
    updateToken(storage, newTok);
  } catch (_) {
    print(res.headers["Authorization"]);
  }
}

/// We call this class for login purposes so that we are at least
/// a tiny little bit testable.
class LoginManager {
  LoginManager(this.tokenStorage);

  TokenStorage tokenStorage;

  Future<bool> logIn(String email, String password) async {
    var res = await http.post("$baseUrl/auth/login",
        body: {"email": email, "password": password});

    print("<login>");
    print("data: ${res.body}");
    print("statuscode: ${res.statusCode}");
    print("</login>");

    if (res.statusCode == INVALID_CREDENTIALS)
      throw BackendError(INVALID_CREDENTIALS);
    if (res.statusCode == GENERIC_ERROR) throw BackendError(GENERIC_ERROR);
    if (res.statusCode == SERVER_DOWN) throw ServerError();

    Map resBody = json.decode(res.body);

    tokenStorage.writeJson("token", resBody["auth_token"]);
    tokenStorage.writeJson(
        "expiry",
        DateTime.fromMillisecondsSinceEpoch(
                int.parse(resBody["refresh_token_expiry"]) * 1000)
            .toIso8601String());

    return resBody["success"];
  }

  static void logOut(TokenStorage storage) {
    storage.delete("token");
    storage.delete("expiry");
  }

  Future<bool> signUp(String email, String password, String unimoreId,
      String name, String surname) async {
    var res = await http.post("$baseUrl/auth/register", body: {
      "email": email,
      "password": password,
      "name": name,
      "surname": surname,
      "unimore_id": unimoreId
    });

    if (res.statusCode == SERVER_DOWN) throw ServerError();

    return json.decode(res.body)["success"];
  }
}

abstract class TokenStorage {
  /// throws `NotFoundError` if it can't read the thing

  String readJson(String name);
  void writeJson(String name, String value);
  void delete(String name);
}
