import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/child_profile.dart';
import '../models/milestone.dart';
import '../models/growth_record.dart';
import '../models/article.dart';
import 'seed_data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'smarth_growth.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE, password TEXT NOT NULL, created_at TEXT NOT NULL)''');
    await db.execute('''CREATE TABLE children (
      id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL,
      name TEXT NOT NULL, gender TEXT NOT NULL, birth_date TEXT NOT NULL,
      weight REAL, height REAL, photo_path TEXT,
      FOREIGN KEY (user_id) REFERENCES users (id))''');
    await db.execute('''CREATE TABLE milestones (
      id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT NOT NULL,
      subcategory TEXT NOT NULL, age_months_min INTEGER NOT NULL,
      age_months_max INTEGER NOT NULL, description TEXT NOT NULL, icon TEXT)''');
    await db.execute('''CREATE TABLE milestone_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT, child_id INTEGER NOT NULL,
      milestone_id INTEGER NOT NULL, is_achieved INTEGER NOT NULL DEFAULT 0,
      achieved_date TEXT, record_month INTEGER NOT NULL,
      FOREIGN KEY (child_id) REFERENCES children (id),
      FOREIGN KEY (milestone_id) REFERENCES milestones (id))''');
    await db.execute('''CREATE TABLE growth_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT, child_id INTEGER NOT NULL,
      weight REAL NOT NULL, height REAL NOT NULL, record_date TEXT NOT NULL,
      FOREIGN KEY (child_id) REFERENCES children (id))''');
    await db.execute('''CREATE TABLE articles (
      id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL,
      content TEXT NOT NULL, category TEXT NOT NULL,
      image_url TEXT, published_at TEXT NOT NULL)''');
    await db.execute('''CREATE TABLE reminders (
      id INTEGER PRIMARY KEY AUTOINCREMENT, child_id INTEGER NOT NULL,
      title TEXT NOT NULL, description TEXT, reminder_date TEXT NOT NULL,
      is_completed INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (child_id) REFERENCES children (id))''');
    await SeedData.seedMilestones(db);
    await SeedData.seedArticles(db);
  }

  // USER
  Future<int> insertUser(AppUser user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<AppUser?> getUser(String email, String password) async {
    final db = await database;
    final maps = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    return maps.isNotEmpty ? AppUser.fromMap(maps.first) : null;
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return maps.isNotEmpty ? AppUser.fromMap(maps.first) : null;
  }

  Future<AppUser?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? AppUser.fromMap(maps.first) : null;
  }

  // CHILDREN
  Future<int> insertChild(ChildProfile child) async {
    final db = await database;
    return await db.insert('children', child.toMap());
  }

  Future<List<ChildProfile>> getChildren(int userId) async {
    final db = await database;
    final maps = await db.query('children', where: 'user_id = ?', whereArgs: [userId]);
    return maps.map((m) => ChildProfile.fromMap(m)).toList();
  }

  Future<ChildProfile?> getChild(int childId) async {
    final db = await database;
    final maps = await db.query('children', where: 'id = ?', whereArgs: [childId]);
    return maps.isNotEmpty ? ChildProfile.fromMap(maps.first) : null;
  }

  Future<int> updateChild(ChildProfile child) async {
    final db = await database;
    return await db.update('children', child.toMap(), where: 'id = ?', whereArgs: [child.id]);
  }

  Future<void> deleteChild(int childId) async {
    final db = await database;
    await db.delete('milestone_records', where: 'child_id = ?', whereArgs: [childId]);
    await db.delete('growth_records', where: 'child_id = ?', whereArgs: [childId]);
    await db.delete('reminders', where: 'child_id = ?', whereArgs: [childId]);
    await db.delete('children', where: 'id = ?', whereArgs: [childId]);
  }

  // MILESTONES
  Future<List<Milestone>> getMilestones(String category, int ageMonths) async {
    final db = await database;
    final maps = await db.query('milestones',
        where: 'category = ? AND age_months_min <= ? AND age_months_max >= ?',
        whereArgs: [category, ageMonths, ageMonths]);
    return maps.map((m) => Milestone.fromMap(m)).toList();
  }

  Future<List<Milestone>> getMilestonesBySubcategory(String subcategory, int ageMonths) async {
    final db = await database;
    final maps = await db.query('milestones',
        where: 'subcategory = ? AND age_months_min <= ? AND age_months_max >= ?',
        whereArgs: [subcategory, ageMonths, ageMonths]);
    return maps.map((m) => Milestone.fromMap(m)).toList();
  }

  // MILESTONE RECORDS
  Future<void> upsertMilestoneRecord(int childId, int milestoneId, bool isAchieved, int recordMonth) async {
    final db = await database;
    final existing = await db.query('milestone_records',
        where: 'child_id = ? AND milestone_id = ? AND record_month = ?',
        whereArgs: [childId, milestoneId, recordMonth]);
    if (existing.isNotEmpty) {
      await db.update('milestone_records', {
        'is_achieved': isAchieved ? 1 : 0,
        'achieved_date': isAchieved ? DateTime.now().toIso8601String() : null,
      }, where: 'id = ?', whereArgs: [existing.first['id']]);
    } else {
      await db.insert('milestone_records', {
        'child_id': childId, 'milestone_id': milestoneId,
        'is_achieved': isAchieved ? 1 : 0,
        'achieved_date': isAchieved ? DateTime.now().toIso8601String() : null,
        'record_month': recordMonth,
      });
    }
  }

  Future<List<MilestoneRecord>> getMilestoneRecords(int childId, int recordMonth) async {
    final db = await database;
    final maps = await db.query('milestone_records',
        where: 'child_id = ? AND record_month = ?', whereArgs: [childId, recordMonth]);
    return maps.map((m) => MilestoneRecord.fromMap(m)).toList();
  }

  Future<Map<String, double>> getCategoryProgress(int childId, int ageMonths) async {
    final db = await database;
    final categories = ['motorik', 'kognitif', 'bahasa', 'sosial_emosional'];
    final Map<String, double> progress = {};
    for (final cat in categories) {
      final milestones = await getMilestones(cat, ageMonths);
      if (milestones.isEmpty) { progress[cat] = 0; continue; }
      int achieved = 0;
      for (final m in milestones) {
        final r = await db.query('milestone_records',
            where: 'child_id = ? AND milestone_id = ? AND is_achieved = 1',
            whereArgs: [childId, m.id]);
        if (r.isNotEmpty) achieved++;
      }
      progress[cat] = achieved / milestones.length * 100;
    }
    return progress;
  }

  // GROWTH
  Future<int> insertGrowthRecord(GrowthRecord record) async {
    final db = await database;
    return await db.insert('growth_records', record.toMap());
  }

  Future<List<GrowthRecord>> getGrowthRecords(int childId) async {
    final db = await database;
    final maps = await db.query('growth_records', where: 'child_id = ?',
        whereArgs: [childId], orderBy: 'record_date ASC');
    return maps.map((m) => GrowthRecord.fromMap(m)).toList();
  }

  // ARTICLES
  Future<List<Article>> getArticles({String? category}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    if (category != null && category != 'Semua') {
      maps = await db.query('articles', where: 'category = ?',
          whereArgs: [category], orderBy: 'published_at DESC');
    } else {
      maps = await db.query('articles', orderBy: 'published_at DESC');
    }
    return maps.map((m) => Article.fromMap(m)).toList();
  }

  Future<Article?> getArticle(int id) async {
    final db = await database;
    final maps = await db.query('articles', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? Article.fromMap(maps.first) : null;
  }
}
