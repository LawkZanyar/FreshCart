import 'package:flutter/material.dart';

class CustomerHomeScreen extends StatelessWidget {
  final String? username;
  
  const CustomerHomeScreen({super.key, this.username});

  @override
  Widget build(BuildContext context) {
    final displayName = username ?? 'Guest';
    
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              displayName[0].toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text('Welcome, $displayName'),
      ),
      body: const Center(
        child: Text('CustomerHomeScreen - under construction'),
      ),
    );
  }
}

//test