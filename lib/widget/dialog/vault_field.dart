import 'package:flutter/material.dart';
import 'package:free_authenticator/model/interface/entry_type.dart';
import 'package:free_authenticator/widget/store_injector.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class VaultField extends StatefulWidget {
  VaultField({
    Key key,
    this.controller,
    this.decoration,
  }) : super(key: key);

  final TextEditingController controller;
  final InputDecoration decoration;

  @override
  _VaultField createState() => _VaultField();
}

class _VaultField extends State<VaultField> {
  TextEditingController input = TextEditingController();
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
