import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/emergency_contact_model.dart';
import 'emergency_profile_service.dart';

class EmergencyContactsService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, EmergencyProfileService.databaseName);

    return openDatabase(
      path,
      version: EmergencyProfileService.databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${EmergencyProfileService.contactsTableName} (
            local_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            relation TEXT NOT NULL,
            phone_number TEXT NOT NULL,
            is_primary INTEGER NOT NULL DEFAULT 0,
            created_at TEXT,
            updated_at TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS ${EmergencyProfileService.contactsTableName} (
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
      },
    );
  }

  Future<List<EmergencyContactModel>> getContacts() async {
    final db = await database;

    final result = await db.query(
      EmergencyProfileService.contactsTableName,
      orderBy: 'is_primary DESC, local_id ASC',
    );

    return result
        .map((row) => EmergencyContactModel.fromJson(row))
        .toList();
  }

  Future<void> addContact(EmergencyContactModel contact) async {
    final db = await database;
    final existingContacts = await getContacts();

    final shouldBePrimary =
        contact.isPrimary || existingContacts.isEmpty;

    if (shouldBePrimary) {
      await _clearPrimaryFlag(db);
    }

    final now = DateTime.now();

    final payload = contact.copyWith(
      isPrimary: shouldBePrimary,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert(
      EmergencyProfileService.contactsTableName,
      payload.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateContact(EmergencyContactModel contact) async {
    if (contact.localId == null) return;

    final db = await database;

    if (contact.isPrimary) {
      await _clearPrimaryFlag(db);
    }

    final payload = contact.copyWith(
      updatedAt: DateTime.now(),
    );

    await db.update(
      EmergencyProfileService.contactsTableName,
      payload.toJson(),
      where: 'local_id = ?',
      whereArgs: [contact.localId],
    );

    await _ensureAtLeastOnePrimary(db);
  }

  Future<void> deleteContact(int localId) async {
    final db = await database;

    final existing = await db.query(
      EmergencyProfileService.contactsTableName,
      where: 'local_id = ?',
      whereArgs: [localId],
      limit: 1,
    );

    final wasPrimary =
        existing.isNotEmpty && (existing.first['is_primary'] ?? 0) == 1;

    await db.delete(
      EmergencyProfileService.contactsTableName,
      where: 'local_id = ?',
      whereArgs: [localId],
    );

    if (wasPrimary) {
      await _ensureAtLeastOnePrimary(db);
    }
  }

  Future<void> setPrimaryContact(int localId) async {
    final db = await database;

    await _clearPrimaryFlag(db);

    await db.update(
      EmergencyProfileService.contactsTableName,
      {
        'is_primary': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> _clearPrimaryFlag(Database db) async {
    await db.update(
      EmergencyProfileService.contactsTableName,
      {
        'is_primary': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> _ensureAtLeastOnePrimary(Database db) async {
    final contacts = await db.query(
      EmergencyProfileService.contactsTableName,
      orderBy: 'local_id ASC',
    );

    if (contacts.isEmpty) return;

    final hasPrimary =
    contacts.any((contact) => (contact['is_primary'] ?? 0) == 1);

    if (!hasPrimary) {
      final firstId = contacts.first['local_id'] as int;
      await db.update(
        EmergencyProfileService.contactsTableName,
        {
          'is_primary': 1,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'local_id = ?',
        whereArgs: [firstId],
      );
    }
  }
}