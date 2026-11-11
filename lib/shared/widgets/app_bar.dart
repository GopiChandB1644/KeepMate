import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/app_colors.dart';
import '../../core/design_system/app_text.dart';

/// Clean circular icon button matching movonride_driver design.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  final Color? iconColor;
  final String? tooltip;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 40,
    this.color,
    this.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color ?? AppColors.surfaceRaised,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.8)),
          ),
          child: Icon(
            icon,
            size: size * 0.5,
            color: iconColor ?? AppColors.textPrimary,
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return Semantics(
      button: true,
      label: tooltip,
      child: button,
    );
  }
}

/// Custom AppBar that integrates seamlessly with the KeepRemind app flow and structure.
/// Clean, basic, and distraction-free with round action/back buttons.
class KeepRemindAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final bool? showBack;
  final Widget? leading;
  final bool transparent;
  final Color? backgroundColor;
  final bool centerTitle;

  const KeepRemindAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.actions = const [],
    this.onBack,
    this.showBack,
    this.leading,
    this.transparent = false,
    this.backgroundColor,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) {
    bool canPop = false;
    try {
      canPop = Navigator.canPop(context);
    } catch (_) {}
    final shouldShowBack = showBack ?? canPop;

    return Container(
      decoration: BoxDecoration(
        color: transparent
            ? Colors.transparent
            : (backgroundColor ?? AppColors.surface),
        border: transparent
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.cardBorder.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 62,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 12),
                ] else if (shouldShowBack) ...[
                  CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onTap: onBack ?? () {
                      try {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          context.pop();
                        }
                      } catch (_) {
                        try {
                          context.pop();
                        } catch (_) {}
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: centerTitle
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.h3.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bodySmall.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (actions.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  ...actions,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Backward-compatibility alias
typedef KeepMateAppBar = KeepRemindAppBar;
