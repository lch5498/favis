import 'package:flutter/cupertino.dart';

import '../../core/api_client.dart';
import '../../shared/schedule_section_switcher.dart';
import '../anniversary/anniversary_screen.dart';
import '../education/education_screen.dart';
import 'schedule_screen.dart';

class ScheduleHubScreen extends StatefulWidget {
  const ScheduleHubScreen({
    super.key,
    required this.family,
    required this.families,
    required this.sessionToken,
    required this.refreshToken,
    required this.todayRequestToken,
    required this.onSelectFamily,
  });

  final AppFamily family;
  final List<AppFamily> families;
  final String sessionToken;
  final int refreshToken;
  final int todayRequestToken;
  final Future<void> Function(AppFamily family) onSelectFamily;

  @override
  State<ScheduleHubScreen> createState() => _ScheduleHubScreenState();
}

class _ScheduleHubScreenState extends State<ScheduleHubScreen> {
  ScheduleSection _section = ScheduleSection.calendar;

  void _setSection(ScheduleSection section) {
    setState(() {
      _section = section;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_section) {
      case ScheduleSection.recurring:
        return EducationScreen(
          key: ValueKey('recurring-${widget.family.id}'),
          family: widget.family,
          families: widget.families,
          sessionToken: widget.sessionToken,
          selectedScheduleSection: _section,
          onScheduleSectionChanged: _setSection,
          onSelectFamily: widget.onSelectFamily,
        );
      case ScheduleSection.anniversary:
        return AnniversaryScreen(
          key: ValueKey('anniversary-${widget.family.id}'),
          family: widget.family,
          families: widget.families,
          sessionToken: widget.sessionToken,
          selectedScheduleSection: _section,
          onScheduleSectionChanged: _setSection,
          onSelectFamily: widget.onSelectFamily,
        );
      case ScheduleSection.calendar:
        return ScheduleScreen(
          key: ValueKey('calendar-${widget.family.id}'),
          family: widget.family,
          families: widget.families,
          sessionToken: widget.sessionToken,
          refreshToken: widget.refreshToken,
          todayRequestToken: widget.todayRequestToken,
          selectedScheduleSection: _section,
          onScheduleSectionChanged: _setSection,
          onSelectFamily: widget.onSelectFamily,
        );
    }
  }
}
