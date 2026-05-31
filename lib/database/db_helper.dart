import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/contact_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('contacts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      // Initialize FFI for SQLite on desktop platforms
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullableType = 'TEXT';
    const integerType = 'INTEGER NOT NULL DEFAULT 0';

    await db.execute('''
      CREATE TABLE contacts (
        id $idType,
        name $textType,
        phone $textType,
        email $textType,
        imagePath $textNullableType,
        isFavorite $integerType
      )
    ''');
  }

  // CREATE (Insert)
  Future<Contact> insertContact(Contact contact) async {
    final db = await instance.database;
    final id = await db.insert('contacts', contact.toMap());
    return contact.copyWith(id: id);
  }

  // READ (All Contacts)
  Future<List<Contact>> getAllContacts() async {
    final db = await instance.database;
    // Order by name alphabetically (case-insensitive)
    final result = await db.query('contacts', orderBy: 'LOWER(name) ASC');
    return result.map((json) => Contact.fromMap(json)).toList();
  }

  // READ (Favorites only)
  Future<List<Contact>> getFavoriteContacts() async {
    final db = await instance.database;
    final result = await db.query(
      'contacts',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'LOWER(name) ASC',
    );
    return result.map((json) => Contact.fromMap(json)).toList();
  }

  // READ (Single Contact)
  Future<Contact?> getContactById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'contacts',
      columns: ['id', 'name', 'phone', 'email', 'imagePath', 'isFavorite'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // UPDATE
  Future<int> updateContact(Contact contact) async {
    final db = await instance.database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // DELETE
  Future<int> deleteContact(int id) async {
    final db = await instance.database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Toggle Favorite Status
  Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await instance.database;
    return await db.update(
      'contacts',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close Database connection
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
