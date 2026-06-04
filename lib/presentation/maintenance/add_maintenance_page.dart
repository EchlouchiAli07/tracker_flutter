import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../domain/entities/maintenance.dart';
import '../../domain/entities/category_maintenance.dart';

class AddMaintenancePage extends ConsumerStatefulWidget {
  final String? vehicleId;
  const AddMaintenancePage({super.key, this.vehicleId});

  @override
  ConsumerState<AddMaintenancePage> createState() => _AddMaintenancePageState();
}

class _AddMaintenancePageState extends ConsumerState<AddMaintenancePage> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _newCategoryController = TextEditingController();
  String? _selectedVehicleId;
  String? _selectedCategoryId;
  bool _isLoading = false;
  bool _isAddingCategory = false;

  @override
  void initState() {
    super.initState();
    _selectedVehicleId = widget.vehicleId;
  }

  Future<void> _addMaintenance() async {
    if (_selectedVehicleId == null || _selectedCategoryId == null) return;
    setState(() => _isLoading = true);
    try {
      final maintenance = Maintenance(
        id: '',
        vehicleId: _selectedVehicleId!,
        date: DateTime.now(),
        description: _descriptionController.text.trim(),
        amount: double.tryParse(_amountController.text) ?? 0,
        categoryId: _selectedCategoryId!,
      );
      await ref.read(maintenanceRepositoryProvider).addMaintenance(maintenance);
      if (!mounted) return;
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _addCategory() async {
    final label = _newCategoryController.text.trim();
    if (label.isEmpty) return;
    setState(() => _isAddingCategory = true);
    try {
      await ref.read(maintenanceRepositoryProvider).addCategory(
            CategoryMaintenance(id: '', label: label),
          );
      _newCategoryController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catégorie ajoutée')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
    setState(() => _isAddingCategory = false);
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une maintenance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            vehiclesAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erreur: $e'),
              data: (vehicles) => DropdownButtonFormField<String>(
                initialValue: _selectedVehicleId,
                decoration: const InputDecoration(labelText: 'Véhicule', border: OutlineInputBorder()),
                items: vehicles.map((v) => DropdownMenuItem(value: v.id, child: Text('${v.brand} ${v.model}'))).toList(),
                onChanged: (val) => setState(() => _selectedVehicleId = val),
              ),
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erreur: $e'),
              data: (categories) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder()),
                    items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.label))).toList(),
                    onChanged: (val) => setState(() => _selectedCategoryId = val),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _newCategoryController,
                    decoration: const InputDecoration(labelText: 'Nouvelle catégorie', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAddingCategory ? null : _addCategory,
                      child: _isAddingCategory ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Ajouter catégorie'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Montant (DH)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addMaintenance,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading ? const CircularProgressIndicator() : const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}