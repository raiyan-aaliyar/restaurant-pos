import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:yarpay/features/orders/domain/order.dart';
import 'package:yarpay/features/restaurant/domain/restaurant.dart';

class ReceiptService {
  static Future<Uint8List> generateReceipt({
    required Order order,
    required Restaurant restaurant,
    bool gstEnabled = true,
    double gstRate = 5.0,
    String footer = 'Thank you for dining with us!',
    bool showAddress = true,
    bool showPhone = true,
  }) async {
    final pdf = pw.Document();
    final currencyFormat =
        NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 2);
    final dateFormat = DateFormat("dd MMM yyyy - hh:mm a");

    final receiptWidth = 226.0;
    final contentWidth = receiptWidth - 24;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat(receiptWidth, 1000, marginAll: 12),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              restaurant.name.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          if (showAddress && restaurant.address.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Center(
              child: pw.Text(
                restaurant.address,
                style: pw.TextStyle(fontSize: 7),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
          if (showPhone && restaurant.phone.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Center(
              child: pw.Text(
                restaurant.phone,
                style: pw.TextStyle(fontSize: 7),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
          pw.SizedBox(height: 8),
          _dashedLine(contentWidth),
          pw.SizedBox(height: 6),
          _twoColumn(
            'Order #${order.id.substring(order.id.length - 5).toUpperCase()}',
            dateFormat.format(order.createdAt),
            contentWidth,
          ),
          pw.SizedBox(height: 2),
          _twoColumn(
            'Table: ${order.tableNumber.isEmpty ? "N/A" : order.tableNumber}',
            'Payment: ${order.paymentMethod}',
            contentWidth,
          ),
          if (order.customerName.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              'Customer: ${order.customerName}',
              style: pw.TextStyle(fontSize: 8),
            ),
          ],
          pw.SizedBox(height: 8),
          _dashedLine(contentWidth),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'Item',
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(
                width: 30,
                child: pw.Text(
                  'Qty',
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(
                width: 50,
                child: pw.Text(
                  'Amount',
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          _dashedLine(contentWidth),
          pw.SizedBox(height: 4),
          ...order.items.map(
            (item) => pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(item.product.name,
                      style: pw.TextStyle(fontSize: 8)),
                ),
                pw.SizedBox(
                  width: 30,
                  child: pw.Text('${item.quantity}',
                      style: pw.TextStyle(fontSize: 8),
                      textAlign: pw.TextAlign.center),
                ),
                pw.SizedBox(
                  width: 50,
                  child: pw.Text(
                    currencyFormat
                        .format(item.product.price * item.quantity),
                    style: pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          _dashedLine(contentWidth),
          pw.SizedBox(height: 6),
          _twoColumn(
            'Subtotal',
            currencyFormat.format(order.subtotal),
            contentWidth,
          ),
          if (order.discount > 0) ...[
            pw.SizedBox(height: 2),
            _twoColumn(
              'Discount',
              '- ${currencyFormat.format(order.discount)}',
              contentWidth,
            ),
          ],
          if (gstEnabled) ...[
            pw.SizedBox(height: 2),
            _twoColumn(
              'GST (${gstRate.toStringAsFixed(0)}%)',
              currencyFormat.format(order.tax),
              contentWidth,
            ),
          ],
          pw.SizedBox(height: 4),
          _dashedLine(contentWidth),
          pw.SizedBox(height: 4),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'TOTAL',
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Text(
                currencyFormat.format(order.total),
                style: pw.TextStyle(
                    fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          _dashedLine(contentWidth),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              footer,
              style: pw.TextStyle(
                  fontSize: 8, fontStyle: pw.FontStyle.italic),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _twoColumn(String left, String right, double width) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(left, style: pw.TextStyle(fontSize: 8)),
        ),
        pw.Text(right, style: pw.TextStyle(fontSize: 8)),
      ],
    );
  }

  static pw.Widget _dashedLine(double width) {
    return pw.Center(
      child: pw.Text(
        '-' * 38,
        style: pw.TextStyle(fontSize: 6, color: PdfColors.grey600),
      ),
    );
  }
}
