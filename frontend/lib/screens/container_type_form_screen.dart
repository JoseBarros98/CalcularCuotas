import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/container.dart';
import 'package:frontend/services/container_service.dart';

class ContainerTypeFormScreen extends StatefulWidget {
  final ContainerType? containerType;

  const ContainerTypeFormScreen({super.key, this.containerType});

  @override
  State<ContainerTypeFormScreen> createState() => _ContainerTypeFormScreenState();
}

class _ContainerTypeFormScreenState extends State<ContainerTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _maxWeightController = TextEditingController();
  final TextEditingController _internalLengthController = TextEditingController();
  final TextEditingController _internalWidthController = TextEditingController();
  final TextEditingController _internalHeightController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.containerType != null) {
      _nameController.text = widget.containerType!.name;
      _sizeController.text = widget.containerType!.size;
      _typeController.text = widget.containerType!.type;
      _maxWeightController.text = widget.containerType!.maxWeight.toString();
      _internalLengthController.text = widget.containerType!.internalLength.toString();
      _internalWidthController.text = widget.containerType!.internalWidth.toString();
      _internalHeightController.text = widget.containerType!.internalHeight.toString();
      _volumeController.text = widget.containerType!.volume.toString();
      _isActive = widget.containerType!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _typeController.dispose();
    _maxWeightController.dispose();
    _internalLengthController.dispose();
    _internalWidthController.dispose();
    _internalHeightController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  Future<void> _saveContainerType() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final containerService = Provider.of<ContainerService>(context, listen: false);
      final newContainerType = ContainerType(
        id: widget.containerType?.id ?? 0,
        name: _nameController.text,
        size: _sizeController.text,
        type: _typeController.text,
        maxWeight: double.parse(_maxWeightController.text),
        internalLength: double.parse(_internalLengthController.text),
        internalWidth: double.parse(_internalWidthController.text),
        internalHeight: double.parse(_internalHeightController.text),
        volume: double.parse(_volumeController.text),
        isActive: _isActive,
      );

      if (widget.containerType == null) {
        await containerService.createContainerType(newContainerType);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de contenedor creado exitosamente')),
        );
      } else {
        await containerService.updateContainerType(newContainerType);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de contenedor actualizado exitosamente')),
        );
      }
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al guardar tipo de contenedor: $e';
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
        title: Text(widget.containerType == null ? 'Crear Nuevo Tipo de Contenedor' : 'Editar Tipo de Contenedor'),
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
                controller: _sizeController,
                decoration: const InputDecoration(labelText: 'Tamaño (Ej: 20ft, 40ft)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el tamaño';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Tipo (Ej: Dry, Reefer)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el tipo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxWeightController,
                decoration: const InputDecoration(labelText: 'Peso Máximo (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Ingresa un número válido para el peso máximo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _internalLengthController,
                decoration: const InputDecoration(labelText: 'Longitud Interna (m)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Ingresa un número válido para la longitud';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _internalWidthController,
                decoration: const InputDecoration(labelText: 'Ancho Interno (m)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Ingresa un número válido para el ancho';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _internalHeightController,
                decoration: const InputDecoration(labelText: 'Altura Interna (m)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Ingresa un número válido para la altura';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _volumeController,
                decoration: const InputDecoration(labelText: 'Volumen (CBM)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Ingresa un número válido para el volumen';
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
                        onPressed: _saveContainerType,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Tipo de Contenedor'),
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
