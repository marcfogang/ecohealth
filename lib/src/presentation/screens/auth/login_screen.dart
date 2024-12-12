// lib/src/presentation/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) 
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            _isLoading 
                ? const CircularProgressIndicator() 
                : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });

                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      final success = await authProvider.login(email, password);

                      setState(() {
                        _isLoading = false;
                      });

                      if (success) {
                        // Redirection basée sur le rôle factice
                        if (authProvider.role == 'doctor') {
                          context.go('/doctor_home');
                        } else if (authProvider.role == 'patient') {
                          context.go('/patient_home');
                        } else {
                          context.go('/aidant_home');
                        }
                      } else {
                        setState(() {
                          _errorMessage = 'Impossible de se connecter. Vérifiez vos identifiants.';
                        });
                      }
                    },
                    child: const Text('Se connecter'),
                  ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.go('/signup');
              },
              child: const Text("Pas de compte ? S'inscrire"),
            )
          ],
        ),
      ),
    );
  }
}
