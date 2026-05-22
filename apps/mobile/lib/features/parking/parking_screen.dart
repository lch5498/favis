import 'package:flutter/cupertino.dart';

class ParkingScreen extends StatelessWidget {
  const ParkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FeaturePlaceholderScreen(
      title: '주차 관리',
      icon: CupertinoIcons.car_detailed,
      accentColor: CupertinoColors.systemOrange,
      backgroundColor: Color(0xFFFFF0E5),
    );
  }
}

class _FeaturePlaceholderScreen extends StatelessWidget {
  const _FeaturePlaceholderScreen({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(title)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: accentColor, size: 48),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
