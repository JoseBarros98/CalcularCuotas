import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/services/port_service.dart';
import 'package:frontend/services/container_service.dart';
import 'package:frontend/services/quote_service.dart';
import 'package:frontend/services/country_service.dart';
import 'package:frontend/services/shipping_route_service.dart';
import 'package:frontend/services/base_rate_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<PortService>(create: (_) => PortService()),
        Provider<ContainerService>(create: (_) => ContainerService()),
        Provider<QuoteService>(create: (_) => QuoteService()),
        Provider<CountryService>(create: (_) => CountryService()),
        Provider<ShippingRouteService>(create: (_) => ShippingRouteService()),
        Provider<BaseRateService>(create: (_) => BaseRateService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cálculo de Cotizaciones',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.blueGrey, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blueGrey.shade200, width: 1.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Colors.blueGrey[700],
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
