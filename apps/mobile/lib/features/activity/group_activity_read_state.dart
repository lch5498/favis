import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GroupActivityReadState {
  GroupActivityReadState._();

  static const _storage = FlutterSecureStorage();

  static String _key(String familyId) => 'groupActivity.readAt.$familyId';

  static Future<DateTime?> readAt({required String familyId}) async {
    final value = await _storage.read(key: _key(familyId));

    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value)?.toLocal();
  }

  static Future<void> markRead({
    required String familyId,
    required DateTime readAt,
  }) {
    return _storage.write(
      key: _key(familyId),
      value: readAt.toUtc().toIso8601String(),
    );
  }
}
