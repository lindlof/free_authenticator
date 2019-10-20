import 'package:flutter/material.dart';
import 'package:free_authenticator/entry_widget/entry_widget_factory.dart';
import 'package:free_authenticator/factory/entry_factory.dart';
import 'package:free_authenticator/factory/vault_factory.dart';
import 'package:free_authenticator/model/interface/entry.dart';
import 'package:free_authenticator/widget/dialog/create_entry.dart';
import 'package:free_authenticator/widget/reorderable_list.dart';

class EntryList extends StatefulWidget {
  final String title;
  final int vaultId;

  EntryList({
    Key key,
    @required this.title,
    this.vaultId: VaultEntry.rootId,
  }) : super(key: key);

  @override
  _EntryList createState() => _EntryList();
}

class _EntryList extends State<EntryList> {
  final entries = <Entry>[];
  Key selected;
  Entry vault;

  @override
  void initState() {
    super.initState();
    this._init();
  }

  _init() async {
    this.vault = await EntryFactory.get(this.widget.vaultId);
    this._loadEntries();
  }

  _loadEntries() async {
    final entries = await EntryFactory.getEntries(this.vault.id, this._nextPosition);
    setState(() {
      this.entries.addAll(entries);
    });
  }

  _createEntry(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return CreateEntry(
          onCreate: (Map<String, dynamic> input) async {
            String inputVault = input["vault"];
            int vault = input.containsKey("vault") ?
              await VaultFactory.getOrCreate(inputVault) :
              VaultEntry.rootId;
            await EntryFactory.create(input, vault);
            Entry entry = await EntryFactory.getEntry(this._nextPosition, this.vault.id);
            if (entry != null) {
              setState(() {
                this.entries.add(entry);
              });
            }
          }
        );
      });
  }

  int get _nextPosition => this.entries.length + 1;

  _openVault(int id) async {
    EntryList newRoute = EntryList(title: 'One-time Passwords', vaultId: id);
    Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => newRoute))
      .then((dynamic v) => _loadEntries());
  }

  _onSelect(Entry entry) {
    setState(() {
      this.selected = ValueKey(entry.id);
    });
  }

  bool _reorderCallback(Key item, Key newPosition) {
    int draggingIndex = entries.indexWhere((Entry e) => ValueKey(e.id) == item);
    int newPositionIndex = entries.indexWhere((Entry e) => ValueKey(e.id) == newPosition);
    final draggedItem = entries[draggingIndex];

    this.setState(() {
      entries.removeAt(draggingIndex);
      entries.insert(newPositionIndex, draggedItem);
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ReorderableListSelect(
          selected: this.selected,
          itemCount: this.entries.length,
          indexItemBuilder: (int index) {
            Entry entry = entries[index];
            return EntryWidgetFactory.create(entry, ValueKey(entry.id) == this.selected, this._onSelect, this._openVault);
          },
          onReorder: this._reorderCallback,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { _createEntry(context); },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
