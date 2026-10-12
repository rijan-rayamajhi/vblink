import 'package:shared_preferences/shared_preferences.dart';
import 'package:vblink/core/storage.dart';

/// Fresh in-memory storage, optionally pre-filled with saved values.
Future<Storage> testStorage([Map<String, Object> saved = const {}]) async {
  SharedPreferences.setMockInitialValues(saved);
  return Storage.load();
}
