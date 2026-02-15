import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/api_user.dart';
import '../models/loyalty.dart';
import '../models/wash_record.dart';

class UserService {
  final ApiClient _client;

  UserService(this._client);

  Future<ApiUser> getMe() async {
    final data = await _client.get(ApiConstants.me);
    return ApiUser.fromJson(data);
  }

  Future<Loyalty> getLoyalty() async {
    final data = await _client.get(ApiConstants.loyalty);
    return Loyalty.fromJson(data);
  }

  Future<List<WashRecord>> getWashes() async {
    final list = await _client.getList(ApiConstants.washes);
    return list
        .map((e) => WashRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
