import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/design_tokens.dart';
import '../providers/pomodoro_provider.dart';
import '../routes.dart';
import '../models/pomodoro_session.dart';

class PomodoroTimerScreen extends StatefulWidget {
  const PomodoroTimerScreen({super.key});

  @override
  State<PomodoroTimerScreen> createState() => _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends State<PomodoroTimerScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-start timer when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PomodoroProvider>();
      if (provider.status == TimerStatus.initial && !provider.isReverseMode) {
        provider.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          Consumer<PomodoroProvider>(
            builder: (context, provider, _) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'mode') {
                    provider.toggleTimerMode();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'mode',
                    child: Row(
                      children: [
                        Icon(
                          provider.isReverseMode ? Icons.timer : Icons.timer_off,
                        ),
                        const SizedBox(width: 8),
                        Text(provider.isReverseMode ? 'Classic Mode' : 'Reverse Mode'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.progress);
            },
            tooltip: 'View Progress',
          ),
        ],
      ),
      body: Consumer<PomodoroProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: EdgeInsets.all(spacing.s4),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                // Session counter
                Text(
                  'Session ${provider.completedWorkSessions + 1}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                
                SizedBox(height: spacing.s2),
                
                // Session type label
                Builder(
                  builder: (context) {
                    final hideBreak =
                        provider.settings.autoStartBreaks && provider.currentSessionType != SessionType.work;
                    return Text(
                      hideBreak ? 'Focus Time' : provider.sessionLabel,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                    );
                  },
                ),
                SizedBox(height: spacing.s5),
                
                // Circular timer
                SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      CustomPaint(
                        size: const Size(280, 280),
                        painter: CircularTimerPainter(
                          progress: provider.progress,
                          sessionType: provider.currentSessionType,
                        ),
                      ),
                      // Time display
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            provider.formattedTime,
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: spacing.s2),
                          Text(
                            _getStatusText(provider.status),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.s5),
                
                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!provider.isReverseMode) ...[
                      // Reset button (only in classic mode)
                      IconButton(
                        onPressed: provider.reset,
                        icon: const Icon(Icons.refresh),
                        iconSize: 32,
                        tooltip: 'Reset',
                      ),
                      SizedBox(width: spacing.s4),
                    ],
                    
                    // Start/Pause/Stop button
                    ElevatedButton(
                      onPressed: () {
                        if (provider.isReverseMode) {
                          if (provider.isRunning) {
                            provider.stopReverseTimer();
                          } else {
                            provider.start();
                          }
                        } else {
                          provider.isRunning ? provider.pause() : provider.start();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            provider.isReverseMode && provider.isRunning
                                ? Icons.stop
                                : provider.isRunning
                                    ? Icons.pause
                                    : Icons.play_arrow,
                            size: 32,
                          ),
                          SizedBox(width: spacing.s2),
                          Text(
                            provider.isReverseMode && provider.isRunning
                                ? 'STOP'
                                : provider.isRunning
                                    ? 'PAUSE'
                                    : 'START',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    if (!provider.isReverseMode && (provider.isRunning || provider.isPaused) && !provider.settings.autoStartBreaks) ...[
                      SizedBox(width: spacing.s4),
                      // Skip button (only in classic mode)
                      IconButton(
                        onPressed: provider.skip,
                        icon: const Icon(Icons.skip_next),
                        iconSize: 32,
                        tooltip: 'Skip',
                      ),
                    ],
                  ],
                ),
                SizedBox(height: spacing.s3),

                // Exit break button (visible during break sessions in classic mode)
                if (!provider.isReverseMode && provider.currentSessionType != SessionType.work)
                  ElevatedButton.icon(
                    onPressed: () {
                      // End the break immediately and move to next (work) session
                      provider.skip();
                    },
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Exit Break'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                SizedBox(height: spacing.s5),
                
                // Mode indicator
                if (provider.isReverseMode)
                  Card(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Padding(
                      padding: EdgeInsets.all(spacing.s2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(width: spacing.s1),
                          Text(
                            'Reverse Mode: Timer counts up from 00:00',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: spacing.s3),
                
                // Auto-start toggles (only in classic mode)
                if (!provider.isReverseMode) ...[
                  Card(
                  child: SwitchListTile(
                    title: const Text('Auto-start sessions'),
                    subtitle: const Text('Automatically start breaks and work sessions'),
                    value: provider.settings.autoStartBreaks,
                    onChanged: (val) => provider.setAutoStartBreaks(val),
                  ),
                ),
                SizedBox(height: spacing.s4),
                Card(
                  child: SwitchListTile(
                    title: const Text('Auto-start pomodoros'),
                    subtitle: const Text('Automatically start a new work session after break'),
                    value: provider.settings.autoStartPomodoros,
                    onChanged: (val) => provider.setAutoStartPomodoros(val),
                  ),
                ),
                SizedBox(height: spacing.s4),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(spacing.s3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Work session length',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        SizedBox(height: spacing.s2),
                        Wrap(
                          spacing: spacing.s2,
                          children: [25, 45].map((minutes) {
                            return ChoiceChip(
                              label: Text('$minutes min'),
                              selected: provider.settings.workDuration == minutes,
                              onSelected: (_) => provider.setWorkDurationPreset(minutes),
                            );
                          }).toList(),
                        ),
                          SizedBox(height: spacing.s2),
                          if (provider.settings.workDuration == 45 &&
                              (provider.settings.autoStartBreaks || provider.settings.autoStartPomodoros))
                            Text(
                              '45-min sessions use a long break when auto-start is enabled',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: spacing.s4),
                if (!provider.settings.autoStartBreaks)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(spacing.s3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manual breaks',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          SizedBox(height: spacing.s2),
                          Wrap(
                            spacing: spacing.s2,
                            runSpacing: spacing.s2,
                            children: [
                              ElevatedButton(
                                onPressed: () => provider.startManualBreak(SessionType.shortBreak),
                                child: const Text('Start Short Break'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey,
                                ),
                                onPressed: () => provider.startManualBreak(SessionType.longBreak),
                                child: const Text('Start Long Break'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: spacing.s4),
                ],
                
                // Stats summary (only in classic mode)
                if (!provider.isReverseMode)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(spacing.s3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context,
                            'Completed',
                            '${provider.completedWorkSessions}',
                            Icons.check_circle,
                          ),
                          _buildStatItem(
                            context,
                            'Until Long Break',
                            '${_sessionsUntilLongBreak(provider)}',
                            Icons.coffee,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _getStatusText(TimerStatus status) {
    switch (status) {
      case TimerStatus.initial:
        return 'Ready to start';
      case TimerStatus.running:
        return 'In progress';
      case TimerStatus.paused:
        return 'Paused';
      case TimerStatus.completed:
        return 'Completed!';
    }
  }

  int _sessionsUntilLongBreak(PomodoroProvider provider) {
    return provider.settings.sessionsUntilLongBreak - (provider.completedWorkSessions % provider.settings.sessionsUntilLongBreak);
  }
}

class CircularTimerPainter extends CustomPainter {
  final double progress;
  final SessionType sessionType;

  CircularTimerPainter({
    required this.progress,
    required this.sessionType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius - 10, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = _getSessionColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  Color _getSessionColor() {
    switch (sessionType) {
      case SessionType.work:
        return Colors.red;
      case SessionType.shortBreak:
        return Colors.green;
      case SessionType.longBreak:
        return Colors.blue;
    }
  }

  @override
  bool shouldRepaint(CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.sessionType != sessionType;
  }
}
