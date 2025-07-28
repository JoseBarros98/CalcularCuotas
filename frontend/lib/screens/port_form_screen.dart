import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/port.dart';
import 'package:frontend/models/country.dart';
import 'package:frontend/services/port_service.dart';
import 'package:frontend/services/country_service.dart';
import 'package:frontend/widgets/searchable_dropdown_field.dart';

class PortFormScreen extends StatefulWidget {
  final Port? port;

  const PortFormScreen({super.key, this.port});

  @override
  State<PortFormScreen> createState() => _PortFormScreenState();
}

class _PortFormScreenState extends State<PortFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  Country? _selectedCountry;
  bool _isActive = true;
  bool _isLoading = false;
  String? _errorMessage;

  List<Country> _availableCountries = [];
  Future<List<Country>>? _countriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCountries();
    if (widget.port != null) {
      _nameController.text = widget.port!.name;
      _codeController.text = widget.port!.code;
      _cityController.text = widget.port!.city;
      _latitudeController.text = widget.port!.latitude?.toString() ?? '';
      _longitudeController.text = widget.port!.longitude?.toString() ?? '';
      _selectedCountry = widget.port!.country;
      _isActive = widget.port!.isActive;
    }
  }

  void _loadCountries() {
    setState(() {
      _countriesFuture = Provider.of<CountryService>(context, listen: false).getCountries();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _cityController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _savePort() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCountry == null) {
      setState(() {
        _errorMessage = 'Por favor, selecciona un país.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final portService = Provider.of<PortService>(context, listen: false);
      final newPort = Port(
        id: widget.port?.id ?? 0,
        name: _nameController.text,
        code: _codeController.text,
        country: _selectedCountry!,
        city: _cityController.text,
        latitude: double.tryParse(_latitudeController.text),
        longitude: double.tryParse(_longitudeController.text),
        isActive: _isActive,
        createdAt: widget.port?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.port == null) {
        await portService.createPort(newPort);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Puerto creado exitosamente')),
        );
      } else {
        await portService.updatePort(newPort);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Puerto actualizado exitosamente')),
        );
      }
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al guardar puerto: $e';
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
        title: Text(widget.port == null ? 'Crear Nuevo Puerto' : 'Editar Puerto'),
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
                decoration: const InputDecoration(labelText: 'Nombre del Puerto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el nombre del puerto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Código del Puerto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el código del puerto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Country>>(
                future: _countriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar países: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay países disponibles.'));
                  } else {
                    _availableCountries = snapshot.data!;
                    return SearchableDropdownField<Country>(
                      labelText: 'País',
                      hintText: 'Selecciona el país',
                      items: _availableCountries,
                      selectedItem: _selectedCountry,
                      itemAsString: (Country c) => '${c.name} (${c.code})',
                      onChanged: (Country? country) {
                        setState(() {
                          _selectedCountry = country;
                        });
                      },
                      validator: (value) => value == null ? 'Por favor, selecciona un país' : null,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Ciudad'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa la ciudad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(labelText: 'Latitud'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return 'Ingresa un número válido para la latitud';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(labelText: 'Longitud'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return 'Ingresa un número válido para la longitud';
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
                        onPressed: _savePort,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Puerto'),
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
