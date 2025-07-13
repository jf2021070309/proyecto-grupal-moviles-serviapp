import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'vista/login_page.dart';
import 'vista/home_page.dart';
import 'vista/home_proveedor_page.dart';
import 'admin/vista/admin_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase MVC',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/home_proveedor': (context) => HomeProveedorPage(),
        '/admin': (context) => AdminHomePage(),
      },
    );
  }
}
