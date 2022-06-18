import 'package:flutter/material.dart';

import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

ThemeData _lightTheme = ThemeData(brightness: Brightness.light);
ThemeData _darktheme = ThemeData(brightness: Brightness.dark);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WORDLE in a Minute',
      themeMode: ThemeMode.light, // TODO:
      theme: _lightTheme,
      darkTheme: _darktheme,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
