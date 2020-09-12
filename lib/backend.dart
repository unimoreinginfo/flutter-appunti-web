import 'dart:convert' show json, ascii, base64;
import 'consts.dart' show baseUrl;
import 'package:http/http.dart' as http;
import 'errors.dart' as errors;
import 'io.dart' as io;
import 'platform.dart' as platform;


// TODO: find out why cookies are not being sent to the server

/// Get payload from the base64 JWT token string
Map getPayload(String token) => json.decode(
  ascii.decode(
    base64.decode(base64.normalize(token.split(".")[1]))
  )
);

Future<void> editProfile(String id, String jwt, Map data, http.BaseClient httpClient) async {
  try {
    var res = await http.post(
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

Future<List> getSubjects(http.BaseClient httpClient) async {
  try {
    var res = json.decode(await http.read("$baseUrl/subjects"))["result"];
    return res;
  } catch(_) {
    throw errors.ServerError();
  }
}


Future<void> deleteNote(String id, String sub_id, String jwt, http.BaseClient httpClient) async {
    var res = await http.delete("$baseUrl/notes/$sub_id/$id", headers: {"Authorization": "Bearer $jwt"});
    if(res.statusCode == errors.SERVER_DOWN) {
      throw errors.ServerError();
    } else if(json.decode(res.body)["success"] == false) {
      throw errors.BackendError(res.statusCode);
    } else {
      io.getAndUpdateToken(res, platform.tokenStorage);
    }
  }
/// Get note by id
Future getNote(String sub_id, String id, http.BaseClient httpClient) async {
  // TODO: what if this fails?

  var res = json.decode(
    await http.read("$baseUrl/notes/$sub_id/$id")
  );
  if(res["success"] == false) {
    throw errors.NotFoundError();
  }
  return res["result"];
}

Future<void> addNote(String jwt, Map data, Future<http.MultipartFile> file, http.BaseClient httpClient) async {
  var req = http.MultipartRequest('POST', Uri.parse("$baseUrl/"));
  req.fields.addAll(data);
  req.files.add(await file);

  try {
    var res = await http.Response.fromStream(await httpClient.send(req));
    if(res.statusCode == errors.SERVER_DOWN) {
      throw errors.ServerError();
    } else if(res.statusCode == errors.NOT_FOUND) {
      throw errors.NotFoundError();
    } else {
      var body = json.decode(res.body);
      if(body["success"] == false) {
        throw errors.BackendError(res.statusCode);
      } else {
        return;
      }
    }
  } catch(e) {
    print(e);
    throw errors.ServerError();
  }
}

// Get notes, optionally 
Future<List<Map<String, Object>>> getNotes(http.BaseClient httpClient, {String author, int subjectId}) async {
  // TODO: what if this fails?
  Map<String, Object> result;
  if(author == null && subjectId != null) result =  json.decode(
    await http.read("$baseUrl/notes?subject_id=$subjectId")
  );
  else if(author != null && subjectId == null) result =  json.decode(
    await http.read("$baseUrl/notes?author_id=$author")
  );
  else if(author != null && subjectId != null) result =  json.decode(
    await http.read("$baseUrl/notes?author_id=$author&subject_id=$subjectId")
  );
  else result = json.decode(
    await http.read("$baseUrl/notes")
  );

  return result["result"];
}

Future<void> deleteUser(int id, String jwt, http.BaseClient httpClient) async {
  var res = await http.delete("$baseUrl/users/$id", headers: {"Authorization": "Bearer $jwt"});

  if(res.statusCode == errors.SERVER_DOWN) {
    throw errors.ServerError();
  }
  else if(res.statusCode == errors.INVALID_CREDENTIALS || res.statusCode == errors.USER_NOT_FOUND) {
    throw errors.BackendError(res.statusCode);
  } else if(json.decode(res.body)["success"] == true) {
    return;
  } 
  io.getAndUpdateToken(res, platform.tokenStorage);
}


Future<Map<String, Object>> getUser(String uid, http.BaseClient httpClient) async {
  // TODO: what if this fails?

  return json.decode(
    await http.read("$baseUrl/users/$uid")
  )["result"];
}

Future<List<Map<String, Object>>> search(String q, http.BaseClient httpClient) async {
  return json.decode(
    await http.read('$baseUrl/notes/search?q=$q')
  )["result"];
}

Future<void> editNote(String id, String subjectId, String jwt, http.BaseClient httpClient,  Map data) async {
    // TODO: what if this fails?
    // TODO:tenere presente che la route backend è considerata WIP/instabile


  var res = await http.post(
    "$baseUrl/$subjectId/$id",
    body: data,
    headers: {
      "Authorization": "Bearer $jwt"
    }
  );

  if(res.statusCode == errors.INVALID_CREDENTIALS) {
    throw errors.BackendError(errors.INVALID_CREDENTIALS);
  }
  io.getAndUpdateToken(res, platform.tokenStorage);
}

Future<List<Map<String, Object>>> getUsers(http.BaseClient httpClient) async {
  return json.decode(
    await http.read('$baseUrl/users')
  )["result"];
}