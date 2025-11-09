import 'package:shared_preferences/shared_preferences.dart';

class HighScoreService {
  static const String _highScoreKey = 'high_score';
  
  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }
  
  Future<bool> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHigh = await getHighScore();
    
    if (score > currentHigh) {
      await prefs.setInt(_highScoreKey, score);
      return true; // New high score!
    }
    return false; // Not a high score
  }
  
  Future<void> clearHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_highScoreKey);
  }
}
