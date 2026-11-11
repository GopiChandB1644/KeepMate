import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/app_text.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/widgets/app_toast.dart';

/// In-app Camera page tailored for document and item scanning.
///
/// Running the camera directly inside KeepMate avoids switching to the external
/// system camera app, which is prone to being killed by aggressive Low Memory Killers
/// (such as on Vivo/iQOO Funtouch OS).
class DocumentCameraPage extends StatefulWidget {
  final String title;

  const DocumentCameraPage({
    super.key,
    this.title = 'Scan Document / Photo',
  });

  /// Opens the document camera and returns the compressed image file path,
  /// or null if cancelled.
  static Future<String?> open(BuildContext context, {String title = 'Scan Document / Photo'}) async {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => DocumentCameraPage(title: title),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<DocumentCameraPage> createState() => _DocumentCameraPageState();
}

class _DocumentCameraPageState extends State<DocumentCameraPage> with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.auto;
  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _errorMessage;
  XFile? _capturedFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCameraController(_cameras[_selectedCameraIndex]);
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Camera permission is required to scan documents and take photos.';
        });
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'No camera found on this device.';
        });
        return;
      }

      // Default to the first back-facing camera
      final backCameraIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      _selectedCameraIndex = backCameraIndex != -1 ? backCameraIndex : 0;

      await _initCameraController(_cameras[_selectedCameraIndex]);
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Could not access camera: $e';
      });
    }
  }

  Future<void> _initCameraController(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = controller;

    try {
      await controller.initialize();
      await controller.setFlashMode(_flashMode);
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Camera initialization failed: $e';
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    FlashMode nextMode;
    switch (_flashMode) {
      case FlashMode.off:
        nextMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        nextMode = FlashMode.torch;
        break;
      case FlashMode.torch:
      case FlashMode.always:
        nextMode = FlashMode.off;
        break;
    }

    try {
      await controller.setFlashMode(nextMode);
      setState(() {
        _flashMode = nextMode;
      });
    } catch (_) {}
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    setState(() {
      _isInitializing = true;
    });
    await _controller?.dispose();
    await _initCameraController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _takePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) return;

    try {
      setState(() {
        _isCapturing = true;
      });

      final file = await controller.takePicture();
      if (!mounted) return;

      setState(() {
        _isCapturing = false;
        _capturedFile = file;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
        showToast(
          context,
          'Capture failed: $e',
          type: ToastType.error,
          icon: Icons.error_outline_rounded,
        );
      }
    }
  }

  Future<void> _confirmCapturedPhoto() async {
    final file = _capturedFile;
    if (file == null) return;

    try {
      final compressed = await ImageCompressor.compress(
        file.path,
        purpose: ImagePurpose.document,
      );
      if (!mounted) return;
      Navigator.of(context).pop(compressed);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(file.path);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
      if (picked != null && mounted) {
        final compressed = await ImageCompressor.compress(
          picked.path,
          purpose: ImagePurpose.document,
        );
        if (!mounted) return;
        Navigator.of(context).pop(compressed);
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          'Gallery error: $e',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _fallbackToSystemCamera() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
      if (picked != null && mounted) {
        final compressed = await ImageCompressor.compress(
          picked.path,
          purpose: ImagePurpose.document,
        );
        if (!mounted) return;
        Navigator.of(context).pop(compressed);
      }
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          'System camera error: $e',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: KeepMateAppBar(
        title: widget.title,
        showBack: true,
        actions: [
          if (_controller != null && _controller!.value.isInitialized && _capturedFile == null)
            CircleIconButton(
              icon: _getFlashIcon(),
              tooltip: 'Toggle Flash',
              onTap: _toggleFlash,
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off_rounded;
      case FlashMode.auto:
        return Icons.flash_auto_rounded;
      case FlashMode.torch:
      case FlashMode.always:
        return Icons.flash_on_rounded;
    }
  }

  Widget _buildBody() {
    if (_capturedFile != null) {
      return _buildPreviewView();
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_isInitializing || _controller == null || !_controller!.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Starting camera...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera live feed
        Center(
          child: CameraPreview(_controller!),
        ),

        // Document framing guide overlay
        _buildDocumentFrame(),

        // Bottom control bar
        Positioned(
          left: 0,
          right: 0,
          bottom: 24,
          child: _buildControlsBar(),
        ),

        // Top instruction pill
        Positioned(
          top: 16,
          left: 24,
          right: 24,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: const Text(
                'Align document or bill inside the frame',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        if (_isCapturing)
          Container(
            color: Colors.black45,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildDocumentFrame() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameWidth = constraints.maxWidth * 0.88;
        final frameHeight = constraints.maxHeight * 0.65;

        return Center(
          child: Container(
            width: frameWidth,
            height: frameHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Corner accents for document scanner look
                _cornerMark(Alignment.topLeft),
                _cornerMark(Alignment.topRight),
                _cornerMark(Alignment.bottomLeft),
                _cornerMark(Alignment.bottomRight),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cornerMark(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.6),
          borderRadius: BorderRadius.only(
            topLeft: alignment == Alignment.topLeft ? const Radius.circular(14) : Radius.zero,
            topRight: alignment == Alignment.topRight ? const Radius.circular(14) : Radius.zero,
            bottomLeft: alignment == Alignment.bottomLeft ? const Radius.circular(14) : Radius.zero,
            bottomRight: alignment == Alignment.bottomRight ? const Radius.circular(14) : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildControlsBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Gallery pick shortcut
          IconButton(
            icon: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 28),
            tooltip: 'Pick from Gallery',
            onPressed: _pickFromGallery,
          ),

          // Big round shutter button
          GestureDetector(
            onTap: _takePhoto,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Flip camera button (or spacer if single camera)
          if (_cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_android_rounded, color: Colors.white, size: 28),
              tooltip: 'Flip Camera',
              onPressed: _flipCamera,
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPreviewView() {
    final file = _capturedFile!;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(file.path),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          color: AppColors.surface,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _capturedFile = null;
                    });
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Retake'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _confirmCapturedPhoto,
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Use Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_off_rounded, size: 56, color: AppColors.warningOrange),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Camera unavailable',
              style: AppText.bodyMedium.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeCamera,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry Camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _fallbackToSystemCamera,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Use System Camera'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Choose from Gallery'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

