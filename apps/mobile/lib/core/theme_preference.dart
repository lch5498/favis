import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AppThemePreference {
  system('system', '시스템'),
  light('light', '라이트'),
  dark('dark', '다크');

  const AppThemePreference(this.storageValue, this.label);

  final String storageValue;
  final String label;

  ThemeMode get themeMode {
    switch (this) {
      case AppThemePreference.system:
        return ThemeMode.system;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
    }
  }

  static AppThemePreference fromStorageValue(String? value) {
    for (final preference in AppThemePreference.values) {
      if (preference.storageValue == value) {
        return preference;
      }
    }

    return AppThemePreference.system;
  }
}

class ThemePreferenceController extends ChangeNotifier {
  ThemePreferenceController({
    FlutterSecureStorage storage = const FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  }) : _storage = storage;

  static const _storageKey = 'settings.themePreference';

  final FlutterSecureStorage _storage;

  AppThemePreference _preference = AppThemePreference.system;
  bool _isLoaded = false;

  AppThemePreference get preference => _preference;
  ThemeMode get themeMode => _preference.themeMode;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final value = await _storage.read(key: _storageKey);
    _preference = AppThemePreference.fromStorageValue(value);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setPreference(AppThemePreference preference) async {
    if (_preference == preference && _isLoaded) {
      return;
    }

    _preference = preference;
    _isLoaded = true;
    notifyListeners();

    await _storage.write(key: _storageKey, value: preference.storageValue);
  }
}

class ThemePreferenceScope
    extends InheritedNotifier<ThemePreferenceController> {
  const ThemePreferenceScope({
    super.key,
    required ThemePreferenceController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemePreferenceController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ThemePreferenceScope>();

    assert(scope != null, 'ThemePreferenceScope가 위젯 트리에 없습니다.');
    return scope!.notifier!;
  }
}
