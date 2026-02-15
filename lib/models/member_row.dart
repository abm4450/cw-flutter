class MemberRow {
  final String id;
  final String fullName;
  final String phone;
  final String? plateNumber;
  final String barcode;
  final int washesCount;
  final bool freeWashAvailable;
  final int createdAt;
  final int? lastWashAt;
  final String? lastWashType;

  const MemberRow({
    required this.id,
    required this.fullName,
    required this.phone,
    this.plateNumber,
    required this.barcode,
    required this.washesCount,
    required this.freeWashAvailable,
    required this.createdAt,
    this.lastWashAt,
    this.lastWashType,
  });

  factory MemberRow.fromJson(Map<String, dynamic> json) => MemberRow(
        id: json['id'].toString(),
        fullName: json['fullName'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        plateNumber: json['plateNumber'] as String?,
        barcode: json['barcode'] as String? ?? '',
        washesCount: json['washesCount'] as int? ?? 0,
        freeWashAvailable: json['freeWashAvailable'] as bool? ?? false,
        createdAt: json['createdAt'] as int? ?? 0,
        lastWashAt: json['lastWashAt'] as int?,
        lastWashType: json['lastWashType'] as String?,
      );
}
