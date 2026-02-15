import 'package:flutter/material.dart';
import '../core/utils/plate_utils.dart';

class SaudiPlate extends StatelessWidget {
  final String plate;
  final double scale;

  const SaudiPlate({super.key, required this.plate, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final parsed = parsePlate(plate);

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
              // Main 2x2 grid
              Expanded(
                child: Column(
                  children: [
                    // Top row: Hindi digits | Arabic letters
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.black, width: 1.5),
                                  right: BorderSide(color: Colors.black, width: 1.5),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  parsed.hindiDigits,
                                  style: const TextStyle(
                                    fontSize: 22,
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
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.black, width: 1.5),
                                  right: BorderSide(color: Colors.black, width: 1.5),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  parsed.arabicLetters,
                                  style: const TextStyle(
                                    fontSize: 18,
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
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.black, width: 1.5),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                parsed.digits,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.black, width: 1.5),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                parsed.letters,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0,
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
              // Right KSA section
              SizedBox(
                width: 30,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Column(
                        children: [
                          Icon(Icons.account_balance, size: 14, color: Colors.black),
                          Text(
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
}
