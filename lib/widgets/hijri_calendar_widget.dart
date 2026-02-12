import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

class HijriCalendarWidget extends StatefulWidget {
  final HijriCalendar currentMonth;
  final HijriCalendar selectedDate;
  final Function(HijriCalendar) onDateSelected;
  final Function(HijriCalendar) onMonthChanged;

  const HijriCalendarWidget({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  @override
  State<HijriCalendarWidget> createState() => _HijriCalendarWidgetState();
}

class _HijriCalendarWidgetState extends State<HijriCalendarWidget> {
  late HijriCalendar _displayMonth;

  @override
  void initState() {
    super.initState();
    _displayMonth = widget.currentMonth;
  }

  @override
  void didUpdateWidget(HijriCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth != widget.currentMonth) {
      setState(() {
        _displayMonth = widget.currentMonth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildWeekdayHeaders(),
            const SizedBox(height: 8),
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    
    return Row(
      children: weekdays.map((day) => Expanded(
        child: Center(
          child: Text(
            day,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth(_displayMonth.hYear, _displayMonth.hMonth);
    final firstWeekday = _getFirstWeekdayOfMonth(_displayMonth.hYear, _displayMonth.hMonth);
    
    final rows = <Widget>[];
    var dayCount = 1;

    for (int week = 0; week < 6; week++) {
      final dayWidgets = <Widget>[];
      
      for (int weekday = 0; weekday < 7; weekday++) {
        if (week == 0 && weekday < firstWeekday) {
          dayWidgets.add(const SizedBox());
        } else if (dayCount > daysInMonth) {
          dayWidgets.add(const SizedBox());
        } else {
          final currentDate = HijriCalendar.addMonth(
            _displayMonth.hYear,
            _displayMonth.hMonth,
          )..hDay = dayCount;
          
          final isSelected = widget.selectedDate.hYear == _displayMonth.hYear &&
                           widget.selectedDate.hMonth == _displayMonth.hMonth &&
                           widget.selectedDate.hDay == dayCount;
          
          final isToday = _isToday(currentDate);
          
          dayWidgets.add(
            GestureDetector(
              onTap: () => widget.onDateSelected(currentDate),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : isToday
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday && !isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$dayCount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : isToday
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
              ),
            ),
          );
          dayCount++;
        }
      }
      
      rows.add(Row(children: dayWidgets));
      
      if (dayCount > daysInMonth) break;
    }

    return Column(children: rows);
  }

  int _getDaysInMonth(int year, int month) {
    if (month == 12) {
      return 30;
    } else if (month % 2 == 1) {
      return 30;
    } else {
      return 29;
    }
  }

  int _getFirstWeekdayOfMonth(int year, int month) {
    final firstDay = HijriCalendar.addMonth(year, month);
    final gregorian = firstDay.hijriToGregorian(year, month, 1);
    
    return (gregorian.weekday + 1) % 7;
  }

  bool _isToday(HijriCalendar date) {
    final today = HijriCalendar.now();
    return today.hYear == date.hYear &&
           today.hMonth == date.hMonth &&
           today.hDay == date.hDay;
  }
}