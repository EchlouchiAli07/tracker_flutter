import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/providers.dart';
import '../../domain/entities/vehicle.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (stats) {
          final vehicles = stats['vehicles'] as List<Vehicle>;
          final totalFuel = stats['totalFuel'] as double;
          final totalMaintenance = stats['totalMaintenance'] as double;
          final total = stats['total'] as double;
          final fuelPct = stats['fuelPct'] as double;
          final maintPct = stats['maintPct'] as double;
          final monthFuel = stats['monthFuel'] as double;
          final monthMaintenance = stats['monthMaintenance'] as double;
          final monthFuelPct = stats['monthFuelPct'] as double;
          final monthMaintPct = stats['monthMaintPct'] as double;
          final fuelByVehicle = stats['fuelByVehicle'] as List<Map<String, dynamic>>;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardStatsProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cards stats
                  Row(
                    children: [
                      _StatCard(
                        title: 'Véhicules',
                        value: '${vehicles.length}',
                        icon: Icons.directions_car,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        title: 'Total Dépenses',
                        value: '${total.toStringAsFixed(0)} MAD',
                        icon: Icons.account_balance_wallet,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dépenses ce mois',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ProgressRow(
                            label: 'Gasoil',
                            value: monthFuelPct,
                            amount: monthFuel,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          _ProgressRow(
                            label: 'Maintenance',
                            value: monthMaintPct,
                            amount: monthMaintenance,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Consommation gasoil par véhicule ce mois',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (fuelByVehicle.isEmpty)
                            const Text('Aucune consommation relevée pour ce mois.'),
                          if (fuelByVehicle.isNotEmpty)
                            ...fuelByVehicle.map((data) {
                              final vehicle = data['vehicle'] as Vehicle;
                              final liters = data['liters'] as double;
                              final amount = data['amount'] as double;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text('${vehicle.brand} ${vehicle.model}')),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('${liters.toStringAsFixed(1)} L', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text('${amount.toStringAsFixed(0)} MAD', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Répartition dépenses
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Répartition des dépenses',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ProgressRow(
                            label: 'Gasoil',
                            value: fuelPct,
                            amount: totalFuel,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          _ProgressRow(
                            label: 'Maintenance',
                            value: maintPct,
                            amount: totalMaintenance,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Liste véhicules
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mes Véhicules',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push('/vehicles'),
                        icon: const Icon(Icons.list, size: 16),
                        label: const Text('Voir tout'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (vehicles.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Aucun véhicule.\nAjoutez-en un !',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...vehicles.map((v) => _VehicleCard(vehicle: v)),

                  const SizedBox(height: 16),

                  // Actions rapides
                  const Text(
                    'Actions rapides',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ActionButton(
                        label: 'Ajouter Véhicule',
                        icon: Icons.add_circle,
                        color: Colors.blue,
                        onTap: () => context.push('/vehicles/add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Widgets helper

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double value, amount;
  final Color color;

  const _ProgressRow({
    required this.label,
    required this.value,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            Text(
              '${value.toStringAsFixed(0)}% — ${amount.toStringAsFixed(0)} MAD',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          color: color,
          backgroundColor: color.withAlpha((0.15 * 255).round()),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: const Icon(Icons.directions_car, color: Colors.blue),
        ),
        title: Text(vehicle.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${vehicle.brand} • ${vehicle.licensePlate}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Plein carburant',
              icon: const Icon(Icons.local_gas_station, color: Colors.orange),
              onPressed: () => context.push('/fuel/add', extra: vehicle.id),
            ),
            IconButton(
              tooltip: 'Maintenance',
              icon: const Icon(Icons.build, color: Colors.purple),
              onPressed: () => context.push('/maintenance/add', extra: vehicle.id),
            ),
            IconButton(
              tooltip: 'Historique',
              icon: const Icon(Icons.history, color: Colors.grey),
              onPressed: () => context.push('/maintenance/history', extra: vehicle.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(backgroundColor: color),
    );
  }
}