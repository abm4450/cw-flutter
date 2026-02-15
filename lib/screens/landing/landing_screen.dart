import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cw_flutter/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/errors/api_error.dart';
import '../../core/utils/plate_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/saudi_plate.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  String _mode = 'login'; // login, register, admin
  String _mobile = '';
  String _fullName = '';
  String _password = '';
  String _otpStep = 'request'; // request, verify
  String _registerOtpStep = 'request';
  List<String> _otpOptions = [];
  List<String> _registerOtpOptions = [];
  String _notice = '';
  String _plateDigits = '';
  String _plateLetters = '';
  String _error = '';
  bool _submitting = false;

  AuthService get _authService => ref.read(authServiceProvider);

  Future<void> _handleSubmit() async {
    setState(() {
      _error = '';
      _notice = '';
      _submitting = true;
    });

    final isAr = ref.read(languageProvider).languageCode == 'ar';

    try {
      if (_mode == 'register') {
        if (_registerOtpStep == 'request') {
          final res = await _authService.requestOtp(
            phone: _mobile,
            purpose: 'register',
          );
          setState(() {
            _registerOtpStep = 'verify';
            _registerOtpOptions = res.options;
            _notice = isAr
                ? 'تم إرسال رمز التحقق عبر واتساب.'
                : 'OTP sent via WhatsApp.';
          });
        }
      } else if (_mode == 'admin') {
        final res = await _authService.login(
          phone: _mobile,
          password: _password,
        );
        await ref.read(authProvider.notifier).login(res.token, res.user);
      } else {
        // login
        if (_otpStep == 'request') {
          final res = await _authService.requestOtp(
            phone: _mobile,
            purpose: 'login',
          );
          if (!res.exists) {
            setState(() {
              _mode = 'register';
              _otpStep = 'request';
              _registerOtpStep = 'request';
              _otpOptions = [];
              _registerOtpOptions = [];
              _notice = isAr
                  ? 'رقمك غير مسجل. أكمل التسجيل.'
                  : 'Your number is not registered. Complete signup.';
            });
          } else if (res.sent) {
            setState(() {
              _otpStep = 'verify';
              _otpOptions = res.options;
              _notice = isAr
                  ? 'تم إرسال رمز التحقق عبر واتساب.'
                  : 'OTP sent via WhatsApp.';
            });
          }
        }
      }
    } on ApiError catch (e) {
      setState(() => _error = e.arabicMessage);
    } catch (_) {
      setState(() => _error = isAr
          ? 'حدث خطأ. حاول مرة أخرى.'
          : 'Something went wrong. Try again.');
    } finally {
      setState(() => _submitting = false);
    }
  }

  Future<void> _handleOtpChoice(String code, String purpose) async {
    setState(() {
      _error = '';
      _notice = '';
      _submitting = true;
    });

    final isAr = ref.read(languageProvider).languageCode == 'ar';

    try {
      if (purpose == 'register') {
        await _authService.verifyOtp(
          phone: _mobile,
          code: code,
          purpose: 'register',
        );
        final plateNumber = '$_plateDigits-$_plateLetters';
        final res = await _authService.register(
          fullName: _fullName.trim(),
          phone: _mobile,
          plateNumber: plateNumber,
        );
        await ref.read(authProvider.notifier).login(res.token, res.user);
      } else {
        final res = await _authService.verifyOtp(
          phone: _mobile,
          code: code,
          purpose: 'login',
        );
        if (res.token != null && res.user != null) {
          await ref.read(authProvider.notifier).login(res.token!, res.user!);
        }
      }
    } on ApiError catch (e) {
      setState(() => _error = e.arabicMessage);
    } catch (_) {
      setState(() => _error = isAr
          ? 'حدث خطأ. حاول مرة أخرى.'
          : 'Something went wrong. Try again.');
    } finally {
      setState(() => _submitting = false);
    }
  }

  void _switchMode() {
    setState(() {
      _mode = _mode == 'login' ? 'register' : 'login';
      _error = '';
      _notice = '';
      _otpStep = 'request';
      _registerOtpStep = 'request';
      _otpOptions = [];
      _registerOtpOptions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = ref.watch(languageProvider).languageCode == 'ar';

    final showOtp = (_mode == 'login' && _otpStep == 'verify') ||
        (_mode == 'register' && _registerOtpStep == 'verify');
    final currentOtpOptions =
        _mode == 'register' ? _registerOtpOptions : _otpOptions;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => ref.read(languageProvider.notifier).toggle(),
            child: Text(
              isAr ? 'EN' : 'العربية',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(56),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 100,
                      offset: const Offset(0, 40),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_car_wash,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _mode == 'login'
                                ? l10n.login
                                : _mode == 'register'
                                    ? l10n.register
                                    : l10n.admin,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Notice
                    if (_notice.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          border: Border.all(color: AppColors.successBorder),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _notice,
                          style: const TextStyle(
                            color: AppColors.successText,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                    // Error
                    if (_error.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 32),
                        decoration: BoxDecoration(
                          color: AppColors.errorBg,
                          border: Border.all(color: AppColors.errorBorder),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _error,
                          style: const TextStyle(
                            color: AppColors.errorText,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                    // Full Name (register only)
                    if (_mode == 'register') ...[
                      _buildLabel(l10n.fullName),
                      const SizedBox(height: 8),
                      _buildInput(
                        value: _fullName,
                        onChanged: (v) => setState(() => _fullName = v),
                        placeholder: 'Abdullah Ali',
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Mobile / Secret Key
                    _buildLabel(_mode == 'admin' ? l10n.secretKey : l10n.mobile),
                    const SizedBox(height: 8),
                    _buildInput(
                      value: _mobile,
                      onChanged: (v) => setState(() => _mobile = v),
                      placeholder: _mode == 'admin' ? '••••' : '05xxxxxxxx',
                      keyboardType: _mode == 'admin'
                          ? TextInputType.visiblePassword
                          : TextInputType.phone,
                      obscureText: _mode == 'admin',
                    ),

                    // Password (admin only)
                    if (_mode == 'admin') ...[
                      const SizedBox(height: 24),
                      _buildLabel(l10n.password),
                      const SizedBox(height: 8),
                      _buildInput(
                        value: _password,
                        onChanged: (v) => setState(() => _password = v),
                        placeholder: '••••••••',
                        obscureText: true,
                      ),
                    ],

                    // OTP choices
                    if (showOtp) ...[
                      const SizedBox(height: 24),
                      _buildLabel(isAr
                          ? 'اختر رمز التحقق الصحيح'
                          : 'Choose the correct code'),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: currentOtpOptions.map((code) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: InkWell(
                              onTap: _submitting
                                  ? null
                                  : () => _handleOtpChoice(
                                      code,
                                      _mode == 'register'
                                          ? 'register'
                                          : 'login'),
                              borderRadius: BorderRadius.circular(32),
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.background,
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  code,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // Plate inputs (register only)
                    if (_mode == 'register') ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(isAr ? 'الأرقام (١-٤)' : 'Digits (1-4)'),
                                const SizedBox(height: 8),
                                _buildInput(
                                  value: _plateDigits,
                                  onChanged: (v) => setState(
                                      () => _plateDigits = normalizePlateDigits(v)),
                                  placeholder: isAr ? '٧٦٥٣' : '7653',
                                  maxLength: 4,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel(isAr ? 'الحروف (٣)' : 'Letters (3)'),
                                const SizedBox(height: 8),
                                _buildInput(
                                  value: (isAr
                                          ? toArabicLetters(_plateLetters)
                                          : _plateLetters)
                                      .split('')
                                      .join(' '),
                                  onChanged: (v) => setState(() =>
                                      _plateLetters = normalizePlateLetters(v)),
                                  placeholder: isAr ? 'ت ن ج' : 'T N J',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Plate preview
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: AppColors.borderMedium,
                            width: 2,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              isAr ? 'معاينة اللوحة' : 'Plate Preview',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMuted,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SaudiPlate(
                              plate:
                                  '${_plateDigits.isEmpty ? "0000" : _plateDigits}-${_plateLetters.isEmpty ? "AAA" : _plateLetters}',
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Submit button
                    if (!showOtp) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 8,
                            shadowColor: AppColors.primary.withValues(alpha: 0.4),
                          ),
                          child: Text(
                            _submitting
                                ? '...'
                                : _mode == 'login'
                                    ? (isAr ? 'دخول' : 'Sign In')
                                    : _mode == 'register'
                                        ? (isAr ? 'تسجيل' : 'Register')
                                        : l10n.submit,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Switch mode
                    if (_mode != 'admin') ...[
                      const SizedBox(height: 32),
                      Center(
                        child: GestureDetector(
                          onTap: _switchMode,
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMuted,
                                letterSpacing: 0,
                              ),
                              children: [
                                TextSpan(
                                  text: _mode == 'login'
                                      ? '${l10n.noAccount} '
                                      : '${l10n.hasAccount} ',
                                ),
                                TextSpan(
                                  text: _mode == 'login'
                                      ? l10n.registerNow
                                      : l10n.signIn,
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: AppColors.textMuted,
        letterSpacing: 0,
      ),
    );
  }

  Widget _buildInput({
    required String value,
    required ValueChanged<String> onChanged,
    String? placeholder,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLength,
    TextAlign textAlign = TextAlign.start,
    TextStyle? style,
  }) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: value.length),
        ),
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      textAlign: textAlign,
      style: style ??
          const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
      decoration: InputDecoration(
        hintText: placeholder,
        counterText: '',
        hintStyle: TextStyle(
          color: AppColors.textMuted.withValues(alpha: 0.5),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
