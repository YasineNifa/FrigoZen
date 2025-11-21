import 'package:flutter/material.dart';

class ShoppinglistTile extends StatelessWidget {
  final String title;
  final String id;
  final bool isChecked;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  const ShoppinglistTile({
    super.key,
    required this.title,
    required this.id,
    required this.isChecked,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: Colors.red[700],
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: Checkbox(
          activeColor: Colors.green[400],
          value: isChecked,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: isChecked
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: isChecked ? Colors.grey[600] : Colors.black,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
