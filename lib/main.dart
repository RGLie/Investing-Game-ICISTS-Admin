import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:investing_game_admin/root_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  MaterialColor kPrimaryColor = const MaterialColor(
    0xFF7568F0,
    const <int, Color>{
      50: const Color(0xFF7568F0),
      100: const Color(0xFF7568F0),
      200: const Color(0xFF7568F0),
      300: const Color(0xFF7568F0),
      400: const Color(0xFF7568F0),
      500: const Color(0xFF7568F0),
      600: const Color(0xFF7568F0),
      700: const Color(0xFF7568F0),
      800: const Color(0xFF7568F0),
      900: const Color(0xFF7568F0),
    },
  );
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',
      theme: ThemeData(
        fontFamily: 'SpoqaHanSansNeo',
        primarySwatch: kPrimaryColor,

      ),
      home: RootPage(),
    );
  }
}
