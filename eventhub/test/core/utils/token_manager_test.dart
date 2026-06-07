import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/core/utils/token_manager.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockFlutterSecureStorage mockStorage;
  late TokenManager tokenManager;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    tokenManager = TokenManager(storage: mockStorage);
  });

  group('TokenManager', () {
    test('saveToken writes to storage', () async {
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async => {});

      await tokenManager.saveToken('test-token');

      verify(() => mockStorage.write(key: 'jwt_token', value: 'test-token')).called(1);
    });

    test('getToken reads from storage', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'test-token');

      final token = await tokenManager.getToken();

      expect(token, 'test-token');
      verify(() => mockStorage.read(key: 'jwt_token')).called(1);
    });

    test('getToken returns null when no token', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      final token = await tokenManager.getToken();

      expect(token, isNull);
    });

    test('clearTokens deletes all tokens', () async {
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async => {});

      await tokenManager.clearTokens();

      verify(() => mockStorage.delete(key: 'jwt_token')).called(1);
      verify(() => mockStorage.delete(key: 'refresh_token')).called(1);
    });
  });
}
