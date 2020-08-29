import 'dart:convert' show json, ascii, base64;
import 'consts.dart' show baseUrl;
import 'package:http/http.dart' show BaseClient;

/// Get payload from the base64 JWT token string
Map getPayload(String token) => json.decode(
  ascii.decode(
    base64.decode(base64.normalize(token.split(".")[1]))
  )
);

Future<List> getSubjects(BaseClient httpClient) async =>
  // TODO: what if this fails?
    json.decode(await httpClient.read("$baseUrl/subjects"));

/// Get note by id
Future<Map> getNote(String id, BaseClient httpClient) async => json.decode(
  // TODO: what if this fails?
  await httpClient.read("$baseUrl/notes/$id")
)["result"];


// Get notes, optionally 
Future<List<Map<String, Object>>> getNotes(BaseClient httpClient, {String author, int subjectId}) async {
  // TODO: what if this fails?
    
  if(author == null && subjectId != null) return json.decode(
    await httpClient.read("$baseUrl/notes?subject_id=$subjectId}")
  );
  if(author != null && subjectId == null) return json.decode(
    await httpClient.read("$baseUrl/notes?author_id=$author}")
  );
  if(author != null && subjectId != null) return json.decode(
    await httpClient.read("$baseUrl/notes?author_id=$author}&subject_id=$subjectId")
  );
  
  // both null
  return json.decode(
    await httpClient.read("$baseUrl/notes")
  );
}


Future<Map<String, Object>> getUser(uid, BaseClient httpClient) async {
  // TODO: what if this fails?

  return json.decode(
    await httpClient.read("$baseUrl/users/$uid")
  )["result"];
}

Future<bool> isMod(String token, BaseClient httpClient) async {
  // we suppose the user is logged in
  Map decodedToken = getPayload(token);
  Map user = json.decode(await httpClient.read("$baseUrl/users/${decodedToken["user_id"]}"));
  if(user["is_admin"] == 1) return true;
  else return false;

}
