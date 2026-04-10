import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:vibration/vibration.dart';
import '../services/habit_provider.dart';
import '../utils/app_strings.dart';
import '../widgets/habit_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;

  final List<String> availableIcons = [
    'assets/icons/nofap.png',
    'assets/icons/smoking.png',
    'assets/icons/sugar.png',
    'assets/icons/sleep.png',
    'assets/icons/money.png',
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _triggerSuccessEffect() async {
    _confettiController.play();
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 50, 100, 50]);
    }
  }

  void _triggerUndoEffect() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final savings = provider.totalSavings;
    final currency = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Dashboard
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.get('total_saved', context).toUpperCase(),
                        style: const TextStyle(fontSize: 14, letterSpacing: 1.5, color: Colors.white54),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currency.format(savings),
                        style: const TextStyle(
                          fontSize: 48, 
                          fontWeight: FontWeight.w900, 
                          color: Color(0xFF69F0AE),
                          shadows: [Shadow(color: Color(0x6669F0AE), blurRadius: 20)]
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: provider.habits.length,
                    itemBuilder: (ctx, i) => HabitCard(
                      habit: provider.habits[i],
                      onToggle: (isDone) {
                        provider.toggleCheckIn(provider.habits[i]);
                        if (!isDone) {
                          _triggerSuccessEffect();
                        } else {
                          _triggerUndoEffect();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            // Confetti layer
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                maxBlastForce: 20,
                minBlastForce: 8,
                gravity: 0.2,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: const Color(0xFF69F0AE),
        label: Text(AppStrings.get('add_habit', context), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    String selectedIcon = availableIcons.first;

    showDialog(
      context: context, 
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF222222),
              title: Text(AppStrings.get('add_habit', context)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl, 
                      decoration: InputDecoration(labelText: AppStrings.get('habit_name', context))
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: costCtrl, 
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: AppStrings.get('cost_per_day', context))
                    ),
                    const SizedBox(height: 20),
                    const Text("Select Icon", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: availableIcons.length,
                        itemBuilder: (context, index) {
                          final icon = availableIcons[index];
                          final isSelected = icon == selectedIcon;
                          return GestureDetector(
                            onTap: () => setState(() => selectedIcon = icon),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: isSelected ? const Color(0xFF69F0AE) : Colors.transparent, width: 2),
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFF1A1A1A),
                              ),
                              child: Image.asset(icon, width: 40, height: 40),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx), 
                  child: Text(AppStrings.get('cancel', context))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF69F0AE)),
                  onPressed: () {
                    if (titleCtrl.text.isNotEmpty) {
                      ctx.read<HabitProvider>().addHabit(
                        titleCtrl.text, 
                        selectedIcon,
                        0xFFFFFFFF, 
                        double.tryParse(costCtrl.text) ?? 0.0
                      );
                      Navigator.pop(ctx);
                    }
                  }, 
                  child: Text(AppStrings.get('save', context), style: const TextStyle(color: Colors.black))
                ),
              ],
            );
          }
        );
      }
    );
  }
}
