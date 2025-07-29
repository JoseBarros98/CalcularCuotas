import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import 'package:frontend/models/quote_calculation.dart';

Future<void> generateQuotePdf(QuoteCalculation quote) async {
  final pdf = pw.Document();
  final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'Cotización de Envío Marítimo',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 10),
            _buildSectionTitle('Detalles del Envío'),
            _buildInfoRow('Ruta:', '${quote.originPort.name} (${quote.originPort.code}) → ${quote.destinationPort.name} (${quote.destinationPort.code})'),
            _buildInfoRow('Tipo de Contenedor:', quote.containerType.name),
            _buildInfoRow('Tipo de Carga:', quote.cargoType.name),
            _buildInfoRow('Cantidad:', '${quote.quantity} contenedor(es)'),
            _buildInfoRow('Peso Total:', '${quote.weightKg} kg'),
            _buildInfoRow('Volumen Total:', '${quote.volumeCbm} CBM'),
            _buildInfoRow('Días de Tránsito Estimados:', '${quote.estimatedTransitDays} días'),
            pw.SizedBox(height: 20),
            _buildSectionTitle('Desglose de Costos'),
            _buildBreakdownRow('Tarifa Base por Contenedor:', currencyFormatter.format(quote.breakdown['base_rate_per_container'])),
            _buildBreakdownRow('Recargo por Combustible (%):', '${quote.breakdown['fuel_surcharge_percentage']}%'),
            _buildBreakdownRow('Recargo por Combustible (Monto):', currencyFormatter.format(quote.breakdown['fuel_surcharge_amount_per_container'])),
            _buildBreakdownRow('Tarifa de Manipulación por Contenedor:', currencyFormatter.format(quote.breakdown['handling_fee_per_container'])),
            _buildBreakdownRow('Tarifa de Seguro por Contenedor:', currencyFormatter.format(quote.breakdown['insurance_fee_per_container'])),
            _buildBreakdownRow('Tarifa de Documentación por Cotización:', currencyFormatter.format(quote.breakdown['documentation_fee_per_quote'])),
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 10),
            _buildTotalRow('Costo Total por Ítem:', currencyFormatter.format(quote.totalItemCost)),
            _buildTotalRow('Monto Total de la Cotización:', currencyFormatter.format(quote.totalQuoteAmount)),
            _buildInfoRow('Válida Hasta:', dateFormatter.format(quote.validUntil)),
            pw.Spacer(),
            pw.Center(
              child: pw.Text(
                'Generado el ${dateFormatter.format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ),
          ],
        );
      },
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/cotizacion_${DateTime.now().millisecondsSinceEpoch}.pdf');
  await file.writeAsBytes(await pdf.save());

  // Abrir el PDF
  OpenFilex.open(file.path);
}

pw.Widget _buildSectionTitle(String title) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Text(
      title,
      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
    ),
  );
}

pw.Widget _buildInfoRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 12, color: PdfColors.blueGrey700)),
        pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );
}

pw.Widget _buildBreakdownRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(left: 16, top: 2, bottom: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
        pw.Text(value, style: pw.TextStyle(fontSize: 11)),
      ],
    ),
  );
}

pw.Widget _buildTotalRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
        pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
      ],
    ),
  );
}
