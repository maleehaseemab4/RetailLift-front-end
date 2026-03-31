import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class NavBarItemData {
  const NavBarItemData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class FloatingBottomNavBar extends StatelessWidget {
  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavBarItemData> items;

  static const double _barHeight = 80;
  static const double _bubbleRise = 24.0;
  static const Duration _animationDuration = Duration(milliseconds: 360);
  static const Curve _animationCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navBackgroundGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF07091D), Color(0xFF160838)],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.15),
              theme.colorScheme.surface.withOpacity(0.75),
            ],
          );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        child: SizedBox(
          height: _barHeight,
          child: Container(
            decoration: BoxDecoration(
              gradient: navBackgroundGradient,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.20),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.55)
                      : Colors.black.withOpacity(0.20),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.none,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (index) {
                final item = items[index];
                return Expanded(
                  child: AnimatedNavItem(
                    icon: item.icon,
                    label: item.label,
                    isSelected: currentIndex == index,
                    onTap: () => onTap(index),
                    animationDuration: _animationDuration,
                    curve: _animationCurve,
                    bubbleRise: _bubbleRise,
                    selectedColor: isDark
                        ? Colors.white
                        : const Color(0xFF001F3F),
                    unselectedColor: isDark
                        ? Colors.white70
                        : const Color(0xFF4D6A84),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedNavItem extends StatefulWidget {
  const AnimatedNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    required this.animationDuration,
    required this.curve,
    required this.bubbleRise,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final Duration animationDuration;
  final Curve curve;
  final double bubbleRise;

  @override
  State<AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<AnimatedNavItem> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _isActive => widget.isSelected || _isHovered;

  void _setHovered(bool value) {
    if (_isHovered == value) return;
    setState(() => _isHovered = value);
  }

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = _isActive
        ? widget.selectedColor
        : widget.unselectedColor;

    final bubbleColor = _isActive
        ? widget.selectedColor.withOpacity(0.22)
        : Colors.transparent;

    final pressScale = _isPressed ? 0.88 : 1.0;
    final iconScale = widget.isSelected ? 1.28 : 1.0;

    return MouseRegion(
      onEnter: (_) {
        if (kIsWeb ||
            Theme.of(context).platform != TargetPlatform.android &&
                Theme.of(context).platform != TargetPlatform.iOS) {
          _setHovered(true);
        }
      },
      onExit: (_) => _setHovered(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: Transform.scale(
          scale: pressScale,
          child: TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0,
              end: widget.isSelected ? -widget.bubbleRise : 0,
            ),
            duration: widget.animationDuration,
            curve: widget.curve,
            builder: (context, translateY, child) {
              return Transform.translate(
                offset: Offset(0, translateY),
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: _isActive ? 1.0 : 0.0),
                      duration: widget.animationDuration,
                      curve: widget.curve,
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              bubbleColor,
                              bubbleColor.withOpacity(0.35),
                            ],
                          ),
                          boxShadow: _isActive
                              ? [
                                  BoxShadow(
                                    color: widget.selectedColor.withOpacity(
                                      0.35,
                                    ),
                                    blurRadius: 18,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                    AnimatedScale(
                      scale: iconScale,
                      duration: widget.animationDuration,
                      curve: widget.curve,
                      child: TweenAnimationBuilder<Color?>(
                        tween: ColorTween(
                          begin: widget.unselectedColor,
                          end: effectiveColor,
                        ),
                        duration: widget.animationDuration,
                        curve: widget.curve,
                        builder: (context, iconColor, _) =>
                            Icon(widget.icon, size: 26, color: iconColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: widget.animationDuration,
                  curve: widget.curve,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: effectiveColor.withOpacity(
                      widget.isSelected ? 0.95 : 0.62,
                    ),
                  ),
                  child: Text(widget.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
