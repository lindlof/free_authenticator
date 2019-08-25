import 'entry.dart';
import 'entry_base.dart';

/// Time-Based One-Time Password
/// https://tools.ietf.org/html/rfc6238
class TOTP implements Entry {
  int type = EntryBase.typeTotp;
  EntryBase entry;
  
  TOTP(String name, String secret) {
    this.entry = EntryBase(name, secret);
  }

  String get name => this.entry.name;
  String get secret => this.entry.secret;

  Future<Map<String, dynamic>> toDbFormat() {
    return this.entry.toDbFormat(EntryBase.typeTotp);
  }
}