import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoplifting_app/providers/dashboard_provider.dart';
import 'package:shoplifting_app/widgets/widget_customization_dialog.dart';
import 'package:shoplifting_app/widgets/customizable_widget_card.dart';

class CustomizableDashboardScreen extends StatelessWidget {
  const CustomizableDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customizable Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Customize Dashboard',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => Consumer<DashboardProvider>(
                  builder: (context, _, _) =>
                      const DashboardCustomizationSheet(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, _) {
          // Show loading indicator while preferences are loading
          if (dashboardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error if there was an issue loading
          if (dashboardProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Error Loading Dashboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      dashboardProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      dashboardProvider.resetToDefaults();
                    },
                    child: const Text('Reset to Defaults'),
                  ),
                ],
              ),
            );
          }

          final visibleWidgets = dashboardProvider.widgets
              .where((w) => w.isVisible)
              .toList();

          if (visibleWidgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dashboard_customize,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No visible widgets',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the customize button to show widgets',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.tune),
                    label: const Text('Customize'),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => Consumer<DashboardProvider>(
                          builder: (context, _, _) =>
                              const DashboardCustomizationSheet(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          return ReorderableListView(
            onReorder: (oldIndex, newIndex) {
              dashboardProvider.reorderWidgets(oldIndex, newIndex);
            },
            children: visibleWidgets
                .map(
                  (widget) => CustomizableWidgetCard(
                    key: ValueKey(widget.id),
                    config: widget,
                    content: widget.description,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            WidgetCustomizationDialog(widget: widget),
                      );
                    },
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
