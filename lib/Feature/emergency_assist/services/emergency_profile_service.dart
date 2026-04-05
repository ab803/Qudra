import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/emergency_profile_model.dart';

class EmergencyProfileService {
  static const String databaseName = 'emergency_assist.db';
  static const int databaseVersion = 2;

  static const String _profileTableName = 'emergency_profile';
  static const String contactsTableName = 'emergency_contacts';
  static const int _singleProfileId = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, databaseName);

    return openDatabase(
      path,
      version: databaseVersion,
      onCreate: (db, version) async {
        await _createProfileTable(db);
        await _createContactsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createContactsTable(db);
        }
      },
    );
  }

  Future<void> _createProfileTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_profileTableName (
        local_id INTEGER PRIMARY KEY,
        full_name TEXT NOT NULL,
        disability_type TEXT NOT NULL,
        blood_type TEXT NOT NULL,
        preferred_communication_method TEXT NOT NULL,
        important_medical_notes TEXT,
        allergies_and_medications TEXT,
        vibration_on_alert INTEGER NOT NULL DEFAULT 1,
        is_setup_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future<void> _createContactsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $contactsTableName (
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        relation TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        is_primary INTEGER NOT NULL DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future<EmergencyProfileModel?> getProfile() async {
    final db = await database;
    final result = await db.query(
      _profileTableName,
      where: 'local_id = ?',
      whereArgs: [_singleProfileId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return EmergencyProfileModel.fromJson(result.first);
  }

  Future<void> saveProfile(EmergencyProfileModel profile) async {
    final db = await database;

    final preparedProfile = profile.copyWith(
      localId: _singleProfileId,
      isSetupCompleted: true,
      createdAt: profile.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await db.insert(
      _profileTableName,
      preparedProfile.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> hasCompletedSetup() async {
    final profile = await getProfile();
    return profile?.isSetupCompleted ?? false;
  }

  Future<void> clearProfile() async {
    final db = await database;
    await db.delete(
      _profileTableName,
      where: 'local_id = ?',
      whereArgs: [_singleProfileId],
    );
  }
}