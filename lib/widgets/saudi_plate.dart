import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/utils/plate_utils.dart';

/// Saudi license plate widget matching the Node (cw) project design:
/// - Grid 1 : 1.25 (digits : letters), text-2xl (24) / text-xl (20)
/// - Plate logo SVG 16x16, "السعودية" 4.5px, KSA 7px, dot 6px
class SaudiPlate extends StatelessWidget {
  final String plate;
  final double scale;

  const SaudiPlate({super.key, required this.plate, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final parsed = parsePlate(plate);
    // English letters displayed reversed with spaces (like Node: letters.split('').reverse().join(' '))
    final lettersDisplay = parsed.letters.replaceAll(' ', '').split('').reversed.join(' ');

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 180,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 2.5),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Main grid: cols 1 : 1.25 (flex 4 : 5) — matches Node grid-cols-[1fr_1.25fr]
              Expanded(
                child: Column(
                  children: [
                    // Top row: Hindi digits | Arabic letters
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: _cell(
                              borderBottom: true,
                              borderRight: true,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  parsed.hindiDigits,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: _cell(
                              borderBottom: true,
                              borderRight: true,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  parsed.arabicLetters,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bottom row: English digits | English letters
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: _cell(
                              borderRight: true,
                              child: Text(
                                parsed.digits,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: _cell(
                              borderRight: true,
                              child: Text(
                                lettersDisplay,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Right section: logo + السعودية + KSA + dot — matches Node w-[30px] py-1
              Container(
                width: 30,
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.black, width: 1.5),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            'assets/platelogo.svg',
                            width: 16,
                            height: 16,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'السعودية',
                            style: TextStyle(
                              fontSize: 4.5,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('K', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, height: 0.8)),
                        Text('S', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, height: 0.8)),
                        Text('A', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, height: 0.8)),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell({
    required Widget child,
    bool borderBottom = false,
    bool borderRight = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: borderBottom ? const BorderSide(color: Colors.black, width: 1.5) : BorderSide.none,
          right: borderRight ? const BorderSide(color: Colors.black, width: 1.5) : BorderSide.none,
        ),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
