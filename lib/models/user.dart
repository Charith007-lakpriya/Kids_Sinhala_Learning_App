class AppUser {
  final String username;
  final int stars;
  final int streak;
  final int level;
  final int gamesPlayed;
  final int accuracy;
  final int bestStreak;

  const AppUser({
    required this.username,
    required this.stars,
    required this.streak,
    required this.level,
    required this.gamesPlayed,
    required this.accuracy,
    required this.bestStreak,
  });
}
