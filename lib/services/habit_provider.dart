import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';

class HabitProvider extends ChangeNotifier {
  late Box<Habit> _box;
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;
  double get totalSavings => _habits.fold(0.0, (sum, h) => sum + h.totalSaved);

  Future<void> init() async {
    await Hive.initFlutter();
    // In dev, if generated adapter doesn't exist yet, we might need a fallback or just require build_runner.
    // Assuming build_runner will be run.
    try {
      Hive.registerAdapter(HabitAdapter());
    } catch (e) {
      debugPrint('Adapter error: $e');
    }
    _box = await Hive.openBox<Habit>('habits_v2');
    _habits = _box.values.toList();
    
    if (_habits.isEmpty) {
      addHabit('Energy', 'assets/icons/nofap.png', 0xFFFFD700, 0.0); 
      addHabit('Smoking', 'assets/icons/smoking.png', 0xFFE57373, 25.0); 
      addHabit('Sugar', 'assets/icons/sugar.png', 0xFFBA68C8, 30.0);  
      addHabit('Sleep', 'assets/icons/sleep.png', 0xFF64B5F6, 0.0); 
      addHabit('Money', 'assets/icons/money.png', 0xFF81C784, 50.0); 
    }
    notifyListeners();
  }

  void addHabit(String title, String iconPath, int color, double cost) {
    final habit = Habit(
      id: const Uuid().v4(),
      title: title,
      icon: iconPath,
      color: color,
      history: [],
      createdAt: DateTime.now(),
      costPerDay: cost,
    );
    _box.put(habit.id, habit);
    _habits.add(habit);
    notifyListeners();
  }

  void toggleCheckIn(Habit habit) {
    if (habit.isDoneToday) {
      // Undo today's check-in
      final now = DateTime.now();
      habit.history.removeWhere((dt) => 
        dt.year == now.year && dt.month == now.month && dt.day == now.day
      );
    } else {
      // Check in
      habit.history.add(DateTime.now());
    }
    habit.save();
    notifyListeners();
  }
  
  void deleteHabit(Habit habit) {
    habit.delete();
    _habits.remove(habit);
    notifyListeners();
  }
}
