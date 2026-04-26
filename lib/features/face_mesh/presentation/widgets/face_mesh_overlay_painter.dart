import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

class FaceMeshOverlayPainter extends CustomPainter {
  FaceMeshOverlayPainter({
    required this.result,
    required this.rotationDegrees,
    required this.lensDirection,
    this.strokeColor = Colors.greenAccent,
    this.strokeWidth = 0.45,
  });

  final FaceMeshResult result;
  final int rotationDegrees;
  final CameraLensDirection lensDirection;
  final Color strokeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    for (final MpFaceMeshTriangle triangle in result.triangles) {
      final Offset p0 = _map(triangle.points[0], size);
      final Offset p1 = _map(triangle.points[1], size);
      final Offset p2 = _map(triangle.points[2], size);

      final Path path =
          Path()
            ..moveTo(p0.dx, p0.dy)
            ..lineTo(p1.dx, p1.dy)
            ..lineTo(p2.dx, p2.dy)
            ..close();

      canvas.drawPath(path, paint);
    }
  }

  Offset _map(FaceMeshLandmark landmark, Size size) {
    return result.landmarkAsOffset(
      landmark,
      targetSize: size,
      rotationDegrees: rotationDegrees,
      mirrorHorizontal:
          !Platform.isIOS && lensDirection == CameraLensDirection.front,
    );
  }

  @override
  bool shouldRepaint(covariant FaceMeshOverlayPainter oldDelegate) {
    return oldDelegate.result != result ||
        oldDelegate.rotationDegrees != rotationDegrees ||
        oldDelegate.lensDirection != lensDirection ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
