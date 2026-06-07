import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('returns null for valid email', () {
        expect(Validators.email('test@example.com'), isNull);
        expect(Validators.email('user+tag@domain.co'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.email(null), isNotEmpty);
        expect(Validators.email(''), isNotEmpty);
      });

      test('returns error for invalid email', () {
        expect(Validators.email('not-an-email'), isNotEmpty);
        expect(Validators.email('@domain.com'), isNotEmpty);
        expect(Validators.email('user@'), isNotEmpty);
      });
    });

    group('password', () {
      test('returns null for valid password', () {
        expect(Validators.password('ValidPass1'), isNull);
        expect(Validators.password('Abcdefg1'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.password(null), isNotEmpty);
        expect(Validators.password(''), isNotEmpty);
      });

      test('returns error for short password', () {
        expect(Validators.password('Ab1'), isNotEmpty);
      });

      test('returns error without uppercase', () {
        expect(Validators.password('abcdefg1'), isNotEmpty);
      });

      test('returns error without number', () {
        expect(Validators.password('Abcdefgh'), isNotEmpty);
      });
    });

    group('name', () {
      test('returns null for valid name', () {
        expect(Validators.name('John'), isNull);
        expect(Validators.name('Alice Smith'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.name(null), isNotEmpty);
        expect(Validators.name(''), isNotEmpty);
      });

      test('returns error for too short name', () {
        expect(Validators.name('A'), isNotEmpty);
      });
    });

    group('phone', () {
      test('returns null for valid phone', () {
        expect(Validators.phone('+21612345678'), isNull);
        expect(Validators.phone('123456789'), isNull);
      });

      test('returns null for null or empty (optional)', () {
        expect(Validators.phone(null), isNull);
        expect(Validators.phone(''), isNull);
      });

      test('returns error for invalid phone', () => expect(Validators.phone('abc'), isNotEmpty));
    });

    group('required', () {
      test('returns null for non-empty', () {
        expect(Validators.required('value'), isNull);
      });

      test('returns error for empty', () {
        expect(Validators.required(''), isNotEmpty);
        expect(Validators.required('  '), isNotEmpty);
      });
    });
  });
}
