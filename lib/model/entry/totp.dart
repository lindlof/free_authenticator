import '../api/entry.dart';
import 'entry_base.dart';
import 'package:dotp/dotp.dart' as dotp;

import '../api/entry_type.dart';

/// Time-Based One-Time Password
/// https://tools.ietf.org/html/rfc6238
class TOTP extends EntryBase implements TimedPasswordEntry {
  int timeStep;
  String secret;
  
  TOTP(int id, String name, this.secret, int position, int vault, this.timeStep) :
  super(EntryType.totp, id, name, position, vault);

  int get id => super.id;
  String get name => super.name;
  int get position => super.position;
  int get vault => super.vault;

  String genPassword() {
    dotp.TOTP totp = dotp.TOTP(this.secret, this.timeStep);
    try {
      return totp.now();
    } catch(Exception) {
      return "Invalid secret";
    }
  }

  @override
  String toString() {
    return "TOTP ${this.id} ${this.vault}:${this.position} ${this.name}";
  }
}
