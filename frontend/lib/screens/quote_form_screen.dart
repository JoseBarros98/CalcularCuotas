import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'package:frontend/models/port.dart';
import 'package:frontend/models/container.dart';
import 'package:frontend/models/quote_calculation.dart';
import 'package:frontend/services/port_service.dart';
import 'package:frontend/services/container_service.dart';
import 'package:frontend/services/quote_service.dart';
import 'package:frontend/widgets/searchable_dropdown_field.dart';
import 'package:frontend/utils/pdf_generator.dart';

class QuoteFormScreen extends StatefulWidget {
  const QuoteFormScreen({super.key});

  @override
  State<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends State<QuoteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  Port? _selectedOriginPort;
  Port? _selectedDestinationPort;
  ContainerType? _selectedContainerType;
  CargoType? _selectedCargoType;
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();

  QuoteCalculation? _calculatedQuote;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGeneratingPdf = false;

  List<Port> _availablePorts = [];
  List<ContainerType> _availableContainerTypes = [];
  List<CargoType> _availableCargoTypes = [];
  bool _isDataLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isDataLoading = true;
    });
    try {
      final portService = Provider.of<PortService>(context, listen: false);
      final containerService = Provider.of<ContainerService>(context, listen: false);

      final ports = await portService.getPorts();
      final containerTypes = await containerService.getContainerTypes();
      final cargoTypes = await containerService.getCargoTypes();

      setState(() {
        _availablePorts = ports;
        _availableContainerTypes = containerTypes;
        _availableCargoTypes = cargoTypes;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar datos iniciales: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isDataLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _weightController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  Future<void> _calculateQuote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _calculatedQuote = null;
    });

    try {
      final quoteService = Provider.of<QuoteService>(context, listen: false);
      final result = await quoteService.calculateQuote(
        originPortId: _selectedOriginPort!.id,
        destinationPortId: _selectedDestinationPort!.id,
        containerTypeId: _selectedContainerType!.id,
        cargoTypeId: _selectedCargoType!.id,
        quantity: int.parse(_quantityController.text),
        weightKg: double.parse(_weightController.text),
        volumeCbm: double.parse(_volumeController.text),
      );
      setState(() {
        _calculatedQuote = result;
      });
    } catch (e) {

      print('Error técnico al calcular la cotización: $e');

      setState(() {
        _errorMessage = 'No se pudo calcular la cotización. Por favor, revisa los datos ingresados o intenta más tarde.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePdf() async {
    if (_calculatedQuote == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero calcula una cotización para generar el PDF.')),
      );
      return;
    }

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      await generateQuotePdf(_calculatedQuote!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generado y abierto exitosamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar o abrir el PDF: $e')),
      );
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDataLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cotización de Embarque'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotización de Embarque'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalles del Envío',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Puerto de Origen
              SearchableDropdownField<Port>(
                labelText: 'Puerto de Origen',
                hintText: 'Selecciona el puerto de origen',
                prefixIcon: Icon(FontAwesomeIcons.ship, color: Colors.blueGrey[700]),
                items: _availablePorts,
                selectedItem: _selectedOriginPort,
                itemAsString: (Port p) => '${p.name} (${p.code}, ${p.country.code})',
                onChanged: (Port? port) {
                  setState(() {
                    _selectedOriginPort = port;
                  });
                },
                validator: (value) => value == null ? 'Por favor, selecciona un puerto de origen' : null,
              ),
              const SizedBox(height: 16),
              // Puerto de Destino
              SearchableDropdownField<Port>(
                labelText: 'Puerto de Destino',
                hintText: 'Selecciona el puerto de destino',
                prefixIcon: Icon(FontAwesomeIcons.locationDot, color: Colors.blueGrey[700]),
                items: _availablePorts,
                selectedItem: _selectedDestinationPort,
                itemAsString: (Port p) => '${p.name} (${p.code}, ${p.country.code})',
                onChanged: (Port? port) {
                  setState(() {
                    _selectedDestinationPort = port;
                  });
                },
                validator: (value) => value == null ? 'Por favor, selecciona un puerto de destino' : null,
              ),
              const SizedBox(height: 24),
              Text(
                'Detalles de la Carga',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Tipo de Contenedor
              SearchableDropdownField<ContainerType>(
                labelText: 'Tipo de Contenedor',
                hintText: 'Selecciona el tipo de contenedor',
                prefixIcon: Icon(FontAwesomeIcons.boxOpen, color: Colors.blueGrey[700]),
                items: _availableContainerTypes,
                selectedItem: _selectedContainerType,
                itemAsString: (ContainerType ct) => ct.name,
                onChanged: (ContainerType? ct) {
                  setState(() {
                    _selectedContainerType = ct;
                  });
                },
                validator: (value) => value == null ? 'Por favor, selecciona un tipo de contenedor' : null,
              ),
              const SizedBox(height: 16),
              // Tipo de Carga
              SearchableDropdownField<CargoType>(
                labelText: 'Tipo de Carga',
                hintText: 'Selecciona el tipo de carga',
                prefixIcon: Icon(FontAwesomeIcons.boxesPacking, color: Colors.blueGrey[700]),
                items: _availableCargoTypes,
                selectedItem: _selectedCargoType,
                itemAsString: (CargoType ct) => ct.name,
                onChanged: (CargoType? ct) {
                  setState(() {
                    _selectedCargoType = ct;
                  });
                },
                validator: (value) => value == null ? 'Por favor, selecciona un tipo de carga' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Cantidad de Contenedores',
                  hintText: 'Ej: 1',
                  prefixIcon: Icon(FontAwesomeIcons.cubes, color: Colors.blueGrey[700]),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa la cantidad';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Ingresa un número válido mayor que 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Peso Total (kg)',
                  hintText: 'Ej: 5000',
                  prefixIcon: Icon(FontAwesomeIcons.weightHanging, color: Colors.blueGrey[700]),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el peso';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Ingresa un número válido mayor que 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _volumeController,
                decoration: InputDecoration(
                  labelText: 'Volumen Total (CBM)',
                  hintText: 'Ej: 25.5',
                  prefixIcon: Icon(FontAwesomeIcons.cube, color: Colors.blueGrey[700]),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el volumen';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Ingresa un número válido mayor que 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _calculateQuote,
                        icon: const Icon(FontAwesomeIcons.calculator),
                        label: const Text('Calcular Cotización'),
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
              const SizedBox(height: 24),
              if (_calculatedQuote != null)
                _buildQuoteResultCard(_calculatedQuote!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteResultCard(QuoteCalculation quote) {
    final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resultado de la Cotización',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
                ),
                _isGeneratingPdf
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        onPressed: _generatePdf,
                        tooltip: 'Generar PDF',
                      ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            _buildInfoRow('Puerto de Origen:', '${quote.originPort.name} (${quote.originPort.code})'),
            _buildInfoRow('Puerto de Destino:', '${quote.destinationPort.name} (${quote.destinationPort.code})'),
            _buildInfoRow('Tipo de Contenedor:', quote.containerType.name),
            _buildInfoRow('Tipo de Carga:', quote.cargoType.name),
            _buildInfoRow('Cantidad:', '${quote.quantity} contenedor(es)'),
            _buildInfoRow('Peso Total:', '${quote.weightKg} kg'),
            _buildInfoRow('Volumen Total:', '${quote.volumeCbm} CBM'),
            _buildInfoRow('Días de Tránsito Estimados:', '${quote.estimatedTransitDays} días'),
            const SizedBox(height: 16),
            Text(
              'Desglose de Costos:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            _buildBreakdownRow('Tarifa Base por Contenedor:', currencyFormatter.format(quote.breakdown['base_rate_per_container'])),
            _buildBreakdownRow('Recargo por Combustible (%):', '${quote.breakdown['fuel_surcharge_percentage']}%'),
            _buildBreakdownRow('Recargo por Combustible (Monto):', currencyFormatter.format(quote.breakdown['fuel_surcharge_amount_per_container'])),
            _buildBreakdownRow('Tarifa de Manipulación por Contenedor:', currencyFormatter.format(quote.breakdown['handling_fee_per_container'])),
            _buildBreakdownRow('Tarifa de Seguro por Contenedor:', currencyFormatter.format(quote.breakdown['insurance_fee_per_container'])),
            _buildBreakdownRow('Tarifa de Documentación por Cotización:', currencyFormatter.format(quote.breakdown['documentation_fee_per_quote'])),
            const Divider(height: 20, thickness: 1),
            _buildInfoRow('Costo Total por Ítem:', currencyFormatter.format(quote.totalItemCost), isTotal: true),
            _buildInfoRow('Monto Total de la Cotización:', currencyFormatter.format(quote.totalQuoteAmount), isTotal: true),
            _buildInfoRow('Válida Hasta:', dateFormatter.format(quote.validUntil)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
              color: isTotal ? Colors.blueGrey[900] : Colors.blueGrey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
              color: isTotal ? Colors.blueGrey[900] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 2.0, bottom: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
