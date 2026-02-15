class ApiConstants {
  ApiConstants._();

  // TODO: Update this to your actual server URL
  static const String baseUrl = 'https://cw.abdullah9.sa';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String otpRequest = '/auth/otp/request';
  static const String otpVerify = '/auth/otp/verify';
  static const String logout = '/auth/logout';

  // User
  static const String me = '/me';
  static const String loyalty = '/me/loyalty';
  static const String washes = '/me/washes';

  // Admin
  static const String adminStats = '/admin/stats';
  static const String adminMembers = '/admin/members';
  static const String adminActivity = '/admin/activity';
  static const String adminActivityClear = '/admin/activity/clear';
  static const String adminScanBarcode = '/admin/scan-barcode';
  static const String adminUseFreeWash = '/admin/use-free-wash';
  static const String adminUndoWash = '/admin/undo-wash';

  static String adminCustomer(String barcode) =>
      '/admin/customer/${Uri.encodeComponent(barcode)}';

  static String adminMember(String id) => '/admin/member/$id';
}
