import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';

class MaintenanceHistoryPage extends ConsumerStatefulWidget {
  final String? vehicleId;
  const MaintenanceHistoryPage({super.key, this.vehicleId});

  @override
  ConsumerState<MaintenanceHistoryPage> createState() => _MaintenanceHistoryPageState();
}

class _MaintenanceHistoryPageState extends ConsumerState<MaintenanceHistoryPage> {
  String? _selectedVehicleId;
  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    _selectedVehicleId = widget.vehicleId;
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historique Maintenance')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: vehiclesAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erreur: $e'),
              data: (vehicles) => DropdownButtonFormField<String>(
                initialValue: _selectedVehicleId,
                decoration: const InputDecoration(labelText: 'Filtrer par véhicule', border: OutlineInputBorder()),
                items: vehicles.map((v) => DropdownMenuItem(value: v.id, child: Text('${v.brand} ${v.model}'))).toList(),
                onChanged: (val) => setState(() => _selectedVehicleId = val),
              ),
            ),
          ),
          if (_selectedVehicleId != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(_filterDate == null ? 'Filtrer par mois' : '${_filterDate!.month}/${_filterDate!.year}'),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _filterDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _filterDate = picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_filterDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _filterDate = null),
                      tooltip: 'Supprimer le filtre',
                    ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final maintenancesAsync = ref.watch(maintenancesProvider(_selectedVehicleId!));
                  return maintenancesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Erreur: $e')),
                    data: (maintenances) {
                      final filtered = _filterDate == null
                          ? maintenances
                          : maintenances.where((m) =>
                              m.date.year == _filterDate!.year &&
                              m.date.month == _filterDate!.month).toList();
                      if (filtered.isEmpty) return const Center(child: Text('Aucune maintenance'));
                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final m = filtered[index];
                          return ListTile(
                            leading: const Icon(Icons.build),
                            title: Text(m.description),
                            subtitle: Text('${m.date.day}/${m.date.month}/${m.date.year}'),
                            trailing: Text('${m.amount} DH'),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}