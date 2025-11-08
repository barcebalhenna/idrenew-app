import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';
import 'category_page.dart';
import 'services/firebase_service.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? _controller;
  bool _isCameraReady = false;
  bool _flashOn = false;

  // ML and Firebase services
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();

  // State for showing results
  bool _isProcessing = false;
  Map<String, dynamic>? _scanResult;
  bool _showResultCard = false;


  @override
  void initState() {
    super.initState();
    _initCamera();
  }


  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      final back = cams.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.isNotEmpty ? cams.first : throw "No camera found",
      );
      _controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _controller!.initialize();
      await _controller!.setFlashMode(FlashMode.off);
      setState(() => _isCameraReady = true);
    } catch (e) {
      debugPrint("Camera init error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Camera unavailable: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    if (_controller == null) return;
    try {
      _flashOn = !_flashOn;
      await _controller!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_flashOn ? "Flash enabled" : "Flash disabled"),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      debugPrint("Flash error: $e");
    }
  }

  // Gallery picker (for viewing only)
  void _openGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        if(!classifierService.isReady) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Model not ready yet")),
          );
          return;
        }

        await _processImage(File(image.path));
      }
    } catch (e) {
      debugPrint("Gallery picker error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
    }
  }

  // Take photo and process
  void _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera not ready")),
      );
      return;
    }

    // ✅ Check if model is ready before classifying
    if (!classifierService.isReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Model not ready yet")),
      );
      return;
    }

    try {
      await _controller!.setFlashMode(FlashMode.off);
      final file = await _controller!.takePicture();
      await _processImage(File(file.path));
    } catch (e) {
      debugPrint("Take photo error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to take photo")),
      );
    }
  }

  // Process image and save to Firebase
  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isProcessing = true;
      _showResultCard = false;
      _scanResult = null;
    });

    try {
      final result = await classifierService.classifyImage(imageFile);
      await _firebaseService.saveScanResult(result);

      setState(() {
        _scanResult = result;
        _isProcessing = false;
        _showResultCard = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Scan saved to history!'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint("Process image error: $e");
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _closeResultCard() {
    setState(() {
      _showResultCard = false;
      _scanResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            mainPageKey.currentState?.navigateTo(0);
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.recycling, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text(
                "IDRenew",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main scrollable content
            SingleChildScrollView(
              child: Column(
                children: [
                  // Camera section
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 450,
                      color: Colors.transparent,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Camera Preview
                          if (_isCameraReady && _controller != null)
                            CameraPreview(_controller!)
                          else
                            const Center(child: CircularProgressIndicator()),

                          // Top hint
                          Positioned(
                            top: 16,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "Point camera at device parts",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                          ),

                          // Green scanning frame
                          Container(
                            width: 224,
                            height: 224,
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFF10B981), width: 3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          // NEW: Processing indicator
                          if (_isProcessing)
                            Container(
                              color: Colors.black.withOpacity(0.7),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Color(0xFF10B981),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "Analyzing...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Bottom controls
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Gallery button
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.black.withOpacity(0.5),
                                  child: IconButton(
                                    onPressed: _isProcessing ? null : _openGallery,
                                    icon: const Icon(Icons.photo_library, color: Colors.white),
                                  ),
                                ),

                                // Capture button
                                GestureDetector(
                                  onTap: _isProcessing ? null : _takePhoto,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _isProcessing
                                          ? Colors.grey
                                          : const Color(0xFF10B981),
                                      border: Border.all(color: Colors.white, width: 4),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 36,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                // Flash button
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.black.withOpacity(0.5),
                                  child: IconButton(
                                    onPressed: _isProcessing ? null : _toggleFlash,
                                    icon: Icon(
                                      _flashOn ? Icons.flash_on : Icons.flash_off,
                                      color: _flashOn ? Colors.yellow : Colors.white,
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

                  // Quick actions section
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Quick Actions",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionBox(
                                color: const Color(0xFF10B981),
                                icon: Icons.phone_iphone,
                                title: "Phone Parts",
                                subtitle: "Scan phone components",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CategoryPage(title: "Phone Parts"),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionBox(
                                color: const Color(0xFF3B82F6),
                                icon: Icons.laptop,
                                title: "Laptop Parts",
                                subtitle: "Scan laptop components",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CategoryPage(title: "Laptop Parts"),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const _QuickActionTip(
                          icon: Icons.lightbulb,
                          title: "Pro Tip",
                          subtitle: "Hold steady and ensure good lighting for better results",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // NEW: Floating result card (appears on top of everything)
            if (_showResultCard && _scanResult != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 20,
                child: _ResultCard(
                  result: _scanResult!,
                  onClose: _closeResultCard,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// NEW: Result card widget
class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onClose;

  const _ResultCard({
    required this.result,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isReusable = result['condition'] == 'Reusable';

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isReusable
                ? [Color(0xFF10B981), Color(0xFF059669)]
                : [Color(0xFFF59E0B), Color(0xFFD97706)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Scan Result",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: Icon(Icons.close, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Icon
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isReusable ? Icons.check_circle : Icons.warning,
                color: Colors.white,
                size: 48,
              ),
            ),

            SizedBox(height: 16),

            // Item type
            Text(
              result['itemType'] ?? 'Unknown',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8),

            // Condition
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                result['condition'] ?? 'Unknown',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 12),

            // Confidence
            Text(
              'Confidence: ${result['confidencePercentage'] ?? 'N/A'}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),

            SizedBox(height: 16),

            // Action button
            ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: isReusable ? Color(0xFF10B981) : Color(0xFFF59E0B),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Scan Another',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Supporting widgets (unchanged)
class _QuickActionBox extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionBox({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25), width: 0.6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _QuickActionTip({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
              child: Icon(icon, color: const Color(0xFF10B981), size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}