import 'package:flutter/material.dart';
import 'package:stockmanagement/database/firebase_service.dart';
import '../database/database_helper.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> _registerUser() async {
  if (passwordController.text != confirmPasswordController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Les mots de passe ne correspondent pas !')),
    );
    return;
  }

  await DatabaseHelper.instance.createUser(
    nameController.text,
    phoneController.text,
    passwordController.text,
  );

  await FirebaseService().syncUserToFirebase(
    nameController.text,
    phoneController.text,
    passwordController.text,
  );

  Navigator.pushReplacementNamed(context, '/login');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inscription')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nom')),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Numéro de téléphone')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Mot de passe'), obscureText: true),
            TextField(controller: confirmPasswordController, decoration: InputDecoration(labelText: 'Confirmer mot de passe'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerUser,
              child: Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
