import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/base_rate.dart';
import 'package:frontend/models/shipping_route.dart';
import 'package:frontend/models/container.dart';
import 'package:frontend/services/base_rate_service.dart';
import 'package:frontend/services/shipping_route_service.dart';
import 'package:frontend/services/container_service.dart';
import 'package:frontend/widgets/searchable_dropdown_field.dart';
import 'package:intl/intl.dart';

class BaseRateFormScreen extends StatefulWidget {
  final BaseRate? baseRate;

  const BaseRateFormScreen({super.key, this.baseRate});

  @override
  State<BaseRateFormScreen> createState() => _BaseRateFormScreenState();
}

class _BaseRateFormScreenState extends State<BaseRateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _baseRateUsdController = TextEditingController();
  final TextEditingController _fuelSurchargePercentageController = TextEditingController();
  final TextEditingController _handlingFeeUsdController = TextEditingController();
  final TextEditingController _insuranceFeePercentageController = TextEditingController();
  final TextEditingController _documentationFeeUsdController = TextEditingController();
  final TextEditingController _effectiveFromController = TextEditingController();
  final TextEditingController _effectiveToController = TextEditingController();

  ShippingRoute? _selectedRoute;
  ContainerType? _selectedContainerType;
  bool _isActive = true;
  bool _isLoading = false;
  String? _errorMessage;

  List<ShippingRoute> _availableRoutes = [];
  List<ContainerType> _availableContainerTypes = [];
  Future<List<ShippingRoute>>? _routesFuture;
  Future<List<ContainerType>>? _containerTypesFuture;

  @override
  void initState() {
    super.initState();
    _loadDependencies();
    if (widget.baseRate != null) {
      _baseRateUsdController.text = widget.baseRate!.baseRateUsd.toString();
      _fuelSurchargePercentageController.text = widget.baseRate!.fuelSurchargePercentage.toString();
      _handlingFeeUsdController.text = widget.baseRate!.handlingFeeUsd.toString();
      _insuranceFeePercentageController.text = widget.baseRate!.insuranceFeePercentage.toString();
      _documentationFeeUsdController.text = widget.baseRate!.documentationFeeUsd.toString();
      _effectiveFromController.text = DateFormat('yyyy-MM-dd').format(widget.baseRate!.effectiveFrom);
      _effectiveToController.text = widget.baseRate!.effectiveTo != null
          ? DateFormat('yyyy-MM-dd').format(widget.baseRate!.effectiveTo!)
          : '';
      _selectedRoute = widget.baseRate!.route;
      _selectedContainerType = widget.baseRate!.containerType;
      _isActive = widget.baseRate!.isActive;
    }
  }

  void _loadDependencies() {
    setState(() {
      _routesFuture = Provider.of<ShippingRouteService>(context, listen: false).getShippingRoutes();
      _containerTypesFuture = Provider.of<ContainerService>(context, listen: false).getContainerTypes();
    });
  }

  @override
  void dispose() {
    _baseRateUsdController.dispose();
    _fuelSurchargePercentageController.dispose();
    _handlingFeeUsdController.dispose();
    _insuranceFeePercentageController.dispose();
    _documentationFeeUsdController.dispose();
    _effectiveFromController.dispose();
    _effectiveToController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveBaseRate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRoute == null || _selectedContainerType == null) {
      setState(() {
        _errorMessage = 'Por favor, selecciona la ruta y el tipo de contenedor.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final baseRateService = Provider.of<BaseRateService>(context, listen: false);
      final newBaseRate = BaseRate(
        id: widget.baseRate?.id ?? 0,
        route: _selectedRoute!,
        containerType: _selectedContainerType!,
        baseRateUsd: double.parse(_baseRateUsdController.text),
        fuelSurchargePercentage: double.parse(_fuelSurchargePercentageController.text),
        handlingFeeUsd: double.parse(_handlingFeeUsdController.text),
        insuranceFeePercentage: double.parse(_insuranceFeePercentageController.text),
        documentationFeeUsd: double.parse(_documentationFeeUsdController.text),
        effectiveFrom: DateTime.parse(_effectiveFromController.text),
        effectiveTo: _effectiveToController.text.isNotEmpty
            ? DateTime.parse(_effectiveToController.text)
            : null,
        isActive: _isActive,
        createdAt: widget.baseRate?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.baseRate == null) {
        await baseRateService.createBaseRate(newBaseRate);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarifa base creada exitosamente')),
        );
      } else {
        await baseRateService.updateBaseRate(newBaseRate);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarifa base actualizada exitosamente')),
        );
      }
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al guardar tarifa base: $e';
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
        title: Text(widget.baseRate == null ? 'Crear Nueva Tarifa Base' : 'Editar Tarifa Base'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<ShippingRoute>>(
                future: _routesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar rutas: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay rutas disponibles.'));
                  } else {
                    _availableRoutes = snapshot.data!;
                    return SearchableDropdownField<ShippingRoute>(
                      labelText: 'Ruta de Envío',
                      hintText: 'Selecciona la ruta',
                      items: _availableRoutes,
                      selectedItem: _selectedRoute,
                      itemAsString: (ShippingRoute sr) => '${sr.originPort.code} -> ${sr.destinationPort.code}',
                      onChanged: (ShippingRoute? route) {
                        setState(() {
                          _selectedRoute = route;
                        });
                      },
                      validator: (value) => value == null ? 'Por favor, selecciona una ruta' : null,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<ContainerType>>(
                future: _containerTypesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar tipos de contenedor: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay tipos de contenedor disponibles.'));
                  } else {
                    _availableContainerTypes = snapshot.data!;
                    return SearchableDropdownField<ContainerType>(
                      labelText: 'Tipo de Contenedor',
                      hintText: 'Selecciona el tipo de contenedor',
                      items: _availableContainerTypes,
                      selectedItem: _selectedContainerType,
                      itemAsString: (ContainerType ct) => ct.name,
                      onChanged: (ContainerType? ct) {
                        setState(() {
                          _selectedContainerType = ct;
                        });
                      },
                      validator: (value) => value == null ? 'Por favor, selecciona un tipo de contenedor' : null,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _baseRateUsdController,
                decoration: const InputDecoration(labelText: 'Tarifa Base (USD)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Ingresa un número válido para la tarifa base';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fuelSurchargePercentageController,
                decoration: const InputDecoration(labelText: 'Recargo por Combustible (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Ingresa un número válido para el porcentaje';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _handlingFeeUsdController,
                decoration: const InputDecoration(labelText: 'Tarifa de Manipulación (USD)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Ingresa un número válido para la tarifa de manipulación';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _insuranceFeePercentageController,
                decoration: const InputDecoration(labelText: 'Tarifa de Seguro (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Ingresa un número válido para el porcentaje de seguro';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _documentationFeeUsdController,
                decoration: const InputDecoration(labelText: 'Tarifa de Documentación (USD)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Ingresa un número válido para la tarifa de documentación';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _effectiveFromController,
                decoration: InputDecoration(
                  labelText: 'Fecha de Vigencia Desde',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _effectiveFromController),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona la fecha de inicio de vigencia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _effectiveToController,
                decoration: InputDecoration(
                  labelText: 'Fecha de Vigencia Hasta (Opcional)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, _effectiveToController),
                  ),
                ),
                readOnly: true,
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
                        onPressed: _saveBaseRate,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Tarifa Base'),
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
