import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/habit_provider.dart';
import 'screens/home_screen.dart';

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
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFCF9F8), // background color
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4B645C), // primary
          secondary: Color(0xFFCDE8E1), // secondary container
          surface: Color(0xFFFCF9F8),
          error: Color(0xFFA83836),
          onPrimary: Color(0xFFE4FFF4),
          onSecondary: Color(0xFF3E5751),
          onSurface: Color(0xFF323233),
          onError: Color(0xFFFFF7F6),
        ),
        useMaterial3: true,
        fontFamily: 'Inter', // Default to Inter as per HTML body
      ),
      home: const HomeScreen(),
    );
  }
}
