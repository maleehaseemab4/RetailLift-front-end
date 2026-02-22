// Example: Using Dashboard Customization Feature

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoplifting_app/providers/dashboard_provider.dart';
import 'package:shoplifting_app/models/dashboard_widget_config.dart';
import 'package:shoplifting_app/widgets/customizable_widget_card.dart';

/// Example 1: Display all widgets with their customizations
class DashboardExample extends StatelessWidget {
  const DashboardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          final visibleWidgets = provider.widgets
              .where((w) => w.isVisible)
              .toList();

          return ListView.builder(
            itemCount: visibleWidgets.length,
            itemBuilder: (context, index) {
              final widgetConfig = visibleWidgets[index];

              return CustomizableWidgetCard(
                config: widgetConfig,
                content: 'Total incidents: 42',
                onTap: () {
                  // Open customization dialog here
                  debugPrint('Tapped on ${widgetConfig.title}');
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// Example 2: Programmatically update widget properties
class WidgetUpdateExample extends StatelessWidget {
  const WidgetUpdateExample({super.key});

  void _updateAlertWidget(BuildContext context) {
    final provider = context.read<DashboardProvider>();

    // Change size to large
    provider.updateWidgetSize('alerts', WidgetSize.large);

    // Change color to red
    provider.updateWidgetColor('alerts', const Color(0xFFC62828));

    // Toggle visibility
    provider.toggleVisibility('alerts');
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _updateAlertWidget(context),
      child: const Text('Update Alert Widget'),
    );
  }
}

/// Example 3: Listen to widget configuration changes
class ConfigListenerExample extends StatelessWidget {
  const ConfigListenerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        final alertWidget = provider.getWidget('alerts');

        return Column(
          children: [
            Text('Widget: ${alertWidget.title}'),
            Text('Size: ${alertWidget.size.displayName}'),
            Text('Visible: ${alertWidget.isVisible}'),
            Container(width: 50, height: 50, color: alertWidget.color),
          ],
        );
      },
    );
  }
}

/// Example 4: Reset to defaults
class ResetExample extends StatelessWidget {
  const ResetExample({super.key});

  void _reset(BuildContext context) {
    context.read<DashboardProvider>().resetToDefaults();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dashboard reset to defaults')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _reset(context),
      child: const Text('Reset Dashboard'),
    );
  }
}

/// Example 5: Custom widget with customization support
class CustomAlertWidget extends StatelessWidget {
  final DashboardWidgetConfig config;

  const CustomAlertWidget({required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomizableWidgetCard(
      config: config,
      content: 'Alert details here',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, color: config.color, size: 48),
            const SizedBox(height: 12),
            Text(
              'Alerts Today',
              style: TextStyle(
                color: config.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '15 incidents',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 6: Full customization interaction
class CustomizationInteractionExample extends StatelessWidget {
  const CustomizationInteractionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return ListView(
          children: [
            // Settings Header
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Widget Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Size Control
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Adjust Size'),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<WidgetSize>(
                segments: WidgetSize.values
                    .map(
                      (size) => ButtonSegment<WidgetSize>(
                        value: size,
                        label: Text(size.displayName),
                      ),
                    )
                    .toList(),
                selected: {provider.getWidget('alerts').size},
                onSelectionChanged: (Set<WidgetSize> newSelection) {
                  provider.updateWidgetSize('alerts', newSelection.first);
                },
              ),
            ),

            // Visibility Toggle
            SwitchListTile(
              title: const Text('Show Alerts Widget'),
              value: provider.getWidget('alerts').isVisible,
              onChanged: (_) {
                provider.toggleVisibility('alerts');
              },
            ),

            // Reset Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => provider.resetToDefaults(),
                child: const Text('Reset All Settings'),
              ),
            ),
          ],
        );
      },
    );
  }
}
