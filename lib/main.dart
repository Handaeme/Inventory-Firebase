import 'package:flutter/material.dart';
import 'package:inventory_sqlite/screens/add_item_screen.dart';
import 'package:inventory_sqlite/screens/add_transaction_screen.dart';
import 'package:inventory_sqlite/screens/item_detail_screen.dart';
import 'package:inventory_sqlite/screens/item_list_screen.dart';

import 'models/item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobile Inventory System',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => ItemListScreen());
          case '/add-item':
            return MaterialPageRoute(builder: (context) => AddItemScreen());
          case '/item-detail':
            final item = settings.arguments as Item; 
            return MaterialPageRoute(
                builder: (context) => ItemDetailScreen(item: item));
          case '/add-transaction':
            final item = settings.arguments as Item;
            return MaterialPageRoute(
                builder: (context) => AddTransactionScreen(item: item));
          default:
            return MaterialPageRoute(builder: (context) => ItemListScreen());
        }
      },
    );
  }
}
