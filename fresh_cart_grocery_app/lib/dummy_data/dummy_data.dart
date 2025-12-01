import 'package:flutter/material.dart';

final List<Map<String,dynamic>> dummyProducts = [
  {'id':'p1','name':'Organic Apples','price':2.99,'unit':'kg','icon':Icons.apple},
  {'id':'p2','name':'Ripe Bananas','price':1.49,'unit':'doz','icon':Icons.set_meal},
  {'id':'p3','name':'Carrot Pack','price':1.99,'unit':'bag','icon':Icons.grass},
];

class LoginData {
  static const List<Map<String, String>> demoUsers = [
    {
      'email': 'customer@freshcart.com',
      'password': 'customer123',
      'name': 'John Doe',
      'role': 'customer',
    },
    {
      'email': 'owner@freshcart.com',
      'password': 'owner123',
      'name': 'Jane Smith',
      'role': 'owner',
    },
  ];

  static Map<String, String>? validateCredentials(String email, String password) {
    try {
      return demoUsers.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
      );
    } catch (e) {
      return null;
    }
  }

  static String extractUsernameFromEmail(String email) {
    if (email.contains('@')) {
      return email.split('@')[0];
    }
    return email;
  }
}

final List<Map<String,dynamic>> dummyShops = [
  {'id':'s1','name':'Green Mart','logo':Icons.store},
  {'id':'s2','name':'Freshly','logo':Icons.local_grocery_store},
  {'id':'s3','name':'Veggie Hub','logo':Icons.storefront},
  {'id':'s4','name':'Fresh Picks','logo':Icons.shopping_basket},
  {'id':'s5','name':'Organic Lane','logo':Icons.eco},
  {'id':'s6','name':'Daily Harvest','logo':Icons.agriculture},
  {'id':'s7','name':'Farm Direct','logo':Icons.park},
  {'id':'s8','name':'Healthy Foods','logo':Icons.favorite},
  {'id':'s9','name':'Quick Mart','logo':Icons.local_convenience_store},
  {'id':'s10','name':'Nature Basket','logo':Icons.nature},
  {'id':'s11','name':'Green Valley','logo':Icons.grass},
  {'id':'s12','name':'City Fresh','logo':Icons.location_city},
  {'id':'s13','name':'Pure Organics','logo':Icons.water_drop},
  {'id':'s14','name':'Super Saver','logo':Icons.savings},
  {'id':'s15','name':'Corner Store','logo':Icons.store_mall_directory},
];