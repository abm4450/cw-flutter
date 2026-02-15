import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cw_flutter/l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart' as app_date;
import '../../providers/auth_provider.dart';
import '../../providers/user_portal_provider.dart';
import '../../widgets/glass_app_bar.dart';
import '../../widgets/wash_progress_circles.dart';
import '../../widgets/saudi_plate.dart';

class CustomerPortalScreen extends ConsumerWidget {
  const CustomerPortalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final portalState = ref.watch(userPortalProvider);
    final user = authState.user;

    if (user == null || portalState.loading) {
      return const Scaffold(
        body: Center(
          child: Text(
            '...',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      );
    }

    final loyalty = portalState.loyalty;
    final lastWash = portalState.lastWash;
    final washesCount = loyalty?.washesCount ?? 0;
    final freeWashAvailable = loyalty?.freeWashAvailable ?? false;
    final currentCycleCount = washesCount > 5 ? 5 : washesCount;
    final washesUntilFree = freeWashAvailable ? 0 : (5 - washesCount).clamp(0, 5);
    final barcodeValue = loyalty?.barcode ?? user.id;
    final displayBarcode = loyalty?.barcode.replaceAll('CW-', '') ?? user.id;

    return Scaffold(
      appBar: const GlassAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: freeWashAvailable
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : Colors.white,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: freeWashAvailable
                          ? AppColors.primary.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.1),
                      blurRadius: 60,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress circles
                    WashProgressCircles(activeCount: currentCycleCount),

                    // Message row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Text('🎁', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    freeWashAvailable
                                        ? l10n.freeNextMsg
                                        : l10n.progressMsg,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                if (!freeWashAvailable) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '$washesUntilFree',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: freeWashAvailable
                                          ? AppColors.primary
                                          : AppColors.dark,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                l10n.hello,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0,
                                  color: freeWashAvailable
                                      ? AppColors.primary
                                      : AppColors.textMuted,
                                ),
                              ),
                              Text(
                                user.fullName.split(' ').first,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.dark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // QR Code
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: freeWashAvailable
                                    ? AppColors.primary.withValues(alpha: 0.2)
                                    : AppColors.background,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: barcodeValue,
                              version: QrVersions.auto,
                              size: 130,
                              eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: freeWashAvailable
                                    ? AppColors.primary
                                    : AppColors.dark,
                              ),
                              dataModuleStyle: QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: freeWashAvailable
                                    ? AppColors.primary
                                    : AppColors.dark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: freeWashAvailable
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.background.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              displayBarcode,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                letterSpacing: 0,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: freeWashAvailable
                                    ? AppColors.primary
                                    : AppColors.dark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Plate section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: freeWashAvailable
                            ? Colors.white
                            : AppColors.background.withValues(alpha: 0.8),
                        border: Border(
                          top: BorderSide(
                            color: freeWashAvailable
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.border,
                          ),
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.plateNumberLabel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                              color: freeWashAvailable
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (user.plateNumber != null &&
                              user.plateNumber!.isNotEmpty)
                            SaudiPlate(plate: user.plateNumber!, scale: 0.7)
                          else
                            const Text(
                              '—',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          if (lastWash != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              '${l10n.lastWash} · ${app_date.formatShortDate(lastWash.createdAt)} ${app_date.formatTime(lastWash.createdAt)}',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
