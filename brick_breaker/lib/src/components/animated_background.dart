import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../brick_breaker.dart';

class AnimatedBackground extends Component with HasGameReference<BrickBreaker> {
  AnimatedBackground() : super(priority: -100); // Render behind everything

  double _time = 0.0;
  
  // Background gradient colors that will animate
  final List<Color> _gradientColors = [
    const Color(0xff1a1a2e),
    const Color(0xff16213e),
    const Color(0xff0f3460),
    const Color(0xff533483),
  ];

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt * 0.3; // Speed of animation (lower = slower)
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Calculate animated color positions
    final t = (_time % 4.0) / 4.0; // Loop every 4 seconds
    
    // Interpolate between colors
    final colorIndex = (t * _gradientColors.length).floor();
    final nextColorIndex = (colorIndex + 1) % _gradientColors.length;
    final colorT = (t * _gradientColors.length) - colorIndex;
    
    final color1 = Color.lerp(
      _gradientColors[colorIndex],
      _gradientColors[nextColorIndex],
      colorT,
    )!;
    
    final color2Index = (colorIndex + 2) % _gradientColors.length;
    final color2NextIndex = (color2Index + 1) % _gradientColors.length;
    final color2 = Color.lerp(
      _gradientColors[color2Index],
      _gradientColors[color2NextIndex],
      colorT,
    )!;

    // Create animated gradient
    final rect = Rect.fromLTWH(0, 0, game.width, game.height);
    
    // Add some movement to the gradient angle
    final angle = math.sin(_time * 0.5) * 0.3 + math.pi / 4;
    
    final gradient = LinearGradient(
      begin: Alignment(math.cos(angle), math.sin(angle)),
      end: Alignment(-math.cos(angle), -math.sin(angle)),
      colors: [color1, color2],
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    
    canvas.drawRect(rect, paint);
    
    // Add subtle moving particles/stars
    _renderStars(canvas);
  }

  void _renderStars(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Create 20 animated stars
    for (int i = 0; i < 20; i++) {
      final seed = i * 137.508; // Golden angle for distribution
      final x = (seed % game.width);
      final y = ((seed * 2.5) % game.height);
      
      // Pulsing effect
      final pulse = math.sin(_time * 2 + i * 0.5) * 0.5 + 0.5;
      final size = (1.0 + pulse) * 2.0;
      
      // Slight movement
      final offsetX = math.sin(_time * 0.3 + i) * 10;
      final offsetY = math.cos(_time * 0.4 + i) * 10;
      
      canvas.drawCircle(
        Offset(x + offsetX, y + offsetY),
        size,
        paint..color = Colors.white.withOpacity(0.2 + pulse * 0.3),
      );
    }
  }
}
