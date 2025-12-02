import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: l10n.inputFieldHintText,
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
            icon: isAdding 
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.add_shopping_cart, color: Colors.white),
            onPressed: isAdding ? null : onAdd,
            style: IconButton.styleFrom(
              backgroundColor: Colors.green[400],
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.green[200], // Lighter green when disabled
            ),
          ),
        ],
      ),
    );
  }
}
