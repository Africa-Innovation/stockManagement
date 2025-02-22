// import 'package:flutter/material.dart';
// import '../utils/session_manager.dart';

// class HomeScreen extends StatelessWidget {
//   Future<void> _logout(BuildContext context) async {
//     await SessionManager.clearSession();
//     Navigator.pushReplacementNamed(context, '/login');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Accueil'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () => _logout(context),
//           ),
//         ],
//       ),
//       body: Center(child: Text('Bienvenue dans l’application de gestion de stock !')),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:stockmanagement/screens/ProductManagementScreen.dart';
import 'package:stockmanagement/screens/ReceiptScreen.dart';
import 'package:stockmanagement/screens/SaleHistoric.dart';
import 'package:stockmanagement/screens/SalesScreen.dart';

import '../utils/session_manager.dart';
        

class HomeScreen extends StatelessWidget {
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
            ListTile(
              leading: Icon(Icons.insert_chart),
              title: Text('Tableau de Bord'),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => DashboardScreen()),
                // );
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Stock Faible'),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => LowStockScreen()),
                // );
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
      body: Center(child: Text('Bienvenue dans l’application de gestion de stock !')),
    );
  }
}
