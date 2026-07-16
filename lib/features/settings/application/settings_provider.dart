import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class AppSettings {
  final bool gstEnabled;
  final double gstRate;
  final String receiptFooter;
  final bool receiptShowLogo;
  final bool receiptShowAddress;
  final bool receiptShowPhone;

  const AppSettings({
    this.gstEnabled = true,
    this.gstRate = 5.0,
    this.receiptFooter = 'Thank you for dining with us!',
    this.receiptShowLogo = true,
    this.receiptShowAddress = true,
    this.receiptShowPhone = true,
  });

  AppSettings copyWith({
    bool? gstEnabled,
    double? gstRate,
    String? receiptFooter,
    bool? receiptShowLogo,
    bool? receiptShowAddress,
    bool? receiptShowPhone,
  }) {
    return AppSettings(
      gstEnabled: gstEnabled ?? this.gstEnabled,
      gstRate: gstRate ?? this.gstRate,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      receiptShowLogo: receiptShowLogo ?? this.receiptShowLogo,
      receiptShowAddress: receiptShowAddress ?? this.receiptShowAddress,
      receiptShowPhone: receiptShowPhone ?? this.receiptShowPhone,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _load();
    return const AppSettings();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      gstEnabled: prefs.getBool('gst_enabled') ?? true,
      gstRate: prefs.getDouble('gst_rate') ?? 5.0,
      receiptFooter: prefs.getString('receipt_footer') ?? 'Thank you for dining with us!',
      receiptShowLogo: prefs.getBool('receipt_show_logo') ?? true,
      receiptShowAddress: prefs.getBool('receipt_show_address') ?? true,
      receiptShowPhone: prefs.getBool('receipt_show_phone') ?? true,
    );
  }

  Future<void> toggleGst(bool enabled) async {
    state = state.copyWith(gstEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gst_enabled', enabled);
  }

  Future<void> setGstRate(double rate) async {
    state = state.copyWith(gstRate: rate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('gst_rate', rate);
  }

  Future<void> setReceiptFooter(String text) async {
    state = state.copyWith(receiptFooter: text);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('receipt_footer', text);
  }

  Future<void> toggleReceiptShowLogo(bool show) async {
    state = state.copyWith(receiptShowLogo: show);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('receipt_show_logo', show);
  }

  Future<void> toggleReceiptShowAddress(bool show) async {
    state = state.copyWith(receiptShowAddress: show);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('receipt_show_address', show);
  }

  Future<void> toggleReceiptShowPhone(bool show) async {
    state = state.copyWith(receiptShowPhone: show);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('receipt_show_phone', show);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
