import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediapipe_face_mesh/face_mesh_stream_processor.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

import 'package:plovy/features/face_mesh/data/face_mesh_camera_image_adapter.dart';
import 'package:plovy/features/face_mesh/presentation/widgets/face_mesh_overlay_painter.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  static const Map<DeviceOrientation, int> _deviceOrientationDegrees =
      <DeviceOrientation, int>{
        DeviceOrientation.portraitUp: 0,
        DeviceOrientation.landscapeLeft: 90,
        DeviceOrientation.portraitDown: 180,
        DeviceOrientation.landscapeRight: 270,
      };

  CameraController? _cameraController;
  CameraDescription? _cameraDescription;
  FaceMeshProcessor? _faceMeshProcessor;
  FaceMeshStreamProcessor? _faceMeshStreamProcessor;
  StreamController<FaceMeshNv21Image>? _nv21StreamController;
  StreamController<FaceMeshImage>? _bgraStreamController;
  StreamSubscription<FaceMeshResult>? _meshSubscription;

  FaceMeshResult? _meshResult;
  String? _errorMessage;
  int? _streamRotationDegrees;
  Size? _cameraImageSize;
  bool _isInitializing = true;
  bool _isFrameInFlight = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw StateError('No available cameras on this device.');
      }

      final CameraDescription selectedCamera = _selectCamera(cameras);
      _cameraDescription = selectedCamera;

      final FaceMeshProcessor faceMeshProcessor =
          await FaceMeshProcessor.create(delegate: FaceMeshDelegate.xnnpack);
      _faceMeshProcessor = faceMeshProcessor;
      _faceMeshStreamProcessor = FaceMeshStreamProcessor(faceMeshProcessor);

      final CameraController cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup:
            Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.nv21,
      );

      await cameraController.initialize();
      await cameraController.startImageStream(_onCameraImage);
      _cameraController = cameraController;
    } catch (error) {
      _errorMessage = '$error';
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  CameraDescription _selectCamera(List<CameraDescription> cameras) {
    for (final CameraDescription camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        return camera;
      }
    }
    return cameras.first;
  }

  void _onCameraImage(CameraImage cameraImage) {
    if (!mounted ||
        _faceMeshStreamProcessor == null ||
        _cameraController == null) {
      return;
    }

    if (_isFrameInFlight) {
      return;
    }

    final int? rotationDegrees = _rotationCompensationDegrees(
      controller: _cameraController!,
      description: _cameraDescription!,
    );
    if (rotationDegrees == null) {
      return;
    }

    _cameraImageSize = Size(
      cameraImage.width.toDouble(),
      cameraImage.height.toDouble(),
    );
    _ensureStreamReady(rotationDegrees);

    if (Platform.isAndroid) {
      final FaceMeshNv21Image? image = FaceMeshCameraImageAdapter.toNv21(
        cameraImage,
      );
      final StreamController<FaceMeshNv21Image>? controller =
          _nv21StreamController;
      if (image == null || controller == null || controller.isClosed) {
        return;
      }
      _isFrameInFlight = true;
      controller.add(image);
      return;
    }

    if (Platform.isIOS) {
      final FaceMeshImage? image = FaceMeshCameraImageAdapter.toBgra(
        cameraImage,
      );
      final StreamController<FaceMeshImage>? controller = _bgraStreamController;
      if (image == null || controller == null || controller.isClosed) {
        return;
      }
      _isFrameInFlight = true;
      controller.add(image);
    }
  }

  void _ensureStreamReady(int rotationDegrees) {
    if (_streamRotationDegrees == rotationDegrees &&
        _meshSubscription != null) {
      return;
    }

    _stopMeshStream();
    _streamRotationDegrees = rotationDegrees;

    if (Platform.isAndroid) {
      final StreamController<FaceMeshNv21Image> controller =
          StreamController<FaceMeshNv21Image>();
      _nv21StreamController = controller;
      _meshSubscription = _faceMeshStreamProcessor!
          .processNv21(controller.stream, rotationDegrees: rotationDegrees)
          .listen(_onMeshResult, onError: _onMeshError);
      return;
    }

    if (Platform.isIOS) {
      final StreamController<FaceMeshImage> controller =
          StreamController<FaceMeshImage>();
      _bgraStreamController = controller;
      _meshSubscription = _faceMeshStreamProcessor!
          .process(controller.stream, rotationDegrees: rotationDegrees)
          .listen(_onMeshResult, onError: _onMeshError);
    }
  }

  void _onMeshResult(FaceMeshResult result) {
    _isFrameInFlight = false;
    if (!mounted) {
      return;
    }

    setState(() {
      _meshResult = result;
    });
  }

  void _onMeshError(Object error) {
    _isFrameInFlight = false;
    if (!mounted) {
      return;
    }

    setState(() {
      _errorMessage ??= '$error';
    });
  }

  int? _rotationCompensationDegrees({
    required CameraController controller,
    required CameraDescription description,
  }) {
    final int? deviceRotation =
        _deviceOrientationDegrees[controller.value.deviceOrientation];
    if (deviceRotation == null) {
      return null;
    }

    if (Platform.isAndroid) {
      if (description.lensDirection == CameraLensDirection.front) {
        return (description.sensorOrientation + deviceRotation) % 360;
      }
      return (description.sensorOrientation - deviceRotation + 360) % 360;
    }

    if (Platform.isIOS) {
      return deviceRotation;
    }

    return 0;
  }

  int _displayRotationDegrees(int processingRotation) {
    return (processingRotation + 90) % 360;
  }

  // Returns the image size as it appears on screen (portrait-oriented).
  // The raw Android camera frame is landscape, so width/height must be
  // swapped whenever the processing rotation is 90° or 270°.
  Size? _orientedImageSize(int processingRotation) {
    final Size? raw = _cameraImageSize;
    if (raw == null) return null;
    final bool swapped = processingRotation == 90 || processingRotation == 270;
    return swapped ? Size(raw.height, raw.width) : raw;
  }

  bool get _isFaceDetected {
    return _meshResult != null && _meshResult!.landmarks.isNotEmpty;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _stopMeshStream();
    _faceMeshProcessor?.close();
    super.dispose();
  }

  void _stopMeshStream() {
    _meshSubscription?.cancel();
    _meshSubscription = null;
    _nv21StreamController?.close();
    _nv21StreamController = null;
    _bgraStreamController?.close();
    _bgraStreamController = null;
    _streamRotationDegrees = null;
    _isFrameInFlight = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }

    final CameraController? controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const Scaffold(
        body: Center(child: Text('Camera is not available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CameraPreview(controller),
                  if (_meshResult != null)
                    CustomPaint(
                      painter: FaceMeshOverlayPainter(
                        result: _meshResult!,
                        rotationDegrees: _displayRotationDegrees(
                          _streamRotationDegrees ?? 0,
                        ),
                        lensDirection: controller.description.lensDirection,
                        imageSize: _orientedImageSize(
                          _streamRotationDegrees ?? 0,
                        ),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color:
                            _isFaceDetected
                                ? Colors.green.withValues(alpha: 0.85)
                                : Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          _isFaceDetected ? 'Face detected' : 'No face',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}
