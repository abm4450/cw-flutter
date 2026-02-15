class ApiError implements Exception {
  final int statusCode;
  final String message;
  final String? code;

  ApiError({
    required this.statusCode,
    required this.message,
    this.code,
  });

  String get arabicMessage => _toArabicError(message, code);

  static String _toArabicError(String message, String? code) {
    const byCode = <String, String>{
      'NO_TOKEN': 'غير مصرح. الرجاء تسجيل الدخول.',
      'INVALID_TOKEN': 'انتهت الجلسة أو رمز الدخول غير صالح.',
      'FORBIDDEN': 'لا تملك الصلاحية للوصول.',
      'VALIDATION': 'بيانات غير صحيحة. الرجاء المراجعة.',
      'PHONE_EXISTS': 'رقم الجوال مسجل مسبقًا.',
      'PLATE_EXISTS': 'لوحة السيارة مسجلة مسبقًا.',
      'INVALID_CREDENTIALS': 'رقم الجوال أو كلمة المرور غير صحيحة.',
      'OTP_REQUIRED': 'رمز التحقق مطلوب.',
      'OTP_NOT_FOUND': 'لا يوجد رمز تحقق فعال.',
      'OTP_EXPIRED': 'انتهت صلاحية رمز التحقق.',
      'OTP_INVALID': 'رمز التحقق غير صحيح.',
      'WA_UNCONFIGURED': 'خدمة واتساب غير مهيأة.',
      'WA_SEND_FAILED': 'فشل إرسال رمز التحقق عبر واتساب.',
      'NOT_FOUND': 'العنصر غير موجود.',
      'NO_FREE_WASH': 'لا توجد غسلة مجانية متاحة.',
      'NO_LOGS': 'لا يوجد سجل غسلات للتراجع.',
      'SERVER': 'حدث خطأ في الخادم. حاول لاحقًا.',
    };

    if (code != null && byCode.containsKey(code)) {
      return byCode[code]!;
    }

    const byMessage = <String, String>{
      'Unauthorized': 'غير مصرح. الرجاء تسجيل الدخول.',
      'Invalid or expired token': 'انتهت الجلسة أو رمز الدخول غير صالح.',
      'Full name, phone, password required': 'الاسم ورقم الجوال وكلمة المرور مطلوبة.',
      'Phone and password required': 'رقم الجوال وكلمة المرور مطلوبة.',
      'Full name and phone required': 'الاسم ورقم الجوال مطلوبان.',
      'Phone required': 'رقم الجوال مطلوب.',
      'OTP required': 'رمز التحقق مطلوب.',
      'Invalid purpose': 'طلب غير صالح.',
      'OTP not found': 'لا يوجد رمز تحقق فعال.',
      'OTP expired': 'انتهت صلاحية رمز التحقق.',
      'Invalid OTP': 'رمز التحقق غير صحيح.',
      'WhatsApp not configured': 'خدمة واتساب غير مهيأة.',
      'WhatsApp send failed': 'فشل إرسال رمز التحقق عبر واتساب.',
      'Phone already registered': 'رقم الجوال مسجل مسبقًا.',
      'Plate already registered': 'لوحة السيارة مسجلة مسبقًا.',
      'Invalid credentials': 'رقم الجوال أو كلمة المرور غير صحيحة.',
      'User not found': 'المستخدم غير موجود.',
      'Customer not found': 'العميل غير موجود.',
      'Barcode required': 'الباركود مطلوب.',
      'No free wash available': 'لا توجد غسلة مجانية متاحة.',
      'No wash logs to undo': 'لا يوجد سجل غسلات للتراجع.',
      'Server error': 'حدث خطأ في الخادم. حاول لاحقًا.',
    };

    return byMessage[message] ?? 'حدث خطأ. حاول مرة أخرى.';
  }

  @override
  String toString() => 'ApiError($statusCode): $arabicMessage';
}
