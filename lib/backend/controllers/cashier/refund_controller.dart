import 'dart:convert';
import 'package:erp_software/backend/services/cashier/refund_service.dart';
import 'package:erp_software/backend/services/jwt_service.dart';
import 'package:erp_software/core/errors/app_exception.dart';
import 'package:erp_software/backend/utils/response_utils.dart';
import 'package:shelf/shelf.dart';

class RefundController {
  final RefundService refundService;

  RefundController(this.refundService);

  Future<Response> createRefund(Request request) async {
    try {
      final bodyStr = await request.readAsString();
      if (bodyStr.isEmpty) {
        return ResponseUtils.error(message: 'Request body cannot be empty', statusCode: 400);
      }

      final body = jsonDecode(bodyStr) as Map<String, dynamic>;
      final user = request.context['user'] as JwtPayload?;
      final processedBy = user?.userId ?? body['processedBy'] ?? 1;

      final orderId = body['orderId'] != null ? int.tryParse(body['orderId'].toString()) : null;
      if (orderId == null) {
        return ResponseUtils.error(message: 'orderId is required', statusCode: 400);
      }

      final itemsToRefund = (body['items'] as List? ?? []).cast<Map<String, dynamic>>();

      final refund = await refundService.createRefund(
        orderId: orderId,
        processedBy: processedBy,
        refundMethod: body['refundMethod']?.toString() ?? 'Cash',
        reason: body['reason']?.toString(),
        itemsToRefund: itemsToRefund,
      );

      return ResponseUtils.success(
        message: 'Refund ${refund.refundNumber} processed successfully and inventory restored!',
        data: refund.toJson(),
      );
    } on ApiException catch (e) {
      return ResponseUtils.error(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to process refund: $e', statusCode: 500, error: e);
    }
  }

  Future<Response> getRefunds(Request request) async {
    try {
      final refunds = await refundService.getAllRefunds();
      return ResponseUtils.success(
        message: 'Refunds fetched successfully',
        data: refunds.map((r) => r.toJson()).toList(),
      );
    } on ApiException catch (e) {
      return ResponseUtils.error(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to fetch refunds', statusCode: 500, error: e);
    }
  }

  Future<Response> getRefundById(Request request, String idStr) async {
    try {
      final id = int.tryParse(idStr);
      if (id == null) {
        return ResponseUtils.error(message: 'Invalid refund ID', statusCode: 400);
      }

      final refund = await refundService.getRefundById(id);
      return ResponseUtils.success(
        message: 'Refund details fetched',
        data: refund.toJson(),
      );
    } on ApiException catch (e) {
      return ResponseUtils.error(message: e.message, statusCode: e.statusCode);
    } catch (e) {
      return ResponseUtils.error(message: 'Failed to fetch refund details', statusCode: 500, error: e);
    }
  }
}

