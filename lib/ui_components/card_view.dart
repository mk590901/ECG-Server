// Custom card view
import 'package:flutter/material.dart';

import '../ui_blocks/item_model.dart';

class CardView extends StatelessWidget {
  final Item item;

  const CardView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.info_outline, color: Colors.lightBlue),
            title: Text(item.title),
            subtitle: Text(
              item.subtitle,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          item.graphWidget,
        ],
      ),
    );
  }
}
