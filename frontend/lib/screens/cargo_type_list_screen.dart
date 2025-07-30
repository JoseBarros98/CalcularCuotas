import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/container.dart';
import 'package:frontend/services/container_service.dart';
import 'package:frontend/screens/cargo_type_form_screen.dart';

class CargoTypeListScreen extends StatefulWidget {
  const CargoTypeListScreen({super.key});

  @override
  State<CargoTypeListScreen> createState() => _CargoTypeListScreenState();
}

class _CargoTypeListScreenState extends State<CargoTypeListScreen> {
  Future<List<CargoType>>? _cargoTypesFuture;

  @override
  void initState() {
    super.initState();
    _loadCargoTypes();
  }

  void _loadCargoTypes() {
    setState(() {
      _cargoTypesFuture = Provider.of<ContainerService>(context, listen: false).getCargoTypes();
    });
  }

  Future<void> _confirmDelete(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar este tipo de carga?'),
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
        await Provider.of<ContainerService>(context, listen: false).deleteCargoType(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de carga eliminado exitosamente')),
        );
        _loadCargoTypes();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar tipo de carga: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Tipos de Carga'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<CargoType>>(
        future: _cargoTypesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay tipos de carga disponibles.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final cargoType = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(cargoType.name),
                    subtitle: Text('Peligroso: ${cargoType.hazardous ? 'Sí' : 'No'}, Factor Densidad: ${cargoType.densityFactor}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CargoTypeFormScreen(cargoType: cargoType),
                              ),
                            );
                            _loadCargoTypes();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(cargoType.id),
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
            MaterialPageRoute(builder: (context) => const CargoTypeFormScreen()),
          );
          _loadCargoTypes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
