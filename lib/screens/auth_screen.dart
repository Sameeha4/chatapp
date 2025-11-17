import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(hintText: "Email"),
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(hintText: "Password"),
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthService().login(email.text, password.text);
              },
              child: Text("Login"),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RegisterScreen()),
              ),
              child: Text("Go to Register"),
            ),
          ],
        ),
      ),
    );
  }
}
