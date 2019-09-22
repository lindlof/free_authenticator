import 'package:flutter/material.dart';
import 'package:free_authenticator/create_entry.dart';
import 'package:free_authenticator/entry.dart';
import 'package:free_authenticator/entry_factory.dart';
import 'package:free_authenticator/entry_type.dart';
import 'package:free_authenticator/vault.dart';
import 'package:free_authenticator/vault_factory.dart';
import 'package:free_authenticator/widget/entry/timed_password_widget.dart';
import 'package:free_authenticator/widget/entry/vault_widget.dart';

class EntryList extends StatefulWidget {
  final String title;
  final int vaultId;

  EntryList({
    Key key,
    @required this.title,
    @required this.vaultId,
  }) : super(key: key);

  @override
  _EntryList createState() => _EntryList();
}

class _EntryList extends State<EntryList> {
  final entries = <Entry>[];
  Vault vault;

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
    final entries = await EntryFactory.getEntries(this.vault.id);
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
              Vault.rootId;
            await EntryFactory.create(input, vault);
            Entry entry = await EntryFactory.getEntry(entries.length+1, vault);
            setState(() {
              this.entries.add(entry);
            });
          }
        );
      });
  }

  _openVault(int id) async {
    EntryList newRoute = EntryList(title: 'One-time Passwords', vaultId: id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => newRoute),
    );

    // this.entries.clear();
    // this.vault = await EntryFactory.get(id);
    // this._loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: this.entries.length,
          itemBuilder: (context, int) {
            var entry = entries[int];
            if (entry.type == EntryType.totp) {
              return TimedPasswordWidget(entry: entry as TimedPasswordEntry);
            } else if (entry.type == EntryType.vault) {
              return VaultWidget(entry: entry, onTap: this._openVault);
            }
            throw StateError("Unknown type " + entry.type.toString());
          },
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
