import 'package:erp_software/core/models/branch_model.dart';
import 'package:erp_software/backend/admin/branch/repositories/branch_repository.dart';

class BranchService {
  final BranchRepository repository;

  BranchService(this.repository);

  // ============================================================
  // CREATE BRANCH
  // ============================================================

  Future<BranchModel> createBranch(BranchModel branch) async {
    final data = await repository.createBranch(
      {
        'code': branch.code,
        'name': branch.name,
        'address': branch.address,
        'city': branch.city,
        'state': branch.state,
        'phone': branch.phone,
        'email': branch.email,
        'is_active': branch.isActive,
      },
    );

    return BranchModel.fromMap(data);
  }

  // ============================================================
  // GET ALL BRANCHES
  // ============================================================

  Future<List<BranchModel>> getBranches() async {
    final data = await repository.getBranches();

    return data
        .map((branch) => BranchModel.fromMap(branch))
        .toList();
  }

  // ============================================================
  // GET BRANCH BY ID
  // ============================================================

  Future<BranchModel?> getBranchById(int id) async {
    final data = await repository.getBranchById(id);

    if (data == null) {
      return null;
    }

    return BranchModel.fromMap(data);
  }

  // ============================================================
  // UPDATE BRANCH
  // ============================================================

  Future<BranchModel?> updateBranch(
    int id,
    BranchModel branch,
  ) async {
    final data = await repository.updateBranch(
      id,
      {
        'code': branch.code,
        'name': branch.name,
        'address': branch.address,
        'city': branch.city,
        'state': branch.state,
        'phone': branch.phone,
        'email': branch.email,
        'is_active': branch.isActive,
      },
    );

    if (data == null) {
      return null;
    }

    return BranchModel.fromMap(data);
  }

  // ============================================================
  // DELETE BRANCH
  // ============================================================

  Future<bool> deleteBranch(int id) async {
    return repository.deleteBranch(id);
  }
}