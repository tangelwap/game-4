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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF69F0AE), 
          secondary: Color(0xFF448AFF),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', 
      ),
      home: const HomeScreen(),
    );
  }
}
