import 'package:dio/dio.dart';
import '../services/api_client.dart';

class OrdersService {
  OrdersService._();
  static final OrdersService instance = OrdersService._();

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final Response response = await ApiClient().get('/orders');
    final data = response.data;
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      error: 'Invalid orders data format',
      type: DioExceptionType.badResponse,
    );
  }

  List<String> extractStatuses(List<Map<String, dynamic>> orders) {
    final statuses = orders.map((order) {
      final status = order['status'];
      if (status is Map) {
        return (status['name'] ?? status['id'] ?? order['status_id'] ?? 'Unknown').toString();
      }
      return (order['status_id'] ?? 'Unknown').toString();
    }).toSet();
    return statuses.cast<String>().toList();
  }

  List<Map<String, dynamic>> filterByStatus(
    List<Map<String, dynamic>> orders,
    String selectedStatus,
  ) {
    if (selectedStatus == 'all') return List.of(orders);
    return orders.where((order) {
      final status = order['status'];
      final name = (status is Map ? status['name'] : null)?.toString();
      final idFromStatus = (status is Map ? status['id'] : null)?.toString();
      final id = order['status_id']?.toString();
      if (idFromStatus == selectedStatus) return true;
      if (id == selectedStatus) return true;
      if (name != null && name.toLowerCase() == selectedStatus.toLowerCase()) return true;
      return false;
    }).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  String classifyStatusColor(String? statusRaw) {
    final statusLower = (statusRaw ?? '').toLowerCase().trim();
    if (statusLower.contains('pending') || statusLower.contains('processing') || statusLower == 'awaiting') {
      return 'yellow';
    }
    if (statusLower.contains('ship') || statusLower.contains('deliver') || statusLower == 'completed' || statusLower == 'done') {
      return 'green';
    }
    if (statusLower.contains('cancel') || statusLower.contains('fail') || statusLower.contains('reject') || statusLower.contains('return')) {
      return 'red';
    }
    return 'gray';
  }
}


