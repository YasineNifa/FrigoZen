import 'package:flutter/material.dart';
import 'package:frigo_zen/models/batch.dart';
import 'package:frigo_zen/theme/app_theme.dart';

class EditBatchDialog extends StatefulWidget {
  final Batch batch;
  final Function(Batch) onSave;

  const EditBatchDialog({
    super.key,
    required this.batch,
    required this.onSave,
  });

  @override
  State<EditBatchDialog> createState() => _EditBatchDialogState();
}

class _EditBatchDialogState extends State<EditBatchDialog> {
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _storeController;
  late int _quantity;
  late DateTime _expirationDate;
  String? _nutriscore;

  final List<String> _nutriscoreOptions = ['A', 'B', 'C', 'D', 'E'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.batch.name ?? '');
    _brandController = TextEditingController(text: widget.batch.brands ?? '');
    _storeController = TextEditingController(text: widget.batch.storeName ?? '');
    _quantity = widget.batch.quantity;
    _expirationDate = widget.batch.expirationDate;
    _nutriscore = widget.batch.nutriscore?.toUpperCase();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _storeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _expirationDate = picked);
    }
  }

  void _save() {
    final updatedBatch = widget.batch.copyWith(
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      brands: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      storeName: _storeController.text.trim().isEmpty ? null : _storeController.text.trim(),
      quantity: _quantity,
      expirationDate: _expirationDate,
      nutriscore: _nutriscore,
    );
    widget.onSave(updatedBatch);
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Modifier le lot"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nom spécifique",
                hintText: "ex: Oeufs Bio",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Marque
            TextField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: "Marque",
                hintText: "ex: Bio Village",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.branding_watermark_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Magasin
            TextField(
              controller: _storeController,
              decoration: const InputDecoration(
                labelText: "Magasin",
                hintText: "ex: Leclerc",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Nutri-Score
            InputDecorator(
              decoration: const InputDecoration(
                labelText: "Nutri-Score",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.health_and_safety_outlined),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _nutriscoreOptions.contains(_nutriscore) ? _nutriscore : null,
                  isDense: true,
                  items: [
                    const DropdownMenuItem(value: null, child: Text("Non défini")),
                    ..._nutriscoreOptions.map((score) => DropdownMenuItem(
                          value: score,
                          child: Text("Nutri-Score $score"),
                        )),
                  ],
                  onChanged: (value) => setState(() => _nutriscore = value),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Date d'expiration
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date d'expiration",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            _formatDate(_expirationDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quantité
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Quantité",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.quantityControlBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text("Enregistrer"),
        ),
      ],
    );
  }
}
