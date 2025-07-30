import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/container.dart';
import 'package:frontend/services/container_service.dart';

class CargoTypeFormScreen extends StatefulWidget {
  final CargoType? cargoType;

  const CargoTypeFormScreen({super.key, this.cargoType});

  @override
  State<CargoTypeFormScreen> createState() => _CargoTypeFormScreenState();
}

class _CargoTypeFormScreenState extends State<CargoTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _densityFactorController = TextEditingController();

  bool _hazardous = false;
  bool _requiresSpecialHandling = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.cargoType != null) {
      _nameController.text = widget.cargoType!.name;
      _descriptionController.text = widget.cargoType!.description;
      _densityFactorController.text = widget.cargoType!.densityFactor.toString();
      _hazardous = widget.cargoType!.hazardous;
      _requiresSpecialHandling = widget.cargoType!.requiresSpecialHandling;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _densityFactorController.dispose();
    super.dispose();
  }

  Future<void> _saveCargoType() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final containerService = Provider.of<ContainerService>(context, listen: false);
      final newCargoType = CargoType(
        id: widget.cargoType?.id ?? 0,
        name: _nameController.text,
        description: _descriptionController.text,
        hazardous: _hazardous,
        requiresSpecialHandling: _requiresSpecialHandling,
        densityFactor: double.parse(_densityFactorController.text),
      );

      if (widget.cargoType == null) {
        await containerService.createCargoType(newCargoType);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de carga creado exitosamente')),
        );
      } else {
        await containerService.updateCargoType(newCargoType);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de carga actualizado exitosamente')),
        );
      }
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al guardar tipo de carga: $e';
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
        title: Text(widget.cargoType == null ? 'Crear Nuevo Tipo de Carga' : 'Editar Tipo de Carga'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _densityFactorController,
                decoration: const InputDecoration(labelText: 'Factor de Densidad'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Ingresa un número válido para el factor de densidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _hazardous,
                    onChanged: (bool? value) {
                      setState(() {
                        _hazardous = value ?? false;
                      });
                    },
                  ),
                  const Text('Peligroso'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _requiresSpecialHandling,
                    onChanged: (bool? value) {
                      setState(() {
                        _requiresSpecialHandling = value ?? false;
                      });
                    },
                  ),
                  const Text('Requiere Manejo Especial'),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _saveCargoType,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Tipo de Carga'),
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
