import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../widgets/hijri_calendar_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late HijriCalendar _selectedDate;
  late HijriCalendar _currentMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = HijriCalendar.now();
    _currentMonth = HijriCalendar.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Calendar'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCurrentDateCard(),
            const SizedBox(height: 24),
            _buildMonthSelector(),
            const SizedBox(height: 24),
            HijriCalendarWidget(
              currentMonth: _currentMonth,
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
                _showDateDetails(context, date);
              },
              onMonthChanged: (month) {
                setState(() {
                  _currentMonth = month;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildIslamicEvents(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentDateCard() {
    final now = DateTime.now();
    final gregorianDate = '${now.day} ${_getGregorianMonthName(now.month)} ${now.year}';
    final hijriDate = '${_selectedDate.hDay} ${_selectedDate.getLongMonthName()} ${_selectedDate.hYear} AH';

    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.today,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Date',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              hijriDate,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontFamily: 'Amiri',
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              gregorianDate,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _currentMonth = HijriCalendar.addMonth(
                    _currentMonth.hYear,
                    _currentMonth.hMonth - 1,
                  );
                });
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              '${_currentMonth.getLongMonthName()} ${_currentMonth.hYear} AH',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _currentMonth = HijriCalendar.addMonth(
                    _currentMonth.hYear,
                    _currentMonth.hMonth + 1,
                  );
                });
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIslamicEvents() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Islamic Events',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildEventItem('Ramadan', 'Month of Fasting', Colors.green),
            _buildEventItem('Eid al-Fitr', 'End of Ramadan', Colors.blue),
            _buildEventItem('Dhul Hijjah', 'Month of Hajj', Colors.orange),
            _buildEventItem('Eid al-Adha', 'Festival of Sacrifice', Colors.red),
            _buildEventItem('Muharram', 'Islamic New Year', Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(String name, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDateDetails(BuildContext context, HijriCalendar date) {
    final gregorian = date.hijriToGregorian(date.hYear, date.hMonth, date.hDay);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Date Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hijri: ${date.hDay} ${date.getLongMonthName()} ${date.hYear} AH'),
            const SizedBox(height: 8),
            Text('Gregorian: ${gregorian.day} ${_getGregorianMonthName(gregorian.month)} ${gregorian.year}'),
            const SizedBox(height: 8),
            Text('Day: ${_getDayName(gregorian.weekday)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getGregorianMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }
}