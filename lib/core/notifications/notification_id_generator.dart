class NotificationIdGenerator {
  NotificationIdGenerator._();

  /// Deterministically generate a 31-bit integer notification ID from itemId and offsetDays
  static int generate(String itemId, int offsetDays) {
    var hash = 0;
    final combined = '$itemId:$offsetDays';
    for (var i = 0; i < combined.length; i++) {
      hash = (31 * hash + combined.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash;
  }
}

