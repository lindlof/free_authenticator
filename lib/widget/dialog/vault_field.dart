import 'package:flutter/material.dart';
import 'package:free_authenticator/model/interface/entry.dart';
import 'package:free_authenticator/model/interface/entry_type.dart';
import 'package:free_authenticator/widget/store_injector.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class VaultField extends StatefulWidget {
  VaultField({
    Key key,
    @required this.controller,
    this.decoration,
    this.entry,
  }) : super(key: key);

  final TextEditingController controller;
  final InputDecoration decoration;
  final Entry entry;

  @override
  _VaultField createState() => _VaultField();
}

class _VaultField extends State<VaultField> {
  final GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  String currentText = "";

  @override
  void initState() {
    super.initState();
    this._loadVault();
  }

  _loadVault() async {
    await Future.delayed(Duration.zero);
    var vaults = await StoreInjector.of(context).getEntries(type: EntryType.vault);

    if (this.widget.entry != null && this.widget.entry.id != VaultEntry.rootId) {
      var currentVault = vaults.firstWhere(
        (v) => v.id == this.widget.entry.vault,
        orElse: () => null);
      if (currentVault != null) {
        this.setState(() {
          this.widget.controller.text = currentVault.name;
        });
      }
    }

    var vaultNames = vaults.map((v) => v.name);
    vaultSuggestions.addAll(vaultNames);
  }

  List<String> vaultSuggestions = [];

  @override
  Widget build(BuildContext context) {
    return (
      SimpleAutoCompleteTextField(
        key: key,
        decoration: this.widget.decoration,
        controller: this.widget.controller,
        suggestions: vaultSuggestions,
        textChanged: (text) => currentText = text,
        clearOnSubmit: false,
        textSubmitted: (text) => currentText = text,
      )
    );
  }
}
