import 'package:erp_software/core/models/cashier/refund_model.dart';
import 'package:erp_software/backend/repositories/cashier/refund_repository.dart';
import 'package:erp_software/core/errors/app_exception.dart';

class RefundService {
  final RefundRepository refundRepository;

  RefundService(this.refundRepository);

  Future<RefundModel> createRefund({
    required int orderId,
    required int processedBy,
    required String refundMethod,
    String? reason,
    required List<Map<String, dynamic>> itemsToRefund,
  }) async {
    if (itemsToRefund.isEmpty) {
      throw ApiException('At least one order item must be selected for refund', statusCode: 400);
    }

    return await refundRepository.createRefundInTx(
      orderId: orderId,
      processedBy: processedBy,
      refundMethod: refundMethod,
      reason: reason,
      itemsToRefund: itemsToRefund,
    );
  }

  Future<List<RefundModel>> getAllRefunds() async {
    return await refundRepository.getAllRefunds();
  }

  Future<RefundModel> getRefundById(int id) async {
    final refund = await refundRepository.findById(id);
    if (refund == null) {
      throw ApiException('Refund #$id not found', statusCode: 404);
    }
    return refund;
  }
}

