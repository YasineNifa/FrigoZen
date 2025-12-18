import 'package:flutter/material.dart';
import 'package:frigo_zen/l10n/generated/app_localizations.dart';
import 'package:frigo_zen/models/catalog_item.dart';
import 'package:frigo_zen/repositories/product_catalog_repository.dart';

class CustomizedInputField extends StatefulWidget {
  final TextEditingController textController;
  final bool isAdding;
  final VoidCallback onAdd;
  final bool showPremiumLock;
  final VoidCallback? onPremiumLockTap;

  const CustomizedInputField({
    super.key,
    required this.textController,
    required this.isAdding,
    required this.onAdd,
    this.showPremiumLock = false,
    this.onPremiumLockTap,
  });

  @override
  State<CustomizedInputField> createState() => _CustomizedInputFieldState();
}

class _CustomizedInputFieldState extends State<CustomizedInputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Define input decoration separately to reuse it or mimic it
    InputDecoration inputDecoration = InputDecoration(
      hintText: l10n.inputFieldHintText,
      prefixIcon: const Icon(Icons.shop),
      suffixIcon: widget.showPremiumLock
          ? GestureDetector(
              onTap: widget.onPremiumLockTap,
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: Colors.orange[800]),
                    const SizedBox(width: 4),
                    Text(
                      l10n.shoppingInventoryCheckDisabled,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[200]
          : Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top for multi-line or suggestions
        children: [
          Expanded(
            child: RawAutocomplete<CatalogItem>(
              textEditingController: widget.textController,
              focusNode: _focusNode,
              
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.trim().length < 2) {
                   return const Iterable<CatalogItem>.empty();
                }
                final repo = ProductCatalogRepository();
                // We use searchCatalog just like in AddItemSheet
                return await repo.searchCatalog(textEditingValue.text);
              },
              
              displayStringForOption: (CatalogItem option) => option.name,
              
              onSelected: (CatalogItem selection) {
                // When selected, we just fill the text controller.
                // The user still needs to press "Add" to confirm quantity checking etc.
                // Or we could auto-submit? Let's stick to filling text.
                widget.textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: widget.textController.text.length),
                );
              },
              
              fieldViewBuilder: (
                  BuildContext context, 
                  TextEditingController fieldTextEditingController, 
                  FocusNode fieldFocusNode, 
                  VoidCallback onFieldSubmitted
              ) {
                  return TextField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    decoration: inputDecoration,
                    enabled: !widget.isAdding,
                    onSubmitted: (_) => widget.isAdding ? null : widget.onAdd(),
                  );
              },
              
              optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<CatalogItem> onSelected, Iterable<CatalogItem> options) {
                 return Align(
                   alignment: Alignment.topLeft,
                   child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 90, // Approx width adjustment
                        // Or we can use LayoutBuilder to match width.
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (ctx, i) => const Divider(height: 1),
                          itemBuilder: (BuildContext context, int index) {
                             final CatalogItem option = options.elementAt(index);
                             return ListTile(
                               dense: true, // Compact
                               leading: option.imageUrl != null && option.imageUrl!.isNotEmpty
                                   ? SizedBox(
                                       width: 30, 
                                       height: 30,
                                       child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: Image.network(option.imageUrl!, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.fastfood, size: 20))
                                       )
                                   )
                                   : const Icon(Icons.fastfood, size: 20),
                               title: Text(option.name, style: const TextStyle(fontSize: 14)),
                               subtitle: option.brands != null ? Text(option.brands!, style: const TextStyle(fontSize: 11)) : null,
                               onTap: () {
                                 onSelected(option);
                               },
                             );
                          },
                        ),
                      ),
                   ),
                 );
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: widget.isAdding 
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.add_shopping_cart, color: Colors.white),
            onPressed: widget.isAdding ? null : widget.onAdd,
            style: IconButton.styleFrom(
              backgroundColor: Colors.green[400],
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.green[200],
            ),
          ),
        ],
      ),
    );
  }
}
