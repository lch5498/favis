import 'package:flutter/cupertino.dart';

import '../../core/api_client.dart';

class ParkingScreen extends StatelessWidget {
  const ParkingScreen({super.key, required this.family});

  final AppFamily family;

  @override
  Widget build(BuildContext context) {
    return _FeaturePlaceholderScreen(
      title: '주차 관리',
      family: family,
      icon: CupertinoIcons.car_detailed,
      accentColor: CupertinoColors.systemOrange,
      backgroundColor: const Color(0xFFFFF0E5),
    );
  }
}

class _FeaturePlaceholderScreen extends StatelessWidget {
  const _FeaturePlaceholderScreen({
    required this.title,
    required this.family,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
  });

  final String title;
  final AppFamily family;
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
                    family.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF5F6368),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 6),
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
