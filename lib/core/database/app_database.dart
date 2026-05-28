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

      // This version is increased to add the care plan type column to reminders.
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // This table stores medication reminders, feeding guidance, rehab plans, and learning goals.
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        time TEXT,
        isEnabled INTEGER NOT NULL,
        type TEXT NOT NULL DEFAULT 'medication'
      )
    ''');

    // This table stores the daily completion status for each reminder or care plan item.
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

    // This index speeds up loading all logs for a specific day.
    await db.execute('''
      CREATE INDEX idx_reminder_logs_date
      ON reminder_logs(date)
    ''');

    // This index speeds up checking one reminder status on a specific day.
    await db.execute('''
      CREATE INDEX idx_reminder_logs_reminder_date
      ON reminder_logs(reminderId, date)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // This migration rebuilds the reminders table for older app versions.
      await db.execute('''
        CREATE TABLE reminders_new (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          subtitle TEXT NOT NULL,
          time TEXT,
          isEnabled INTEGER NOT NULL
        )
      ''');

      // This block preserves existing reminder data during the old migration.
      await db.execute('''
        INSERT INTO reminders_new (id, title, subtitle, time, isEnabled)
        SELECT id, title, subtitle, time, isEnabled
        FROM reminders
      ''');

      // This block replaces the old reminders table with the rebuilt table.
      await db.execute('DROP TABLE reminders');
      await db.execute('ALTER TABLE reminders_new RENAME TO reminders');
    }

    if (oldVersion < 3) {
      // This migration creates the reminder logs table for daily tracking.
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

      // This index speeds up loading all logs for a specific day.
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_reminder_logs_date
        ON reminder_logs(date)
      ''');

      // This index speeds up checking one reminder status on a specific day.
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_reminder_logs_reminder_date
        ON reminder_logs(reminderId, date)
      ''');
    }

    if (oldVersion < 4) {
      // This migration adds the care plan type column without deleting old reminders.
      final columns = await db.rawQuery('PRAGMA table_info(reminders)');
      final hasTypeColumn = columns.any((column) => column['name'] == 'type');

      // This block safely adds the type column only if it does not already exist.
      if (!hasTypeColumn) {
        await db.execute('''
          ALTER TABLE reminders
          ADD COLUMN type TEXT NOT NULL DEFAULT 'medication'
        ''');
      }
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
