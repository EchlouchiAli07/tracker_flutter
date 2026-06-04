import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../domain/entities/fuel_entry.dart';

class AddFuelPage extends ConsumerStatefulWidget {
  final String? vehicleId;
  const AddFuelPage({super.key, this.vehicleId});

  @override
  ConsumerState<AddFuelPage> createState() => _AddFuelPageState();
}

class _AddFuelPageState extends ConsumerState<AddFuelPage> {
  final _litersController = TextEditingController();
  final _amountController = TextEditingController();
  final _mileageController = TextEditingController();
  String? _selectedVehicleId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedVehicleId = widget.vehicleId;
  }

  Future<void> _addFuelEntry() async {
    if (_selectedVehicleId == null) return;
    setState(() => _isLoading = true);
    try {
      final entry = FuelEntry(
        id: '',
        vehicleId: _selectedVehicleId!,
        date: DateTime.now(),
        liters: double.tryParse(_litersController.text) ?? 0,
        amount: double.tryParse(_amountController.text) ?? 0,
        mileage: double.tryParse(_mileageController.text) ?? 0,
      );
      await ref.read(fuelRepositoryProvider).addFuelEntry(entry);
      if (!mounted) return;
      context.go('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un plein')),
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
            TextField(controller: _litersController, decoration: const InputDecoration(labelText: 'Litres', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Montant (DH)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: _mileageController, decoration: const InputDecoration(labelText: 'Kilométrage', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addFuelEntry,
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