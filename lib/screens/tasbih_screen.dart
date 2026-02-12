import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/vibration_service.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> with TickerProviderStateMixin {
  int _count = 0;
  int _totalCount = 0;
  int _targetCount = 33;
  String _selectedDhikr = 'سُبْحَانَ اللَّهِ';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<String> _commonDhikr = [
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
    _loadSettings();
    _initializeAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _count = prefs.getInt('tasbih_count') ?? 0;
      _totalCount = prefs.getInt('tasbih_total_count') ?? 0;
      _targetCount = prefs.getInt('tasbih_target_count') ?? 33;
      _selectedDhikr = prefs.getString('tasbih_selected_dhikr') ?? 'سُبْحَانَ اللَّهِ';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_count', _count);
    await prefs.setInt('tasbih_total_count', _totalCount);
    await prefs.setInt('tasbih_target_count', _targetCount);
    await prefs.setString('tasbih_selected_dhikr', _selectedDhikr);
  }

  void _incrementCount() {
    setState(() {
      _count++;
      _totalCount++;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    VibrationService.vibrate();

    if (_count >= _targetCount) {
      _showCompletionDialog();
    }

    _saveSettings();
  }

  void _resetCount() {
    setState(() {
      _count = 0;
    });
    _saveSettings();
  }

  void _resetAll() {
    setState(() {
      _count = 0;
      _totalCount = 0;
    });
    _saveSettings();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('MashaAllah!'),
        content: Text(
          'You have completed $_targetCount repetitions of\n$_selectedDhikr',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetCount();
            },
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetCount();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Tasbih'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildStatsCard(),
              const SizedBox(height: 24),
              _buildDhikrCard(),
              const SizedBox(height: 32),
              _buildCounterButton(),
              const SizedBox(height: 24),
              _buildProgressIndicator(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  'Current',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_count',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  'Target',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_targetCount',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_totalCount',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDhikrCard() {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Current Dhikr',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedDhikr,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontFamily: 'Amiri',
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterButton() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _incrementCount,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TAP',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    final progress = _count / _targetCount;
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}% Complete',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _resetCount,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset Count'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _resetAll,
          icon: const Icon(Icons.delete_sweep),
          label: const Text('Reset All'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
        ),
      ],
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tasbih Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Dhikr:'),
            const SizedBox(height: 12),
            ..._commonDhikr.map((dhikr) => RadioListTile<String>(
              title: Text(
                dhikr,
                style: const TextStyle(fontFamily: 'Amiri'),
              ),
              value: dhikr,
              groupValue: _selectedDhikr,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedDhikr = value;
                  });
                  _saveSettings();
                  Navigator.pop(context);
                }
              },
            )),
            const SizedBox(height: 16),
            const Text('Target Count:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [33, 99, 100].map((target) => ChoiceChip(
                label: Text('$target'),
                selected: _targetCount == target,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _targetCount = target;
                    });
                    _saveSettings();
                  }
                },
              )).toList(),
            ),
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
}