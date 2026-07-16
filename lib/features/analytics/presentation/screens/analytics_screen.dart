import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:yarpay/features/analytics/application/analytics_provider.dart';
import 'package:yarpay/features/analytics/presentation/widgets/analytics_pdf_report.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Export PDF Report',
            onPressed: analytics.isLoading
                ? null
                : () => generateAnalyticsPdf(context, analytics),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(analyticsProvider.notifier).refresh(),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard_rounded)),
            Tab(text: 'Sales', icon: Icon(Icons.trending_up_rounded)),
            Tab(text: 'Menu', icon: Icon(Icons.restaurant_menu_rounded)),
            Tab(text: 'Customers', icon: Icon(Icons.people_rounded)),
            Tab(text: 'Payments', icon: Icon(Icons.payment_rounded)),
          ],
        ),
      ),
      body: analytics.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(analyticsProvider.notifier).refresh(),
              child: TabBarView(
                controller: _tab,
                children: [
                  _OverviewTab(analytics),
                  _SalesTab(analytics),
                  _MenuTab(analytics),
                  _CustomersTab(analytics),
                  _PaymentsTab(analytics),
                ],
              ),
            ),
    );
  }
}

// ═══════════════════════════════════════════════
// OVERVIEW TAB
// ═══════════════════════════════════════════════

