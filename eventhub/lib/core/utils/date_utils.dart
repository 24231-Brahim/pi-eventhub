import 'package:intl/intl.dart';

class DateUtils {
  DateUtils._();

  static String format(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  static String formatWithTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}min ago';
    return 'just now';
  }

  static String toISO(DateTime date) => date.toIso8601String();

  static DateTime fromISO(String iso) => DateTime.parse(iso);

  static String formatFriendly(DateTime date) {
    return '${DateFormat('MMM d, yyyy').format(date)} at ${DateFormat('HH:mm').format(date)}';
  }

  static String formatFriendlyFromIso(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return iso;
    return formatFriendly(date);
  }
}
