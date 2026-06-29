import 'package:flutter/material.dart';
import 'package:restobill/core/widgets/app_scaffold.dart';
import 'package:restobill/core/widgets/placeholder_content.dart';
import 'package:restobill/core/widgets/responsive_builder.dart';

/// Application settings screen placeholder.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      body: ResponsiveBuilder(
        mobile: const _SettingsLayout(showSidePanel: false),
        tablet: const _SettingsLayout(showSidePanel: true),
        largeTablet: const _SettingsLayout(showSidePanel: true),
      ),
    );
  }
}

class _SettingsLayout extends StatelessWidget {
  const _SettingsLayout({required this.showSidePanel});

  final bool showSidePanel;

  static const _sections = [
    ('General', Icons.tune_rounded),
    ('Menu', Icons.restaurant_menu_rounded),
    ('Staff', Icons.badge_rounded),
    ('Tax & Pricing', Icons.calculate_rounded),
    ('Devices', Icons.devices_rounded),
    ('About', Icons.info_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final settingsList = ListView.separated(
      itemCount: _sections.length,
      separatorBuilder: (context, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final (title, icon) = _sections[index];
        return Card(
          child: ListTile(
            leading: Icon(icon),
            title: Text(title),
            subtitle: const Text('Configuration placeholder'),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        );
      },
    );

    return PlaceholderContent(
      icon: Icons.settings_rounded,
      title: 'Settings',
      description:
          'Restaurant profile, menu, staff, and device settings will live here.',
      children: [
        Expanded(
          child: showSidePanel
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sections',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              Expanded(child: settingsList),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Card(
                        child: Center(
                          child: Text(
                            'Select a settings section',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : settingsList,
        ),
      ],
    );
  }
}
