import 'dart:convert' show json, ascii, base64;
import 'package:dio/dio.dart';

import 'consts.dart' show baseUrl, http;
import 'errors.dart' as errors;
import 'io.dart' as io;
import 'platform.dart' as platform;

// TODO: find out why cookies are not being sent to the server

/// Get payload from the base64 JWT token string
Map getPayload(String token) => json
    .decode(ascii.decode(base64.decode(base64.normalize(token.split(".")[1]))));

Future<void> editProfile(String id, String jwt, Map data) async {
  try {
    var res = await http.post("$baseUrl/users/$id",
        data: data,
        options: Options(headers: {"Authorization": "Bearer $jwt"}));
    if (res.statusCode == errors.SERVER_DOWN) {
      throw errors.ServerError();
    } else if (res.statusCode == errors.NOT_FOUND) {
      throw errors.NotFoundError();
    } else {
      print('response editProfile: ${res.data}');
      var body = json.decode(res.data as String);
      if (body["success"] == false) {
        throw errors.BackendError(res.statusCode);
      } else {
        return body["result"];
      }
    }
  } catch (e) {
    print(e);
    throw errors.ServerError();
  }
}

Future<List> getSubjects() async {
  try {
    var res = json
        .decode((await http.get("$baseUrl/subjects")).data as String)["result"];
    return res;
  } catch (_) {
    throw errors.ServerError();
  }
}

Future<void> deleteNote(String id, String sub_id, String jwt) async {
  var res = await http.delete("$baseUrl/notes/$sub_id/$id",
      options: Options(headers: {"Authorization": "Bearer $jwt"}));
  if (res.statusCode == errors.SERVER_DOWN) {
    throw errors.ServerError();
  } else if (json.decode(res.data as String)["success"] == false) {
    throw errors.BackendError(res.statusCode);
  } else {
    io.getAndUpdateToken(res, platform.tokenStorage);
  }
}

/// Get note by id
Future getNote(String sub_id, String id) async {
  // TODO: what if this fails?

  var res = json
      .decode((await http.get("$baseUrl/notes/$sub_id/$id")).data as String);
  if (res["success"] == false) {
    throw errors.NotFoundError();
  }
  return res["result"];
}

Future<void> addNote(
    String jwt, String title, String subject, String filePath) async {
  var formData = FormData.fromMap({
    "title": title,
    "subject_id": subject,
    "notes": MultipartFile.fromFile(filePath)
  });
  try {
    var res = await http.post('$baseUrl/notes',
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $jwt"}));

    if (res.statusCode == errors.SERVER_DOWN) {
      throw errors.ServerError();
    } else if (res.statusCode == errors.NOT_FOUND) {
      throw errors.NotFoundError();
    } else {
      var body = json.decode(res.data as String);
      if (body["success"] == false) {
        throw errors.BackendError(res.statusCode);
      } else {
        return;
      }
    }
  } catch (e) {
    print(e);
    throw errors.ServerError();
  }
}

// Get notes, optionally
Future<List<Map<String, Object>>> getNotes(
    {String author, int subjectId}) async {
  // TODO: what if this fails?
  Map<String, Object> result;
  if (author == null && subjectId != null)
    result = json.decode(
        (await http.get("$baseUrl/notes?subject_id=$subjectId")).data
            as String);
  else if (author != null && subjectId == null)
    result = json.decode(
        (await http.get("$baseUrl/notes?author_id=$author")).data as String);
  else if (author != null && subjectId != null)
    result = json.decode((await http
            .get("$baseUrl/notes?author_id=$author&subject_id=$subjectId"))
        .data as String);
  else
    result = json.decode((await http.get("$baseUrl/notes")).data as String);

  return result["result"];
}

Future<void> deleteUser(int id, String jwt) async {
  var res = await http.delete("$baseUrl/users/$id",
      options: Options(headers: {"Authorization": "Bearer $jwt"}));

  if (res.statusCode == errors.SERVER_DOWN) {
    throw errors.ServerError();
  } else if (res.statusCode == errors.INVALID_CREDENTIALS ||
      res.statusCode == errors.USER_NOT_FOUND) {
    throw errors.BackendError(res.statusCode);
  } else if (json.decode(res.data as String)["success"] == true) {
    return;
  }
  io.getAndUpdateToken(res, platform.tokenStorage);
}

Future<Map<String, Object>> getUser(String uid) async {
  // TODO: what if this fails?

  return json
      .decode((await http.get("$baseUrl/users/$uid")).data as String)["result"];
}

Future<List<Map<String, Object>>> search(String q) async {
  return json.decode(
      (await http.get('$baseUrl/notes/search?q=$q')).data as String)["result"];
}

Future<void> editNote(String id, String subjectId, String jwt, Map data) async {
  // TODO: what if this fails?
  // TODO:tenere presente che la route backend è considerata WIP/instabile

  var res = await http.post("$baseUrl/$subjectId/$id",
      data: data, options: Options(headers: {"Authorization": "Bearer $jwt"}));

  if (res.statusCode == errors.INVALID_CREDENTIALS) {
    throw errors.BackendError(errors.INVALID_CREDENTIALS);
  }
  io.getAndUpdateToken(res, platform.tokenStorage);
}

Future<List<Map<String, Object>>> getUsers() async {
  return json
      .decode((await http.get('$baseUrl/users')).data as String)["result"];
}
