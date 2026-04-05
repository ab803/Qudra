import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  AppDatabase._privateConstructor();

  static final AppDatabase instance = AppDatabase._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'medical_reminders.db');

    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        time TEXT,
        isEnabled INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reminder_logs (
        id TEXT PRIMARY KEY,
        reminderId TEXT NOT NULL,
        date TEXT NOT NULL,
        scheduledTime TEXT NOT NULL,
        status TEXT NOT NULL,
        takenAt TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_reminder_logs_date
      ON reminder_logs(date)
    ''');

    await db.execute('''
      CREATE INDEX idx_reminder_logs_reminder_date
      ON reminder_logs(reminderId, date)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE reminders_new (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          subtitle TEXT NOT NULL,
          time TEXT,
          isEnabled INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        INSERT INTO reminders_new (id, title, subtitle, time, isEnabled)
        SELECT id, title, subtitle, time, isEnabled
        FROM reminders
      ''');

      await db.execute('DROP TABLE reminders');
      await db.execute('ALTER TABLE reminders_new RENAME TO reminders');
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reminder_logs (
          id TEXT PRIMARY KEY,
          reminderId TEXT NOT NULL,
          date TEXT NOT NULL,
          scheduledTime TEXT NOT NULL,
          status TEXT NOT NULL,
          takenAt TEXT
        )
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_reminder_logs_date
        ON reminder_logs(date)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_reminder_logs_reminder_date
        ON reminder_logs(reminderId, date)
      ''');
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
