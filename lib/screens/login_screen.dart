import 'package:flutter/material.dart';
import 'package:stockmanagement/database/firebase_service.dart';
import '../database/database_helper.dart';
import '../utils/session_manager.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _loginUser() async {
  final user = await DatabaseHelper.instance.getUser(
    phoneController.text,
    passwordController.text,
  );

  if (user == null) {
    final firebaseUser = await FirebaseService().getUserFromFirebase(phoneController.text);
    if (firebaseUser != null && firebaseUser['password'] == passwordController.text) {
      await SessionManager.saveUserSession(firebaseUser['phone']);
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }
  }

  if (user != null) {
    await SessionManager.saveUserSession(user['phone']);
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Numéro ou mot de passe incorrect !')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Numéro de téléphone')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Mot de passe'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginUser,
              child: Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
