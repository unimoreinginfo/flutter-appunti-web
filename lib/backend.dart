import 'dart:convert' show json, ascii, base64;
import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tuple/tuple.dart';

import 'consts.dart' show baseUrl, http;
import 'errors.dart' as errors;
import 'io.dart' as io;
import 'platform.dart' as platform;

part 'backend.g.dart';

@JsonSerializable()
class Subject {
  int id;
  String name;
  String professor_name;
  String professor_surname;
  Subject({this.id, this.name, this.professor_name, this.professor_surname});
  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}

@JsonSerializable()
class User {
  String id;
  int admin;
  String name;
  String surname;
  String email;
  String unimore_id;
  User(
      {this.id,
      this.name,
      this.surname,
      this.email,
      this.unimore_id,
      this.admin});
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Note {
  String note_id;
  String title;
  int subject_id;
  String author_id;
  String uploaded_at;
  String name;
  String surname;
  int visits;
  Note(
      {this.note_id,
      this.subject_id,
      this.visits,
      this.title,
      this.name,
      this.surname,
      this.uploaded_at});
  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
  Map<String, dynamic> toJson() => _$NoteToJson(this);
}

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

Future<List<Subject>> getSubjects() async {
  try {
    List<Subject> ret = json
        .decode((await http.get("$baseUrl/subjects")).data)["result"]
        .map<Subject>((el) => Subject.fromJson(el))
        .toList();
    for (var item in ret) {
      print("ret: ${item.toJson()}");
    }
    return ret;
  } catch (_) {
    print(_);
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

  var res = await http.post('$baseUrl/notes',
      data: formData,
      options: Options(headers: {"Authorization": "Bearer $jwt"}));

  if (res.statusCode == errors.USER_NOT_VERIFIED)
    throw errors.UserEmailNotVerifiedError();
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
}

// Get notes, optionally with filters
Future<List<Note>> getNotes(int page, {String author, int subjectId}) async {
  Response res;
  if (author == null && subjectId != null)
    res = await http
        .get("$baseUrl/notes?subject_id=$subjectId&order_by=visits&page=$page");
  else if (author != null && subjectId == null)
    res = await http
        .get("$baseUrl/notes?author_id=$author&order_by=visits&page=$page");
  else if (author != null && subjectId != null)
    res = await http.get(
        "$baseUrl/notes?author_id=$author&subject_id=$subjectId&order_by=visits&page=$page");
  else
    res = await http.get("$baseUrl/notes?order_by=visits&page=$page");

  if (res.statusCode == errors.SERVER_DOWN)
    throw errors.ServerError();
  else {
    Map<String, Object> data = json.decode(res.data);
    if (data["success"] == false) throw errors.BackendError(res.statusCode);
    return (data["result"] as List).map((el) => Note.fromJson(el)).toList();
  }
}

Future<Tuple2<int, List<Note>>> getNotesFirstPage(
    {String author, int subjectId}) async {
  Response res;
  if (author == null && subjectId != null)
    res =
        await http.get("$baseUrl/notes?subject_id=$subjectId&order_by=visits");
  else if (author != null && subjectId == null)
    res = await http.get("$baseUrl/notes?author_id=$author&order_by=visits");
  else if (author != null && subjectId != null)
    res = await http.get(
        "$baseUrl/notes?author_id=$author&subject_id=$subjectId&order_by=visits");
  else
    res = await http.get("$baseUrl/notes?order_by=visits");

  if (res.statusCode == errors.SERVER_DOWN)
    throw errors.ServerError();
  else {
    Map<String, Object> data = json.decode(res.data);
    if (data["success"] == false) throw errors.BackendError(res.statusCode);
    return Tuple2(data["pages"],
        (data["result"] as List).map((el) => Note.fromJson(el)).toList());
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

Future<User> getUser(String uid) async {
  var res = await http.get("$baseUrl/users/$uid");

  if (res.statusCode == errors.SERVER_DOWN)
    throw errors.ServerError();
  else if (json.decode(res.data)["success"] == false)
    throw errors.BackendError(res.statusCode);
  return User.fromJson(json.decode(res.data)["result"]);
}

Future<List<Note>> search(String q, int page) async {
  var res = await http.get('$baseUrl/notes/search?q=$q&page=$page');
  if (res.statusCode == errors.SERVER_DOWN) throw errors.ServerError();
  if (json.decode(res.data)["success"] == false)
    throw errors.BackendError(res.statusCode);

  return (json.decode(res.data)["result"] as List)
      .map((e) => Note.fromJson(e))
      .toList();
}

Future<Tuple2<int, List<Note>>> searchFirstPage(String q) async {
  var res = await http.get('$baseUrl/notes/search?q=$q');
  if (res.statusCode == errors.SERVER_DOWN) throw errors.ServerError();
  if (json.decode(res.data)["success"] == false)
    throw errors.BackendError(res.statusCode);

  return Tuple2(
      json.decode(res.data)["pages"],
      (json.decode(res.data)["result"] as List)
          .map((e) => Note.fromJson(e))
          .toList());
}

Future<void> editNote(String id, String subjectId, String jwt, Map data) async {
  var res = await http.post("$baseUrl/notes/$subjectId/$id",
      data: data, options: Options(headers: {"Authorization": "Bearer $jwt"}));

  if (res.statusCode == errors.SERVER_DOWN) throw errors.ServerError();
  if (json.decode(res.data)["success"] == false)
    throw errors.BackendError(res.statusCode);

  io.getAndUpdateToken(res, platform.tokenStorage);
}

Future<List<User>> getUsers(String jwt) async {
  var res = await http.get('$baseUrl/users',
      options: Options(headers: {"Authorization": "Bearer $jwt"}));

  if (res.statusCode == errors.SERVER_DOWN) throw errors.ServerError();
  if (json.decode(res.data)["success"] == false)
    throw errors.BackendError(res.statusCode);

  return (json.decode(res.data)["result"] as List)
      .map((e) => User.fromJson(e))
      .toList();
}

class UserStorageStatus {
  UserStorageStatus(this.folder_size_kilobytes, this.max_size_kilobytes);

  int folder_size_kilobytes;
  int max_size_kilobytes;
}

Future<UserStorageStatus> getSize(String jwt) async {
  var res = await http.get("$baseUrl/users/size",
      options: Options(headers: {"Authorization": "Bearer $jwt"}));

  if (res.statusCode == errors.SERVER_DOWN) throw errors.ServerError();
  if (res.statusCode != 200) throw errors.BackendError(res.statusCode);

  Map data = json.decode(res.data);
  print("get /size ha returnato ${res.data}");
  return UserStorageStatus(double.parse(data["folder_size_kilobytes"]).toInt(),
      data["max_folder_size_kilobytes"]);
}

Future<void> verifyEmail(String token, String userId) async {
  var res = await http.post("$baseUrl/auth/verify/$token/$userId");
  if (!json.decode(res.data as String)["success"])
    throw errors.NotFoundError();
  else
    return;
}
