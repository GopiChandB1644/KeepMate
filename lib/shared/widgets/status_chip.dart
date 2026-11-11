import 'package:flutter/material.dart';
import '../../core/enums/item_enums.dart';

class StatusChip extends StatelessWidget {
  final ItemStatus status;
  final String? customLabel;

  const StatusChip({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case ItemStatus.active:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        break;
      case ItemStatus.upcoming:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case ItemStatus.dueToday:
      case ItemStatus.expired:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        break;
      case ItemStatus.completed:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0369A1);
        break;
      case ItemStatus.consumed:
      case ItemStatus.discarded:
      case ItemStatus.archived:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            customLabel ?? status.label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

