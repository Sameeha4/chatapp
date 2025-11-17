// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool loading = false;

  Future<void> registerUser() async {
    final email = emailController.text.trim();
    final password = passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password required")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // 1️⃣ Create Firebase Auth user
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCred.user?.uid;
      if (uid != null) {
        // 2️⃣ Save user in Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registration successful!")));

      Navigator.pop(context); // Go back to login screen
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Error")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 25),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: registerUser,
                    child: const Text("Register"),
                  ),
          ],
        ),
      ),
    );
  }
}
