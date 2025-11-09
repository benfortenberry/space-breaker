import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  
  const AnimatedGradientBackground({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: GradientBackgroundPainter(_controller.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class GradientBackgroundPainter extends CustomPainter {
  final double animationValue;

  GradientBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Create animated gradient colors
    final colors = [
      Color.lerp(
        const Color(0xff1a1a2e),
        const Color(0xff16213e),
        math.sin(animationValue * 2 * math.pi) * 0.5 + 0.5,
      )!,
      Color.lerp(
        const Color(0xff0f3460),
        const Color(0xff533483),
        math.cos(animationValue * 2 * math.pi) * 0.5 + 0.5,
      )!,
      Color.lerp(
        const Color(0xff16213e),
        const Color(0xff1a1a2e),
        math.sin(animationValue * 2 * math.pi + math.pi / 2) * 0.5 + 0.5,
      )!,
    ];

    // Rotating gradient
    final angle = animationValue * 2 * math.pi;
    final gradient = LinearGradient(
      begin: Alignment(math.cos(angle), math.sin(angle)),
      end: Alignment(-math.cos(angle), -math.sin(angle)),
      colors: colors,
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Add floating orbs/circles
    _drawFloatingOrbs(canvas, size);
    
    // Add stars
    _drawStars(canvas, size);
  }

  void _drawFloatingOrbs(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create several large, subtle orbs
    for (int i = 0; i < 5; i++) {
      final seed = i * 137.508;
      final x = size.width * ((math.sin(seed) * 0.5 + 0.5) * 0.8 + 0.1);
      final y = size.height * ((math.cos(seed) * 0.5 + 0.5) * 0.8 + 0.1);
      
      // Animate position
      final offsetX = math.sin(animationValue * 2 * math.pi + seed) * 50;
      final offsetY = math.cos(animationValue * 2 * math.pi + seed * 1.3) * 50;
      
      // Pulsing size
      final pulse = math.sin(animationValue * 2 * math.pi + i) * 0.3 + 0.7;
      final radius = (100 + i * 30) * pulse;

      // Create radial gradient for orb
      final gradient = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.05 * pulse),
          Colors.white.withValues(alpha: 0.02 * pulse),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      paint.shader = gradient.createShader(
        Rect.fromCircle(
          center: Offset(x + offsetX, y + offsetY),
          radius: radius,
        ),
      );

      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        radius,
        paint,
      );
    }
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create many small stars
    for (int i = 0; i < 50; i++) {
      final seed = i * 97.3;
      final x = size.width * ((math.sin(seed * 2.1) * 0.5 + 0.5));
      final y = size.height * ((math.cos(seed * 1.7) * 0.5 + 0.5));
      
      // Twinkle effect
      final twinkle = math.sin(animationValue * 4 * math.pi + seed) * 0.5 + 0.5;
      final starSize = (1.0 + twinkle) * 1.5;
      
      paint.color = Colors.white.withValues(alpha: 0.3 + twinkle * 0.4);
      
      // Draw star as small circle
      canvas.drawCircle(
        Offset(x, y),
        starSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GradientBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
