import 'dart:convert';

import 'package:shelf/shelf.dart';

import 'package:erp_software/core/models/branch_model.dart';
import 'package:erp_software/backend/admin/branch/services/branch_service.dart';

class BranchController {
  final BranchService service;

  BranchController(this.service);

  // ============================================================
  // POST /admin/branches
  // CREATE BRANCH
  // ============================================================

  Future<Response> createBranch(Request request) async {
    try {
      final body = await request.readAsString();

      if (body.trim().isEmpty) {
        return _badRequest('Request body cannot be empty');
      }

      final decoded = jsonDecode(body);

      if (decoded is! Map<String, dynamic>) {
        return _badRequest('Invalid request body');
      }

      final requiredFields = [
        'code',
        'name',
        'address',
        'city',
        'state',
        'phone',
        'email',
      ];

      for (final field in requiredFields) {
        final value = decoded[field];

        if (value == null || value.toString().trim().isEmpty) {
          return _badRequest('$field is required');
        }
      }

      final branch = BranchModel.fromMap(decoded);

      final createdBranch = await service.createBranch(branch);

      return _success(
        statusCode: 201,
        message: 'Branch created successfully',
        data: createdBranch.toJson(),
      );
    } catch (e) {
      return _serverError(
        'Failed to create branch',
        e,
      );
    }
  }

  // ============================================================
  // GET /admin/branches
  // GET ALL BRANCHES
  // ============================================================

  Future<Response> getBranches(Request request) async {
    try {
      final branches = await service.getBranches();

      return _success(
        message: 'Branches fetched successfully',
        data: branches.map((branch) => branch.toJson()).toList(),
      );
    } catch (e) {
      return _serverError(
        'Failed to fetch branches',
        e,
      );
    }
  }

  // ============================================================
  // GET /admin/branches/<id>
  // GET BRANCH BY ID
  // ============================================================

  Future<Response> getBranchById(
    Request request,
    String id,
  ) async {
    try {
      final branchId = int.tryParse(id);

      if (branchId == null) {
        return _badRequest('Invalid branch ID');
      }

      final branch = await service.getBranchById(branchId);

      if (branch == null) {
        return _notFound('Branch not found');
      }

      return _success(
        message: 'Branch fetched successfully',
        data: branch.toJson(),
      );
    } catch (e) {
      return _serverError(
        'Failed to fetch branch',
        e,
      );
    }
  }

  // ============================================================
  // PUT /admin/branches/<id>
  // UPDATE BRANCH
  // ============================================================

  Future<Response> updateBranch(
    Request request,
    String id,
  ) async {
    try {
      final branchId = int.tryParse(id);

      if (branchId == null) {
        return _badRequest('Invalid branch ID');
      }

      final body = await request.readAsString();

      if (body.trim().isEmpty) {
        return _badRequest('Request body cannot be empty');
      }

      final decoded = jsonDecode(body);

      if (decoded is! Map<String, dynamic>) {
        return _badRequest('Invalid request body');
      }

      final requiredFields = [
        'code',
        'name',
        'address',
        'city',
        'state',
        'phone',
        'email',
      ];

      for (final field in requiredFields) {
        final value = decoded[field];

        if (value == null || value.toString().trim().isEmpty) {
          return _badRequest('$field is required');
        }
      }

      final branch = BranchModel.fromMap({
        ...decoded,
        'id': branchId,
      });

      final updatedBranch = await service.updateBranch(
        branchId,
        branch,
      );

      if (updatedBranch == null) {
        return _notFound('Branch not found');
      }

      return _success(
        message: 'Branch updated successfully',
        data: updatedBranch.toJson(),
      );
    } catch (e) {
      return _serverError(
        'Failed to update branch',
        e,
      );
    }
  }

  // ============================================================
  // DELETE /admin/branches/<id>
  // DELETE BRANCH
  // ============================================================

  Future<Response> deleteBranch(
    Request request,
    String id,
  ) async {
    try {
      final branchId = int.tryParse(id);

      if (branchId == null) {
        return _badRequest('Invalid branch ID');
      }

      final deleted = await service.deleteBranch(branchId);

      if (!deleted) {
        return _notFound('Branch not found');
      }

      return _success(
        message: 'Branch deleted successfully',
      );
    } catch (e) {
      return _serverError(
        'Failed to delete branch',
        e,
      );
    }
  }

  // ============================================================
  // SUCCESS RESPONSE
  // ============================================================

  Response _success({
    int statusCode = 200,
    required String message,
    dynamic data,
  }) {
    final response = <String, dynamic>{
      'success': true,
      'message': message,
    };

    if (data != null) {
      response['data'] = data;
    }

    return Response(
      statusCode,
      body: jsonEncode(response),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  // ============================================================
  // BAD REQUEST
  // ============================================================

  Response _badRequest(String message) {
    return Response(
      400,
      body: jsonEncode({
        'success': false,
        'message': message,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  // ============================================================
  // NOT FOUND
  // ============================================================

  Response _notFound(String message) {
    return Response(
      404,
      body: jsonEncode({
        'success': false,
        'message': message,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  // ============================================================
  // SERVER ERROR
  // ============================================================

  Response _serverError(
    String message,
    Object error,
  ) {
    return Response(
      500,
      body: jsonEncode({
        'success': false,
        'message': message,
        'error': error.toString(),
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }
}