import 'package:flutter/material.dart';
import 'dart:ui';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final resolvedBackground =
        backgroundColor ?? colors.surface.withOpacity(isDark ? 0.82 : 0.55);
    final borderColor = isDark
        ? colors.outlineVariant.withOpacity(0.35)
        : Colors.white.withValues(alpha: 0.35);
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.45)
        : Colors.black.withValues(alpha: 0.07);
    final backgroundBrightness =
        ThemeData.estimateBrightnessForColor(resolvedBackground);
    final needsContrastBoost =
        theme.brightness == Brightness.dark && backgroundBrightness == Brightness.light;
    final contrastedTextColor = needsContrastBoost
        ? Colors.black87
        : theme.textTheme.bodyMedium?.color ?? colors.onSurface;
    ThemeData? contrastTheme;
    Widget? contrastWrappedChild;
    if (needsContrastBoost) {
      final adjustedTextTheme = theme.textTheme.apply(
        bodyColor: contrastedTextColor,
        displayColor: contrastedTextColor,
      );
      contrastTheme = theme.copyWith(
        textTheme: adjustedTextTheme,
        primaryTextTheme: adjustedTextTheme,
      );
      contrastWrappedChild = Theme(
        data: contrastTheme,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: contrastedTextColor),
          child: child,
        ),
      );
    }

    final Widget resolvedChild = contrastWrappedChild ?? child;

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: resolvedBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: resolvedChild,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color? trendColor;
  final String? trend;

  const AnimatedStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.trendColor,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final onSurfaceVariant = colors.onSurfaceVariant;
    final resolvedTrendColor = trendColor ?? colors.primary;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: 0.8 + (animation * 0.2),
          child: Opacity(opacity: animation, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.08), color.withOpacity(0.02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (trend != null)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        trend!,
                        overflow: TextOverflow.visible,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: (Theme.of(context).textTheme.headlineMedium ??
                      const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ))
                  .copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
