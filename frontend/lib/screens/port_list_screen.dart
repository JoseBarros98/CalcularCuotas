import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/port.dart';
import 'package:frontend/services/port_service.dart';
import 'package:frontend/screens/port_form_screen.dart';

class PortListScreen extends StatefulWidget {
  const PortListScreen({super.key});

  @override
  State<PortListScreen> createState() => _PortListScreenState();
}

class _PortListScreenState extends State<PortListScreen> {
  Future<List<Port>>? _portsFuture;

  @override
  void initState() {
    super.initState();
    _loadPorts();
  }

  void _loadPorts() {
    setState(() {
      _portsFuture = Provider.of<PortService>(context, listen: false).getPorts();
    });
  }

  Future<void> _confirmDelete(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar este puerto?'),
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
        await Provider.of<PortService>(context, listen: false).deletePort(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Puerto eliminado exitosamente')),
        );
        _loadPorts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar puerto: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Puertos'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Port>>(
        future: _portsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay puertos disponibles.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final port = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('${port.name} (${port.code})'),
                    subtitle: Text('${port.city}, ${port.country.name}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PortFormScreen(port: port),
                              ),
                            );
                            _loadPorts();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(port.id),
                        ),
                      ],
                    ),
                    onTap: () {
                    },
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
            MaterialPageRoute(builder: (context) => const PortFormScreen()),
          );
          _loadPorts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
