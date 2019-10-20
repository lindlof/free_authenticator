import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:free_authenticator/model/interface/entry.dart';

class VaultWidget extends StatelessWidget {
  final Entry entry;
  final bool isSelected;
  final Function(Entry) onSelect;
  final Function onTap;

  const VaultWidget({
    Key key,
    @required this.entry,
    this.isSelected,
    this.onSelect,
    this.onTap,
  }) : super(key: key);

  void _onSelect() {
    this.onSelect(this.entry);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Icon(Icons.group_work),
        ),
      ),
      title: Text(this.entry.name),
      onLongPress: _onSelect,
      selected: this.isSelected,
      onTap: () => this.onTap(this.entry.id),
    );
  }
}
