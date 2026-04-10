import 'package:hive/hive.dart';
import 'habit.dart';

// Manual fallback generator code for Hive
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
