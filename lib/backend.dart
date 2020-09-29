import 'dart:convert' show json, ascii, base64;
import 'package:dio/dio.dart';

import 'consts.dart' show baseUrl, http;
import 'errors.dart' as errors;
import 'io.dart' as io;
import 'platform.dart' as platform;

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
      var body = json.decode(res.data);
      if (body["success"] == false) {
        throw errors.BackendError(res.statusCode);
      } else {
        io.getAndUpdateToken(res, platform.tokenStorage);
        return body["result"];
      }
    }
  } catch (e) {
    print(e);
    throw errors.ServerError();
  }
}

Future<List<Map<String, Object>>> getSubjects() async {
  try {
    var res = json.decode((await http.get("$baseUrl/subjects")).data)["result"];
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
  } else if (json.decode(res.data)["success"] == false) {
    throw errors.BackendError(res.statusCode);
  } else {
    io.getAndUpdateToken(res, platform.tokenStorage);
  }
}

/// Get note by id
Future<Map> getNote(String sub_id, String id) async {
  Response res = await http.get("$baseUrl/notes/$sub_id/$id");
  if (res.statusCode == errors.SERVER_DOWN) throw errors.ServerError();
  Map resData = json.decode(res.data);
  if (resData["success"] == false) {
    throw errors.BackendError(res.statusCode);
  }
  return resData["result"];
}

Future<void> addNote(
    String jwt, String title, String subject, List<MultipartFile> files) async {
  var formData = FormData();
  formData.fields.addAll([
    MapEntry("title", title),
    MapEntry("subject_id", subject),
  ]);
  formData.files.addAll(files.map((file) => MapEntry("notes", file)));

  try {
    var res = await http.post('$baseUrl/notes',
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $jwt"}));

    if (res.statusCode == errors.SERVER_DOWN) {
      throw errors.ServerError();
    } else {
      var body = json.decode(res.data);
      if (body["success"] == false) {
        throw errors.BackendError(res.statusCode);
      } else {
        io.getAndUpdateToken(res, platform.tokenStorage);
        return;
      }
    }
  } catch (e) {
    print(e);
    throw errors.ServerError();
  }
}

// Get notes, optionally with filters
Future<List<Map<String, Object>>> getNotes(
    {String author, int subjectId}) async {
  Response res;
  if (author == null && subjectId != null)
    res = await http.get("$baseUrl/notes?subject_id=$subjectId");
  else if (author != null && subjectId == null)
    res = await http.get("$baseUrl/notes?author_id=$author");
  else if (author != null && subjectId != null)
    res = await http
        .get("$baseUrl/notes?author_id=$author&subject_id=$subjectId");
  else
    res = await http.get("$baseUrl/notes");

  if (res.statusCode == errors.SERVER_DOWN)
    throw errors.ServerError();
  else {
    Map<String, Object> data = json.decode(res.data);
    if (data["success"] == false) throw errors.BackendError(res.statusCode);
    return data["result"];
  }
}

Future<void> deleteUser(int id, String jwt) async {
  var res = await http.delete("$baseUrl/users/$id",
      options: Options(headers: {"Authorization": "Bearer $jwt"}));

  if (res.statusCode == errors.SERVER_DOWN) {
    throw errors.ServerError();
  } else if (json.decode(res.data)["success"] == false) {
    throw errors.BackendError(res.statusCode);
  }
  io.getAndUpdateToken(res, platform.tokenStorage);
}

Future<Map<String, Object>> getUser(String uid) async {
  var res = await http.get("$baseUrl/users/$uid");

  if (res.statusCode == errors.SERVER_DOWN)
    throw errors.ServerError();
  else if (json.decode(res.data)["success"] == false)
    throw errors.BackendError(res.statusCode);
  return json.decode(res.data)["result"];
}

Future<List<Map<String, Object>>> search(String q) async {
  var res = await http.get('$baseUrl/notes/search?q=$q');
  if (res.statusCode == errors.SERVER_DOWN) throw errors.ServerError();
  if (json.decode(res.data)["success"] == false)
    throw errors.BackendError(res.statusCode);

  return json.decode(res.data)["result"];
}

Future<void> editNote(String id, String subjectId, String jwt, Map data) async {
  var res = await http.post("$baseUrl/notes/$subjectId/$id",
      data: data, options: Options(headers: {"Authorization": "Bearer $jwt"}));

  if (res.statusCode == errors.SERVER_DOWN) throw errors.ServerError();
  if (json.decode(res.data)["success"] == false)
    throw errors.BackendError(res.statusCode);

  io.getAndUpdateToken(res, platform.tokenStorage);
}

Future<List<Map<String, Object>>> getUsers(String jwt) async {
  var res = await http.get('$baseUrl/users',
      options: Options(headers: {"Authorization": "Bearer $jwt"}));

  if (res.statusCode == errors.SERVER_DOWN) throw errors.ServerError();
  if (json.decode(res.data)["success"] == false)
    throw errors.BackendError(res.statusCode);

  return json.decode(res.data)["result"];
}
