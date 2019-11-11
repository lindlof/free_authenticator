import 'package:flutter/widgets.dart';
import 'package:free_authenticator/model/interface/entry.dart';
import 'package:free_authenticator/model/interface/entry_type.dart';

class StoreInjector extends InheritedWidget {
  final Future<Entry> Function(int id) getEntry;
  final Future<List<Entry>> Function(int vault, int fromPosition) getEntries;
  final Future<int> Function(EntryType type, int vault, {String name, String secret, int timestep}) createEntry;
  final Future<Entry> Function(int position, int vault) getEntryInPosition;
  final Future<void> Function(Entry entry, {String name, String secret, int timestep}) updateEntry;
  final Future<int> Function(String name) getOrCreateVault;

  StoreInjector({
    Key key,
    @required Widget child,
    @required this.getEntry,
    @required this.getEntries,
    @required this.createEntry,
    @required this.getEntryInPosition,
    @required this.updateEntry,
    @required this.getOrCreateVault,
  }) : assert(child != null),
        super(key: key, child: child);

  static StoreInjector of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(StoreInjector) as StoreInjector;
  }

  @override
  bool updateShouldNotify(StoreInjector old) => false;
}
