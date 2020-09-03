import 'dart:convert' show json, ascii, base64;
import 'consts.dart' show baseUrl;
import 'package:http/http.dart' show BaseClient;
import 'errors.dart' as errors;

/// Get payload from the base64 JWT token string
Map getPayload(String token) => json.decode(
  ascii.decode(
    base64.decode(base64.normalize(token.split(".")[1]))
  )
);

Future<void> editProfile(int id, String jwt, Map data, BaseClient httpClient) async {
  try {
    var res = await httpClient.post(
      "$baseUrl/users/$id",
      body: data,
      headers: {
        "Authorization": "Bearer $jwt"
      }
    );
    if(res.statusCode == errors.SERVER_DOWN) {
      throw errors.ServerError();
    } else if(res.statusCode == errors.NOT_FOUND) {
      throw errors.NotFoundError();
    } else {
      var body = json.decode(res.body);
      if(body["success"] == false) {
        throw errors.BackendError(res.statusCode);
      } else {
        return body["result"];
      }
    }
  } catch(e) {
    print(e);
    throw errors.ServerError();
  }

}

// TODO: error handling
Future<List> getSubjects(BaseClient httpClient) async =>
  // TODO: what if this fails?
    json.decode(await httpClient.read("$baseUrl/subjects"))["result"];

/// Get note by id
Future getNote(String sub_id, String id, BaseClient httpClient) async {
    // TODO: what if this fails?

  var note = json.decode(
    await httpClient.read("$baseUrl/notes/$sub_id/$id")
  )["result"];

  print("ottenendo nota $note");

  return note;
}

// Get notes, optionally 
Future<List<Map<String, Object>>> getNotes(BaseClient httpClient, {String author, int subjectId}) async {
  // TODO: what if this fails?
  Map<String, Object> result;
  if(author == null && subjectId != null) result =  json.decode(
    await httpClient.read("$baseUrl/notes?subject_id=$subjectId")
  );
  else if(author != null && subjectId == null) result =  json.decode(
    await httpClient.read("$baseUrl/notes?author_id=$author")
  );
  else if(author != null && subjectId != null) result =  json.decode(
    await httpClient.read("$baseUrl/notes?author_id=$author&subject_id=$subjectId")
  );
  else result = json.decode(
    await httpClient.read("$baseUrl/notes")
  );

  return result["result"];
}


Future<Map<String, Object>> getUser(String uid, BaseClient httpClient) async {
  // TODO: what if this fails?

  return json.decode(
    await httpClient.read("$baseUrl/users/$uid")
  )["result"];
}

Future<void> editNote(int id, String jwt, BaseClient httpClient,  Map data) async {
    // TODO: what if this fails?

    var res = await httpClient.post(
      "$baseUrl/notes/$id",
      body: data,
      headers: {
        "Authorization": "Bearer $jwt"
      }
    );

    if(res.statusCode == errors.INVALID_CREDENTIALS) {
      throw errors.BackendError(errors.INVALID_CREDENTIALS);
    }
  //  getAndUpdateToken(res, tokenStorage);
  }