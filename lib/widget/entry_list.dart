import 'package:flutter/material.dart';
import 'package:free_authenticator/entry_widget/entry_widget_factory.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/widget/dependencies.dart';
import 'package:free_authenticator/widget/reorderable_list.dart';
import 'dialog/create_entry_dialog.dart';
import 'dialog/delete_entry_dialog.dart';
import 'dialog/edit_entry_dialog.dart';
import 'select_route.dart';

class EntryList extends StatefulWidget {
  final String title;
  final int vaultId;
  final Dialogs dialogs;

  EntryList({
    Key key,
    @required this.title,
    this.vaultId: VaultEntry.rootId,
    this.dialogs: const Dialogs(),
  }) : super(key: key);

  @override
  _EntryList createState() => _EntryList();
}

class _EntryList extends State<EntryList> {
  var entries = <Entry>[];
  Entry selected;
  Entry vault;

  @override
  void initState() {
    super.initState();
    this._init();
  }

  _init() async {
    this._loadEntries();
  }

  _loadEntries() async {
    await Future.delayed(Duration.zero);
    if (this.vault == null) this.vault = await Dependencies.of(context).store.getEntry(this.widget.vaultId);
    final entries = await Dependencies.of(context).store.getEntries(vault: this.vault.id);
    setState(() {
      this.entries = entries;
    });
  }

  _createEntry(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return this.widget.dialogs.createEntryDialog(
          onCreate: (int id) async {
            _loadEntries();
          },
        );
      });
  }

  _editEntry(Entry selected) {
    return showDialog(
      context: context,
      builder: (context) {
        return this.widget.dialogs.editEntryDialog(
          entry: selected,
          onEdit: (int id) async {
            this._deselect();
            setState(() {
              this._loadEntries();
            });
          },
        );
      });
  }

  _deleteEntry(Entry selected) {
    return showDialog(
      context: context,
      builder: (context) {
        return this.widget.dialogs.deleteEntryDialog(
          entry: selected,
          onDelete: (int id) async {
            this._deselect();
            this._loadEntries();
          }
        );
      });
  }

  Key get _selectedKey => this.selected == null ? null : ValueKey(this.selected.id);

  _openVault(int id) async {
    EntryList newRoute = EntryList(title: 'One-time Passwords', vaultId: id);
    Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => newRoute))
      .then((dynamic v) => _loadEntries());
  }

  _onSelect(Entry entry) {
    var selectRoute = SelectRoute(onRemove: () {
      setState(() {
        this.selected = null;
      });
    });
    Navigator.of(context).push(selectRoute);
    setState(() {
      this.selected = entry;
    });
  }

  _deselect() {
    Navigator.of(context).popUntil((route) { return route is! SelectRoute; });
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

  _reorderDone(Key item, Key lastPosition) {
    if (lastPosition == null) return;
    int draggingIndex = entries.indexWhere((Entry e) => ValueKey(e.id) == item);
    int newPositionIndex = entries.indexWhere((Entry e) => ValueKey(e.id) == lastPosition);
    final draggedItem = entries[draggingIndex];
    final newPositionItem = entries[newPositionIndex];
    Dependencies.of(context).store.reorderEntry(draggedItem.id, newPositionItem.position)
      .then((x) { this._deselect(); this._loadEntries(); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: this.selected == null ? null : new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: this.selected == null ? null : <Widget>[
          new IconButton(
            icon: new Icon(Icons.edit),
            onPressed: () => _editEntry(this.selected),
          ),
          new IconButton(
            icon: new Icon(Icons.delete),
            highlightColor: Colors.red,
            onPressed: () => _deleteEntry(this.selected),
          ),
        ],
        title: this.selected != null ? Text(this.selected.name) : Text(widget.title),
      ),
      body: Center(
        child: ReorderableListSelect(
          selected: _selectedKey,
          itemCount: this.entries.length,
          indexItemBuilder: (int index) {
            Entry entry = entries[index];
            return EntryWidgetFactory.create(
              entry,
              ValueKey(entry.id) == _selectedKey,
              this._onSelect,
              this._openVault
            );
          },
          onReorder: this._reorderCallback,
          onReorderDone: this._reorderDone,
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

class Dialogs {
  const Dialogs();

  Widget createEntryDialog({Key key, Future Function(int) onCreate}) {
    return CreateEntryDialog(key: key, onCreate: onCreate);
  }
  Widget editEntryDialog({Key key, @required Entry entry, Future<dynamic> Function(int) onEdit}) {
    return EditEntryDialog(key: key, entry: entry, onEdit: onEdit);
  }
  Widget deleteEntryDialog({Key key, @required Entry entry, Future<dynamic> Function(int) onDelete}) {
    return DeleteEntryDialog(key: key, entry: entry, onDelete: onDelete);
  }
}
