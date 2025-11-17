import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth_screen.dart';
import 'screens/main_chat_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyChatApp());
}

class MyChatApp extends StatelessWidget {
  const MyChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MainChatScreen();
          }
          return AuthScreen();
        },
      ),
    );
  }
}
