import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

// ----------------------------------------
// 1. CONFIG & LOCALIZATION (V2.0 New)
// ----------------------------------------
class AppStrings {
  static Map<String, Map<String, String>> localizedValues = {
    'en': {
      'app_title': 'Quit What?',
      'subtitle': 'Discipline & Savings',
      'total_saved': 'Total Saved',
      'days': 'Days',
      'check_in': 'Check In',
      'done': 'Done',
      'add_habit': 'Add Habit',
      'habit_name': 'Habit Name',
      'cost_per_day': 'Cost Per Day',
      'save': 'Save',
      'cancel': 'Cancel',
      'purchasable': 'You can buy:',
    },
    'zh': {
      'app_title': '戒什么',
      'subtitle': '自律与搞钱',
      'total_saved': '累计节省',
      'days': '天',
      'check_in': '打卡',
      'done': '已完成',
      'add_habit': '添加习惯',
      'habit_name': '习惯名称',
      'cost_per_day': '日均开销 (元)',
      'save': '保存',
      'cancel': '取消',
      'purchasable': '这笔钱够买：',
    },
  };

  static String get(String key, BuildContext context) {
    // Simple locale detection
    final locale = Localizations.localeOf(context).languageCode;
    final lang = (locale == 'zh') ? 'zh' : 'en';
    return localizedValues[lang]?[key] ?? key;
  }
}

// ----------------------------------------
// 2. MODELS (Updated for Savings)
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
  final int color;
  @HiveField(4)
  final List<DateTime> history;
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  final double costPerDay; // New: Daily savings value

  Habit({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.history,
    required this.createdAt,
    this.costPerDay = 0.0,
  });

  int get streak => history.length; // Simplified for MVP
  
  double get totalSaved => streak * costPerDay;

  bool get isDoneToday {
    if (history.isEmpty) return false;
    final now = DateTime.now();
    return history.any((dt) => 
      dt.year == now.year && dt.month == now.month && dt.day == now.day
    );
  }
}

// ----------------------------------------
// 3. PROVIDER
// ----------------------------------------
class HabitProvider extends ChangeNotifier {
  late Box<Habit> _box;
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;
  
  double get totalSavings => _habits.fold(0.0, (sum, h) => sum + h.totalSaved);

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(HabitAdapter());
    _box = await Hive.openBox<Habit>('habits_v2');
    _habits = _box.values.toList();
    
    if (_habits.isEmpty) {
      // Seed V2 Data
      addHabit('Smoking', '🚭', 0xFFE57373, 25.0); // ~25 RMB/pack
      addHabit('Coffee', '☕', 0xFFBA68C8, 30.0);  // ~30 RMB
      addHabit('Late Night', '🌙', 0xFF64B5F6, 0.0);
    }
    notifyListeners();
  }

  void addHabit(String title, String icon, int color, double cost) {
    final habit = Habit(
      id: const Uuid().v4(),
      title: title,
      icon: icon,
      color: color,
      history: [],
      createdAt: DateTime.now(),
      costPerDay: cost,
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
  
  void deleteHabit(Habit habit) {
    habit.delete();
    _habits.remove(habit);
    notifyListeners();
  }
}

// ----------------------------------------
// 4. UI (V2.0 - Dashboard Style)
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
      title: 'Quit What?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF69F0AE), // Neon Green for money
          secondary: Color(0xFF448AFF),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', 
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final savings = provider.totalSavings;
    final currency = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- Header: Savings Dashboard ---
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
                  const SizedBox(height: 12),
                  // "Purchasable" logic (Simple fun logic)
                  if (savings > 300) 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text(
                        "${AppStrings.get('purchasable', context)} 🎮 3A Game",
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                ],
              ),
            ),
            
            // --- Habit Grid ---
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
                itemBuilder: (ctx, i) => HabitCard(habit: provider.habits[i]),
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
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: Text(AppStrings.get('add_habit', context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl, 
              decoration: InputDecoration(
                labelText: AppStrings.get('habit_name', context),
                prefixIcon: const Icon(Icons.edit)
              )
            ),
            const SizedBox(height: 12),
            TextField(
              controller: costCtrl, 
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppStrings.get('cost_per_day', context),
                prefixIcon: const Icon(Icons.attach_money)
              )
            ),
          ],
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
                  '🎯', // Default icon for manual add
                  0xFFFFFFFF, 
                  double.tryParse(costCtrl.text) ?? 0.0
                );
                Navigator.pop(ctx);
              }
            }, 
            child: Text(AppStrings.get('save', context), style: const TextStyle(color: Colors.black))
          ),
        ],
      )
    );
  }
}

class HabitCard extends StatelessWidget {
  final Habit habit;
  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final done = habit.isDoneToday;
    // Dynamic color based on done status
    final baseColor = Color(habit.color);
    final cardColor = done ? baseColor.withOpacity(0.15) : const Color(0xFF1E1E1E);
    final borderColor = done ? baseColor : Colors.transparent;

    return GestureDetector(
      onTap: () {
        if (!done) {
          context.read<HabitProvider>().checkIn(habit);
        }
      },
      onLongPress: () {
        // Delete option
        context.read<HabitProvider>().deleteHabit(habit);
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
            // Background Icon Faded
            Positioned(
              right: -10, bottom: -10,
              child: Opacity(
                opacity: 0.1,
                child: Text(habit.icon, style: const TextStyle(fontSize: 100)),
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
                      Text(habit.icon, style: const TextStyle(fontSize: 32)),
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

// ADAPTER (Mock, manual implementation for Hive without build_runner)
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
      costPerDay: reader.read(),
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
    writer.write(obj.costPerDay);
  }
}
