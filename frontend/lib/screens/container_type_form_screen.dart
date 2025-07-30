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
  final TextEditingController _maxWeightController = TextEditingController();
  final TextEditingController _internalLengthController = TextEditingController();
  final TextEditingController _internalWidthController = TextEditingController();
  final TextEditingController _internalHeightController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();

  String? _selectedSize;
  String? _selectedType;
  bool _isActive = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Opciones para los dropdowns
  //Tamaño del contenedor
  final Map<String, String> _sizesLabels = {
    '20': '20ft',
    '40': '40ft',
    '45': '45ft',
    '40HC': '40ft HC',
  };
  List<String> get _availableSizes => _sizesLabels.keys.toList();
  //Tipo de contenedor
  final Map<String, String> _typeLabels = {
    'DRY': 'Seco',
    'REEFER': 'Refrigerado',
    'OPEN_TOP': 'Abierto',
    'FLAT_RACK': 'Plataforma',
    'TANK': 'Tanque',
  };
  List<String> get _availableTypes => _typeLabels.keys.toList();

  @override
  void initState() {
    super.initState();
    if (widget.containerType != null) {
      _nameController.text = widget.containerType!.name;
      _selectedSize = widget.containerType!.size;
      _selectedType = widget.containerType!.type;
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

    // Validar que los dropdowns no estén vacíos
    if (_selectedSize == null || _selectedSize!.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, selecciona un tamaño de contenedor.';
      });
      return;
    }
    if (_selectedType == null || _selectedType!.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, selecciona un tipo de contenedor.';
      });
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
        size: _selectedSize!,
        type: _selectedType!,
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
              // Dropdown para Tamaño (con nombres amigables)
              DropdownButtonFormField<String>(
                value: _selectedSize,
                decoration: const InputDecoration(
                  labelText: 'Tamaño',
                  hintText: 'Selecciona el tamaño del contenedor',
                ),
                items: _availableSizes.map((String size) {
                  return DropdownMenuItem<String>(
                    value: size,
                    child: Text(_sizesLabels[size] ?? size),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSize = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona el tamaño';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  hintText: 'Selecciona el tipo de contenedor',
                ),
                items: _availableTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(_typeLabels[type] ?? type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona el tipo';
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
