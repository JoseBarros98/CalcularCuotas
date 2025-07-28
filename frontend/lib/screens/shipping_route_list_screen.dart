import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/shipping_route.dart';
import 'package:frontend/services/shipping_route_service.dart';
import 'package:frontend/screens/shipping_route_form_screen.dart';

class ShippingRouteListScreen extends StatefulWidget {
  const ShippingRouteListScreen({super.key});

  @override
  State<ShippingRouteListScreen> createState() => _ShippingRouteListScreenState();
}

class _ShippingRouteListScreenState extends State<ShippingRouteListScreen> {
  Future<List<ShippingRoute>>? _shippingRoutesFuture;

  @override
  void initState() {
    super.initState();
    _loadShippingRoutes();
  }

  void _loadShippingRoutes() {
    setState(() {
      _shippingRoutesFuture = Provider.of<ShippingRouteService>(context, listen: false).getShippingRoutes();
    });
  }

  Future<void> _confirmDelete(int id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de que quieres eliminar esta ruta de envío?'),
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
        await Provider.of<ShippingRouteService>(context, listen: false).deleteShippingRoute(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ruta de envío eliminada exitosamente')),
        );
        _loadShippingRoutes();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar ruta de envío: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Rutas de Envío'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ShippingRoute>>(
        future: _shippingRoutesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay rutas de envío disponibles.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final route = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('${route.originPort.name} (${route.originPort.code}) -> ${route.destinationPort.name} (${route.destinationPort.code})'),
                    subtitle: Text('Distancia: ${route.distanceNauticalMiles} NM, Tránsito: ${route.estimatedTransitDays} días'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShippingRouteFormScreen(shippingRoute: route),
                              ),
                            );
                            _loadShippingRoutes();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(route.id),
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
            MaterialPageRoute(builder: (context) => const ShippingRouteFormScreen()),
          );
          _loadShippingRoutes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
