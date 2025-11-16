import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../constants/design_tokens.dart';

class TaskCalendarScreen extends StatefulWidget {
  const TaskCalendarScreen({super.key});

  @override
  State<TaskCalendarScreen> createState() => _TaskCalendarScreenState();
}

class _TaskCalendarScreenState extends State<TaskCalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<String>> _tasks = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('calendar_tasks');
    if (tasksJson != null) {
      final decoded = jsonDecode(tasksJson) as Map<String, dynamic>;
      setState(() {
        _tasks = decoded.map((key, value) => 
          MapEntry(key, List<String>.from(value as List)));
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calendar_tasks', jsonEncode(_tasks));
  }

  @override
  Widget build(BuildContext context) {
    final spacing = DesignTokens.spacing;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      
      ),
      body: Column(
        children: [
          // Month navigation
          Container(
            padding: EdgeInsets.all(spacing.s3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _focusedMonth = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month - 1,
                      );
                    });
                  },
                ),
                Text(
                  _getMonthYearString(_focusedMonth),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _focusedMonth = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month + 1,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Calendar grid (wrap in Flexible + scroll so smaller devices can scroll the month view)
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildCalendarGrid(),
            ),
          ),
          
          SizedBox(height: spacing.s3),
          Divider(),
          
          // Tasks list
          Expanded(
            child: _selectedDay == null
                ? Center(
                    child: Text(
                      'Select a day to view or add tasks',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  )
                : _buildTasksList(),
          ),
        ],
      ),
      floatingActionButton: _selectedDay != null
          ? FloatingActionButton(
              onPressed: () => _showAddTaskDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildCalendarGrid() {
    final spacing = DesignTokens.spacing;
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Convert to start on Sunday
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.s3),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          day,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: spacing.s2),
          
          // Calendar days
          ...List.generate(6, (weekIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox(width: 40, height: 48);
                }
                
                final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
                final dateKey = _getDateKey(date);
                final hasTasks = _tasks[dateKey]?.isNotEmpty ?? false;
                final isSelected = _selectedDay != null && _isSameDay(date, _selectedDay!);
                final isToday = _isSameDay(date, DateTime.now());
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = date;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 48,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : isToday
                              ? Theme.of(context).primaryColor.withOpacity(0.2)
                              : null,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSelected
                          ? Border.all(color: Theme.of(context).primaryColor)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (hasTasks)
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  List<String> _getTasksForDay(DateTime day) {
    final key = _getDateKey(day);
    return _tasks[key] ?? [];
  }

  Widget _buildTasksList() {
    final tasks = _getTasksForDay(_selectedDay!);
    final spacing = DesignTokens.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.s3),
          child: Text(
            'Tasks for ${_getDateString(_selectedDay!)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: spacing.s2),
        
        if (tasks.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: spacing.s3),
                  Text(
                    'No tasks for this day',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: spacing.s2),
                  Text(
                    'Tap the + button to add a task',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(spacing.s3),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: spacing.s2),
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(tasks[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(index),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  String _getDateString(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showAddTaskDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter task description',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addTask(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addTask(String task) {
    final key = _getDateKey(_selectedDay!);
    setState(() {
      if (_tasks[key] == null) {
        _tasks[key] = [];
      }
      _tasks[key]!.add(task);
    });
    _saveTasks();
  }

  void _deleteTask(int index) {
    final key = _getDateKey(_selectedDay!);
    setState(() {
      _tasks[key]?.removeAt(index);
    });
    _saveTasks();
  }
}
