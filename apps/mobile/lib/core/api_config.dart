class ApiConfig {
  const ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const _rawKakaoNativeAppKey = String.fromEnvironment(
    'KAKAO_NATIVE_APP_KEY',
  );

  static String get kakaoNativeAppKey =>
      _rawKakaoNativeAppKey.startsWith('kakao')
      ? _rawKakaoNativeAppKey.substring(5)
      : _rawKakaoNativeAppKey;
}
