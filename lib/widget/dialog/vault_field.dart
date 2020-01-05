import 'package:flutter/material.dart';
import 'package:free_authenticator/model/api/entry.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/widget/dependencies.dart';
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
  String currentVault = "";
  String currentText = "";

  @override
  void initState() {
    super.initState();
    this.widget.controller.addListener(() {
        this.setState(() {
          currentText = this.widget.controller.text;
        });
    });
    this._loadVault();
  }

  _loadVault() async {
    await Future.delayed(Duration.zero);
    var vaults = await Dependencies.of(context).store.getEntries(type: EntryType.vault);

    if (this.widget.entry != null) {
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
    var vaultDesc = "";
    if (this.currentText.isEmpty) {
      vaultDesc = "Storing in Main Vault";
    } else if (vaultSuggestions.contains(this.currentText)) {
      vaultDesc = "Storing in an existing vault";
    } else {
      vaultDesc = "Forging a new vault";
    }

    return (
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SimpleAutoCompleteTextField(
            key: key,
            decoration: this.widget.decoration,
            controller: this.widget.controller,
            suggestions: vaultSuggestions,
            textChanged: (text) => currentVault = text,
            clearOnSubmit: false,
            textSubmitted: (text) => currentVault = text,
          ),
          Text(
            vaultDesc,
            style: TextStyle(fontSize: 13),
          ),
        ]
      )
    );
  }
}
