import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Cache duration constants (in milliseconds)
  static const int shortCacheDuration = 5 * 60 * 1000; // 5 minutes
  static const int mediumCacheDuration = 30 * 60 * 1000; // 30 minutes
  static const int longCacheDuration = 24 * 60 * 60 * 1000; // 24 hours

  Future<void> cacheData({
    required String table,
    required String key,
    required Map<String, dynamic> data,
    int? customDuration,
  }) async {
    if (kIsWeb) {
      debugPrint('Cache storage skipped on web platform');
      return;
    }
    final db = await _databaseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = now + (customDuration ?? mediumCacheDuration);

    await db.insert(
      table,
      {
        'id': key,
        'data': jsonEncode(data),
        'timestamp': now,
        'expires_at': expiresAt,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getCachedData({
    required String table,
    required String key,
  }) async {
    if (kIsWeb) {
      return null; // No cache available on web
    }
    final db = await _databaseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final result = await db.query(
      table,
      where: 'id = ? AND expires_at > ?',
      whereArgs: [key, now],
    );

    if (result.isNotEmpty) {
      final data = result.first['data'] as String;
      return jsonDecode(data) as Map<String, dynamic>;
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> getCachedList({
    required String table,
  }) async {
    if (kIsWeb) {
      return []; // No cache available on web
    }
    final db = await _databaseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final result = await db.query(
      table,
      where: 'expires_at > ?',
      whereArgs: [now],
      orderBy: 'timestamp DESC',
    );

    return result.map((row) {
      final data = jsonDecode(row['data'] as String) as Map<String, dynamic>;
      return data;
    }).toList();
  }

  Future<void> removeCachedData({
    required String table,
    required String key,
  }) async {
    if (kIsWeb) {
      return;
    }
    final db = await _databaseHelper.database;
    await db.delete(table, where: 'id = ?', whereArgs: [key]);
  }

  Future<bool> isCached({
    required String table,
    required String key,
  }) async {
    if (kIsWeb) {
      return false;
    }
    final data = await getCachedData(table: table, key: key);
    return data != null;
  }

  // Specific cache methods for different data types
  Future<void> cacheTours(List<Map<String, dynamic>> tours) async {
    for (final tour in tours) {
      await cacheData(
        table: 'cache_tours',
        key: tour['id'].toString(),
        data: tour,
        customDuration: mediumCacheDuration,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getCachedTours() async {
    return await getCachedList(table: 'cache_tours');
  }

  Future<void> cacheRegistrations(
      List<Map<String, dynamic>> registrations) async {
    for (final registration in registrations) {
      await cacheData(
        table: 'cache_registrations',
        key: registration['id'].toString(),
        data: registration,
        customDuration: shortCacheDuration,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getCachedRegistrations() async {
    return await getCachedList(table: 'cache_registrations');
  }

  Future<void> cacheDocuments(List<Map<String, dynamic>> documents) async {
    for (final document in documents) {
      await cacheData(
        table: 'cache_documents',
        key: document['id'].toString(),
        data: document,
        customDuration: longCacheDuration,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getCachedDocuments() async {
    return await getCachedList(table: 'cache_documents');
  }

  Future<void> cacheMessages(List<Map<String, dynamic>> messages) async {
    for (final message in messages) {
      await cacheData(
        table: 'cache_messages',
        key: message['id'].toString(),
        data: message,
        customDuration: mediumCacheDuration,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getCachedMessages() async {
    return await getCachedList(table: 'cache_messages');
  }

  Future<void> cacheProviders(List<Map<String, dynamic>> providers) async {
    for (final provider in providers) {
      await cacheData(
        table: 'cache_providers',
        key: provider['id'].toString(),
        data: provider,
        customDuration: longCacheDuration,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getCachedProviders() async {
    return await getCachedList(table: 'cache_providers');
  }

  Future<void> cacheTourTemplates(List<Map<String, dynamic>> templates) async {
    for (final template in templates) {
      await cacheData(
        table: 'cache_tour_templates',
        key: template['id'].toString(),
        data: template,
        customDuration: longCacheDuration,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getCachedTourTemplates() async {
    return await getCachedList(table: 'cache_tour_templates');
  }

  Future<void> clearAllCache() async {
    await _databaseHelper.clearCache();
  }

  Future<void> clearExpiredCache() async {
    await _databaseHelper.clearExpiredCache();
  }
}
