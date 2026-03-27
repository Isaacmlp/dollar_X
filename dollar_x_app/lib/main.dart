import 'package:dollar_x_app/presentation/Constants/colors.dart';
import 'package:dollar_x_app/presentation/screens/home.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: AppColors.secondary,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}
