import 'package:eventhub/core/constants/api_constants.dart';
import 'package:eventhub/core/network/api_client.dart';

abstract class PaymentRemoteDataSource {
  Future<Map<String, dynamic>> createPaymentIntent(
      double amount, String currency);
  Future<Map<String, dynamic>> confirmPayment(String paymentIntentId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClient apiClient;
  PaymentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> createPaymentIntent(
      double amount, String currency) async {
    final response =
        await apiClient.post(ApiConstants.payments, data: {
      'amount': amount,
      'currency': currency,
    });
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> confirmPayment(String paymentIntentId) async {
    final response = await apiClient.post(
      '${ApiConstants.payments}/confirm',
      data: {'paymentIntentId': paymentIntentId},
    );
    return response.data as Map<String, dynamic>;
  }
}
