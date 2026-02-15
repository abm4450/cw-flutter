import 'wash_record.dart';

class ScannedCustomer {
  final String id;
  final String fullName;
  final String phone;
  final String? plateNumber;
  final String barcode;
  final int washesCount;
  final bool freeWashAvailable;
  final List<WashRecord> washHistory;

  const ScannedCustomer({
    required this.id,
    required this.fullName,
    required this.phone,
    this.plateNumber,
    required this.barcode,
    required this.washesCount,
    required this.freeWashAvailable,
    required this.washHistory,
  });

  factory ScannedCustomer.fromJson(Map<String, dynamic> json) =>
      ScannedCustomer(
        id: json['id'].toString(),
        fullName: json['fullName'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        plateNumber: json['plateNumber'] as String?,
        barcode: json['barcode'] as String? ?? '',
        washesCount: json['washesCount'] as int? ?? 0,
        freeWashAvailable: json['freeWashAvailable'] as bool? ?? false,
        washHistory: (json['washHistory'] as List<dynamic>?)
                ?.map((e) => WashRecord.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  ScannedCustomer copyWith({
    int? washesCount,
    bool? freeWashAvailable,
    List<WashRecord>? washHistory,
  }) =>
      ScannedCustomer(
        id: id,
        fullName: fullName,
        phone: phone,
        plateNumber: plateNumber,
        barcode: barcode,
        washesCount: washesCount ?? this.washesCount,
        freeWashAvailable: freeWashAvailable ?? this.freeWashAvailable,
        washHistory: washHistory ?? this.washHistory,
      );
}
