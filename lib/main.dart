import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    Future<SharedPreferences> sharedPreferences = _getSharedPreferences();

    return MaterialApp(
      title: 'WORDLE in a Minute',
      themeMode: ThemeMode.light, // TODO:
      theme: _lightTheme,
      darkTheme: _darktheme,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
          future: sharedPreferences,
          builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(
                  child: Text('Waiting'),
                );
              case ConnectionState.done:
                return HomePage(pref: sharedPreferences, snapshot: snapshot);
              default:
                return Container();
            }
          }),
    );
  }
}

Future<SharedPreferences> _getSharedPreferences() async {
  return await SharedPreferences.getInstance();
}
