import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

class SqlDatabase {
  late Database database;
  bool _isInitialized = false;
  final String dbName = 'church.db';

  Future<void> createDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbName);

    database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE church (id INTEGER PRIMARY KEY, churchName TEXT)');
    });

    _isInitialized = true;
  }

//check if it exist
  Future<void> initializeDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbName);

    if (await _databaseExists(path)) {
      // Database exists, open it
      database = await openDatabase(path);
    } else {
      // Database does not exist, create it
      await createDatabase();
    }
  }

  Future<bool> _databaseExists(String path) async {
    return File(path).exists();
  }

  void insertChurchName({churchName}) async {
    if (!_isInitialized)await initializeDatabase(); // Ensure the database is initialized

    try {
      await database.transaction((txn) async {
        int id1 = await txn.rawInsert(
            'INSERT INTO church (churchName) VALUES (?)', [churchName]);
        print('inserted1: $id1');
      });
    } catch (error) {
      print("Church not inserted");
    }
  }

  Future<String> getChurchName() async {
    if (!_isInitialized)await initializeDatabase(); // Ensure the database is initialized

    try {
      List<Map> list = await database.rawQuery('SELECT * FROM church');

      final name = list[0]["churchName"].toString();

      return name;
    } catch (error) {
      print("Somethimg went wrong getting church name");
      return "";
    }
  }

  Future<void> deleteAllChurches() async {
    if (!_isInitialized) await initializeDatabase();

    try {
      await database.transaction((txn) async {
        int count = await txn.rawDelete('DELETE FROM church');
        print('Deleted $count church records');
      });
    } catch (error) {
      print("Error deleting churches: $error");
      rethrow; // Optional: rethrow if you want calling code to handle the error
    }
  }

  Future<void> deleteBase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbName);

    try {
      // Check if the database exists
      if (await _databaseExists(path)) {
        // Close the database before deleting it
        await database.close();
        // Delete the database file
        await deleteDatabase(path);
        print('Database deleted successfully');
      } else {
        print('Database does not exist');
      }
    } catch (error) {
      print("Error deleting database: $error");
    }
  }
}
