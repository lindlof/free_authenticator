import 'entry.dart';
import 'entry_base.dart';
import 'package:dotp/dotp.dart' as dotp;

/// Time-Based One-Time Password
/// https://tools.ietf.org/html/rfc6238
class TOTP implements Entry {
  int type = EntryBase.typeTotp;
  EntryBase entry;
  
  TOTP(String name, String secret) {
    this.entry = EntryBase(name, secret);
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
    return this.entry.toDbFormat(EntryBase.typeTotp);
  }
}