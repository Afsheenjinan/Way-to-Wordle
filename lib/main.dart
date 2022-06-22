// import 'package:device_preview/device_preview.dart';
// import 'package:device_preview_screenshot/device_preview_screenshot.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

// const bool debugMode = bool.fromEnvironment('dart.vm.product');

// void main() {
//   runApp(debugMode
//       ? DevicePreview(
//           enabled: debugMode,
//           builder: (context) => const MyApp(),
//           tools: [
//             DevicePreviewScreenshot(
//               onScreenshot: screenshotAsFiles(Directory(r'C:\Users\Ali\Desktop\')),
//             ),
//             ...DevicePreview.defaultTools,
//           ],
//         )
//       : const MyApp());
// }

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<SharedPreferences> sharedPreferences = _getSharedPreferences();

    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      // useInheritedMediaQuery: debugMode ? true : false,
      // locale: debugMode ? DevicePreview.locale(context) : null,
      // builder: debugMode ? DevicePreview.appBuilder : null,
      title: 'Guess The Word | WORDLE',
      themeMode: ThemeMode.system,
      theme: ThemeData.light().copyWith(
          appBarTheme:
              const AppBarTheme(titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 0.15))),
      darkTheme: ThemeData.dark(),
      home: FutureBuilder(
          future: sharedPreferences,
          builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Scaffold();
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
