import 'package:flutter/material.dart';

/// Enum for widget size options
enum WidgetSize {
  small(1, 'Small'),
  medium(2, 'Medium'),
  large(3, 'Large');

  final int flex;
  final String displayName;

  const WidgetSize(this.flex, this.displayName);

  int get heightMultiplier => (flex * 100).toInt();
}

/// Configuration for a customizable dashboard widget
class DashboardWidgetConfig {
  final String id;
  final String title;
  final String description;
  bool isVisible;
  WidgetSize size;
  Color color;
  int order;

  DashboardWidgetConfig({
    required this.id,
    required this.title,
    this.description = '',
    this.isVisible = true,
    this.size = WidgetSize.medium,
    this.color = const Color(0xFF001F3F),
    this.order = 0,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isVisible': isVisible,
      'size': size.name,
      'colorValue': color.value,
      'order': order,
    };
  }

  /// Create from JSON
  factory DashboardWidgetConfig.fromJson(Map<String, dynamic> json) {
    return DashboardWidgetConfig(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      isVisible: json['isVisible'] as bool? ?? true,
      size: WidgetSize.values.firstWhere(
        (s) => s.name == json['size'],
        orElse: () => WidgetSize.medium,
      ),
      color: Color(json['colorValue'] as int? ?? 0xFF001F3F),
      order: json['order'] as int? ?? 0,
    );
  }

  /// Create a copy with optional replacements
  DashboardWidgetConfig copyWith({
    String? id,
    String? title,
    String? description,
    bool? isVisible,
    WidgetSize? size,
    Color? color,
    int? order,
  }) {
    return DashboardWidgetConfig(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isVisible: isVisible ?? this.isVisible,
      size: size ?? this.size,
      color: color ?? this.color,
      order: order ?? this.order,
    );
  }
}
