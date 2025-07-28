import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/container.dart';
import 'package:frontend/services/container_service.dart';
import 'package:frontend/screens/container_type_form_screen.dart';

class ContainerTypeListScreen extends StatefulWidget {
  const ContainerTypeListScreen({super.key});

  @override
  State<ContainerTypeListScreen> createState() => _ContainerTypeListScreenState();
}

class _ContainerTypeListScreenState extends State<ContainerTypeListScreen> {
  Future<List<ContainerType>>? _containerTypesFuture;

  @override
  void initState() {
    super.initState();
    _loadContainerTypes();
  }

  void _loadContainerTypes() {
    setState(() {
      _containerTypesFuture = Provider.of<ContainerService>(context, listen: false).getContainerTypes();
    });
  }

  Future<void> _confirmDelete(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar este tipo de contenedor?'),
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
        await Provider.of<ContainerService>(context, listen: false).deleteContainerType(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de contenedor eliminado exitosamente')),
        );
        _loadContainerTypes();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar tipo de contenedor: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Tipos de Contenedor'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ContainerType>>(
        future: _containerTypesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay tipos de contenedor disponibles.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final containerType = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('${containerType.name} (${containerType.size}\' ${containerType.type})'),
                    subtitle: Text('Max Peso: ${containerType.maxWeight} kg, Volumen: ${containerType.volume} CBM'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContainerTypeFormScreen(containerType: containerType),
                              ),
                            );
                            _loadContainerTypes();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(containerType.id),
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
            MaterialPageRoute(builder: (context) => const ContainerTypeFormScreen()),
          );
          _loadContainerTypes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
