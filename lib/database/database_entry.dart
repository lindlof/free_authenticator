import 'package:sqflite/sqlite_api.dart';

abstract class DatabaseEntry {
  static final table = 'entry';
  static final columnId = 'id';
  static final columnType = 'type';
  static final columnData = 'data';
  static final columnPosition = 'position';
  static final columnVault = 'vault';

  static final vaultTypeId = 1;
  static final totpTypeId = 2;

  static Future<List<Map<String, dynamic>>> get(DatabaseExecutor db, List<int> ids) async {
    List<Map<String, dynamic>> entries = await db.query(
      table, columns: [columnId, columnType, columnData, columnPosition, columnVault],
      where: "$columnId IN (${ids.map((x) => "?").join(", ")})", whereArgs: ids);
    return entries;
  }

  static Future<List<Map<String, dynamic>>> getByType(DatabaseExecutor db, int type) async {
    List<Map<String, dynamic>> entries = await db.query(
      table, columns: [columnId, columnData],
      where: "$columnType = ?", whereArgs: [type]);
    return entries;
  }

  static Future<int> create(DatabaseExecutor db, Map<String, dynamic> map) async {
    return db.insert(table, map);
  }

  static Future<int> update(DatabaseExecutor db, int id, Map<String, dynamic> map) async {
    return db.update(
      table, map,
      where: "$columnId = ?", whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getEntries(DatabaseExecutor db, int vault, { int limit, int offset }) async {
    final entries = await db.query(
      DatabaseEntry.table,
      where: "${DatabaseEntry.columnVault} = ?",
      whereArgs: [vault],
      limit: limit,
      offset: offset,
      orderBy: DatabaseEntry.columnPosition);
    return entries;
  }

  static Future<Map<String, dynamic>> getEntry(DatabaseExecutor db, int position, int vault) async {
    final entries = await db.query(
      DatabaseEntry.table,
      where: "${DatabaseEntry.columnPosition} = ? AND ${DatabaseEntry.columnVault} = ?",
      whereArgs: [position, vault],
      orderBy: DatabaseEntry.columnPosition);
    return entries.length < 1 ? null : entries[0];
  }

  static Future<int> nextPosition(DatabaseExecutor db, int vault) async {
    final x = await db.rawQuery('SELECT MAX(${DatabaseEntry.columnPosition}) AS position FROM ${DatabaseEntry.table} WHERE ${DatabaseEntry.columnVault} = $vault;');
    return ((x[0]['position'] as int) ?? 0) + 1;
  }
}
