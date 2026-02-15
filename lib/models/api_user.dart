class ApiUser {
  final String id;
  final String fullName;
  final String phone;
  final String? plateNumber;
  final String role;
  final bool isVerified;
  final int? createdAt;

  const ApiUser({
    required this.id,
    required this.fullName,
    required this.phone,
    this.plateNumber,
    required this.role,
    required this.isVerified,
    this.createdAt,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) => ApiUser(
        id: json['id'].toString(),
        fullName: json['fullName'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        plateNumber: json['plateNumber'] as String?,
        role: json['role'] as String? ?? 'CUSTOMER',
        isVerified: json['isVerified'] as bool? ?? false,
        createdAt: json['createdAt'] as int?,
      );

  bool get isAdmin => role == 'ADMIN';
  bool get isCustomer => role == 'CUSTOMER';
}
