import 'package:flutter/material.dart';
import 'package:free_authenticator/model/interface/entry.dart';
import 'package:free_authenticator/model/interface/entry_type.dart';

import 'timed_password_widget.dart';
import 'vault_widget.dart';

class EntryWidgetFactory {
  static Widget create(
      Entry entry,
      Function(int) openVault
    ) {
    if (entry.type == EntryType.totp) {
      return TimedPasswordWidget(entry: entry as TimedPasswordEntry);
    } else if (entry.type == EntryType.vault) {
      return VaultWidget(entry: entry, onTap: openVault);
    }
    throw StateError("Unknown type " + entry.type.toString());
  }
}