/*import 'dart:html';

import 'errors.dart';
import 'io.dart';

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
  
}*/
