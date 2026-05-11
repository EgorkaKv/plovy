import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

class FaceMeshOverlayPainter extends CustomPainter {
  FaceMeshOverlayPainter({
    required this.result,
    required this.rotationDegrees,
    required this.lensDirection,
    this.imageSize,
    this.strokeColor = Colors.greenAccent,
    this.strokeWidth = 0.45,
  });

  final FaceMeshResult result;
  final int rotationDegrees;
  final CameraLensDirection lensDirection;
  final Size? imageSize;
  final Color strokeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect previewRect = _computePreviewRect(size);
    final Paint paint =
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    for (final MpFaceMeshTriangle triangle in result.triangles) {
      final Offset p0 = _mapToRect(triangle.points[0], previewRect);
      final Offset p1 = _mapToRect(triangle.points[1], previewRect);
      final Offset p2 = _mapToRect(triangle.points[2], previewRect);

      canvas.drawPath(
        Path()
          ..moveTo(p0.dx, p0.dy)
          ..lineTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..close(),
        paint,
      );
    }
  }

  Offset _mapToRect(FaceMeshLandmark landmark, Rect rect) {
    final Offset normalized = result.landmarkAsOffset(
      landmark,
      targetSize: rect.size,
      rotationDegrees: rotationDegrees,
      mirrorHorizontal:
          !Platform.isIOS && lensDirection == CameraLensDirection.front,
    );
    return normalized + rect.topLeft;
  }

  Rect _computePreviewRect(Size canvasSize) {
    final Size? img = imageSize;
    if (img == null) return Offset.zero & canvasSize;

    // imageSize is already orientation-corrected by the caller
    final double imgAspect = img.width / img.height;
    final double canvasAspect = canvasSize.width / canvasSize.height;

    if (imgAspect > canvasAspect) {
      // Image wider than canvas — letterbox top/bottom
      final double h = canvasSize.width / imgAspect;
      return Rect.fromLTWH(
        0,
        (canvasSize.height - h) / 2,
        canvasSize.width,
        h,
      );
    } else {
      // Image taller than canvas — letterbox left/right
      final double w = canvasSize.height * imgAspect;
      return Rect.fromLTWH(
        (canvasSize.width - w) / 2,
        0,
        w,
        canvasSize.height,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FaceMeshOverlayPainter oldDelegate) {
    return oldDelegate.result != result ||
        oldDelegate.rotationDegrees != rotationDegrees ||
        oldDelegate.lensDirection != lensDirection ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
