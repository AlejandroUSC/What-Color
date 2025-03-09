import 'package:flutter/material.dart';
import 'menu_screen.dart';
import 'game_screen.dart';
import 'skeddadle_screen.dart';
import 'leaderboard_screen.dart';

void main() {
  runApp(SpotTheDifferentColorApp());
}

class SpotTheDifferentColorApp extends StatelessWidget {
  const SpotTheDifferentColorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spot the Different Color!',
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromRGBO(255, 224, 158, 1.0),
      ),
      home: MenuScreen(),
      initialRoute: '/',
      routes: {
        // Code Piece below passes the username that user typed into memory to
        // later be used in the leaderboard showcase
        '/game': (context) => GameScreen(username: ModalRoute.of(context)?.settings.arguments as String),
        '/leaderboard': (context) => LeaderboardScreen(),
        '/skeddadle' : (context) => SkeddadleScreen(username: ModalRoute.of(context)?.settings.arguments as String),
        '/hideandseek' : (context) => HideAndSeekScreen(username: ModalRoute.of(context)?.settings.arguments as String),
      },
    );
  }
}

// Placeholder for the new game mode
class HideAndSeekScreen extends StatelessWidget {
  final String username;

  const HideAndSeekScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hide and Seek Mode'),
        backgroundColor: Color.fromRGBO(255, 224, 158, 1.0),
      ),
      body: Center(
        child: Text(
          'Welcome to Hide and Seek, $username!\nComing Soon!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}