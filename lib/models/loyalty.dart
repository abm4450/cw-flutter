class Loyalty {
  final String barcode;
  final int washesCount;
  final bool freeWashAvailable;

  const Loyalty({
    required this.barcode,
    required this.washesCount,
    required this.freeWashAvailable,
  });

  factory Loyalty.fromJson(Map<String, dynamic> json) => Loyalty(
        barcode: json['barcode'] as String? ?? '',
        washesCount: json['washesCount'] as int? ?? 0,
        freeWashAvailable: json['freeWashAvailable'] as bool? ?? false,
      );
}
