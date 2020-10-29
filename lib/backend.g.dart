// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) {
  return Subject(
    id: json['id'] as int,
    name: json['name'] as String,
    professor_name: json['professor_name'] as String,
    professor_surname: json['professor_surname'] as String,
  );
}

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'professor_name': instance.professor_name,
      'professor_surname': instance.professor_surname,
    };

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as String,
    name: json['name'] as String,
    surname: json['surname'] as String,
    email: json['email'] as String,
    unimore_id: json['unimore_id'] as String,
    admin: json['admin'] as int,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'admin': instance.admin,
      'name': instance.name,
      'surname': instance.surname,
      'email': instance.email,
      'unimore_id': instance.unimore_id,
    };

Note _$NoteFromJson(Map<String, dynamic> json) {
  return Note(
    note_id: (json['note_id'] != null ? json['note_id'] : json['id'])
        as String, // TODO: remove manual modification when backend is fixed
    subject_id: json['subject_id'] as int,
    visits: json['visits'] as int,
    title: json['title'] as String,
    name: json['name'] as String,
    surname: json['surname'] as String,
    uploaded_at: json['uploaded_at'] as String,
  )..author_id = json['author_id'] as String;
}

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'note_id': instance.note_id,
      'title': instance.title,
      'subject_id': instance.subject_id,
      'author_id': instance.author_id,
      'uploaded_at': instance.uploaded_at,
      'name': instance.name,
      'surname': instance.surname,
      'visits': instance.visits,
    };
