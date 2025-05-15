import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

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
      _initializeControllerFuture = _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/blue.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Flutify - Camera',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        body:
            _controller == null
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Stack(
                        children: [
                          CameraPreview(_controller!),
                          Positioned(
                            bottom: 30,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: FloatingActionButton(
                                backgroundColor: Colors.white,
                                onPressed: () async {
                                  try {
                                    await _initializeControllerFuture;
                                    final image =
                                        await _controller!.takePicture();

                                    // Check if the widget is still mounted before using context
                                    if (!context.mounted) return;

                                    Navigator.pop(context, image.path);
                                  } catch (e) {
                                    debugPrint('Error taking picture: $e');
                                  }
                                },

                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                  },
                ),
      ),
    );
  }
}
