import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/country.dart';
import 'package:frontend/services/country_service.dart';

class CountryFormScreen extends StatefulWidget {
  final Country? country;

  const CountryFormScreen({super.key, this.country});

  @override
  State<CountryFormScreen> createState() => _CountryFormScreenState();
}

class _CountryFormScreenState extends State<CountryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _continentController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.country != null) {
      _nameController.text = widget.country!.name;
      _codeController.text = widget.country!.code;
      _continentController.text = widget.country!.continent;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _continentController.dispose();
    super.dispose();
  }

  Future<void> _saveCountry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final countryService = Provider.of<CountryService>(context, listen: false);
      final newCountry = Country(
        id: widget.country?.id ?? 0,
        name: _nameController.text,
        code: _codeController.text,
        continent: _continentController.text,
      );

      if (widget.country == null) {
        await countryService.createCountry(newCountry);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('País creado exitosamente')),
        );
      } else {
        await countryService.updateCountry(newCountry);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('País actualizado exitosamente')),
        );
      }
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al guardar país: $e';
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
        title: Text(widget.country == null ? 'Crear Nuevo País' : 'Editar País'),
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
                decoration: const InputDecoration(labelText: 'Nombre del País'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el nombre del país';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Código del País (Ej: US, ES)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el código del país';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _continentController,
                decoration: const InputDecoration(labelText: 'Continente'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el continente';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _saveCountry,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar País'),
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
