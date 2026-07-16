import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:yarpay/features/analytics/application/analytics_provider.dart';

Future<void> generateAnalyticsPdf(BuildContext context, AnalyticsState data) async {
  final pdf = pw.Document();
  final now = DateTime.now();
  final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(now);

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(30),
    header: (context) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Analytics Report', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.Text(dateStr, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        ]),
        pw.SizedBox(height: 4),
        pw.Divider(),
      ],
    ),
    build: (context) => [
      // OVERVIEW
      _pdfSection('Overview'),
      pw.SizedBox(height: 6),
      pw.Row(children: [
        _pdfMetric("Today's Sales", "Rs.${data.todaySales.toStringAsFixed(0)}"),
        pw.SizedBox(width: 20),
        _pdfMetric("Today's Orders", "${data.todayOrders}"),
        pw.SizedBox(width: 20),
        _pdfMetric("This Month", "Rs.${data.monthSales.toStringAsFixed(0)}"),
        pw.SizedBox(width: 20),
        _pdfMetric("Month Orders", "${data.monthOrders}"),
      ]),
      pw.SizedBox(height: 6),
      pw.Row(children: [
        _pdfMetric("All Time Sales", "Rs.${data.totalSales.toStringAsFixed(0)}"),
        pw.SizedBox(width: 20),
        _pdfMetric("All Time Orders", "${data.totalOrders}"),
        pw.SizedBox(width: 20),
        _pdfMetric("Avg Ticket", "Rs.${data.avgTicket.toStringAsFixed(0)}"),
        pw.SizedBox(width: 20),
        _pdfMetric("Avg Daily Rev", "Rs.${data.avgDailyRevenue.toStringAsFixed(0)}"),
      ]),
      if (data.monthGrowth != 0) ...[
        pw.SizedBox(height: 6),
        _pdfMetric("Month Growth", "${data.monthGrowth >= 0 ? '+' : ''}${data.monthGrowth.toStringAsFixed(1)}%"),
      ],

      // SALES TREND
      pw.SizedBox(height: 16),
      _pdfSection('Sales Trend (Last 30 Days)'),
      pw.SizedBox(height: 6),
      if (data.dailySales.isNotEmpty)
        pw.TableHelper.fromTextArray(
          headers: ['Date', 'Orders', 'Revenue', 'Discount', 'Tax', 'Avg Order'],
          data: data.dailySales.map((d) => [
            DateFormat('dd MMM').format(d.date),
            '${d.orderCount}',
            'Rs.${d.revenue.toStringAsFixed(0)}',
            'Rs.${d.discountTotal.toStringAsFixed(0)}',
            'Rs.${d.taxTotal.toStringAsFixed(0)}',
            'Rs.${d.avgOrderValue.toStringAsFixed(0)}',
          ]).toList(),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        )
      else
        _pdfEmpty,

      // CATEGORY BREAKDOWN
      pw.SizedBox(height: 16),
      _pdfSection('Category Breakdown'),
      pw.SizedBox(height: 6),
      if (data.categorySales.isNotEmpty)
        pw.TableHelper.fromTextArray(
          headers: ['Category', 'Orders', 'Items Sold', 'Revenue'],
          data: data.categorySales.map((c) => [
            c.categoryName,
            '${c.orderCount}',
            '${c.itemsSold}',
            'Rs.${c.revenue.toStringAsFixed(0)}',
          ]).toList(),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        )
      else
        _pdfEmpty,

      // TOP PRODUCTS
      pw.SizedBox(height: 16),
      _pdfSection('Top Products'),
      pw.SizedBox(height: 6),
      if (data.productSales.isNotEmpty)
        pw.TableHelper.fromTextArray(
          headers: ['#', 'Product', 'Category', 'Qty Sold', 'Revenue'],
          data: data.productSales.asMap().entries.map((e) => [
            '${e.key + 1}',
            e.value.productName,
            e.value.category,
            '${e.value.totalQty}',
            'Rs.${e.value.totalRevenue.toStringAsFixed(0)}',
          ]).toList(),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        )
      else
        _pdfEmpty,

      // PAYMENTS
      pw.SizedBox(height: 16),
      _pdfSection('Payment Breakdown'),
      pw.SizedBox(height: 6),
      if (data.paymentBreakdown.isNotEmpty)
        pw.TableHelper.fromTextArray(
          headers: ['Method', 'Orders', 'Total', 'Avg', '% Share'],
          data: data.paymentBreakdown.map((p) => [
            p.paymentMethod,
            '${p.orderCount}',
            'Rs.${p.totalAmount.toStringAsFixed(0)}',
            'Rs.${p.avgAmount.toStringAsFixed(0)}',
            '${p.percentage.toStringAsFixed(1)}%',
          ]).toList(),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        )
      else
        _pdfEmpty,

      // CUSTOMERS
      pw.SizedBox(height: 16),
      _pdfSection('Customer Insights'),
      pw.SizedBox(height: 6),
      pw.Row(children: [
        _pdfMetric("Total Customers", "${data.customerAnalytics['total_customers'] ?? 0}"),
        pw.SizedBox(width: 20),
        _pdfMetric("Repeat Customers", "${data.customerAnalytics['repeat_customers'] ?? 0}"),
        pw.SizedBox(width: 20),
        _pdfMetric("Avg Spend/Customer", "Rs.${data.customerAnalytics['avg_spend_per_customer'] ?? 0}"),
      ]),

      // DISCOUNT
      if (data.discountAnalytics.isNotEmpty) ...[
        pw.SizedBox(height: 16),
        _pdfSection('Discount Impact'),
        pw.SizedBox(height: 6),
        pw.Row(children: [
          _pdfMetric("Orders with Discount", "${data.discountAnalytics['total_orders_with_discount'] ?? 0}"),
          pw.SizedBox(width: 20),
          _pdfMetric("Total Discount Given", "Rs.${(data.discountAnalytics['total_discount_given'] as num?)?.toDouble().toStringAsFixed(0) ?? '0'}"),
          pw.SizedBox(width: 20),
          _pdfMetric("Avg Discount", "Rs.${(data.discountAnalytics['avg_discount'] as num?)?.toDouble().toStringAsFixed(0) ?? '0'}"),
        ]),
      ],

      // FOOTER
      pw.SizedBox(height: 24),
      pw.Divider(),
      pw.Center(child: pw.Text('Generated by Yarpay POS', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500))),
    ],
  ));

  final Uint8List bytes = await pdf.save();
  await Printing.sharePdf(bytes: bytes, filename: 'analytics-report-${DateFormat('yyyyMMdd').format(now)}.pdf');
}

pw.Widget _pdfSection(String title) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
  );
}

pw.Widget _pdfMetric(String label, String value) {
  return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Text(value, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
    pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
  ]);
}

pw.Widget get _pdfEmpty => pw.Text('No data available', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500));
