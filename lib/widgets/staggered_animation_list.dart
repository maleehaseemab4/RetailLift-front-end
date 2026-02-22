import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum AnimationType { fadeIn, slideInLeft, slideInRight, slideInUp, slideInDown }

/// A wrapper that applies staggered animations to a list of widgets
/// Useful for animating multiple widgets with a delay between each one
class StaggeredAnimationList extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration animationDuration;
  final AnimationType animationType;

  const StaggeredAnimationList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 600),
    this.animationType = AnimationType.fadeIn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(children.length, (index) {
        Widget child = children[index];

        // Apply staggered animation based on index
        final delayMs = (index * staggerDelay.inMilliseconds).toDouble();

        switch (animationType) {
          case AnimationType.fadeIn:
            child = child
                .animate(delay: Duration(milliseconds: delayMs.toInt()))
                .fadeIn(duration: animationDuration);
            break;
          case AnimationType.slideInLeft:
            child = child
                .animate(delay: Duration(milliseconds: delayMs.toInt()))
                .slide(duration: animationDuration, begin: const Offset(-1, 0));
            break;
          case AnimationType.slideInRight:
            child = child
                .animate(delay: Duration(milliseconds: delayMs.toInt()))
                .slide(duration: animationDuration, begin: const Offset(1, 0));
            break;
          case AnimationType.slideInUp:
            child = child
                .animate(delay: Duration(milliseconds: delayMs.toInt()))
                .slide(duration: animationDuration, begin: const Offset(0, 1));
            break;
          case AnimationType.slideInDown:
            child = child
                .animate(delay: Duration(milliseconds: delayMs.toInt()))
                .slide(duration: animationDuration, begin: const Offset(0, -1));
            break;
        }

        return child;
      }),
    );
  }
}

/// Animated container with glow effect on tap
class AnimatedGlowButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color glowColor;
  final double glowRadius;

  const AnimatedGlowButton({
    super.key,
    required this.child,
    required this.onTap,
    this.glowColor = Colors.blue,
    this.glowRadius = 20,
  });

  @override
  State<AnimatedGlowButton> createState() => _AnimatedGlowButtonState();
}

class _AnimatedGlowButtonState extends State<AnimatedGlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0,
      end: widget.glowRadius,
    ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _triggerGlow() {
    _glowController.forward().then((_) {
      _glowController.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerGlow,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withValues(
                    alpha: _glowAnimation.value / widget.glowRadius * 0.5,
                  ),
                  blurRadius: _glowAnimation.value,
                  spreadRadius: _glowAnimation.value / 2,
                ),
              ],
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
