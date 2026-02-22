import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoplifting_app/providers/dashboard_customization_provider.dart';

/// Simplified Dashboard Customization Sheet
/// Only allows:
/// 1. Reordering Quick Actions
/// 2. Changing System Status card color
class SimpleDashboardCustomizationSheet extends StatefulWidget {
  const SimpleDashboardCustomizationSheet({super.key});

  @override
  State<SimpleDashboardCustomizationSheet> createState() =>
      _SimpleDashboardCustomizationSheetState();
}

class _SimpleDashboardCustomizationSheetState
    extends State<SimpleDashboardCustomizationSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<DashboardCustomizationProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 400,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Customize Dashboard',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // System Status Color Section
                    _buildSectionHeader(theme, 'System Status Color'),
                    const SizedBox(height: 12),
                    _buildColorPicker(context, provider),

                    const SizedBox(height: 32),

                    // Quick Actions Order Section
                    _buildSectionHeader(theme, 'Quick Actions Order'),
                    const SizedBox(height: 8),
                    Text(
                      'Drag to reorder',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActionsReorderList(context, provider),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        provider.resetToDefaults();
                      },
                      icon: const Icon(Icons.restore),
                      label: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check),
                      label: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildColorPicker(
    BuildContext context,
    DashboardCustomizationProvider provider,
  ) {
    final colors = [
      const Color(0xFF001F3F), // Deep Navy (default)
      const Color(0xFF1B5E20), // Dark Green
      const Color(0xFFE65100), // Dark Orange
      const Color(0xFF880E4F), // Dark Pink
      const Color(0xFF4A148C), // Dark Purple
      const Color(0xFF006064), // Dark Cyan
      const Color(0xFFF57F17), // Dark Yellow
      const Color(0xFF3E2723), // Dark Brown
      const Color(0xFF37474F), // Dark Blue Grey
      const Color(0xFFB71C1C), // Dark Red
      const Color(0xFF1A237E), // Dark Indigo
      const Color(0xFF004D40), // Dark Teal
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((color) {
        final isSelected = provider.systemStatusColor == color;
        return GestureDetector(
          onTap: () => provider.updateSystemStatusColor(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withOpacity(0.3),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.black54, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionsReorderList(
    BuildContext context,
    DashboardCustomizationProvider provider,
  ) {
    final theme = Theme.of(context);
    final actions = provider.quickActions;

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: actions.length,
      onReorder: (oldIndex, newIndex) {
        provider.reorderQuickActions(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final action = actions[index];
        return Card(
          key: ValueKey(action.id),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_handle,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(action.title),
            subtitle: Text(action.subtitle),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                action.icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }
}
