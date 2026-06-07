import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/core/utils/date_utils.dart' as date_utils;

void main() {
  group('DateUtils', () {
    final testDate = DateTime(2026, 6, 7, 14, 30);

    test('format returns correct pattern', () {
      expect(date_utils.DateUtils.format(testDate), '07/06/2026');
      expect(
        date_utils.DateUtils.format(testDate, pattern: 'yyyy-MM-dd'),
        '2026-06-07',
      );
    });

    test('formatWithTime includes time', () {
      expect(
        date_utils.DateUtils.formatWithTime(testDate),
        '07/06/2026 14:30',
      );
    });

    test('timeAgo returns relative time', () {
      expect(
        date_utils.DateUtils.timeAgo(DateTime.now().subtract(const Duration(hours: 2))),
        '2h ago',
      );
      expect(
        date_utils.DateUtils.timeAgo(DateTime.now().subtract(const Duration(days: 3))),
        '3d ago',
      );
      expect(
        date_utils.DateUtils.timeAgo(DateTime.now().subtract(const Duration(minutes: 5))),
        '5min ago',
      );
      expect(date_utils.DateUtils.timeAgo(DateTime.now()), 'just now');
    });

    test('toISO and fromISO are reversible', () {
      final iso = date_utils.DateUtils.toISO(testDate);
      final parsed = date_utils.DateUtils.fromISO(iso);
      expect(parsed, testDate);
    });
  });
}
