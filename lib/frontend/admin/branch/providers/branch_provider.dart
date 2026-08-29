import 'package:flutter/foundation.dart';

import 'package:erp_software/core/errors/app_exception.dart';
import 'package:erp_software/core/models/branch_model.dart';
import '../services/branch_api_service.dart';

enum BranchSort { defaultOrder, nameAZ, nameZA, newest, oldest }

class BranchProvider extends ChangeNotifier {
  final BranchApiService _api;

  BranchProvider({BranchApiService? api}) : _api = api ?? BranchApiService();

  List<BranchModel> _branches = [];
  bool isLoading = false;
  bool isMutating = false; // create/update/delete in-flight
  String? errorMessage;
  String searchQuery = '';
  BranchSort sortOption = BranchSort.defaultOrder;

  List<BranchModel> get branches {
    var list = _branches.where((b) {
      if (searchQuery.trim().isEmpty) return true;
      final q = searchQuery.toLowerCase();
      return b.code.toLowerCase().contains(q) ||
          b.name.toLowerCase().contains(q) ||
          b.city.toLowerCase().contains(q) ||
          b.state.toLowerCase().contains(q) ||
          b.email.toLowerCase().contains(q) ||
          b.phone.contains(q);
    }).toList();

    switch (sortOption) {
      case BranchSort.nameAZ:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case BranchSort.nameZA:
        list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case BranchSort.newest:
        list.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
        break;
      case BranchSort.oldest:
        list.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
        break;
      case BranchSort.defaultOrder:
        break;
    }

    return list;
  }

  Future<void> fetchBranches() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _branches = await _api.getBranches();
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Failed to load branches';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBranch(BranchModel branch) => _mutate(() async {
        final created = await _api.createBranch(branch);
        _branches.insert(0, created);
      });

  Future<bool> updateBranch(int id, BranchModel branch) => _mutate(() async {
        final updated = await _api.updateBranch(id, branch);
        final index = _branches.indexWhere((b) => b.id == id);
        if (index != -1) _branches[index] = updated;
      });

  Future<bool> deleteBranch(int id) => _mutate(() async {
        await _api.deleteBranch(id);
        _branches.removeWhere((b) => b.id == id);
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
      errorMessage = 'Something went wrong: $e';
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

  void setSort(BranchSort value) {
    sortOption = value;
    notifyListeners();
  }
}
