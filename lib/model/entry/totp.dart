import '../interface/entry.dart';
import 'entry_base.dart';
import 'package:dotp/dotp.dart' as dotp;

import '../interface/entry_type.dart';

/// Time-Based One-Time Password
/// https://tools.ietf.org/html/rfc6238
class TOTP implements TimedPasswordEntry {
  EntryType type = EntryType.totp;
  int timeStep;
  EntryBase entry;
  String secret;
  
  TOTP(int id, String name, this.secret, int position, int vault, this.timeStep) {
    this.entry = EntryBase(id, name, position, vault);
  }

  int get id => this.entry.id;
  String get name => this.entry.name;
  int get position => this.entry.position;
  int get vault => this.entry.vault;
  setPosition(position, vault) => this.entry.setPosition(position, vault);

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
