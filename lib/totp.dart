import 'package:free_authenticator/database_entry.dart';

import 'timed_entry.dart';
import 'entry_base.dart';
import 'package:dotp/dotp.dart' as dotp;

/// Time-Based One-Time Password
/// https://tools.ietf.org/html/rfc6238
class TOTP implements TimedEntry {
  int type = DatabaseEntry.typeTotp;
  int timeStep;
  EntryBase entry;
  
  TOTP(String name, String secret, {timeStep}) {
    this.entry = EntryBase(name, secret);
    this.timeStep = (timeStep == null) ? 30000 : timeStep;
  }

  String get name => this.entry.name;

  String genPassword() {
    dotp.TOTP totp = dotp.TOTP(this.entry.secret);
    try {
      return totp.now();
    } catch(Exception) {
      return "Invalid secret";
    }
  }

  Future<Map<String, dynamic>> toDbFormat() {
    Map<String, dynamic> dataMap = {
      DatabaseEntry.dataName     : entry.name,
      DatabaseEntry.dataSecret   : entry.secret,
      DatabaseEntry.dataTimeStep : this.timeStep,
    };
    return this.entry.toDbFormat(DatabaseEntry.typeTotp, dataMap);
  }
}
