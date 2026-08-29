import 'package:flutter/foundation.dart';

import 'package:erp_software/core/errors/app_exception.dart';
import 'package:erp_software/core/models/audit_log_model.dart';
import 'package:erp_software/core/models/audit_stats_model.dart';
import 'package:erp_software/core/models/employee_timeline_model.dart';
import '../services/audit_log_api_service.dart';

class AuditLogProvider extends ChangeNotifier {
  final AuditLogApiService _api;

  AuditLogProvider({AuditLogApiService? api}) : _api = api ?? AuditLogApiService();

  // ---- list state ----
  AuditStatsModel stats = AuditStatsModel.empty();
  List<AuditLogModel> logs = [];
  bool isLoading = false;
  String? errorMessage;

  // ---- filters ----
  String search = '';
  String selectedAction = 'All Actions';
  String selectedModule = 'All Modules';

  static const actionOptions = ['All Actions', 'LOGIN', 'LOGOUT', 'CREATE', 'UPDATE', 'DELETE'];
  static const moduleOptions = [
    'All Modules',
    'Employee',
    'Branch',
    'Manager',
    'Reports',
    'Auth',
    'Settings'
  ];

  // ---- timeline state ----
  EmployeeTimelinePage? timeline;
  bool isTimelineLoading = false;
  String? timelineError;

  Future<void> fetchLogs() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.getLogs(
        search: search,
        action: selectedAction,
        module: selectedModule,
      );
      stats = result.stats;
      logs = result.logs;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Failed to load audit logs';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSearch(String value) {
    search = value;
    fetchLogs();
  }

  void setAction(String value) {
    selectedAction = value;
    fetchLogs();
  }

  void setModule(String value) {
    selectedModule = value;
    fetchLogs();
  }

  void resetFilters() {
    search = '';
    selectedAction = 'All Actions';
    selectedModule = 'All Modules';
    fetchLogs();
  }

  Future<void> fetchEmployeeTimeline(int employeeDbId) async {
    isTimelineLoading = true;
    timelineError = null;
    timeline = null;
    notifyListeners();

    try {
      timeline = await _api.getEmployeeTimeline(employeeDbId);
    } on ApiException catch (e) {
      timelineError = e.message;
    } catch (e) {
      timelineError = 'Failed to load employee timeline';
    } finally {
      isTimelineLoading = false;
      notifyListeners();
    }
  }

  void clearTimeline() {
    timeline = null;
    timelineError = null;
  }
}
