import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

import '../app_formatters.dart';
import '../app_theme.dart';
import '../widgets/decorative_backdrop.dart';
import '../widgets/hijri_calendar_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late HijriCalendar _selectedDate;
  late HijriCalendar _currentMonth;

  static const List<_IslamicEvent> _events = <_IslamicEvent>[
    _IslamicEvent(month: 1, day: 1, title: 'Islamic New Year', subtitle: 'Opening day of Muharram'),
    _IslamicEvent(month: 3, day: 12, title: 'Mawlid', subtitle: 'Observed by many communities'),
    _IslamicEvent(month: 9, day: 1, title: 'Ramadan Begins', subtitle: 'Beginning of the month of fasting'),
    _IslamicEvent(month: 10, day: 1, title: 'Eid al-Fitr', subtitle: 'Festival marking the end of Ramadan'),
    _IslamicEvent(month: 12, day: 8, title: 'Days of Hajj', subtitle: 'Pilgrimage days begin'),
    _IslamicEvent(month: 12, day: 10, title: 'Eid al-Adha', subtitle: 'Festival of sacrifice'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = HijriCalendar.now();
    _currentMonth = HijriCalendar.now();
  }

  @override
  Widget build(BuildContext context) {
    final selectedGregorian = _selectedDate.hijriToGregorian(
      _selectedDate.hYear,
      _selectedDate.hMonth,
      _selectedDate.hDay,
    );
    final currentMonthEvents = _events
        .where((event) => event.month == _currentMonth.hMonth)
        .toList(growable: false);
    final selectedEvent = _eventForDate(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecorativeBackdrop(
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              _buildHeader(context),
              const SizedBox(height: 18),
              _buildHeroCard(context),
              const SizedBox(height: 16),
              _buildMonthNavigator(context, currentMonthEvents.length),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hijri Calendar', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        'Select a date to compare Hijri and Gregorian timing.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 14),
                      HijriCalendarWidget(
                        currentMonth: _currentMonth,
                        selectedDate: _selectedDate,
                        onDateSelected: (date) {
                          setState(() => _selectedDate = date);
                        },
                        onMonthChanged: (month) {
                          setState(() => _currentMonth = month);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSelectedDateCard(context, selectedGregorian, selectedEvent),
              const SizedBox(height: 16),
              _buildEventsCard(context, currentMonthEvents),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Islamic Dates', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'A clearer Hijri view with dual-date context and notable days.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final now = DateTime.now();
    final todayHijri = HijriCalendar.now();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white,
            Color(0xFFF7F1E7),
            Color(0xFFEEE6D8),
          ],
        ),
        border: Border.all(color: const Color(0xFFE8DDCE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.slate,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            '${todayHijri.hDay} ${todayHijri.getLongMonthName()} ${todayHijri.hYear} AH',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.emerald,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${AppFormatters.weekdayName(now.weekday)} • ${AppFormatters.formatDate(now)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DateMetric(
                  label: 'Current month',
                  value: todayHijri.getLongMonthName(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateMetric(
                  label: 'Selected day',
                  value: _selectedDate.hDay.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateMetric(
                  label: 'Events',
                  value: _events.where((event) => event.month == todayHijri.hMonth).length.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigator(BuildContext context, int currentMonthEvents) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
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
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${_currentMonth.getLongMonthName()} ${_currentMonth.hYear} AH',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$currentMonthEvents notable dates in this month',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
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
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateCard(
    BuildContext context,
    DateTime gregorian,
    _IslamicEvent? selectedEvent,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selected Date', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Hijri',
              value: '${_selectedDate.hDay} ${_selectedDate.getLongMonthName()} ${_selectedDate.hYear} AH',
            ),
            const SizedBox(height: 10),
            _InfoRow(
              label: 'Gregorian',
              value: '${gregorian.day} ${_monthName(gregorian.month)} ${gregorian.year}',
            ),
            const SizedBox(height: 10),
            _InfoRow(
              label: 'Weekday',
              value: AppFormatters.weekdayName(gregorian.weekday),
            ),
            if (selectedEvent != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E8CA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedEvent.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedEvent.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventsCard(BuildContext context, List<_IslamicEvent> currentMonthEvents) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notable Dates', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              currentMonthEvents.isEmpty
                  ? 'No major dates are configured for this Hijri month.'
                  : 'A few well-known Islamic dates for quick reference.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            if (currentMonthEvents.isEmpty)
              Text(
                'Move through the Hijri months to see other annual markers.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ...currentMonthEvents.map((event) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          event.day.toString(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.emerald,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.title, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(event.subtitle, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  _IslamicEvent? _eventForDate(HijriCalendar date) {
    try {
      return _events.firstWhere(
        (event) => event.month == date.hMonth && event.day == date.hDay,
      );
    } catch (_) {
      return null;
    }
  }

  String _monthName(int month) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

class _IslamicEvent {
  const _IslamicEvent({
    required this.month,
    required this.day,
    required this.title,
    required this.subtitle,
  });

  final int month;
  final int day;
  final String title;
  final String subtitle;
}

class _DateMetric extends StatelessWidget {
  const _DateMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
