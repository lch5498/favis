import 'package:flutter/cupertino.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../../core/api_client.dart';
import '../../core/api_config.dart';
import '../home/home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _apiClient = ApiClient();

  AuthResponse? _auth;
  String? _message;
  bool _isLoading = false;

  Future<void> _loginWithKakaoSdk() async {
    if (ApiConfig.kakaoNativeAppKey.isEmpty) {
      setState(() {
        _message = '카카오 네이티브 앱 키가 설정되지 않았습니다.';
      });
      return;
    }

    await _run(() async {
      final OAuthToken token;

      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final auth = await _apiClient.loginWithKakaoAccessToken(
        token.accessToken,
      );

      setState(() {
        _auth = auth;
      });
    });
  }

  Future<void> _run(Future<void> Function() task) async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await task();
    } catch (error) {
      setState(() {
        _message = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = _auth;

    if (auth != null) {
      return HomeScreen(
        userNickname: auth.user.nickname,
        onLogout: () {
          setState(() {
            _auth = null;
            _message = null;
          });
        },
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const _AppMark(),
              const SizedBox(height: 24),
              const _LoginTitle(),
              if (_message != null) ...[
                const SizedBox(height: 18),
                _ErrorMessage(message: _message!),
              ],
              const Spacer(),
              _KakaoLoginButton(
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _loginWithKakaoSdk,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppMark extends StatelessWidget {
  const _AppMark();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'H',
          style: TextStyle(
            color: Color(0xFF111111),
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _LoginTitle extends StatelessWidget {
  const _LoginTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'House Keeping',
          style: TextStyle(
            color: Color(0xFF111111),
            fontSize: 38,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '가족 일정과 주차 기록을 간단하게 관리하세요.',
          style: TextStyle(
            color: Color(0xFF6E6E73),
            fontSize: 17,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          message,
          style: const TextStyle(
            color: Color(0xFFB42318),
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _KakaoLoginButton extends StatelessWidget {
  const _KakaoLoginButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: CupertinoButton(
        color: const Color(0xFFFEE500),
        disabledColor: const Color(0xFFFEE500),
        borderRadius: BorderRadius.circular(14),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: isLoading
            ? const CupertinoActivityIndicator(color: Color(0xFF191919))
            : const Text(
                '카카오로 계속하기',
                style: TextStyle(
                  color: Color(0xFF191919),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
      ),
    );
  }
}
