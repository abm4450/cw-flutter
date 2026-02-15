class ActivityItem {
  final String id;
  final ActivityUser user;
  final ActivityWash wash;

  const ActivityItem({
    required this.id,
    required this.user,
    required this.wash,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) => ActivityItem(
        id: json['id'].toString(),
        user: ActivityUser.fromJson(json['user'] as Map<String, dynamic>),
        wash: ActivityWash.fromJson(json['wash'] as Map<String, dynamic>),
      );
}

class ActivityUser {
  final String id;
  final String fullName;
  final String phone;
  final String? plateNumber;

  const ActivityUser({
    required this.id,
    required this.fullName,
    required this.phone,
    this.plateNumber,
  });

  factory ActivityUser.fromJson(Map<String, dynamic> json) => ActivityUser(
        id: json['id'].toString(),
        fullName: json['fullName'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        plateNumber: json['plateNumber'] as String?,
      );
}

class ActivityWash {
  final String id;
  final String washType;
  final int timestamp;
  final bool isFree;

  const ActivityWash({
    required this.id,
    required this.washType,
    required this.timestamp,
    required this.isFree,
  });

  factory ActivityWash.fromJson(Map<String, dynamic> json) => ActivityWash(
        id: json['id'].toString(),
        washType: json['washType'] as String? ?? 'PAID',
        timestamp: json['timestamp'] as int? ?? 0,
        isFree: json['isFree'] as bool? ?? false,
      );
}
