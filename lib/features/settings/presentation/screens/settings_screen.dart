import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yarpay/features/auth/application/auth_provider.dart';
import 'package:yarpay/features/restaurant/application/restaurant_provider.dart';
import 'package:yarpay/features/menu/presentation/screens/menu_screen.dart';
import 'package:yarpay/features/customers/presentation/screens/customers_screen.dart';
import 'package:yarpay/features/settings/application/settings_provider.dart';
import 'package:yarpay/core/router/app_routes.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _taxRateController = TextEditingController();
  bool _isEditingRate = false;

  @override
  void dispose() {
    _taxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final restaurant = ref.watch(restaurantProvider);
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restaurant',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (restaurant.restaurant != null) ...[
                    _SettingsTile(
                      icon: Icons.store_rounded,
                      title: restaurant.restaurant!.name,
                      subtitle: restaurant.restaurant!.address,
                    ),
                    if (restaurant.restaurant!.phone.isNotEmpty)
                      _SettingsTile(
                        icon: Icons.phone_rounded,
                        title: 'Phone',
                        subtitle: restaurant.restaurant!.phone,
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Management',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.restaurant_menu_rounded),
                    title: const Text('Menu'),
                    subtitle: const Text('Manage categories and products'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MenuScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.people_rounded),
                    title: const Text('Customers'),
                    subtitle: const Text('Manage customer database'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomersScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Billing',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.receipt_long_rounded),
                    title: const Text('GST'),
                    subtitle: Text(
                      settings.gstEnabled
                          ? 'ON - ${settings.gstRate.toStringAsFixed(0)}% applied to orders'
                          : 'OFF - No tax on orders',
                    ),
                    value: settings.gstEnabled,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleGst(value);
                    },
                  ),
                  if (settings.gstEnabled) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 56),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('Rate: '),
                              Expanded(
                                child: Slider(
                                  value: settings.gstRate,
                                  min: 1,
                                  max: 28,
                                  divisions: 27,
                                  label: '${settings.gstRate.toStringAsFixed(0)}%',
                                  onChanged: (value) {
                                    ref.read(settingsProvider.notifier).setGstRate(value);
                                    _taxRateController.text = value.toStringAsFixed(0);
                                  },
                                ),
                              ),
                              if (!_isEditingRate)
                                GestureDetector(
                                  onTap: () {
                                    _taxRateController.text = settings.gstRate.toStringAsFixed(0);
                                    setState(() => _isEditingRate = true);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text('${settings.gstRate.toStringAsFixed(0)}%'),
                                  ),
                                )
                              else
                                SizedBox(
                                  width: 70,
                                  child: TextField(
                                    controller: _taxRateController,
                                    keyboardType: TextInputType.number,
                                    autofocus: true,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      suffixText: '%',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    ),
                                    onSubmitted: (value) {
                                      final rate = double.tryParse(value);
                                      if (rate != null && rate >= 1 && rate <= 28) {
                                        ref.read(settingsProvider.notifier).setGstRate(rate);
                                      }
                                      setState(() => _isEditingRate = false);
                                    },
                                    onTapOutside: (_) {
                                      final rate = double.tryParse(_taxRateController.text);
                                      if (rate != null && rate >= 1 && rate <= 28) {
                                        ref.read(settingsProvider.notifier).setGstRate(rate);
                                      }
                                      setState(() => _isEditingRate = false);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Receipt',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.storefront_rounded),
                    title: const Text('Show Restaurant Address'),
                    value: settings.receiptShowAddress,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleReceiptShowAddress(value);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.phone_rounded),
                    title: const Text('Show Phone Number'),
                    value: settings.receiptShowPhone,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleReceiptShowPhone(value);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(text: settings.receiptFooter),
                    decoration: const InputDecoration(
                      labelText: 'Receipt Footer Text',
                      hintText: 'Thank you for dining with us!',
                    ),
                    onSubmitted: (value) {
                      ref.read(settingsProvider.notifier).setReceiptFooter(value);
                    },
                    onTapOutside: (_) {
                      ref.read(settingsProvider.notifier).setReceiptFooter(
                        TextEditingController(text: settings.receiptFooter).text,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (restaurant.userProfile != null)
                    _SettingsTile(
                      icon: Icons.person_rounded,
                      title: restaurant.userProfile!.fullName.isEmpty
                          ? 'User'
                          : restaurant.userProfile!.fullName,
                      subtitle: restaurant.userProfile!.role.toUpperCase(),
                    ),
                  const SizedBox(height: 4),
                  _SettingsTile(
                    icon: Icons.email_rounded,
                    title: 'Email',
                    subtitle: auth.user?.email ?? 'Not signed in',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Yarpay POS',
                    subtitle: 'Version 1.0.0',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
