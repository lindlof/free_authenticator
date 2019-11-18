import 'package:flutter/widgets.dart';
import 'package:free_authenticator/model/interface/entry.dart';
import 'package:free_authenticator/model/interface/entry_type.dart';

class StoreInjector extends InheritedWidget {
  final Future<Entry> Function(int id) getEntry;
  final Future<List<Entry>> Function(int vault, { int limit, int offset }) getEntries;
  final Future<int> Function(EntryType type, int vault, {String name, String secret, int timestep}) createEntry;
  final Future<void> Function(Entry entry, {int vault, String name, String secret, int timestep}) updateEntry;
  final Future<void> Function(int id) deleteEntry;
  final Future<void> Function(int id, int position) reorderEntry;
  final Future<int> Function(String name) getOrCreateVault;

  StoreInjector({
    Key key,
    @required Widget child,
    @required this.getEntry,
    @required this.getEntries,
    @required this.createEntry,
    @required this.updateEntry,
    @required this.deleteEntry,
    @required this.reorderEntry,
    @required this.getOrCreateVault,
  }) : assert(child != null),
        super(key: key, child: child);

  static StoreInjector of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(StoreInjector) as StoreInjector;
  }

  @override
  bool updateShouldNotify(StoreInjector old) => false;
}
