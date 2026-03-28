import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_theme.dart';
import '../services/vibration_service.dart';
import '../widgets/decorative_backdrop.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> with TickerProviderStateMixin {
  static const int _dailyGoalRounds = 3;

  int _count = 0;
  int _totalCount = 0;
  int _targetCount = 33;
  int _completedRounds = 0;
  int _dailyCompletedRounds = 0;
  int _currentStreak = 0;
  String _selectedDhikr = 'سُبْحَانَ اللَّهِ';
  String _lastCompletionDate = '';
  bool _justCompletedRound = false;

  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  Timer? _completionTimer;

  final List<String> _commonDhikr = <String>[
    'سُبْحَانَ اللَّهِ',
    'الْحَمْدُ لِلَّهِ',
    'اللَّهُ أَكْبَرُ',
    'لَا إِلَهَ إِلَّا اللَّهُ',
    'أَسْتَغْفِرُ اللَّهَ',
    'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 170),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.96,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _loadSettings();
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dateKey(DateTime.now());
    final storedLastCompletion = prefs.getString('tasbih_last_completion_date') ?? '';
    final storedDailyRounds = prefs.getInt('tasbih_daily_completed_rounds') ?? 0;

    setState(() {
      _count = prefs.getInt('tasbih_count') ?? 0;
      _totalCount = prefs.getInt('tasbih_total_count') ?? 0;
      _targetCount = prefs.getInt('tasbih_target_count') ?? 33;
      _selectedDhikr = prefs.getString('tasbih_selected_dhikr') ?? _commonDhikr.first;
      _completedRounds = prefs.getInt('tasbih_completed_rounds') ?? 0;
      _currentStreak = prefs.getInt('tasbih_current_streak') ?? 0;
      _lastCompletionDate = storedLastCompletion;
      _dailyCompletedRounds = storedLastCompletion == todayKey ? storedDailyRounds : 0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_count', _count);
    await prefs.setInt('tasbih_total_count', _totalCount);
    await prefs.setInt('tasbih_target_count', _targetCount);
    await prefs.setString('tasbih_selected_dhikr', _selectedDhikr);
    await prefs.setInt('tasbih_completed_rounds', _completedRounds);
    await prefs.setInt('tasbih_daily_completed_rounds', _dailyCompletedRounds);
    await prefs.setInt('tasbih_current_streak', _currentStreak);
    await prefs.setString('tasbih_last_completion_date', _lastCompletionDate);
  }

  Future<void> _incrementCount() async {
    setState(() {
      _count += 1;
      _totalCount += 1;
    });

    await _animationController.forward();
    await _animationController.reverse();
    VibrationService.vibrate();

    if (_count >= _targetCount) {
      await _completeRound();
    } else {
      await _saveSettings();
    }
  }

  Future<void> _decrementCount() async {
    if (_count == 0) return;
    setState(() {
      _count -= 1;
      if (_totalCount > 0) {
        _totalCount -= 1;
      }
    });
    await _saveSettings();
  }

  Future<void> _completeRound() async {
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    final yesterdayKey = _dateKey(now.subtract(const Duration(days: 1)));

    _completionTimer?.cancel();
    setState(() {
      _completedRounds += 1;
      if (_lastCompletionDate == todayKey) {
        _dailyCompletedRounds += 1;
      } else {
        _dailyCompletedRounds = 1;
        _currentStreak = _lastCompletionDate == yesterdayKey ? _currentStreak + 1 : 1;
        _lastCompletionDate = todayKey;
      }
      _count = 0;
      _justCompletedRound = true;
    });

    VibrationService.vibrateHeavy();
    await _saveSettings();
    _completionTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _justCompletedRound = false);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _dailyCompletedRounds >= _dailyGoalRounds
              ? 'Round complete. Daily goal reached.'
              : 'Round complete. $_dailyCompletedRounds of $_dailyGoalRounds daily rounds finished.',
        ),
      ),
    );
  }

  Future<void> _resetCount() async {
    setState(() => _count = 0);
    await _saveSettings();
  }

  Future<void> _resetAll() async {
    setState(() {
      _count = 0;
      _totalCount = 0;
      _completedRounds = 0;
      _dailyCompletedRounds = 0;
      _currentStreak = 0;
      _lastCompletionDate = '';
    });
    await _saveSettings();
  }

  Future<void> _setTarget(int target) async {
    setState(() => _targetCount = target);
    await _saveSettings();
  }

  Future<void> _setDhikr(String dhikr) async {
    setState(() => _selectedDhikr = dhikr);
    await _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _count / _targetCount;
    final goalProgress = (_dailyCompletedRounds / _dailyGoalRounds).clamp(0.0, 1.0);

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
              _buildHeroCard(context, goalProgress),
              const SizedBox(height: 16),
              _buildCounter(context, progress),
              const SizedBox(height: 16),
              _buildSessionDeck(context),
              const SizedBox(height: 18),
              _buildActionRow(context),
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
        Text('Tasbih', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'A calmer counter with daily goals, streaks, and gentle feedback.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, double goalProgress) {
    final goalReached = _dailyCompletedRounds >= _dailyGoalRounds;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.emerald,
            AppColors.emeraldSoft,
            Color(0xFF153F35),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.28),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current dhikr',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
          ),
          const SizedBox(height: 10),
          Text(
            _selectedDhikr,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'Target',
                  value: _targetCount.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroStat(
                  label: 'Streak',
                  value: '$_currentStreak days',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroStat(
                  label: 'Rounds',
                  value: _completedRounds.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: goalProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.14),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Daily goal: $_dailyCompletedRounds of $_dailyGoalRounds rounds',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
          ),
          if (goalReached) ...[
            const SizedBox(height: 12),
            const _GoalPill(
              icon: Icons.workspace_premium_rounded,
              label: 'Daily tasbih goal complete',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCounter(BuildContext context, double progress) {
    final remaining = (_targetCount - _count).clamp(0, _targetCount);
    final counterGradient = _justCompletedRound
        ? const [
            AppColors.gold,
            Color(0xFFD7B06C),
          ]
        : const [
            AppColors.emerald,
            AppColors.emeraldSoft,
          ];
    final statusLabel = _justCompletedRound ? 'Round complete' : 'Tap to count';
    final statusDetail = _justCompletedRound
        ? (_dailyCompletedRounds >= _dailyGoalRounds
            ? 'Daily goal reached'
            : 'Steady progress for today')
        : '$remaining remaining';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFECE2D3)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          children: [
            SizedBox(
              width: 292,
              height: 292,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedProgress, child) {
                      return SizedBox(
                        width: 262,
                        height: 262,
                        child: CircularProgressIndicator(
                          value: animatedProgress,
                          strokeWidth: 14,
                          backgroundColor: const Color(0xFFE7DED0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.emerald,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 238,
                    height: 238,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      key: const ValueKey<String>('tasbih-counter-button'),
                      onTap: _incrementCount,
                      onLongPress: _decrementCount,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: counterGradient,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_justCompletedRound
                                      ? AppColors.gold
                                      : AppColors.emerald)
                                  .withValues(alpha: 0.26),
                              blurRadius: 30,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: Tween<double>(
                                    begin: 0.9,
                                    end: 1,
                                  ).animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                '$_count',
                                key: ValueKey<int>(_count),
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              child: Text(
                                statusLabel,
                                key: ValueKey<String>(statusLabel),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.92),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              child: Text(
                                statusDetail,
                                key: ValueKey<String>(statusDetail),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.78),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Text(
                _justCompletedRound
                    ? 'A round has just been completed'
                    : '${(progress * 100).toInt()}% of this round complete',
                key: ValueKey<String>(
                  _justCompletedRound ? 'round-complete' : 'round-progress',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _SessionPill(label: 'Today $_dailyCompletedRounds/$_dailyGoalRounds'),
                _SessionPill(label: 'Lifetime $_totalCount'),
                const _SessionPill(label: 'Long press to undo'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionDeck(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFECE2D3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session setup', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Choose the remembrance, set the round target, and stay aware of your spiritual momentum.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text('Dhikr set', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _commonDhikr.map((dhikr) {
                final selected = _selectedDhikr == dhikr;
                return ChoiceChip(
                  selected: selected,
                  label: Text(
                    dhikr,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Amiri',
                          color: selected ? AppColors.emerald : AppColors.ink,
                        ),
                  ),
                  onSelected: (_) => _setDhikr(dhikr),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Text('Round target', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <int>[33, 99, 100].map((target) {
                return ChoiceChip(
                  label: Text('$target'),
                  selected: _targetCount == target,
                  onSelected: (_) => _setTarget(target),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Current round',
                    value: '$_count / $_targetCount',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Today',
                    value: '$_dailyCompletedRounds rounds',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Streak',
                    value: '$_currentStreak days',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetCount,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset round'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: _resetAll,
            icon: const Icon(Icons.delete_sweep_rounded),
            label: const Text('Reset all'),
          ),
        ),
      ],
    );
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _SessionPill extends StatelessWidget {
  const _SessionPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
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
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

class _GoalPill extends StatelessWidget {
  const _GoalPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
