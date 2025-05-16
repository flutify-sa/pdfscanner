import 'package:camera/camera.dart';
import 'package:flutifyscan/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutifyscan/pdf_generator.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _initializeControllerFuture = _controller!.initialize().then((_) {
        if (mounted) setState(() {});
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<String> _saveImageToAppDir(XFile image) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${dir.path}/$fileName';
      await File(image.path).copy(savedPath);
      return savedPath;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return image.path; // fallback
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Flutify - Camera',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0052D4),
                  Color(0xFF4364F7),
                  Color(0xFF6FB1FC),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  _controller != null) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CameraPreview(_controller!),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
            },
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await _initializeControllerFuture;
                    if (!mounted) return; // Check State.mounted

                    if (_controller != null) {
                      final image = await _controller!.takePicture();
                      if (!mounted) return; // Check State.mounted

                      final savedPath = await _saveImageToAppDir(image);
                      if (!mounted) return; // Check State.mounted

                      if (context.mounted) {
                        final usePhoto = await Navigator.push<bool>(
                          context, // Safe to use context here
                          MaterialPageRoute(
                            builder:
                                (_) => ImagePreviewScreen(imagePath: savedPath),
                          ),
                        );
                        if (!context.mounted) {
                          return; // Check context.mounted after async
                        }

                        if (usePhoto == true) {
                          await PdfGenerator.createPdfFromImage(
                            imagePath: savedPath,
                          );
                          if (context.mounted) {
                            // Add this check
                            Navigator.pop(
                              context,
                              savedPath,
                            ); // Safe to use context here
                          }
                        }
                      }
                    }
                  } catch (e) {
                    debugPrint('Error taking or saving picture: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                  elevation: 8,
                  shadowColor: Colors.black54,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 32,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
