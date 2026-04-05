import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:qudra_0/core/database/app_database.dart';

import '../models/reminder_model.dart';

class ReminderService {
  static const String tableName = 'reminders';

  Future<Database> get _db async => AppDatabase.instance.database;

  // ---------------------------
  // CREATE
  // ---------------------------
  Future<int> createReminder(ReminderModel reminder) async {
    final db = await _db;

    try {
      return await db.insert(
        tableName,
        reminder.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error inserting reminder: $e');
      throw Exception('Failed to insert reminder');
    }
  }

  // ---------------------------
  // READ
  // ---------------------------
  Future<List<ReminderModel>> getAllReminders() async {
    final db = await _db;

    final maps = await db.query(
      tableName,
      orderBy: 'title COLLATE NOCASE ASC',
    );

    return maps.map((m) => ReminderModel.fromMap(m)).toList();
  }

  // ---------------------------
  // UPDATE
  // ---------------------------
  Future<int> updateReminder(ReminderModel reminder) async {
    final db = await _db;

    try {
      return await db.update(
        tableName,
        reminder.toMap(),
        where: 'id = ?',
        whereArgs: [reminder.id],
      );
    } catch (e) {
      debugPrint('Error updating reminder: $e');
      throw Exception('Failed to update reminder');
    }
  }

  // ---------------------------
  // DELETE
  // ---------------------------
  Future<int> deleteReminder(String id) async {
    final db = await _db;

    try {
      return await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
      throw Exception('Failed to delete reminder');
    }
  }

  // ---------------------------
  // SET ENABLED
  // ---------------------------
  Future<int> setEnabled(String id, bool enabled) async {
    final db = await _db;

    return await db.update(
      tableName,
      {'isEnabled': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}