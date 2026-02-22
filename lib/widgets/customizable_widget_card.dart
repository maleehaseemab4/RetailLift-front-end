import 'package:flutter/material.dart';
import 'package:shoplifting_app/models/dashboard_widget_config.dart';

/// Reusable widget card that respects size and color customization
class CustomizableWidgetCard extends StatelessWidget {
  final DashboardWidgetConfig config;
  final Widget? child;
  final VoidCallback? onTap;
  final String content;

  const CustomizableWidgetCard({
    required this.config,
    this.child,
    this.onTap,
    this.content = 'Widget content',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate height based on size multiplier
    final height = config.size.heightMultiplier.toDouble();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: config.color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Card(
          color: config.color.withOpacity(0.1),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: config.color.withOpacity(0.5), width: 2),
          ),
          child:
              child ??
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: config.color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.widgets, color: config.color, size: 32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      config.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: config.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 12,
                        color: config.color.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
