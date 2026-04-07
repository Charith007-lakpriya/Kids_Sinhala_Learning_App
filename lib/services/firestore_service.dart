import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static bool _matchWordsSeeded = false;

  static Future<void> seedSampleData({String? userId}) async {
    final resolvedUserId = userId ?? 'demo';
    final batch = _db.batch();

    final userRef = _db.collection('users').doc(resolvedUserId);
    batch.set(userRef, {
      'level': 1,
      'stars': 0,
      'streak': 0,
      'bestStreak': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final lessonsRef = _db.collection('lessons');
    batch.set(lessonsRef.doc('intro_1'), {
      'title': 'Basics 1',
      'description': 'Greetings and common words',
      'level': 1,
      'order': 1,
    });
    batch.set(lessonsRef.doc('intro_2'), {
      'title': 'Basics 2',
      'description': 'Family and home',
      'level': 1,
      'order': 2,
    });

    final gamesRef = _db.collection('games');
    batch.set(gamesRef.doc('match_words'), {
      'title': 'Match Words',
      'type': 'match',
      'icon': '🎯',
      'difficulty': 1,
    });
    batch.set(gamesRef.doc('letter_tracing'), {
      'title': 'Letter Tracing',
      'type': 'trace',
      'icon': '✍️',
      'difficulty': 1,
    });
    batch.set(gamesRef.doc('picture_quiz'), {
      'title': 'Picture Quiz',
      'type': 'quiz',
      'icon': '🖼️',
      'difficulty': 2,
    });

    final progressRef = _db
        .collection('users')
        .doc(resolvedUserId)
        .collection('progress')
        .doc('overview');
    batch.set(progressRef, {
      'gamesPlayed': 0,
      'accuracy': 0,
      'correctAnswers': 0,
      'lastPlayed': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final rewardsRef = _db
        .collection('users')
        .doc(resolvedUserId)
        .collection('rewards');
    batch.set(rewardsRef.doc('daily_reward'), {
      'title': 'Daily Reward',
      'status': 'available',
      'stars': 20,
    });

    final settingsRef = _db
        .collection('users')
        .doc(resolvedUserId)
        .collection('settings')
        .doc('preferences');
    batch.set(settingsRef, {
      'sound': true,
      'notifications': true,
      'language': 'si',
    });

    final matchWordsRef = _db.collection('match_words');
    final items = <Map<String, String>>[
      {'word': 'ඇපල්', 'emoji': '🍎'},
      {'word': 'කෙසෙල්', 'emoji': '🍌'},
      {'word': 'දොඩම්', 'emoji': '🍊'},
      {'word': 'අන්නාසි', 'emoji': '🍍'},
      {'word': 'අඹ', 'emoji': '🥭'},
      {'word': 'දැලිම', 'emoji': '🍉'},
      {'word': 'කිරි', 'emoji': '🥛'},
      {'word': 'තේ', 'emoji': '🍵'},
      {'word': 'පාන්', 'emoji': '🍞'},
      {'word': 'බත්', 'emoji': '🍚'},
      {'word': 'මාළු', 'emoji': '🐟'},
      {'word': 'කුකුල්', 'emoji': '🐔'},
      {'word': 'අලි', 'emoji': '🐘'},
      {'word': 'කොටියා', 'emoji': '🐯'},
      {'word': 'සිංහයා', 'emoji': '🦁'},
      {'word': 'බල්ලා', 'emoji': '🐶'},
      {'word': 'බළලා', 'emoji': '🐱'},
      {'word': 'මුහුදු කකුළුවා', 'emoji': '🦀'},
      {'word': 'අලියාඩ', 'emoji': '🐰'},
      {'word': 'වළාකුල', 'emoji': '☁️'},
      {'word': 'වැහි', 'emoji': '🌧️'},
      {'word': 'සූරිය', 'emoji': '☀️'},
      {'word': 'චන්ද්‍රයා', 'emoji': '🌙'},
      {'word': 'නක්ෂත්‍ර', 'emoji': '⭐'},
      {'word': 'මල්', 'emoji': '🌸'},
      {'word': 'කෙදිය', 'emoji': '🌿'},
      {'word': 'ගස', 'emoji': '🌳'},
      {'word': 'ගින්න', 'emoji': '🔥'},
      {'word': 'ජලය', 'emoji': '💧'},
      {'word': 'හෘදය', 'emoji': '❤️'},
      {'word': 'පොත', 'emoji': '📘'},
      {'word': 'පෑන', 'emoji': '🖊️'},
      {'word': 'කැමරාව', 'emoji': '📷'},
      {'word': 'දුරකථන', 'emoji': '📱'},
      {'word': 'පරිගණක', 'emoji': '💻'},
      {'word': 'මෝටර් රථය', 'emoji': '🚗'},
      {'word': 'බස්', 'emoji': '🚌'},
      {'word': 'බයිසිකලය', 'emoji': '🚲'},
      {'word': 'ගුවන් යානය', 'emoji': '✈️'},
      {'word': 'නාවික යානය', 'emoji': '🛳️'},
      {'word': 'ගෙදර', 'emoji': '🏠'},
      {'word': 'පාසල', 'emoji': '🏫'},
      {'word': 'වෛද්‍ය', 'emoji': '🧑‍⚕️'},
      {'word': 'පොලිසිය', 'emoji': '👮'},
      {'word': 'ගුරුවරයා', 'emoji': '🧑‍🏫'},
      {'word': 'දරුවා', 'emoji': '🧒'},
      {'word': 'සංගීතය', 'emoji': '🎵'},
      {'word': 'රංගනය', 'emoji': '🎭'},
      {'word': 'බාල්දිය', 'emoji': '🪣'},
      {'word': 'පාදය', 'emoji': '🦶'},
      {'word': 'අත', 'emoji': '✋'},
      {'word': 'මුහුණ', 'emoji': '🙂'},
      {'word': 'ඇස්', 'emoji': '👀'},
    ];

    for (var i = 0; i < items.length; i++) {
      batch.set(matchWordsRef.doc('item_${i + 1}'), items[i]);
    }

    await batch.commit();
  }

  static Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? parentEmail,
    int? age,
  }) async {
    await _db.collection('users').doc(userId).set({
      if (name != null && name.isNotEmpty) 'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
      if (parentEmail != null && parentEmail.isNotEmpty)
        'parentEmail': parentEmail,
      if (age != null) 'age': age,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> createAccount({
    required String userId,
    required String username,
    required String parentEmail,
    required String password,
  }) async {
    await _db.collection('accounts').doc(userId).set({
      'username': username,
      'usernameLower': username.toLowerCase(),
      'parentEmail': parentEmail,
      'parentEmailLower': parentEmail.toLowerCase(),
      'password': password,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getAccount(String userId) async {
    final doc = await _db.collection('accounts').doc(userId).get();
    return doc.data();
  }

  static Future<Map<String, dynamic>?> getAccountByIdentifier(
      String identifier) async {
    final key = identifier.trim().toLowerCase();
    final direct = await _db.collection('accounts').doc(key).get();
    if (direct.exists) {
      final data = direct.data();
      if (data == null) return null;
      return {...data, '_id': direct.id};
    }

    final query = await _db
        .collection('accounts')
        .where('parentEmailLower', isEqualTo: key)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      final byUsername = await _db
          .collection('accounts')
          .where('usernameLower', isEqualTo: key)
          .limit(1)
          .get();
      if (byUsername.docs.isEmpty) return null;
      final doc = byUsername.docs.first;
      return {...doc.data(), '_id': doc.id};
    }
    final doc = query.docs.first;
    return {...doc.data(), '_id': doc.id};
  }

  static Future<void> addStars({
    required String userId,
    required int delta,
  }) async {
    await _db.collection('users').doc(userId).set({
      'stars': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> addCorrectAnswer({
    required String userId,
    required int delta,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc('overview')
        .set({
      'correctAnswers': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<bool> updateLevelForStars({
    required String userId,
  }) async {
    final userRef = _db.collection('users').doc(userId);
    final snap = await userRef.get();
    final data = snap.data() ?? {};
    final stars = (data['stars'] ?? 0) as int? ?? 0;
    final prevLevel = (data['level'] ?? 1) as int? ?? 1;
    final level = (stars ~/ 20) + 1;
    await userRef.set({
      'level': level,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return level > prevLevel;
  }

  static Future<void> setLastPlayedWord({
    required String userId,
    required String word,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc('overview')
        .set({
      'lastPlayedWord': word,
      'lastPlayedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> seedMatchWordsIfEmpty() async {
    if (_matchWordsSeeded) return;
    _matchWordsSeeded = true;
    final snapshot = await _db.collection('match_words').limit(1).get();
    if (snapshot.docs.isNotEmpty) return;
    final batch = _db.batch();
    final matchWordsRef = _db.collection('match_words');
    final items = <Map<String, String>>[
      {'word': 'ඇපල්', 'emoji': '🍎'},
      {'word': 'කෙසෙල්', 'emoji': '🍌'},
      {'word': 'දොඩම්', 'emoji': '🍊'},
      {'word': 'අන්නාසි', 'emoji': '🍍'},
      {'word': 'අඹ', 'emoji': '🥭'},
      {'word': 'දැලිම', 'emoji': '🍉'},
      {'word': 'කිරි', 'emoji': '🥛'},
      {'word': 'තේ', 'emoji': '🍵'},
      {'word': 'පාන්', 'emoji': '🍞'},
      {'word': 'බත්', 'emoji': '🍚'},
      {'word': 'මාළු', 'emoji': '🐟'},
      {'word': 'කුකුල්', 'emoji': '🐔'},
      {'word': 'අලි', 'emoji': '🐘'},
      {'word': 'කොටියා', 'emoji': '🐯'},
      {'word': 'සිංහයා', 'emoji': '🦁'},
      {'word': 'බල්ලා', 'emoji': '🐶'},
      {'word': 'බළලා', 'emoji': '🐱'},
      {'word': 'මුහුදු කකුළුවා', 'emoji': '🦀'},
      {'word': 'අලියාඩ', 'emoji': '🐰'},
      {'word': 'වළාකුල', 'emoji': '☁️'},
      {'word': 'වැහි', 'emoji': '🌧️'},
      {'word': 'සූරිය', 'emoji': '☀️'},
      {'word': 'චන්ද්‍රයා', 'emoji': '🌙'},
      {'word': 'නක්ෂත්‍ර', 'emoji': '⭐'},
      {'word': 'මල්', 'emoji': '🌸'},
      {'word': 'කෙදිය', 'emoji': '🌿'},
      {'word': 'ගස', 'emoji': '🌳'},
      {'word': 'ගින්න', 'emoji': '🔥'},
      {'word': 'ජලය', 'emoji': '💧'},
      {'word': 'හෘදය', 'emoji': '❤️'},
      {'word': 'පොත', 'emoji': '📘'},
      {'word': 'පෑන', 'emoji': '🖊️'},
      {'word': 'කැමරාව', 'emoji': '📷'},
      {'word': 'දුරකථන', 'emoji': '📱'},
      {'word': 'පරිගණක', 'emoji': '💻'},
      {'word': 'මෝටර් රථය', 'emoji': '🚗'},
      {'word': 'බස්', 'emoji': '🚌'},
      {'word': 'බයිසිකලය', 'emoji': '🚲'},
      {'word': 'ගුවන් යානය', 'emoji': '✈️'},
      {'word': 'නාවික යානය', 'emoji': '🛳️'},
      {'word': 'ගෙදර', 'emoji': '🏠'},
      {'word': 'පාසල', 'emoji': '🏫'},
      {'word': 'වෛද්‍ය', 'emoji': '🧑‍⚕️'},
      {'word': 'පොලිසිය', 'emoji': '👮'},
      {'word': 'ගුරුවරයා', 'emoji': '🧑‍🏫'},
      {'word': 'දරුවා', 'emoji': '🧒'},
      {'word': 'සංගීතය', 'emoji': '🎵'},
      {'word': 'රංගනය', 'emoji': '🎭'},
      {'word': 'බාල්දිය', 'emoji': '🪣'},
      {'word': 'පාදය', 'emoji': '🦶'},
      {'word': 'අත', 'emoji': '✋'},
      {'word': 'මුහුණ', 'emoji': '🙂'},
      {'word': 'ඇස්', 'emoji': '👀'},
    ];
    for (var i = 0; i < items.length; i++) {
      batch.set(matchWordsRef.doc('item_${i + 1}'), items[i]);
    }
    await batch.commit();
  }
}
