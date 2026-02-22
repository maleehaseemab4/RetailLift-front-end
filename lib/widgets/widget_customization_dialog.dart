import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoplifting_app/models/dashboard_widget_config.dart';
import 'package:shoplifting_app/providers/dashboard_provider.dart';

class WidgetCustomizationDialog extends StatefulWidget {
  final DashboardWidgetConfig widget;

  const WidgetCustomizationDialog({required this.widget, super.key});

  @override
  State<WidgetCustomizationDialog> createState() =>
      _WidgetCustomizationDialogState();
}

class _WidgetCustomizationDialogState extends State<WidgetCustomizationDialog> {
  late WidgetSize selectedSize;
  late Color selectedColor;
  late bool isVisible;

  @override
  void initState() {
    super.initState();
    selectedSize = widget.widget.size;
    selectedColor = widget.widget.color;
    isVisible = widget.widget.isVisible;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          // Prevents overflow on small screens
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Widget',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.widget.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Visibility Section
                _buildSectionHeader('Visibility'),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  title: const Text('Display on Dashboard'),
                  subtitle: Text(isVisible ? 'Visible' : 'Hidden'),
                  value: isVisible,
                  onChanged: (val) => setState(() => isVisible = val),
                ),
                const SizedBox(height: 24),

                // Size Selection Section
                _buildSectionHeader('Widget Size'),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<WidgetSize>(
                      segments: WidgetSize.values
                          .map(
                            (size) => ButtonSegment<WidgetSize>(
                              value: size,
                              label: Text(size.displayName),
                            ),
                          )
                          .toList(),
                      selected: {selectedSize},
                      onSelectionChanged: (Set<WidgetSize> newSelection) {
                        setState(() => selectedSize = newSelection.first);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Color Picker Section
                _buildSectionHeader('Accent Color'),
                const SizedBox(height: 16),
                _buildColorGrid(),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _applyChanges,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _applyChanges() {
    final provider = context.read<DashboardProvider>();
    // Logic for updating visibility only if it changed
    if (isVisible != widget.widget.isVisible) {
      provider.toggleVisibility(widget.widget.id);
    }
    if (selectedSize != widget.widget.size) {
      provider.updateWidgetSize(widget.widget.id, selectedSize);
    }
    if (selectedColor != widget.widget.color) {
      provider.updateWidgetColor(widget.widget.id, selectedColor);
    }
    Navigator.of(context).pop();
  }

  Widget _buildColorGrid() {
    final colors = [
      // Original colors
      const Color(0xFF001F3F), // Deep Navy
      const Color(0xFF003366), // Navy Blue
      const Color(0xFFE91E63), // Pink
      const Color(0xFFF57C00), // Orange
      const Color(0xFF43A047), // Green
      const Color(0xFF5E35B1), // Purple
      const Color(0xFF0097A7), // Teal
      const Color(0xFFC62828), // Red
      const Color(0xFF455A64), // Blue Grey
      // Additional custom colors
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFFCDDC39), // Lime
      const Color(0xFFFFEB3B), // Yellow
      const Color(0xFFFF9800), // Deep Orange
      const Color(0xFF795548), // Brown
      const Color(0xFF9C27B0), // Deep Purple
      const Color(0xFF3F51B5), // Indigo
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF4CAF50), // Medium Green
      const Color(0xFF607D8B), // Blue Grey Light
      const Color(0xFFFF5722), // Deep Orange Red
      const Color(0xFF2196F3), // Blue 500
      const Color(0xFF9E9E9E), // Grey
      const Color(0xFF000000), // Black
    ];

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: colors.length,
          itemBuilder: (context, index) {
            final color = colors[index];
            final isSelected = selectedColor == color;
            return GestureDetector(
              onTap: () => setState(() => selectedColor = color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        // Custom color picker button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickCustomColor,
            icon: const Icon(Icons.color_lens),
            label: const Text('Custom Color'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickCustomColor() async {
    final Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        Color tempColor = selectedColor;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Pick a Custom Color'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Simple color picker with sliders
                  const Text('Red'),
                  Slider(
                    value: tempColor.red.toDouble(),
                    min: 0,
                    max: 255,
                    onChanged: (value) {
                      setState(() {
                        tempColor = Color.fromARGB(
                          tempColor.alpha,
                          value.toInt(),
                          tempColor.green,
                          tempColor.blue,
                        );
                      });
                    },
                  ),
                  const Text('Green'),
                  Slider(
                    value: tempColor.green.toDouble(),
                    min: 0,
                    max: 255,
                    onChanged: (value) {
                      setState(() {
                        tempColor = Color.fromARGB(
                          tempColor.alpha,
                          tempColor.red,
                          value.toInt(),
                          tempColor.blue,
                        );
                      });
                    },
                  ),
                  const Text('Blue'),
                  Slider(
                    value: tempColor.blue.toDouble(),
                    min: 0,
                    max: 255,
                    onChanged: (value) {
                      setState(() {
                        tempColor = Color.fromARGB(
                          tempColor.alpha,
                          tempColor.red,
                          tempColor.green,
                          value.toInt(),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: tempColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Select'),
                onPressed: () {
                  Navigator.of(context).pop(tempColor);
                },
              ),
            ],
          ),
        );
      },
    );

    if (pickedColor != null) {
      setState(() => selectedColor = pickedColor);
    }
  }
}

class DashboardCustomizationSheet extends StatefulWidget {
  const DashboardCustomizationSheet({super.key});

  @override
  State<DashboardCustomizationSheet> createState() =>
      _DashboardCustomizationSheetState();
}

class _DashboardCustomizationSheetState
    extends State<DashboardCustomizationSheet> {
  String? selectedWidgetId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dashboardProvider = context.watch<DashboardProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
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
            Expanded(
              child: ReorderableListView.builder(
                scrollController: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: dashboardProvider.widgets.length,
                onReorder: (oldIndex, newIndex) {
                  dashboardProvider.reorderWidgets(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final config = dashboardProvider.widgets[index];
                  final isSelected = selectedWidgetId == config.id;

                  return Card(
                    key: ValueKey(config.id),
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surface,
                    elevation: isSelected ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          Icons.drag_handle,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      title: Text(
                        config.title,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        'Size: ${config.size.displayName} • ${config.isVisible ? 'Visible' : 'Hidden'}',
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.7)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: config.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() => selectedWidgetId = config.id);
                        showDialog(
                          context: context,
                          builder: (_) =>
                              WidgetCustomizationDialog(widget: config),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
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
                        dashboardProvider.resetToDefaults();
                        setState(() => selectedWidgetId = null);
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.restore),
                      label: const Text('Reset to Defaults'),
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
}
