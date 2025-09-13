import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite database is not supported on web');
    }
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Skip database initialization on web for now
    if (kIsWeb) {
      throw UnsupportedError('SQLite database is not supported on web. Use alternative storage.');
    }
    
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'tourlicity_cache.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create cache tables for essential data
    await db.execute('''
      CREATE TABLE cache_tours (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        expires_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cache_registrations (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        expires_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cache_documents (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        expires_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cache_messages (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        expires_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cache_providers (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        expires_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cache_tour_templates (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        expires_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        endpoint TEXT NOT NULL,
        method TEXT NOT NULL,
        data TEXT,
        timestamp INTEGER NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades if needed
  }

  Future<void> clearCache() async {
    if (kIsWeb) {
      debugPrint('Cache clearing skipped on web platform');
      return;
    }
    final db = await database;
    await db.delete('cache_tours');
    await db.delete('cache_registrations');
    await db.delete('cache_documents');
    await db.delete('cache_messages');
    await db.delete('cache_providers');
    await db.delete('cache_tour_templates');
  }

  Future<void> clearExpiredCache() async {
    if (kIsWeb) {
      debugPrint('Expired cache clearing skipped on web platform');
      return;
    }
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await db.delete('cache_tours', where: 'expires_at < ?', whereArgs: [now]);
    await db.delete('cache_registrations', where: 'expires_at < ?', whereArgs: [now]);
    await db.delete('cache_documents', where: 'expires_at < ?', whereArgs: [now]);
    await db.delete('cache_messages', where: 'expires_at < ?', whereArgs: [now]);
    await db.delete('cache_providers', where: 'expires_at < ?', whereArgs: [now]);
    await db.delete('cache_tour_templates', where: 'expires_at < ?', whereArgs: [now]);
  }

  Future<void> close() async {
    if (kIsWeb) {
      return;
    }
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}