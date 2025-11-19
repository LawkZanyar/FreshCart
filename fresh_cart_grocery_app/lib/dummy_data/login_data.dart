// Sample login credentials for testing

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
