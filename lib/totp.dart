import 'package:free_authenticator/database_entry.dart';
import 'package:free_authenticator/entry_type.dart';

import 'timed_entry.dart';
import 'entry_base.dart';
import 'package:dotp/dotp.dart' as dotp;

/// Time-Based One-Time Password
/// https://tools.ietf.org/html/rfc6238
class TOTP implements TimedEntry {
  EntryType type = EntryType.totp;
  int timeStep;
  EntryBase entry;
  
  TOTP(String name, String secret, {int position, int grouping, this.timeStep}) {
    this.entry = EntryBase(name, secret, position: position, grouping: grouping);
    this.timeStep = (timeStep == null) ? 30 : timeStep;
  }

  String get name => this.entry.name;
  int get position => this.entry.position;
  int get grouping => this.entry.grouping;
  setPosition(position, grouping) => this.entry.setPosition(position, grouping);

  String genPassword() {
    dotp.TOTP totp = dotp.TOTP(this.entry.secret, this.timeStep);
    try {
      return totp.now();
    } catch(Exception) {
      return "Invalid secret";
    }
  }

  @override
  String toString() {
    return "TOTP ${this.grouping ?? 'root'}:${this.position} ${this.name}";
  }

  Future<Map<String, dynamic>> toDbFormat() {
    Map<String, dynamic> dataMap = {
      DatabaseEntry.dataName     : entry.name,
      DatabaseEntry.dataSecret   : entry.secret,
      DatabaseEntry.dataTimeStep : this.timeStep,
    };
    return this.entry.toDbFormat(EntryType.totp, dataMap);
  }
}
