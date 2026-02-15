import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class WashProgressCircles extends StatelessWidget {
  final int activeCount;

  const WashProgressCircles({super.key, required this.activeCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (i) => _CircleIcon(active: i < activeCount)),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final bool active;

  const _CircleIcon({required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: AspectRatio(
          aspectRatio: 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
                width: 2,
              ),
              gradient: active
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryDark, AppColors.primary],
                    )
                  : null,
              color: active ? null : AppColors.background,
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                Icons.local_car_wash,
                size: 24,
                color: active ? Colors.white : AppColors.borderMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
