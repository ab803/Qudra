import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:qudra_0/core/database/app_database.dart';
import '../models/reminder_log_model.dart';

class ReminderLogService {
  static const String tableName = 'reminder_logs';

  Future<Database> get _db async => AppDatabase.instance.database;

  Future<int> upsertLog(ReminderLogModel log) async {
    final db = await _db;
    try {
      return await db.insert(
        tableName,
        log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Error upserting reminder log: $e');
      throw Exception('Failed to save reminder log');
    }
  }

  Future<List<ReminderLogModel>> getLogsByDate(String date) async {
    final db = await _db;
    final maps = await db.query(
      tableName,
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'scheduledTime ASC',
    );
    return maps.map((m) => ReminderLogModel.fromMap(m)).toList();
  }

  Future<ReminderLogModel?> getLogForReminderOnDate(
      String reminderId,
      String date,
      ) async {
    final db = await _db;
    final maps = await db.query(
      tableName,
      where: 'reminderId = ? AND date = ?',
      whereArgs: [reminderId, date],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return ReminderLogModel.fromMap(maps.first);
  }

  Future<int> deleteLogsForReminder(String reminderId) async {
    final db = await _db;
    try {
      return await db.delete(
        tableName,
        where: 'reminderId = ?',
        whereArgs: [reminderId],
      );
    } catch (e) {
      debugPrint('Error deleting reminder logs: $e');
      throw Exception('Failed to delete reminder logs');
    }
  }
}