class _OverviewTab extends StatelessWidget {
  final AnalyticsState data;
  const _OverviewTab(this.data);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Today row
        _sectionTitle(context, "Today"),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _MetricCard(label: "Sales", value: "Rs.${data.todaySales.toStringAsFixed(0)}", icon: Icons.today_rounded, color: Colors.green)),
          const SizedBox(width: 8),
          Expanded(child: _MetricCard(label: "Orders", value: "${data.todayOrders}", icon: Icons.receipt_long_rounded, color: Colors.blue)),
        ]),
        const SizedBox(height: 16),
        // Month row
        _sectionTitle(context, "This Month"),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _MetricCard(label: "Revenue", value: "Rs.${data.monthSales.toStringAsFixed(0)}", icon: Icons.calendar_month_rounded, color: Colors.orange)),
          const SizedBox(width: 8),
          Expanded(child: _MetricCard(label: "Orders", value: "${data.monthOrders}", icon: Icons.shopping_bag_rounded, color: Colors.purple)),
        ]),
        const SizedBox(height: 16),
        // Growth
        if (data.thisMonth != null && data.lastMonth != null) ...[
          _GrowthCard(
            label: 'Month-over-Month Growth',
            value: data.monthGrowth,
            thisRevenue: data.thisMonth!.revenue,
            lastRevenue: data.lastMonth!.revenue,
            thisOrders: data.thisMonth!.orders,
            lastOrders: data.lastMonth!.orders,
          ),
          const SizedBox(height: 16),
        ],
        // All time
        _sectionTitle(context, "All Time"),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _MetricCard(label: "Total Sales", value: "Rs.${data.totalSales.toStringAsFixed(0)}", icon: Icons.account_balance_wallet_rounded, color: Colors.teal)),
          const SizedBox(width: 8),
          Expanded(child: _MetricCard(label: "Avg Ticket", value: "Rs.${data.avgTicket.toStringAsFixed(0)}", icon: Icons.receipt_rounded, color: Colors.indigo)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _MetricCard(label: "Total Orders", value: "${data.totalOrders}", icon: Icons.shopping_cart_rounded, color: Colors.deepPurple)),
          const SizedBox(width: 8),
          Expanded(child: _MetricCard(label: "Avg Daily Rev", value: "Rs.${data.avgDailyRevenue.toStringAsFixed(0)}", icon: Icons.show_chart_rounded, color: Colors.brown)),
        ]),
        const SizedBox(height: 16),
        // Discount summary
        if (data.discountAnalytics.isNotEmpty) ...[
          _DiscountSummaryCard(data.discountAnalytics),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// SALES TAB
// ═══════════════════════════════════════════════

class _SalesTab extends StatelessWidget {
  final AnalyticsState data;
  const _SalesTab(this.data);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle(context, "Revenue Trend (30 Days)"),
        const SizedBox(height: 8),
        if (data.dailySales.isNotEmpty)
          _DailyRevenueChart(data.dailySales)
        else
          _emptyCard("No sales data yet"),
        const SizedBox(height: 24),
        _sectionTitle(context, "Peak Hours Heatmap"),
        const SizedBox(height: 8),
        if (data.hourlyHeatmap.isNotEmpty)
          _HourlyHeatmap(data.hourlyHeatmap)
        else
          _emptyCard("No data yet"),
        const SizedBox(height: 24),
        _sectionTitle(context, "Orders by Day of Week"),
        const SizedBox(height: 8),
        if (data.dayOfWeekSales.isNotEmpty)
          _DayOfWeekChart(data.dayOfWeekSales)
        else
          _emptyCard("No data yet"),
        const SizedBox(height: 24),
        _sectionTitle(context, "Monthly Comparison"),
        const SizedBox(height: 8),
        if (data.thisMonth != null && data.lastMonth != null)
          _MonthlyComparisonChart(data.thisMonth!, data.lastMonth!)
        else
          _emptyCard("Need at least 2 months of data"),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// MENU TAB
// ═══════════════════════════════════════════════

class _MenuTab extends StatelessWidget {
  final AnalyticsState data;
  const _MenuTab(this.data);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle(context, "Category Breakdown"),
        const SizedBox(height: 8),
        if (data.categorySales.isNotEmpty) ...[
          SizedBox(height: 220, child: _CategoryPieChart(data.categorySales)),
          const SizedBox(height: 8),
          ...data.categorySales.map((c) => _CategoryTile(c)),
        ] else
          _emptyCard("No category data yet"),
        const SizedBox(height: 24),
        _sectionTitle(context, "Top 20 Products"),
        const SizedBox(height: 8),
        if (data.productSales.isNotEmpty) ...[
          SizedBox(height: 260, child: _TopProductsBarChart(data.productSales.take(10).toList())),
          const SizedBox(height: 12),
          ...data.productSales.asMap().entries.map((e) => _ProductRankTile(e.key + 1, e.value)),
        ] else
          _emptyCard("No product data yet"),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// CUSTOMERS TAB
// ═══════════════════════════════════════════════

class _CustomersTab extends StatelessWidget {
  final AnalyticsState data;
  const _CustomersTab(this.data);

  @override
  Widget build(BuildContext context) {
    final c = data.customerAnalytics;
    final topCustomers = (c['top_customers'] as List<dynamic>? ?? [])
        .map((j) => TopCustomer.fromJson(j as Map<String, dynamic>))
        .toList();
    final nr = c['new_vs_returning'] as List<dynamic>? ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle(context, "Customer Overview"),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _MetricCard(label: "Total", value: "${c['total_customers'] ?? 0}", icon: Icons.people_rounded, color: Colors.blue)),
          const SizedBox(width: 8),
          Expanded(child: _MetricCard(label: "Repeat", value: "${c['repeat_customers'] ?? 0}", icon: Icons.repeat_rounded, color: Colors.green)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _MetricCard(label: "Avg Orders", value: "${c['avg_orders_per_customer'] ?? 0}", icon: Icons.shopping_cart_rounded, color: Colors.orange)),
          const SizedBox(width: 8),
          Expanded(child: _MetricCard(label: "Avg Spend", value: "Rs.${c['avg_spend_per_customer'] ?? 0}", icon: Icons.payments_rounded, color: Colors.teal)),
        ]),
        const SizedBox(height: 24),
        _sectionTitle(context, "New vs Returning"),
        const SizedBox(height: 8),
        if (nr.isNotEmpty)
          SizedBox(height: 180, child: _NewReturningChart(nr))
        else
          _emptyCard("No customer data yet"),
        const SizedBox(height: 24),
        _sectionTitle(context, "Top Customers"),
        const SizedBox(height: 8),
        if (topCustomers.isNotEmpty)
          ...topCustomers.asMap().entries.map((e) => _CustomerRankTile(e.key + 1, e.value))
        else
          _emptyCard("No customers linked to orders yet"),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// PAYMENTS TAB
// ═══════════════════════════════════════════════

class _PaymentsTab extends StatelessWidget {
  final AnalyticsState data;
  const _PaymentsTab(this.data);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle(context, "Payment Methods"),
        const SizedBox(height: 8),
        if (data.paymentBreakdown.isNotEmpty) ...[
          SizedBox(height: 200, child: _PaymentPieChart(data.paymentBreakdown)),
          const SizedBox(height: 12),
          ...data.paymentBreakdown.map((p) => _PaymentTile(p)),
        ] else
          _emptyCard("No payment data yet"),
        const SizedBox(height: 24),
        _sectionTitle(context, "Payment Method Trends (30 Days)"),
        const SizedBox(height: 8),
        if (data.paymentBreakdown.isNotEmpty)
          _PaymentDailyTrend(data.paymentBreakdown)
        else
          _emptyCard("No data yet"),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// CHART WIDGETS
// ═══════════════════════════════════════════════

class _DailyRevenueChart extends StatelessWidget {
  final List<DailySales> data;
  const _DailyRevenueChart(this.data);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxRevenue = data.map((d) => d.revenue).fold(0.0, max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Rs.${data.map((d) => d.revenue).fold(0.0, (a, b) => a + b).toStringAsFixed(0)} total",
                    style: theme.textTheme.bodySmall),
                Text("Rs.${(data.map((d) => d.revenue).fold(0.0, (a, b) => a + b) / max(data.length, 1)).toStringAsFixed(0)} avg/day",
                    style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxRevenue * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final d = data[group.x.toInt() % data.length];
                        return BarTooltipItem(
                          "Rs.${rod.toY.toStringAsFixed(0)}\n${DateFormat('dd MMM').format(d.date)}",
                          const TextStyle(color: Colors.white, fontSize: 11),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < data.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(DateFormat('dd').format(data[idx].date), style: const TextStyle(fontSize: 9)),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        interval: max(1, (data.length / 7).floor().toDouble()),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text("Rs.${(value / 1000).toStringAsFixed(0)}k", style: const TextStyle(fontSize: 9));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: max(maxRevenue / 4, 1),
                  ),
                  barGroups: data.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.revenue,
                          color: theme.colorScheme.primary,
                          width: max(4, 500 / data.length),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HourlyHeatmap extends StatelessWidget {
  final List<HourlyData> data;
  const _HourlyHeatmap(this.data);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxOrders = data.map((h) => h.orderCount).fold(0, max);

    // Fill all 24 hours
    final hourMap = {for (var h in data) h.hour: h};
    final hours = List.generate(24, (i) => hourMap[i] ?? HourlyData(hour: i, orderCount: 0, revenue: 0));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Busiest: ${hours.reduce((a, b) => a.orderCount > b.orderCount ? a : b).hour}:00 ($maxOrders orders)",
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1.4,
                ),
                itemCount: 24,
                itemBuilder: (context, index) {
                  final h = hours[index];
                  final intensity = maxOrders > 0 ? h.orderCount / maxOrders : 0.0;
                  return Container(
                    decoration: BoxDecoration(
                      color: _heatColor(intensity),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${h.hour}h", style: TextStyle(fontSize: 9, color: intensity > 0.5 ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                        Text("${h.orderCount}", style: TextStyle(fontSize: 10, color: intensity > 0.5 ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Low", style: theme.textTheme.bodySmall),
                const SizedBox(width: 4),
                ...List.generate(5, (i) => Container(width: 20, height: 12, color: _heatColor(i / 4))),
                const SizedBox(width: 4),
                Text("High", style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _heatColor(double intensity) {
    if (intensity <= 0) return Colors.grey.shade100;
    if (intensity < 0.25) return Colors.green.shade100;
    if (intensity < 0.5) return Colors.green.shade300;
    if (intensity < 0.75) return Colors.orange.shade400;
    return Colors.red.shade500;
  }
}

class _DayOfWeekChart extends StatelessWidget {
  final List<DayOfWeekSales> data;
  const _DayOfWeekChart(this.data);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxRevenue = data.map((d) => d.revenue).fold(0.0, max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Peak: ${data.isNotEmpty ? data.reduce((a, b) => a.revenue > b.revenue ? a : b).dayName : '-'}", style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxRevenue * 1.2,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < data.length) {
                            return Text(data[idx].dayName.substring(0, 3), style: const TextStyle(fontSize: 10));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text("Rs.${(value / 1000).toStringAsFixed(0)}k", style: const TextStyle(fontSize: 9));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  barGroups: data.asMap().entries.map((e) {
                    final isPeak = e.value.revenue == maxRevenue;
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.revenue,
                          color: isPeak ? Colors.orange : theme.colorScheme.primary,
                          width: 24,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyComparisonChart extends StatelessWidget {
  final MonthData thisMonth;
  final MonthData lastMonth;
  const _MonthlyComparisonChart(this.thisMonth, this.lastMonth);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxVal = max(thisMonth.revenue, lastMonth.revenue) * 1.3;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("This Month: Rs.${thisMonth.revenue.toStringAsFixed(0)} (${thisMonth.orders} orders)",
                style: theme.textTheme.bodySmall),
            Text("Last Month: Rs.${lastMonth.revenue.toStringAsFixed(0)} (${lastMonth.orders} orders)",
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal,
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: lastMonth.revenue, color: Colors.grey.shade400, width: 40, borderRadius: BorderRadius.circular(4)),
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: thisMonth.revenue, color: Colors.green, width: 40, borderRadius: BorderRadius.circular(4)),
                    ]),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value == 0 ? 'Last Month' : 'This Month', style: const TextStyle(fontSize: 11));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text("Rs.${(value / 1000).toStringAsFixed(0)}k", style: const TextStyle(fontSize: 9));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final List<CategorySales> data;
  const _CategoryPieChart(this.data);

  static const _colors = [
    Color(0xFF2196F3), Color(0xFFFF9800), Color(0xFF4CAF50), Color(0xFFE91E63),
    Color(0xFF9C27B0), Color(0xFF00BCD4), Color(0xFFFF5722), Color(0xFF607D8B),
  ];

  @override
  Widget build(BuildContext context) {
    final total = data.fold(0.0, (sum, c) => sum + c.revenue);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              sections: data.asMap().entries.map((e) {
                final pct = total > 0 ? (e.value.revenue / total * 100) : 0.0;
                return PieChartSectionData(
                  value: e.value.revenue,
                  title: "${pct.toStringAsFixed(0)}%",
                  color: _colors[e.key % _colors.length],
                  radius: 40,
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, color: _colors[e.key % _colors.length]),
                    const SizedBox(width: 6),
                    Expanded(child: Text(e.value.categoryName, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                    Text("Rs.${e.value.revenue.toStringAsFixed(0)}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _TopProductsBarChart extends StatelessWidget {
  final List<ProductSales> data;
  const _TopProductsBarChart(this.data);

  @override
  Widget build(BuildContext context) {
    final maxQty = data.map((p) => p.totalQty).fold(0, max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (maxQty * 1.2).toDouble(),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final p = data[group.x.toInt() % data.length];
                  return BarTooltipItem(
                    "${p.productName}\n${p.totalQty} sold - Rs.${p.totalRevenue.toStringAsFixed(0)}",
                    const TextStyle(color: Colors.white, fontSize: 11),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < data.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(data[idx].productName.length > 8 ? "${data[idx].productName.substring(0, 8)}.." : data[idx].productName, style: const TextStyle(fontSize: 8)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) => Text("${value.toInt()}", style: const TextStyle(fontSize: 9)),
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: true, drawVerticalLine: false),
            barGroups: data.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.totalQty.toDouble(),
                    color: e.key == 0 ? Colors.amber.shade700 : Colors.blue.shade300,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NewReturningChart extends StatelessWidget {
  final List<dynamic> data;
  const _NewReturningChart(this.data);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = data.fold(0.0, (sum, d) => sum + ((d['revenue'] as num?)?.toDouble() ?? 0));

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 28,
              sections: data.asMap().entries.map((e) {
                final label = e.value['type'] as String? ?? '?';
                final rev = (e.value['revenue'] as num?)?.toDouble() ?? 0;
                return PieChartSectionData(
                  value: rev,
                  title: "Rs.${rev.toStringAsFixed(0)}",
                  color: label == 'New' ? Colors.blue : Colors.green,
                  radius: 36,
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((d) {
              final label = d['type'] as String? ?? '?';
              final orders = d['order_count'] ?? 0;
              final rev = (d['revenue'] as num?)?.toDouble() ?? 0;
              final pct = total > 0 ? (rev / total * 100) : 0.0;
              return Row(
                children: [
                  Icon(label == 'New' ? Icons.person_add_rounded : Icons.repeat_rounded,
                      color: label == 'New' ? Colors.blue : Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text("$orders orders - Rs.${rev.toStringAsFixed(0)} (${pct.toStringAsFixed(0)}%)", style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PaymentPieChart extends StatelessWidget {
  final List<PaymentBreakdown> data;
  const _PaymentPieChart(this.data);

  static const _colors = [Color(0xFF4CAF50), Color(0xFF2196F3), Color(0xFFFF9800), Color(0xFF9C27B0), Color(0xFFE91E63)];
  static const _icons = {
    'Cash': Icons.money_rounded,
    'Card': Icons.credit_card_rounded,
    'UPI': Icons.phone_android_rounded,
    'Online': Icons.language_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 28,
              sections: data.asMap().entries.map((e) {
                return PieChartSectionData(
                  value: e.value.totalAmount,
                  title: "${e.value.percentage.toStringAsFixed(0)}%",
                  color: _colors[e.key % _colors.length],
                  radius: 36,
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(_icons[e.value.paymentMethod] ?? Icons.payment_rounded,
                        color: _colors[e.key % _colors.length], size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text("${e.value.paymentMethod} (${e.value.orderCount})", style: const TextStyle(fontSize: 11))),
                    Text("Rs.${e.value.totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PaymentDailyTrend extends StatelessWidget {
  final List<PaymentBreakdown> data;
  const _PaymentDailyTrend(this.data);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...data.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text(p.paymentMethod, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Text("Rs.${p.totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: LinearProgressIndicator(
                      value: p.percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      color: p.paymentMethod == 'Cash' ? Colors.green : p.paymentMethod == 'Card' ? Colors.blue : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text("${p.percentage.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 11)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// TILE / CARD WIDGETS
// ═══════════════════════════════════════════════

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _GrowthCard extends StatelessWidget {
  final String label;
  final double value;
  final double thisRevenue;
  final double lastRevenue;
  final int thisOrders;
  final int lastOrders;

  const _GrowthCard({required this.label, required this.value, required this.thisRevenue, required this.lastRevenue, required this.thisOrders, required this.lastOrders});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUp = value >= 0;
    final color = isUp ? Colors.green : Colors.red;
    final icon = isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 8),
                Text("${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}%", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text("Revenue: Rs.${lastRevenue.toStringAsFixed(0)} -> Rs.${thisRevenue.toStringAsFixed(0)}", style: theme.textTheme.bodySmall),
            Text("Orders: $lastOrders -> $thisOrders", style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _DiscountSummaryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DiscountSummaryCard(this.data);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Discount Impact", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _miniStat("Orders with Discount", "${data['total_orders_with_discount'] ?? 0}")),
              Expanded(child: _miniStat("Total Given", "Rs.${(data['total_discount_given'] as num?)?.toDouble().toStringAsFixed(0) ?? '0'}")),
              Expanded(child: _miniStat("Avg Discount", "Rs.${(data['avg_discount'] as num?)?.toDouble().toStringAsFixed(0) ?? '0'}")),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategorySales data;
  const _CategoryTile(this.data);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(child: Text(data.categoryName.substring(0, min(2, data.categoryName.length)))),
        title: Text(data.categoryName),
        subtitle: Text("${data.itemsSold} items in ${data.orderCount} orders"),
        trailing: Text("Rs.${data.revenue.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _ProductRankTile extends StatelessWidget {
  final int rank;
  final ProductSales data;
  const _ProductRankTile(this.rank, this.data);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: rank <= 3 ? Colors.amber.shade700 : null,
          child: Text("$rank", style: TextStyle(color: rank <= 3 ? Colors.white : null, fontWeight: FontWeight.bold)),
        ),
        title: Text(data.productName, style: const TextStyle(fontSize: 13)),
        subtitle: Text("${data.totalQty} sold - ${data.category}", style: const TextStyle(fontSize: 11)),
        trailing: Text("Rs.${data.totalRevenue.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}

class _CustomerRankTile extends StatelessWidget {
  final int rank;
  final TopCustomer data;
  const _CustomerRankTile(this.rank, this.data);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundColor: rank == 1 ? Colors.amber.shade700 : rank == 2 ? Colors.grey.shade400 : rank == 3 ? Colors.brown.shade300 : null,
          child: Text("$rank", style: TextStyle(color: rank <= 3 ? Colors.white : null, fontWeight: FontWeight.bold)),
        ),
        title: Text(data.name, style: const TextStyle(fontSize: 13)),
        subtitle: Text("${data.phone} - ${data.totalOrders} orders", style: const TextStyle(fontSize: 11)),
        trailing: Text("Rs.${data.totalSpent.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final PaymentBreakdown data;
  const _PaymentTile(this.data);

  @override
  Widget build(BuildContext context) {
    final icon = data.paymentMethod == 'Cash'
        ? Icons.money_rounded
        : data.paymentMethod == 'Card'
            ? Icons.credit_card_rounded
            : Icons.phone_android_rounded;
    final color = data.paymentMethod == 'Cash' ? Colors.green : data.paymentMethod == 'Card' ? Colors.blue : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color),
        title: Text(data.paymentMethod),
        subtitle: Text("${data.orderCount} orders - Rs.${data.avgAmount.toStringAsFixed(0)} avg"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Rs.${data.totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("${data.percentage.toStringAsFixed(1)}%", style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════

Widget _sectionTitle(BuildContext context, String title) {
  return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
}

Widget _emptyCard(String text) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.grey))),
    ),
  );
}
