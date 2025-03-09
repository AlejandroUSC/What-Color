import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LeaderboardManager {
  static const String _fileName = 'leaderboard.json';

  static Future<File> getFile() async {
    // I cant write to a local file do to some sort of OS permission issues
    // I had to look up how to write to a file and this is flutters recommended
    // way on how to do it. Apparently so its cross compatible with IOS and Android
    final directory = await getApplicationDocumentsDirectory();
    // print('Leaderboard file location: ${directory.path}/$_fileName');
    return File('${directory.path}/$_fileName');
  }

  static Future<List<Map<String, dynamic>>> readLeaderboard() async {
    try {
      final file = await getFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        return List<Map<String, dynamic>>.from(json.decode(contents));
      } else {
        return [];
      }
    } catch (e) {
      print('Error reading leaderboard: $e');
      return [];
    }
  }

  static Future<void> saveEntry(String username, int score) async {
    try {
      final file = await getFile();
      final leaderboard = await readLeaderboard();
      leaderboard.add({'username': username, 'score': score});
      leaderboard.sort((a, b) => b['score'].compareTo(a['score']));
      await file.writeAsString(json.encode(leaderboard));
    } catch (e) {
      print('Error saving leaderboard entry: $e');
    }
  }
}