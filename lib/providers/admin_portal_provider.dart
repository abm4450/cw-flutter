import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_item.dart';
import '../models/member_row.dart';
import '../providers/auth_provider.dart';
import '../services/admin_service.dart';

class AdminPortalState {
  final AdminStats stats;
  final List<MemberRow> members;
  final List<ActivityItem> activity;
  final bool loading;

  const AdminPortalState({
    this.stats = const AdminStats(membersCount: 0, giftsReady: 0),
    this.members = const [],
    this.activity = const [],
    this.loading = true,
  });

  AdminPortalState copyWith({
    AdminStats? stats,
    List<MemberRow>? members,
    List<ActivityItem>? activity,
    bool? loading,
  }) =>
      AdminPortalState(
        stats: stats ?? this.stats,
        members: members ?? this.members,
        activity: activity ?? this.activity,
        loading: loading ?? this.loading,
      );
}

class AdminPortalNotifier extends StateNotifier<AdminPortalState> {
  final Ref _ref;
  Timer? _pollTimer;
  bool _scannerActive = false;

  AdminPortalNotifier(this._ref) : super(const AdminPortalState()) {
    _loadData();
    _startPolling();
  }

  AdminService get _adminService =>
      AdminService(_ref.read(apiClientProvider));

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _adminService.getStats(),
        _adminService.getMembers(),
        _adminService.getActivity(),
      ]);
      state = AdminPortalState(
        stats: results[0] as AdminStats,
        members: results[1] as List<MemberRow>,
        activity: results[2] as List<ActivityItem>,
        loading: false,
      );
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_scannerActive) _loadData();
    });
  }

  void setScannerActive(bool active) {
    _scannerActive = active;
  }

  Future<void> reload() => _loadData();

  Future<ScanResult> scanBarcode(String barcode) async {
    return _adminService.scanBarcode(barcode);
  }

  Future<void> useFreeWash(String barcode) async {
    await _adminService.useFreeWash(barcode);
  }

  Future<Map<String, dynamic>> undoWash(String barcode) async {
    return _adminService.undoWash(barcode);
  }

  Future<void> updateMember(
    String id, {
    required String fullName,
    required String phone,
    String? plateNumber,
  }) async {
    await _adminService.updateMember(id,
        fullName: fullName, phone: phone, plateNumber: plateNumber);
    await _loadData();
  }

  Future<void> deleteMember(String id) async {
    await _adminService.deleteMember(id);
    await _loadData();
  }

  Future<void> clearActivity() async {
    await _adminService.clearActivity();
    await _loadData();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final adminPortalProvider =
    StateNotifierProvider.autoDispose<AdminPortalNotifier, AdminPortalState>(
  (ref) => AdminPortalNotifier(ref),
);

final adminServiceProvider = Provider(
  (ref) => AdminService(ref.read(apiClientProvider)),
);
