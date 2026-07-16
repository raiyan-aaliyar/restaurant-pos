import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yarpay/data/services/supabase_service.dart';
import 'package:yarpay/features/restaurant/application/restaurant_provider.dart';

// ── Models ──

class DailySales {
  final DateTime date;
  final int orderCount;
  final double revenue;
  final double grossRevenue;
  final double discountTotal;
  final double taxTotal;
  final double avgOrderValue;

  DailySales({
    required this.date,
    required this.orderCount,
    required this.revenue,
    required this.grossRevenue,
    required this.discountTotal,
    required this.taxTotal,
    required this.avgOrderValue,
  });

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: DateTime.parse(json['date'] as String),
      orderCount: (json['order_count'] as int?) ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      grossRevenue: (json['gross_revenue'] as num?)?.toDouble() ?? 0,
      discountTotal: (json['discount_total'] as num?)?.toDouble() ?? 0,
      taxTotal: (json['tax_total'] as num?)?.toDouble() ?? 0,
      avgOrderValue: (json['avg_order_value'] as num?)?.toDouble() ?? 0,
    );
  }
}

class HourlyData {
  final int hour;
  final int orderCount;
  final double revenue;

  HourlyData({required this.hour, required this.orderCount, required this.revenue});

  factory HourlyData.fromJson(Map<String, dynamic> json) {
    return HourlyData(
      hour: (json['hour'] as int?) ?? 0,
      orderCount: (json['order_count'] as int?) ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class DayOfWeekSales {
  final String dayName;
  final int dayNum;
  final int orderCount;
  final double revenue;

  DayOfWeekSales({required this.dayName, required this.dayNum, required this.orderCount, required this.revenue});

  factory DayOfWeekSales.fromJson(Map<String, dynamic> json) {
    return DayOfWeekSales(
      dayName: json['day_name'] as String,
      dayNum: (json['day_num'] as int?) ?? 0,
      orderCount: (json['order_count'] as int?) ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CategorySales {
  final String categoryName;
  final int orderCount;
  final int itemsSold;
  final double revenue;

  CategorySales({required this.categoryName, required this.orderCount, required this.itemsSold, required this.revenue});

  factory CategorySales.fromJson(Map<String, dynamic> json) {
    return CategorySales(
      categoryName: json['category_name'] as String,
      orderCount: (json['order_count'] as int?) ?? 0,
      itemsSold: (json['items_sold'] as int?) ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ProductSales {
  final String productName;
  final String category;
  final int totalQty;
  final double totalRevenue;
  final double avgPrice;
  final int appearedInOrders;

  ProductSales({required this.productName, required this.category, required this.totalQty, required this.totalRevenue, required this.avgPrice, required this.appearedInOrders});

  factory ProductSales.fromJson(Map<String, dynamic> json) {
    return ProductSales(
      productName: json['product_name'] as String,
      category: json['category'] as String? ?? '',
      totalQty: (json['total_qty'] as int?) ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      avgPrice: (json['avg_price'] as num?)?.toDouble() ?? 0,
      appearedInOrders: (json['appeared_in_orders'] as int?) ?? 0,
    );
  }
}

class PaymentBreakdown {
  final String paymentMethod;
  final int orderCount;
  final double totalAmount;
  final double avgAmount;
  final double percentage;

  PaymentBreakdown({required this.paymentMethod, required this.orderCount, required this.totalAmount, required this.avgAmount, required this.percentage});

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentBreakdown(
      paymentMethod: json['payment_method'] as String,
      orderCount: (json['order_count'] as int?) ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      avgAmount: (json['avg_amount'] as num?)?.toDouble() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
    );
  }
}

class TopCustomer {
  final String name;
  final String phone;
  final int totalOrders;
  final double totalSpent;

  TopCustomer({required this.name, required this.phone, required this.totalOrders, required this.totalSpent});

  factory TopCustomer.fromJson(Map<String, dynamic> json) {
    return TopCustomer(
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      totalOrders: (json['total_orders'] as int?) ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MonthData {
  final double revenue;
  final int orders;
  final double avgOrderValue;
  final double totalDiscount;

  MonthData({required this.revenue, required this.orders, required this.avgOrderValue, required this.totalDiscount});

  factory MonthData.fromJson(Map<String, dynamic> json) {
    return MonthData(
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      orders: (json['orders'] as int?) ?? 0,
      avgOrderValue: (json['avg_order_value'] as num?)?.toDouble() ?? 0,
      totalDiscount: (json['total_discount'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ── State ──

class AnalyticsState {
  final List<DailySales> dailySales;
  final List<HourlyData> hourlyHeatmap;
  final List<DayOfWeekSales> dayOfWeekSales;
  final List<CategorySales> categorySales;
  final List<ProductSales> productSales;
  final List<PaymentBreakdown> paymentBreakdown;
  final Map<String, dynamic> customerAnalytics;
  final MonthData? thisMonth;
  final MonthData? lastMonth;
  final Map<String, dynamic> discountAnalytics;
  final bool isLoading;
  final double todaySales;
  final int todayOrders;
  final double monthSales;
  final int monthOrders;
  final double totalSales;
  final int totalOrders;

  const AnalyticsState({
    this.dailySales = const [],
    this.hourlyHeatmap = const [],
    this.dayOfWeekSales = const [],
    this.categorySales = const [],
    this.productSales = const [],
    this.paymentBreakdown = const [],
    this.customerAnalytics = const {},
    this.thisMonth,
    this.lastMonth,
    this.discountAnalytics = const {},
    this.isLoading = false,
    this.todaySales = 0,
    this.todayOrders = 0,
    this.monthSales = 0,
    this.monthOrders = 0,
    this.totalSales = 0,
    this.totalOrders = 0,
  });

  double get avgTicket => totalOrders > 0 ? totalSales / totalOrders : 0;
  double get avgDailyRevenue => dailySales.isNotEmpty ? dailySales.map((d) => d.revenue).fold(0.0, (a, b) => a + b) / dailySales.length : 0;

  double get monthGrowth {
    if (lastMonth == null || lastMonth!.revenue == 0) return 0;
    return ((thisMonth?.revenue ?? 0) - lastMonth!.revenue) / lastMonth!.revenue * 100;
  }

  AnalyticsState copyWith({
    List<DailySales>? dailySales,
    List<HourlyData>? hourlyHeatmap,
    List<DayOfWeekSales>? dayOfWeekSales,
    List<CategorySales>? categorySales,
    List<ProductSales>? productSales,
    List<PaymentBreakdown>? paymentBreakdown,
    Map<String, dynamic>? customerAnalytics,
    MonthData? thisMonth,
    MonthData? lastMonth,
    Map<String, dynamic>? discountAnalytics,
    bool? isLoading,
    double? todaySales,
    int? todayOrders,
    double? monthSales,
    int? monthOrders,
    double? totalSales,
    int? totalOrders,
  }) {
    return AnalyticsState(
      dailySales: dailySales ?? this.dailySales,
      hourlyHeatmap: hourlyHeatmap ?? this.hourlyHeatmap,
      dayOfWeekSales: dayOfWeekSales ?? this.dayOfWeekSales,
      categorySales: categorySales ?? this.categorySales,
      productSales: productSales ?? this.productSales,
      paymentBreakdown: paymentBreakdown ?? this.paymentBreakdown,
      customerAnalytics: customerAnalytics ?? this.customerAnalytics,
      thisMonth: thisMonth ?? this.thisMonth,
      lastMonth: lastMonth ?? this.lastMonth,
      discountAnalytics: discountAnalytics ?? this.discountAnalytics,
      isLoading: isLoading ?? this.isLoading,
      todaySales: todaySales ?? this.todaySales,
      todayOrders: todayOrders ?? this.todayOrders,
      monthSales: monthSales ?? this.monthSales,
      monthOrders: monthOrders ?? this.monthOrders,
      totalSales: totalSales ?? this.totalSales,
      totalOrders: totalOrders ?? this.totalOrders,
    );
  }
}

// ── Notifier ──

class AnalyticsNotifier extends Notifier<AnalyticsState> {
  @override
  AnalyticsState build() {
    final restaurantId = ref.watch(restaurantIdProvider);
    if (restaurantId != null) {
      _loadAll();
    }
    return const AnalyticsState(isLoading: true);
  }

  Future<void> _loadAll() async {
    try {
      // Each RPC is independent — one failure won't kill the rest
      final overview = await _safeRpc('get_analytics', {});
      final daily = await _safeRpcList('get_daily_sales', {'p_days': 30});
      final hourly = await _safeRpcList('get_hourly_heatmap', {});
      final dow = await _safeRpcList('get_day_of_week_sales', {});
      final cat = await _safeRpcList('get_category_sales', {});
      final prod = await _safeRpcList('get_product_sales', {'p_limit': 20});
      final paymentRaw = await _safeRpc('get_payment_analytics', {});
      final custRaw = await _safeRpc('get_customer_analytics', {});
      final monthRaw = await _safeRpc('get_monthly_comparison', {});
      final discRaw = await _safeRpc('get_discount_analytics', {});

      final paymentList = paymentRaw['breakdown'] as List<dynamic>? ?? [];

      final thisMonthRaw = monthRaw['this_month'] as Map<String, dynamic>?;
      final lastMonthRaw = monthRaw['last_month'] as Map<String, dynamic>?;

      state = AnalyticsState(
        dailySales: daily.map((j) => DailySales.fromJson(j as Map<String, dynamic>)).toList(),
        hourlyHeatmap: hourly.map((j) => HourlyData.fromJson(j as Map<String, dynamic>)).toList(),
        dayOfWeekSales: dow.map((j) => DayOfWeekSales.fromJson(j as Map<String, dynamic>)).toList(),
        categorySales: cat.map((j) => CategorySales.fromJson(j as Map<String, dynamic>)).toList(),
        productSales: prod.map((j) => ProductSales.fromJson(j as Map<String, dynamic>)).toList(),
        paymentBreakdown: paymentList.map((j) => PaymentBreakdown.fromJson(j as Map<String, dynamic>)).toList(),
        customerAnalytics: custRaw,
        thisMonth: thisMonthRaw != null ? MonthData.fromJson(thisMonthRaw) : null,
        lastMonth: lastMonthRaw != null ? MonthData.fromJson(lastMonthRaw) : null,
        discountAnalytics: discRaw,
        todaySales: (overview['today_sales'] as num?)?.toDouble() ?? 0,
        todayOrders: (overview['today_orders'] as int?) ?? 0,
        monthSales: (overview['month_sales'] as num?)?.toDouble() ?? 0,
        monthOrders: (overview['month_orders'] as int?) ?? 0,
        totalSales: (overview['total_sales'] as num?)?.toDouble() ?? 0,
        totalOrders: (overview['total_orders'] as int?) ?? 0,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<Map<String, dynamic>> _safeRpc(String fn, Map<String, dynamic> params) async {
    try {
      final result = await SupabaseService.client
          .rpc(fn, params: params)
          .timeout(const Duration(seconds: 10));
      if (result is Map<String, dynamic>) return result;
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<List<dynamic>> _safeRpcList(String fn, Map<String, dynamic> params) async {
    try {
      final result = await SupabaseService.client
          .rpc(fn, params: params)
          .timeout(const Duration(seconds: 10));
      if (result is List<dynamic>) return result;
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> refresh() async {
    await _loadAll();
  }
}

final analyticsProvider = NotifierProvider<AnalyticsNotifier, AnalyticsState>(
  AnalyticsNotifier.new,
);
