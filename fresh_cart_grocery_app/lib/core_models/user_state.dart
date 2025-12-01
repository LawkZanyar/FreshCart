import 'package:flutter/material.dart';

class UserState extends InheritedWidget {
  final String? username;

  const UserState({
    super.key,
    required this.username,
    required super.child,
  });

  static UserState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserState>();
  }

  @override
  bool updateShouldNotify(UserState oldWidget) {
    return oldWidget.username != username;
  }
}
