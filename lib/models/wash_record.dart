class WashRecord {
  final String id;
  final String washType;
  final int createdAt;

  const WashRecord({
    required this.id,
    required this.washType,
    required this.createdAt,
  });

  factory WashRecord.fromJson(Map<String, dynamic> json) => WashRecord(
        id: json['id'].toString(),
        washType: json['washType'] as String? ?? 'PAID',
        createdAt: json['createdAt'] as int? ?? 0,
      );

  bool get isFree => washType == 'FREE';
  bool get isPaid => washType == 'PAID';
}
