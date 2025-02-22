import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stockmanagement/Model/product_model.dart';
import 'package:stockmanagement/Model/vente_model.dart';
import 'package:stockmanagement/database/database_helper.dart';
import 'package:stockmanagement/firebase_options.dart';
import 'package:stockmanagement/screens/home_screen.dart';
import 'package:stockmanagement/screens/login_screen.dart';
import 'package:stockmanagement/screens/signup_screen.dart';
import 'package:stockmanagement/utils/session_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final String? userPhone = await SessionManager.getUserSession();
  runApp(MyApp(initialRoute: userPhone != null ? '/home' : '/login'));
  
//   Sale venteTest = Sale(
//   id: 0,  // SQLite AUTO_INCREMENT prendra le relais
//   clientName: "John Doe",
//   products: [
//     Product(id: 1, name: "Produit Test", quantity: 2, price: 10.0, minStock: 1)
//   ],
//   totalPrice: 20.0,
//   date: DateTime.now(),
// );

// await DatabaseHelper.instance.insertSale(venteTest);

}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion de Stock',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: initialRoute,
      routes: {
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}