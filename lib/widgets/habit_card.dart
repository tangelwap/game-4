import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../utils/app_strings.dart';
import 'package:provider/provider.dart';
import '../services/habit_provider.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final Function(bool isDone) onToggle;

  const HabitCard({super.key, required this.habit, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final done = habit.isDoneToday;
    final baseColor = Color(habit.color);
    final cardColor = done ? baseColor.withOpacity(0.15) : const Color(0xFF1E1E1E);
    final borderColor = done ? baseColor : Colors.transparent;

    return GestureDetector(
      onTap: () => onToggle(done),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Habit?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  context.read<HabitProvider>().deleteHabit(habit);
                  Navigator.pop(ctx);
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: done ? [
            BoxShadow(color: baseColor.withOpacity(0.4), blurRadius: 12, spreadRadius: -2)
          ] : [],
        ),
        child: Stack(
          children: [
            // Background Faded Asset
            Positioned(
              right: -20, bottom: -20,
              child: Opacity(
                opacity: 0.1,
                child: habit.icon.startsWith('assets/') 
                    ? Image.asset(habit.icon, width: 140, height: 140, fit: BoxFit.cover)
                    : Text(habit.icon, style: const TextStyle(fontSize: 100)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      habit.icon.startsWith('assets/')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(habit.icon, width: 48, height: 48, fit: BoxFit.cover)
                            )
                          : Text(habit.icon, style: const TextStyle(fontSize: 32)),
                          
                      if (done) 
                        const Icon(Icons.check_circle, color: Colors.white, size: 24)
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title, 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.2)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${habit.streak} ${AppStrings.get('days', context)}", 
                        style: TextStyle(color: done ? Colors.white : Colors.grey, fontSize: 12)
                      ),
                      if (habit.costPerDay > 0)
                        Text(
                          "+¥${(habit.streak * habit.costPerDay).toStringAsFixed(0)}",
                          style: const TextStyle(color: Color(0xFF69F0AE), fontSize: 12, fontWeight: FontWeight.w600)
                        )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
