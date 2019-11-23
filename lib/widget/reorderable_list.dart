import 'package:flutter/material.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';

/// Reorderable list with a single item selectable for reordering
class ReorderableListSelect<T> extends StatefulWidget {
  ReorderableListSelect({
    @required this.selected,
    @required this.itemCount,
    @required this.indexItemBuilder,
    @required this.onReorder,
    @required this.onReorderDone,
  });
  
  final Key selected;
  final int itemCount;
  final Widget Function(int) indexItemBuilder;
  final bool Function(Key, Key) onReorder;
  final void Function(Key, Key) onReorderDone;

  @override
  State<ReorderableListSelect> createState() => new _ReorderableListSelectState();
}

class _ReorderableListSelectState extends State<ReorderableListSelect> {
  Key lastReorderPosition;

  @override
  Widget build(BuildContext context) {
    return ReorderableList(
      child: ListView.builder(
        itemCount: this.widget.itemCount,
        itemBuilder: (BuildContext context, int index) {
          Widget item = this.widget.indexItemBuilder(index);
          return ReorderableItemSelect(key: item.key, innerItem: item, isSelected: item.key == this.widget.selected);
        },
      ),
      onReorder: (item, newPosition) {
        this.lastReorderPosition = newPosition;
        return this.widget.onReorder(item, newPosition);
      },
      onReorderDone: (item) {
        var last = this.lastReorderPosition;
        this.lastReorderPosition = null;
        return this.widget.onReorderDone(item, last);
      },
    );
  }
}

class ReorderableItemSelect extends StatelessWidget {
  ReorderableItemSelect({
    @required Key key,
    @required this.innerItem,
    @required this.isSelected,
  }) : super(key: key);

  final Widget innerItem;
  final bool isSelected;

  Widget _buildChild(BuildContext context, ReorderableItemState state) {
    Widget item = this.innerItem;
    if (this.isSelected) {
      item = ReorderableListener(
        child: Opacity(
          opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
          child: item,
        ),
      );
    }
    return item;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableItem(
      key: key,
      childBuilder: _buildChild,
    );
  }
}
