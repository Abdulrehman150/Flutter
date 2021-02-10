import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import './Screens/Home_Screen.dart';
import './Screens/Registration_Screen.dart';
import './Screens/Login_Screen.dart';
import './services/Navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Spark',
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: ThemeData(
        //   textTheme: GoogleFonts.nunitoSansTextTheme(Theme.of(context).textTheme),
        brightness: Brightness.dark,
        primaryColor: Color.fromRGBO(42, 117, 188, 1),
        accentColor: Color.fromRGBO(42, 117, 188, 1),
        backgroundColor: Color.fromRGBO(28, 27, 27, 1),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: "login",
      routes: {
        "login": (BuildContext _context) => LoginScreen(),
        "register": (BuildContext _context) => RegistrationPage(),
        "home": (BuildContext _context) => HomeScreen(),
      },
    );
  }
}
