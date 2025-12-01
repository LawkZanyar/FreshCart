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