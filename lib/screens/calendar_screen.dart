import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  final Map<DateTime, List<String>> _readingLog = {};

  final TextEditingController _controller = TextEditingController();

  List<String> _getLogsForDay(DateTime day) {
    return _readingLog[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _addReading() {
    if (_controller.text.isEmpty) return;

    final key = DateTime(
        _selectedDay.year, _selectedDay.month, _selectedDay.day);

    if (_readingLog[key] == null) {
      _readingLog[key] = [];
    }

    _readingLog[key]!.add(_controller.text);

    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final logs = _getLogsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Calendar Reading'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // Calendar
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) =>
                isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),

          const SizedBox(height: 10),

          // Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'วันนี้อ่านอะไร...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addReading,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('บันทึก'),
                )
              ],
            ),
          ),

          const SizedBox(height: 16),

          // List
          Expanded(
            child: logs.isEmpty
                ? const Center(child: Text('ยังไม่มีการบันทึก'))
                : ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.book),
                        title: Text(logs[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}