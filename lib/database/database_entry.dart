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

  static Future<List<Map<String, dynamic>>> getEntries(DatabaseExecutor db, { int type, int vault, int limit, int offset }) async {
    var where = [];
    var whereArgs = [];
    if (type != null) {
      where.add("${DatabaseEntry.columnType} = ?");
      whereArgs.add(type);
    }
    if (vault != null) {
      where.add("${DatabaseEntry.columnVault} = ?");
      whereArgs.add(vault);
    }
    final entries = await db.query(
      DatabaseEntry.table,
      where: where.join(" AND "),
      whereArgs: whereArgs,
      limit: limit,
      offset: offset,
      orderBy: DatabaseEntry.columnPosition);
    return entries;
  }

  static Future<int> entryUpdatePositions(
      DatabaseExecutor db, int vault, int fromPosition, int toPosition, bool add
    ) async {
    String op = add ? "+" : "-";
    int count = await db.rawUpdate(
      "UPDATE ${DatabaseEntry.table} " +
      "SET ${DatabaseEntry.columnPosition} = ${DatabaseEntry.columnPosition} $op 1 " +
      "WHERE ${DatabaseEntry.columnVault} = ? AND " +
      "${DatabaseEntry.columnPosition} >= ? AND " +
      "${DatabaseEntry.columnPosition} <= ?",
      [vault, fromPosition, toPosition]);
    return count;
  }

  static Future<int> delete(DatabaseExecutor db, int id) async {
    return db.delete(
      table,
      where: "$columnId = ?", whereArgs: [id]
    );
  }

  static Future<int> nextPosition(DatabaseExecutor db, int vault) async {
    final x = await db.rawQuery('SELECT MAX(${DatabaseEntry.columnPosition}) AS position FROM ${DatabaseEntry.table} WHERE ${DatabaseEntry.columnVault} = $vault;');
    return ((x[0]['position'] as int) ?? 0) + 1; // TODO magic number, should be ENTRY_MIN_POSITION
  }
}
