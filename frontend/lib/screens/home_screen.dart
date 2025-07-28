import 'package:flutter/material.dart';
import 'package:frontend/screens/quote_form_screen.dart';
import 'package:frontend/screens/country_list_screen.dart';
import 'package:frontend/screens/port_list_screen.dart';
import 'package:frontend/screens/container_type_list_screen.dart';
import 'package:frontend/screens/cargo_type_list_screen.dart';
import 'package:frontend/screens/shipping_route_list_screen.dart';
import 'package:frontend/screens/base_rate_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cálculo de Cotizaciones'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Navegación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Calcular Cotización'),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuoteFormScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Gestión de Países'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CountryListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.anchor),
              title: const Text('Gestión de Puertos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PortListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Gestión de Contenedores'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContainerTypeListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Gestión de Tipos de Carga'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CargoTypeListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.route),
              title: const Text('Gestión de Rutas de Envío'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShippingRouteListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Gestión de Tarifas Base'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BaseRateListScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido, presione el siguiente boton para realizar una cotización',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuoteFormScreen()),
                );
              },
              icon: const Icon(Icons.calculate),
              label: const Text('Ir a Calcular Cotización'),
            ),
          ],
        ),
      ),
    );
  }
}
