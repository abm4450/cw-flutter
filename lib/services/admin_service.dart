import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/activity_item.dart';
import '../models/member_row.dart';
import '../models/scanned_customer.dart';

class AdminStats {
  final int membersCount;
  final int giftsReady;

  const AdminStats({required this.membersCount, required this.giftsReady});

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
        membersCount: json['membersCount'] as int? ?? 0,
        giftsReady: json['giftsReady'] as int? ?? 0,
      );
}

class ScanResult {
  final bool success;
  final String washType;
  final Map<String, dynamic> customer;
  final Map<String, dynamic> loyalty;

  const ScanResult({
    required this.success,
    required this.washType,
    required this.customer,
    required this.loyalty,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
        success: json['success'] as bool? ?? false,
        washType: json['washType'] as String? ?? 'PAID',
        customer: json['customer'] as Map<String, dynamic>? ?? {},
        loyalty: json['loyalty'] as Map<String, dynamic>? ?? {},
      );

  int get washesCount => loyalty['washesCount'] as int? ?? 0;
  bool get freeWashAvailable => loyalty['freeWashAvailable'] as bool? ?? false;
}

class AdminService {
  final ApiClient _client;

  AdminService(this._client);

  Future<AdminStats> getStats() async {
    final data = await _client.get(ApiConstants.adminStats);
    return AdminStats.fromJson(data);
  }

  Future<List<MemberRow>> getMembers() async {
    final list = await _client.getList(ApiConstants.adminMembers);
    return list
        .map((e) => MemberRow.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ActivityItem>> getActivity() async {
    final list = await _client.getList(ApiConstants.adminActivity);
    return list
        .map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearActivity() async {
    await _client.post(ApiConstants.adminActivityClear);
  }

  Future<ScanResult> scanBarcode(String barcode) async {
    final data = await _client.post(
      ApiConstants.adminScanBarcode,
      data: {'barcode': barcode},
    );
    return ScanResult.fromJson(data);
  }

  Future<void> useFreeWash(String barcode) async {
    await _client.post(
      ApiConstants.adminUseFreeWash,
      data: {'barcode': barcode},
    );
  }

  Future<Map<String, dynamic>> undoWash(String barcode) async {
    return await _client.post(
      ApiConstants.adminUndoWash,
      data: {'barcode': barcode},
    );
  }

  Future<void> updateMember(
    String id, {
    required String fullName,
    required String phone,
    String? plateNumber,
  }) async {
    await _client.put(
      ApiConstants.adminMember(id),
      data: {
        'fullName': fullName,
        'phone': phone,
        if (plateNumber != null) 'plateNumber': plateNumber,
      },
    );
  }

  Future<void> deleteMember(String id) async {
    await _client.delete(ApiConstants.adminMember(id));
  }

  Future<ScannedCustomer> getCustomer(String barcode) async {
    final data = await _client.get(ApiConstants.adminCustomer(barcode));
    return ScannedCustomer.fromJson(data);
  }
}
