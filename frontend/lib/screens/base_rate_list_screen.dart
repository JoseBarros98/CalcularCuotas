import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/base_rate.dart';
import 'package:frontend/services/base_rate_service.dart';
import 'package:frontend/screens/base_rate_form_screen.dart';
import 'package:intl/intl.dart';

class BaseRateListScreen extends StatefulWidget {
  const BaseRateListScreen({super.key});

  @override
  State<BaseRateListScreen> createState() => _BaseRateListScreenState();
}

class _BaseRateListScreenState extends State<BaseRateListScreen> {
  Future<List<BaseRate>>? _baseRatesFuture;

  @override
  void initState() {
    super.initState();
    _loadBaseRates();
  }

  void _loadBaseRates() {
    setState(() {
      _baseRatesFuture = Provider.of<BaseRateService>(context, listen: false).getBaseRates();
    });
  }

  Future<void> _confirmDelete(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar esta tarifa base?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await Provider.of<BaseRateService>(context, listen: false).deleteBaseRate(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarifa base eliminada exitosamente')),
        );
        _loadBaseRates();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar tarifa base: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Tarifas Base'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<BaseRate>>(
        future: _baseRatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay tarifas base disponibles.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final baseRate = snapshot.data![index];
                final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('${baseRate.route.originPort.code} -> ${baseRate.route.destinationPort.code} (${baseRate.containerType.name})'),
                    subtitle: Text('Tarifa: \$${baseRate.baseRateUsd.toStringAsFixed(2)}, Desde: ${dateFormatter.format(baseRate.effectiveFrom)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BaseRateFormScreen(baseRate: baseRate),
                              ),
                            );
                            _loadBaseRates();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(baseRate.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BaseRateFormScreen()),
          );
          _loadBaseRates();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
