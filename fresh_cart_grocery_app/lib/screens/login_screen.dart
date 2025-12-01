import 'package:flutter/material.dart';
import '../routes/routes.dart';
import '../dummy_data/dummy_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _attemptLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final user = LoginData.validateCredentials(email, password);
    if (user == null) {
      setState(() => _errorMessage = 'Invalid email or password');
      return;
    }

    setState(() => _errorMessage = null);
    final role = user['role'];
    final name = user['name'] ?? LoginData.extractUsernameFromEmail(email);

    if (role == 'customer') {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.customerHome,
        arguments: name,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.ownerDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'your_email@gmail.com',
                    prefixIcon: Icon(Icons.email_outlined)
                  ),
                ),
                const SizedBox(height: 32,),
            
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'write your password here...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).hintColor.withOpacity(0.6),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 32,),
            
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                FilledButton.icon(
                  onPressed: _attemptLogin,
                  icon: const Icon(Icons.login),
                  label: const Text('Login'),
                ),
                const SizedBox(height: 24,),
            
                Center(
                  child: Text('v1.0', style: Theme.of(context).textTheme.bodySmall,),
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}