import 'package:flutter/material.dart';

class CustomizedInputField extends StatelessWidget {
  final TextEditingController textController;
  final bool isAdding;
  final VoidCallback onAdd;

  const CustomizedInputField({
    super.key,
    required this.textController,
    required this.isAdding,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Add to shopping list...',
                prefixIcon: const Icon(Icons.shop),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[200]
                    : Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
              enabled: !isAdding,
              onSubmitted: (_) => isAdding ? null : onAdd(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
            onPressed: onAdd,
            style: IconButton.styleFrom(
              backgroundColor: Colors.green[400],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
