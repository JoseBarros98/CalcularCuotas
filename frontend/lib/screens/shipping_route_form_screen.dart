import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/shipping_route.dart';
import 'package:frontend/models/port.dart';
import 'package:frontend/services/shipping_route_service.dart';
import 'package:frontend/services/port_service.dart';
import 'package:frontend/widgets/searchable_dropdown_field.dart';

class ShippingRouteFormScreen extends StatefulWidget {
  final ShippingRoute? shippingRoute;

  const ShippingRouteFormScreen({super.key, this.shippingRoute});

  @override
  State<ShippingRouteFormScreen> createState() => _ShippingRouteFormScreenState();
}

class _ShippingRouteFormScreenState extends State<ShippingRouteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _transitDaysController = TextEditingController();

  Port? _selectedOriginPort;
  Port? _selectedDestinationPort;
  bool _isActive = true;
  bool _isLoading = false;
  String? _errorMessage;

  List<Port> _availablePorts = [];
  Future<List<Port>>? _portsFuture;

  @override
  void initState() {
    super.initState();
    _loadPorts();
    if (widget.shippingRoute != null) {
      _distanceController.text = widget.shippingRoute!.distanceNauticalMiles.toString();
      _transitDaysController.text = widget.shippingRoute!.estimatedTransitDays.toString();
      _selectedOriginPort = widget.shippingRoute!.originPort;
      _selectedDestinationPort = widget.shippingRoute!.destinationPort;
      _isActive = widget.shippingRoute!.isActive;
    }
  }

  void _loadPorts() {
    setState(() {
      _portsFuture = Provider.of<PortService>(context, listen: false).getPorts();
    });
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _transitDaysController.dispose();
    super.dispose();
  }

  Future<void> _saveShippingRoute() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedOriginPort == null || _selectedDestinationPort == null) {
      setState(() {
        _errorMessage = 'Por favor, selecciona ambos puertos.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final shippingRouteService = Provider.of<ShippingRouteService>(context, listen: false);
      final newShippingRoute = ShippingRoute(
        id: widget.shippingRoute?.id ?? 0,
        originPort: _selectedOriginPort!,
        destinationPort: _selectedDestinationPort!,
        distanceNauticalMiles: double.parse(_distanceController.text),
        estimatedTransitDays: int.parse(_transitDaysController.text),
        isActive: _isActive,
        createdAt: widget.shippingRoute?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.shippingRoute == null) {
        await shippingRouteService.createShippingRoute(newShippingRoute);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ruta de envío creada exitosamente')),
        );
      } else {
        await shippingRouteService.updateShippingRoute(newShippingRoute);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ruta de envío actualizada exitosamente')),
        );
      }
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al guardar ruta de envío: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shippingRoute == null ? 'Crear Nueva Ruta de Envío' : 'Editar Ruta de Envío'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<Port>>(
                future: _portsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar puertos: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay puertos disponibles.'));
                  } else {
                    _availablePorts = snapshot.data!;
                    return Column(
                      children: [
                        SearchableDropdownField<Port>(
                          labelText: 'Puerto de Origen',
                          hintText: 'Selecciona el puerto de origen',
                          items: _availablePorts,
                          selectedItem: _selectedOriginPort,
                          itemAsString: (Port p) => '${p.name} (${p.code})',
                          onChanged: (Port? port) {
                            setState(() {
                              _selectedOriginPort = port;
                            });
                          },
                          validator: (value) => value == null ? 'Por favor, selecciona un puerto de origen' : null,
                        ),
                        const SizedBox(height: 16),
                        SearchableDropdownField<Port>(
                          labelText: 'Puerto de Destino',
                          hintText: 'Selecciona el puerto de destino',
                          items: _availablePorts,
                          selectedItem: _selectedDestinationPort,
                          itemAsString: (Port p) => '${p.name} (${p.code})',
                          onChanged: (Port? port) {
                            setState(() {
                              _selectedDestinationPort = port;
                            });
                          },
                          validator: (value) => value == null ? 'Por favor, selecciona un puerto de destino' : null,
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _distanceController,
                decoration: const InputDecoration(labelText: 'Distancia (Millas Náuticas)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Ingresa un número válido para la distancia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _transitDaysController,
                decoration: const InputDecoration(labelText: 'Días de Tránsito Estimados'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Ingresa un número entero válido para los días de tránsito';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isActive,
                    onChanged: (bool? value) {
                      setState(() {
                        _isActive = value ?? false;
                      });
                    },
                  ),
                  const Text('Activo'),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _saveShippingRoute,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Ruta de Envío'),
                      ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
