import 'package:flutter/foundation.dart';

import 'package:erp_software/core/errors/app_exception.dart';
import 'package:erp_software/core/models/branch_model.dart';
import '../../branch/services/branch_api_service.dart';
import 'package:erp_software/core/models/manager_model.dart';
import '../services/manager_api_service.dart';

enum ManagerSort { defaultOrder, nameAZ, nameZA, newest, oldest }

class ManagerProvider extends ChangeNotifier {
  final ManagerApiService _api;
  final BranchApiService _branchApi;

  ManagerProvider({ManagerApiService? api, BranchApiService? branchApi})
      : _api = api ?? ManagerApiService(),
        _branchApi = branchApi ?? BranchApiService();

  List<ManagerModel> _managers = [];
  List<BranchModel> branchOptions = [];

  bool isLoading = false;
  bool isMutating = false;
  String? errorMessage;
  String searchQuery = '';
  ManagerSort sortOption = ManagerSort.defaultOrder;

  List<ManagerModel> get managers {
    var list = _managers.where((m) {
      if (searchQuery.trim().isEmpty) return true;
      final q = searchQuery.toLowerCase();
      return m.fullName.toLowerCase().contains(q) ||
          m.employeeId.toLowerCase().contains(q) ||
          m.email.toLowerCase().contains(q) ||
          m.phone.contains(q) ||
          (m.branchName?.toLowerCase().contains(q) ?? false);
    }).toList();

    switch (sortOption) {
      case ManagerSort.nameAZ:
        list.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
        break;
      case ManagerSort.nameZA:
        list.sort((a, b) => b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase()));
        break;
      case ManagerSort.newest:
        list.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
        break;
      case ManagerSort.oldest:
        list.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
        break;
      case ManagerSort.defaultOrder:
        break;
    }

    return list;
  }

  Future<void> init() async {
    await Future.wait([fetchManagers(), loadBranchOptions()]);
  }

  Future<void> loadBranchOptions() async {
    try {
      branchOptions = await _branchApi.getBranches();
      notifyListeners();
    } catch (_) {
      // Non-critical for the list view — the form dialog will just show no branches.
    }
  }

  Future<void> fetchManagers() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _managers = await _api.getManagers();
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Failed to load managers';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createManager(ManagerModel manager, String password) => _mutate(() async {
        final created = await _api.createManager(manager, password);
        _managers.insert(0, created);
      });

  Future<bool> updateManager(int id, ManagerModel manager, {String password = ''}) =>
      _mutate(() async {
        final updated = await _api.updateManager(id, manager, password: password);
        final index = _managers.indexWhere((m) => m.id == id);
        if (index != -1) _managers[index] = updated;
      });

  Future<bool> deleteManager(int id) => _mutate(() async {
        await _api.deleteManager(id);
        _managers.removeWhere((m) => m.id == id);
      });

  Future<bool> _mutate(Future<void> Function() action) async {
    isMutating = true;
    errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (e) {
      errorMessage = 'Something went wrong';
      return false;
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void setSort(ManagerSort value) {
    sortOption = value;
    notifyListeners();
  }
}
