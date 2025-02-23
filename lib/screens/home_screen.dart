import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:stockmanagement/screens/ProductManagementScreen.dart';
import 'package:stockmanagement/screens/ReceiptScreen.dart';
import 'package:stockmanagement/screens/SaleHistoric.dart';
import 'package:stockmanagement/screens/SalesScreen.dart';
import '../utils/session_manager.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String expression = "";
  String result = "0";

  void _onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        expression = "";
        result = "0";
      } else if (value == "=") {
        try {
          Parser p = Parser();
          Expression exp = p.parse(expression);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          result = eval.toString();
        } catch (e) {
          result = "Erreur";
        }
      } else {
        expression += value;
      }
    });
  }

  Future<void> _logout(BuildContext context) async {
    await SessionManager.clearSession();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion de Stock'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Nom Utilisateur'),
              accountEmail: Text('Utilisateur@exemple.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue),
              ),
            ),
            ListTile(
              leading: Icon(Icons.store),
              title: Text('Gestion des Produits'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductManagementScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Ventes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SaleScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt),
              title: Text('Reçus'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReceiptScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Historique des Achats'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SaleHistoryScreen()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Déconnexion'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Column(

        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Bienvenue sur l'app de gestion de stock",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              result,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              expression,
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.5,
              ),
              itemCount: buttons.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () => _onButtonPressed(buttons[index]),
                  child: Text(
                    buttons[index],
                    style: TextStyle(fontSize: 24),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

const List<String> buttons = [
  "7", "8", "9", "/",
  "4", "5", "6", "*",
  "1", "2", "3", "-",
  "C", "0", "=", "+"
];
