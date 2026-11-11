import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text.dart';

OverlayEntry? _activeToast;

enum ToastType {
  success,
  error,
  warning,
  info,
}

/// Floating top toast message matching movonride_driver ergonomics.
/// Slides down smoothly from the top of the screen beneath the status bar.
void showToast(
  BuildContext context,
  String message, {
  IconData? icon,
  Color? color,
  ToastType type = ToastType.success,
  Duration duration = const Duration(milliseconds: 3200),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true) ?? Overlay.maybeOf(context);
  if (overlay == null) return;

  // Remove any currently showing toast cleanly
  if (_activeToast != null) {
    try {
      _activeToast?.remove();
    } catch (_) {}
    _activeToast = null;
  }

  IconData resolvedIcon = icon ?? Icons.check_circle_rounded;
  Color resolvedColor = color ?? AppColors.safeGreen;

  switch (type) {
    case ToastType.success:
      resolvedIcon = icon ?? Icons.check_circle_rounded;
      resolvedColor = color ?? AppColors.safeGreen;
      break;
    case ToastType.error:
      resolvedIcon = icon ?? Icons.error_rounded;
      resolvedColor = color ?? AppColors.dangerRed;
      break;
    case ToastType.warning:
      resolvedIcon = icon ?? Icons.warning_amber_rounded;
      resolvedColor = color ?? AppColors.warningOrange;
      break;
    case ToastType.info:
      resolvedIcon = icon ?? Icons.info_outline_rounded;
      resolvedColor = color ?? AppColors.primary;
      break;
  }

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _TopToastWidget(
      message: message,
      icon: resolvedIcon,
      color: resolvedColor,
      duration: duration,
      onDismiss: () {
        if (entry.mounted) {
          try {
            entry.remove();
          } catch (_) {}
        }
        if (_activeToast == entry) {
          _activeToast = null;
        }
      },
    ),
  );

  _activeToast = entry;
  overlay.insert(entry);
}

class _TopToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;
  final Duration duration;
  final VoidCallback onDismiss;

  const _TopToastWidget({
    required this.message,
    required this.icon,
    required this.color,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<_TopToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  Timer? _dismissTimer;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -0.65),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _controller.forward();

    _dismissTimer = Timer(widget.duration, () {
      if (mounted) _dismiss();
    });
  }

  void _dismiss() async {
    if (_dismissed || !mounted) return;
    _dismissed = true;
    _dismissTimer?.cancel();
    try {
      await _controller.reverse();
    } catch (_) {}
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: topPadding > 0 ? topPadding + 8 : 16,
      left: 16,
      right: 16,
      child: Material(
        type: MaterialType.transparency,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: GestureDetector(
              onTap: _dismiss,
              onVerticalDragUpdate: (details) {
                if ((details.primaryDelta ?? 0) < -3) {
                  _dismiss();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: widget.color.withValues(alpha: 0.3), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: AppText.label.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textMuted,
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
}
