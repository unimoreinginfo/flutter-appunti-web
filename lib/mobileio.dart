import 'package:appunti_web_frontend/errors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'io.dart';

class SecureStorageTokenStorage implements TokenStorage {
  SecureStorageTokenStorage() {
    storage = FlutterSecureStorage();
  }

  FlutterSecureStorage storage;
  @override
  Future<String> readJson(String name) async {
    String val = await storage.read(key: name);
    if (val == null)
      throw NotFoundError();
    else
      return val;
  }

  @override
  Future<void> writeJson(String name, String value) =>
      storage.write(key: name, value: value);

  @override
  Future<void> delete(String name) => storage.delete(key: name);
}
