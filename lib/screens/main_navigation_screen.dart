import 'package:flutter/material.dart';

import 'pomodoro_timer_screen.dart';
import 'progress_tracker_screen.dart';
import 'task_calendar_screen.dart';
import 'ai_quiz_generator_screen.dart';
import 'quiz_dashboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PomodoroTimerScreen(),
    const ProgressTrackerScreen(),
    const QuizDashboardScreen(),
    const TaskCalendarScreen(),
    const AIQuizGeneratorScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.timer_outlined),
      selectedIcon: Icon(Icons.timer),
      label: 'Timer',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_view_month_outlined),
      selectedIcon: Icon(Icons.calendar_view_month),
      label: 'Progress',
    ),
    NavigationDestination(
      icon: Icon(Icons.quiz_outlined),
      selectedIcon: Icon(Icons.quiz),
      label: 'Quiz',
    ),
    NavigationDestination(
      icon: Icon(Icons.event_note_outlined),
      selectedIcon: Icon(Icons.event_note),
      label: 'Tasks',
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_awesome_outlined),
      selectedIcon: Icon(Icons.auto_awesome),
      label: 'AI Quiz',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _destinations,
      ),
    );
  }
}
