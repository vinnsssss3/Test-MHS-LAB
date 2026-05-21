import 'package:flutter/material.dart';
import '../../config/stores.dart';
import '../../models/item.dart';
import '../../services/item_service.dart';
import '../../widgets/validated_field.dart';
import '../../widgets/themed_button.dart';

// Page 11 — create or edit an item (admin only)
class ItemFormScreen extends StatefulWidget {
  const ItemFormScreen({super.key});

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _stockCtrl  = TextEditingController();
  final _priceCtrl  = TextEditingController();
  final _imageCtrl  = TextEditingController();

  String? _selectedStore;
  String? _selectedType;
  bool _loading = false;
  bool _isEdit  = false;
  Item? _existingItem;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isEdit) return; // only parse once

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) return;

    _selectedStore = args['store'] as String?;
    final item = args['item'] as Item?;
    if (item != null) {
      _isEdit        = true;
      _existingItem  = item;
      _nameCtrl.text  = item.name;
      _descCtrl.text  = item.description;
      _stockCtrl.text = item.stock.toString();
      _priceCtrl.text = item.price.toString();
      _imageCtrl.text = item.image;
      _selectedStore  = item.store;
      _selectedType   = item.type;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _stockCtrl.dispose();
    _priceCtrl.dispose(); _imageCtrl.dispose();
    super.dispose();
  }

  StoreMeta? get _storeMeta =>
      _selectedStore == null ? null : storeById(_selectedStore!);

  // Validation 5: type must be valid for the selected store
  String? _validateType(String? v) {
    if (v == null || v.isEmpty) return 'This field is required';
    final meta = _storeMeta;
    if (meta != null && !meta.types.contains(v)) {
      return 'Select a valid type for this store';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final body = {
      'store':       _selectedStore,
      'name':        _nameCtrl.text.trim(),
      'type':        _selectedType,
      'description': _descCtrl.text.trim(),
      'stock':       int.parse(_stockCtrl.text.trim()),
      'price':       double.parse(_priceCtrl.text.trim()),
      'image':       _imageCtrl.text.trim(),
    };
    try {
      if (_isEdit && _existingItem != null) {
        await ItemService.updateItem(_existingItem!.id, body);
      } else {
        await ItemService.createItem(body);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Item updated' : 'Item created')));
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeTypes = _storeMeta?.types ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Item' : 'Add Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // Store selector
            DropdownButtonFormField<String>(
              value: _selectedStore,
              decoration: const InputDecoration(labelText: 'Store'),
              dropdownColor: const Color(0xFF0B1026),
              style: const TextStyle(color: Color(0xFFE6E8EF)),
              items: kStores.map((s) => DropdownMenuItem(
                value: s.id,
                child: Text(s.label),
              )).toList(),
              onChanged: (v) => setState(() {
                _selectedStore = v;
                _selectedType  = null; // reset type when store changes
              }),
              validator: (v) =>
                  v == null ? 'This field is required' : null,
            ),
            const SizedBox(height: 14),
            // Type selector — constrained to selected store's types
            DropdownButtonFormField<String>(
              value: storeTypes.contains(_selectedType) ? _selectedType : null,
              decoration: const InputDecoration(labelText: 'Type'),
              dropdownColor: const Color(0xFF0B1026),
              style: const TextStyle(color: Color(0xFFE6E8EF)),
              items: storeTypes.map((t) => DropdownMenuItem(
                value: t, child: Text(t))).toList(),
              onChanged: storeTypes.isEmpty ? null : (v) =>
                  setState(() => _selectedType = v),
              validator: _validateType,
            ),
            const SizedBox(height: 14),
            ValidatedField(
              label: 'Name',
              controller: _nameCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'This field is required' : null,
            ),
            const SizedBox(height: 14),
            ValidatedField(
              label: 'Description',
              controller: _descCtrl,
              maxLines: 3,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'This field is required' : null,
            ),
            const SizedBox(height: 14),
            // Validation 3: stock is non-negative integer
            ValidatedField(
              label: 'Stock',
              controller: _stockCtrl,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'This field is required';
                final n = int.tryParse(v.trim());
                if (n == null || n < 0) return 'Stock must be a non-negative integer';
                return null;
              },
            ),
            const SizedBox(height: 14),
            // Validation 3: price is non-negative number
            ValidatedField(
              label: 'Price (₱)',
              controller: _priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'This field is required';
                final n = double.tryParse(v.trim());
                if (n == null || n < 0) return 'Price must be a non-negative number';
                return null;
              },
            ),
            const SizedBox(height: 14),
            ValidatedField(
              label: 'Image path or URL',
              controller: _imageCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'This field is required' : null,
            ),
            const SizedBox(height: 24),
            ThemedButton(
              label: _isEdit ? 'Save Changes' : 'Create Item',
              loading: _loading,
              icon: _isEdit ? Icons.save : Icons.add_circle_outline,
              onPressed: _submit,
            ),
          ]),
        ),
      ),
    );
  }
}
