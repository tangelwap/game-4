import 'package:hive/hive.dart';

part 'habit.g.dart';

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
  final double costPerDay;

  Habit({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.history,
    required this.createdAt,
    this.costPerDay = 0.0,
  });

  int get streak => history.length;
  
  double get totalSaved => streak * costPerDay;

  bool get isDoneToday {
    if (history.isEmpty) return false;
    final now = DateTime.now();
    return history.any((dt) => 
      dt.year == now.year && dt.month == now.month && dt.day == now.day
    );
  }
}
