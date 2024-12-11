// lib/src/presentation/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("S'inscrire")),
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

                final success = await authProvider.signup(email, password);

                setState(() {
                  _isLoading = false;
                });

                if (success) {
                  // Une fois inscrit, on redirige l'utilisateur
                  context.go('/patient_home');
                } else {
                  setState(() {
                    _errorMessage = "Impossible de s'inscrire. Vérifiez vos informations.";
                  });
                }
              },
              child: const Text("S'inscrire"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Retour à l'écran de login
                context.go('/login');
              },
              child: const Text("Déjà un compte ? Se connecter"),
            )
          ],
        ),
      ),
    );
  }
}