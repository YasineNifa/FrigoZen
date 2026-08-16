import 'package:flutter/material.dart';

import 'package:frigo_zen/models/shopping_item.dart';
import 'package:frigo_zen/components/initials_avatar.dart';

import 'package:frigo_zen/models/frigo_user.dart';

class ShoppinglistTile extends StatelessWidget {
  final ShoppingItem item;
  final FrigoUser? addedByUser;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const ShoppinglistTile({
    super.key,
    required this.item,
    this.addedByUser,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red[700],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isChecked ? Colors.green.withValues(alpha: 0.2) : Colors.grey[200]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                activeColor: Colors.green[400],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                value: item.isChecked,
                onChanged: (_) => onToggle(),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                height: 40,
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => InitialsAvatar(
                            name: item.cleanedName.isNotEmpty ? item.cleanedName : item.name,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : InitialsAvatar(
                        name: item.cleanedName.isNotEmpty ? item.cleanedName : item.name,
                        fontSize: 14,
                      ),
              ),
            ],
          ),
          title: Text(
            item.name,
            style: TextStyle(
              decoration: item.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
              color: item.isChecked ? Colors.grey[600] : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: (item.quantity > 1 || (item.brands != null && item.brands!.isNotEmpty) || addedByUser?.photoURL != null || addedByUser?.displayName != null)
            ? Row(
                children: [
                  if (item.quantity > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        "x${item.quantity}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (item.brands != null && item.brands!.isNotEmpty)
                    Expanded(
                      child: Text(
                        item.brands!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (addedByUser != null && (addedByUser!.photoURL != null || addedByUser!.displayName != null)) ...[
                    const SizedBox(width: 8),
                    if (addedByUser!.photoURL != null) ...[
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: addedByUser!.photoURL!.startsWith('http')
                                ? NetworkImage(addedByUser!.photoURL!)
                                : AssetImage(addedByUser!.photoURL!) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (addedByUser!.displayName != null)
                      Flexible(
                        child: Text(
                          addedByUser!.displayName!,
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ],
              )
            : null,
          trailing: IconButton(
            icon: Icon(Icons.close, size: 18, color: Colors.grey[400]),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}
