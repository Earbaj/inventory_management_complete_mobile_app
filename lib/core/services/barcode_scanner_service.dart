import 'dart:developer' as developer;
import 'package:flutter/material.dart';

/// Camera Barcode & QR Code Scanner Service & Modal Viewfinder.
class BarcodeScannerService {
  /// Opens interactive Camera Barcode Scanner Viewfinder Sheet.
  /// Returns scanned Barcode/SKU string or null if cancelled.
  static Future<String?> scanBarcode(BuildContext context) async {
    developer.log('📷 [BarcodeScannerService] Launching Camera Barcode Scanner...', name: 'BarcodeScannerService');
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _BarcodeScannerModal(),
    );
  }
}

class _BarcodeScannerModal extends StatefulWidget {
  const _BarcodeScannerModal();

  @override
  State<_BarcodeScannerModal> createState() => _BarcodeScannerModalState();
}

class _BarcodeScannerModalState extends State<_BarcodeScannerModal> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _manualInputController = TextEditingController();
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(String code) {
    developer.log('⚡ [BarcodeScannerService] Scanned Barcode Code: $code', name: 'BarcodeScannerService');
    Navigator.pop(context, code);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height * 0.85,
      child: Stack(
        children: [
          // SIMULATED CAMERA VIEWFINDER BACKDROP
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0F172A),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_outlined, size: 48, color: Colors.white30),
                  const SizedBox(height: 12),
                  Text(
                    'Align Barcode / QR Code inside frame',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // SCANNING TARGET FRAME OVERLAY
          Center(
            child: Container(
              width: 260,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.cyanAccent, width: 2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: _animationController.value * 190,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.cyanAccent,
                            boxShadow: [
                              BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.8), blurRadius: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // TOP HEADER CONTROLS
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.white12),
                ),
                const Text(
                  'Barcode / QR Scanner',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  onPressed: () => setState(() => _isFlashOn = !_isFlashOn),
                  icon: Icon(_isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded, color: _isFlashOn ? Colors.amber : Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.white12),
                ),
              ],
            ),
          ),

          // BOTTOM QUICK SCAN TESTER & MANUAL CODE INPUT
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Quick Test Barcodes:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickCodeChip('8901234567890'),
                      _buildQuickCodeChip('1001-SKU'),
                      _buildQuickCodeChip('1002-SKU'),
                      _buildQuickCodeChip('PROD-99'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualInputController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter SKU / Barcode manually',
                            hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                            filled: true,
                            fillColor: Colors.black26,
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_manualInputController.text.trim().isNotEmpty) {
                            _onBarcodeDetected(_manualInputController.text.trim());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCodeChip(String code) {
    return InkWell(
      onTap: () => _onBarcodeDetected(code),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_scanner_rounded, color: Colors.cyanAccent, size: 14),
            const SizedBox(width: 6),
            Text(code, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
