import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';

class VehiclesListPage extends ConsumerWidget {
  const VehiclesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Véhicules')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/vehicles/add'),
        child: const Icon(Icons.add),
      ),
      body: vehiclesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return const Center(child: Text('Aucun véhicule ajouté'));
          }
          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final v = vehicles[index];
              return ListTile(
                leading: const Icon(Icons.directions_car),
                title: Text('${v.brand} ${v.model}'),
                subtitle: Text('${v.licensePlate} • ${v.year}'),
              );
            },
          );
        },
      ),
    );
  }
}