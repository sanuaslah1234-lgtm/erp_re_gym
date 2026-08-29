import 'package:erp_software/core/models/manager_model.dart';
import '../repositories/manager_repository.dart';

class ManagerValidationException implements Exception {
  final String message;
  ManagerValidationException(this.message);
}

class ManagerService {
  final ManagerRepository repository;

  ManagerService(this.repository);

  void _validate(Map<String, dynamic> data, {required bool isCreate}) {
    final fullName = (data['full_name'] as String?)?.trim() ?? '';
    final email = (data['email'] as String?)?.trim() ?? '';
    final phone = (data['phone'] as String?)?.trim() ?? '';
    final password = (data['password'] as String?)?.trim() ?? '';

    if (fullName.isEmpty) throw ManagerValidationException('Full name is required');
    if (email.isEmpty) throw ManagerValidationException('Email is required');
    if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      throw ManagerValidationException('Enter a valid email');
    }
    if (phone.isEmpty) throw ManagerValidationException('Phone is required');

    if (isCreate && password.length < 6) {
      throw ManagerValidationException('Password must be at least 6 characters');
    }
    if (!isCreate && password.isNotEmpty && password.length < 6) {
      throw ManagerValidationException('New password must be at least 6 characters');
    }
  }

  Future<ManagerModel> createManager(Map<String, dynamic> data) async {
    _validate(data, isCreate: true);
    final row = await repository.createManager(data);
    return ManagerModel.fromMap(row);
  }

  Future<List<ManagerModel>> getManagers() async {
    final rows = await repository.getManagers();
    return rows.map((r) => ManagerModel.fromMap(r)).toList();
  }

  Future<ManagerModel?> getManagerById(int id) async {
    final row = await repository.getManagerById(id);
    return row == null ? null : ManagerModel.fromMap(row);
  }

  Future<ManagerModel?> updateManager(int id, Map<String, dynamic> data) async {
    _validate(data, isCreate: false);
    final row = await repository.updateManager(id, data);
    return row == null ? null : ManagerModel.fromMap(row);
  }

  Future<bool> deleteManager(int id) {
    return repository.deleteManager(id);
  }
}