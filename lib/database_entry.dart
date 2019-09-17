import 'package:free_authenticator/database_helper.dart';
import 'package:free_authenticator/entry_type.dart';
import 'package:sqflite/sqflite.dart';

abstract class DatabaseEntry {
  static final table = 'entry';
  static final columnId = 'id';
  static final columnType = 'type';
  static final columnData = 'data';
  static final columnPosition = 'position';
  static final columnVault = 'vault';

  static Future<List<Map<String, dynamic>>> getByType(EntryType type, String name) async {
    Database db = await DatabaseHelper.database;
    List<Map<String, dynamic>> vaults = await db.query(
      table, columns: [columnId, columnData],
      where: "$columnType = ?", whereArgs: [type]);
    return vaults;
  }

  static Future<int> create(EntryType type, String data, int position, int vault) async {
    final db = await DatabaseHelper.database;
    Map<String, dynamic> map = {
      DatabaseEntry.columnType : EntryTypeId[type],
      DatabaseEntry.columnData : data,
      DatabaseEntry.columnPosition : position,
      DatabaseEntry.columnVault : vault,
    };
    return db.insert(table, map);
  }

  static Future<List<Map<String, dynamic>>> getEntries(int vault) async {
    final db = await DatabaseHelper.database;
    final entries = await db.query(
      DatabaseEntry.table,
      where: "${DatabaseEntry.columnVault} = ?",
      whereArgs: [vault],
      orderBy: DatabaseEntry.columnPosition);
    return entries;
  }

  static Future<Map<String, dynamic>> getEntry(int position, int vault) async {
    final db = await DatabaseHelper.database;
    final entries = await db.query(
      DatabaseEntry.table,
      where: "${DatabaseEntry.columnPosition} = ? AND ${DatabaseEntry.columnVault} = ?",
      whereArgs: [position, vault],
      orderBy: DatabaseEntry.columnPosition);
    return entries.length < 1 ? null : entries[0];
  }

  static Future<int> nextPosition(int vault) async {
    final db = await DatabaseHelper.database;
    final x = await db.rawQuery('SELECT MAX(${DatabaseEntry.columnPosition}) AS position FROM ${DatabaseEntry.table} WHERE ${DatabaseEntry.columnVault} = $vault;');
    return ((x[0]['position'] as int) ?? 0) + 1;
  }
}

const Map<EntryType, int> EntryTypeId = {
  EntryType.vault: 1,
  EntryType.totp: 2,
};