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

    // Use specific colors from the provided HTML reference
    final primaryColor = const Color(0xFF4B645C); // Greenish text
    final primaryContainer = const Color(0xFFCDE9DE); // Light green bg
    final cardBgColor = const Color(0xFFFFFFFF); // Surface Container Lowest
    
    return GestureDetector(
      onTap: () => onToggle(done),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFFFCF9F8),
            title: const Text('Delete Habit?', style: TextStyle(color: Color(0xFF323233))),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFF5F5F5F)))),
              TextButton(
                onPressed: () {
                  context.read<HabitProvider>().deleteHabit(habit);
                  Navigator.pop(ctx);
                },
                child: const Text('Delete', style: TextStyle(color: Color(0xFFA83836))), // error red
              ),
            ],
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: done ? primaryColor.withOpacity(0.3) : const Color(0xFF4B645C).withOpacity(0.1), 
            width: 1
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2C443D).withOpacity(0.04), // soft shadow
              blurRadius: 20,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            // Check icon positioned top right if done
            if (done)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4B645C),
                    size: 24,
                  ),
                ),
              ),
              
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon Circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: habit.icon.startsWith('assets/')
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(habit.icon, width: 24, height: 24, fit: BoxFit.cover)
                        )
                      : Text(habit.icon, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                
                // Texts
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title, 
                      style: const TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w600, 
                        color: Color(0xFF323233), // on-surface
                      )
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${habit.streak} ${AppStrings.get('days', context).toUpperCase()}", 
                      style: const TextStyle(
                        color: Color(0xFF5F5F5F), // on-surface-variant
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      )
                    ),
                  ],
                ),
                
                // Money and Progress Bar
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "¥${(habit.streak * habit.costPerDay).toStringAsFixed(0)}",
                          style: TextStyle(
                            color: primaryColor, 
                            fontSize: 14, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                        // Mock tiny progress bar
                        Container(
                          height: 4,
                          width: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAE8E7), // surface-container-high
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: done ? 1.0 : (habit.streak % 10) / 10.0, // pseudo progress
                            child: Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
