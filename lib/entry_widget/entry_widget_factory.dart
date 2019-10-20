import 'package:flutter/material.dart';
import 'package:free_authenticator/model/interface/entry.dart';
import 'package:free_authenticator/model/interface/entry_type.dart';

import 'timed_password_widget.dart';
import 'vault_widget.dart';

class EntryWidgetFactory {
  static Widget create(
      Entry entry,
      bool isSelected,
      Function(Entry) onSelect,
      Function(int) openVault,
    ) {
    if (entry.type == EntryType.totp) {
      return TimedPasswordWidget(
        key: ValueKey(entry.id),
        entry: entry as TimedPasswordEntry,
        isSelected: isSelected,
        onSelect: onSelect,
      );
    } else if (entry.type == EntryType.vault) {
      return VaultWidget(
        key: ValueKey(entry.id),
        entry: entry,
        isSelected: isSelected,
        onSelect: onSelect,
        onTap: openVault,
      );
    }
    throw StateError("Unknown type " + entry.type.toString());
  }
}