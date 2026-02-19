import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// ----------------------------------------
// 1. MODELS (Core Data)
// ----------------------------------------
part 'main.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String icon;
  @HiveField(3)
  final int color; // Hex int
  @HiveField(4)
  final List<DateTime> history; // Check-in logs
  @HiveField(5)
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.history,
    required this.createdAt,
  });

  int get streak {
    if (history.isEmpty) return 0;
    // Calculate consecutive days from history
    // Simple logic: sort -> check gaps
    history.sort((a, b) => b.compareTo(a)); // Descending
    int count = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check if done today or yesterday to continue streak
    if (history.first.isAfter(today) || history.first.isAtSameMomentAs(today)) {
      count = 1;
    } else if (history.first.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
       // Streak continued yesterday
       // ... logic needs to iterate
    }
    
    // Simplified streak for MVP: Total check-ins
    return history.length;
  }
  
  bool get isDoneToday {
    if (history.isEmpty) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return history.any((dt) => 
      dt.year == today.year && dt.month == today.month && dt.day == today.day
    );
  }
}

// ----------------------------------------
// 2. PROVIDER (State Management)
// ----------------------------------------
class HabitProvider extends ChangeNotifier {
  late Box<Habit> _box;
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(HabitAdapter());
    _box = await Hive.openBox<Habit>('habits');
    _habits = _box.values.toList();
    
    if (_habits.isEmpty) {
      // Seed Data
      addHabit('戒烟', '🚭', Colors.red.value);
      addHabit('早睡', '🛌', Colors.purple.value);
      addHabit('喝水', '💧', Colors.blue.value);
      addHabit('专注', '🍅', Colors.orange.value);
    }
    notifyListeners();
  }

  void addHabit(String title, String icon, int color) {
    final habit = Habit(
      id: const Uuid().v4(),
      title: title,
      icon: icon,
      color: color,
      history: [],
      createdAt: DateTime.now(),
    );
    _box.put(habit.id, habit);
    _habits.add(habit);
    notifyListeners();
  }

  void checkIn(Habit habit) {
    if (habit.isDoneToday) return;
    habit.history.add(DateTime.now());
    habit.save();
    notifyListeners();
  }
}

// ----------------------------------------
// 3. UI (Screens)
// ----------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = HabitProvider();
  await provider.init();
  
  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The One Thing',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitProvider>().habits;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('今日自律', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  Text('The One Thing', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
            
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: habits.length,
                itemBuilder: (ctx, i) => HabitCard(habit: habits[i]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           // TODO: Add Habit Dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HabitCard extends StatelessWidget {
  final Habit habit;
  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final done = habit.isDoneToday;
    final color = Color(habit.color);

    return GestureDetector(
      onTap: () {
        if (!done) {
          context.read<HabitProvider>().checkIn(habit);
          // Haptic Feedback here (if plugin added)
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: done ? color.withOpacity(0.2) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: done ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: done ? [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)
          ] : [],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(habit.icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            Text(habit.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              done ? '已完成' : '点击打卡',
              style: TextStyle(
                color: done ? color : Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text('${habit.streak} 天', style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// GENERATED ADAPTER (Manual Mock for MVP, needs build_runner)
class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;
  @override
  Habit read(BinaryReader reader) {
    return Habit(
      id: reader.read(),
      title: reader.read(),
      icon: reader.read(),
      color: reader.read(),
      history: (reader.read() as List).cast<DateTime>(),
      createdAt: reader.read(),
    );
  }
  @override
  void write(BinaryWriter writer, Habit obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.icon);
    writer.write(obj.color);
    writer.write(obj.history);
    writer.write(obj.createdAt);
  }
}
