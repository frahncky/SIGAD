import 'package:flutter/material.dart';
import '../../app/theme/sigad_colors.dart';

class InteractiveCard extends StatefulWidget {
  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 18,
    this.showShadow = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double borderRadius;
  final bool showShadow;

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _shadowAnimation = Tween<double>(begin: 6, end: 2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPointerDown() {
    if (widget.onTap == null) return;
    _animationController.forward();
  }

  void _onPointerUp() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onTap != null,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _onPointerDown(),
        onTapUp: (_) => _onPointerUp(),
        onTapCancel: _onPointerUp,
        child: MouseRegion(
          onEnter: (_) => _onPointerDown(),
          onExit: (_) => _onPointerUp(),
          cursor: widget.onTap != null
              ? SystemMouseCursors.click
              : MouseCursor.defer,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedBuilder(
              animation: _shadowAnimation,
              builder: (context, child) => Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: SigadColors.surface,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(color: SigadColors.divider),
                  boxShadow: widget.showShadow
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: _shadowAnimation.value,
                            offset: Offset(0, _shadowAnimation.value * 0.3),
                          ),
                        ]
                      : null,
                ),
                child: child,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class InteractiveButton extends StatefulWidget {
  const InteractiveButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.variant = ButtonVariant.filled,
    this.size = ButtonSize.medium,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final ButtonVariant variant;
  final ButtonSize size;

  @override
  State<InteractiveButton> createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<InteractiveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 2, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPointerDown() {
    _animationController.forward();
  }

  void _onPointerUp() {
    _animationController.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkVariant = widget.variant == ButtonVariant.filled;
    final padding = _getPadding();

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _onPointerDown(),
        onTapUp: (_) => _onPointerUp(),
        onTapCancel: () => _animationController.reverse(),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedBuilder(
              animation: _elevationAnimation,
              builder: (context, child) => Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: isDarkVariant ? SigadColors.brand : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: isDarkVariant
                      ? null
                      : Border.all(color: SigadColors.divider, width: 1.5),
                  boxShadow: isDarkVariant
                      ? [
                          BoxShadow(
                            color: SigadColors.brand.withValues(alpha: 0.3),
                            blurRadius: _elevationAnimation.value * 8,
                            offset: Offset(0, _elevationAnimation.value),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: _getIconSize(),
                        color: isDarkVariant ? Colors.white : SigadColors.brand,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isDarkVariant ? Colors.white : SigadColors.brand,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }
}

enum ButtonVariant { filled, outlined }

enum ButtonSize { small, medium, large }
