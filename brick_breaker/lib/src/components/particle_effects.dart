import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class ParticleEffects {
  static final math.Random _random = math.Random();

  /// Creates explosion particles when a brick is destroyed
  static ParticleSystemComponent brickExplosion({
    required Vector2 position,
    required Color brickColor,
    int particleCount = 15,
  }) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: particleCount,
        lifespan: 1.2,
        generator: (i) {
          final direction = Vector2(
            _random.nextDouble() * 2 - 1,  // -1 to 1
            _random.nextDouble() * 2 - 1,  // -1 to 1
          ).normalized();
          
          final speed = 50 + _random.nextDouble() * 100; // 50-150 pixels/sec
          
          return MovingParticle(
            from: position.clone(),
            to: position + direction * speed,
            child: ComputedParticle(
              renderer: (canvas, particle) {
                // Fade from brick color to transparent
                final alpha = (1.0 - particle.progress).clamp(0.0, 1.0);
                final color = brickColor.withOpacity(alpha);
                
                // Shrink particle over time
                final size = (1.0 - particle.progress * 0.7) * 4.0;
                
                canvas.drawCircle(
                  Offset.zero,
                  size,
                  Paint()..color = color,
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Creates sparkle effect for ball hitting objects
  static ParticleSystemComponent ballImpact({
    required Vector2 position,
    Color color = Colors.white,
    int particleCount = 8,
  }) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: particleCount,
        lifespan: 0.6,
        generator: (i) {
          final angle = (i / particleCount) * 2 * math.pi;
          final direction = Vector2(math.cos(angle), math.sin(angle));
          final speed = 30 + _random.nextDouble() * 40;
          
          return MovingParticle(
            from: position.clone(),
            to: position + direction * speed,
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final alpha = (1.0 - particle.progress).clamp(0.0, 1.0);
                final sparkleColor = color.withOpacity(alpha);
                final size = (1.0 - particle.progress * 0.5) * 3.0;
                
                canvas.drawCircle(
                  Offset.zero,
                  size,
                  Paint()..color = sparkleColor,
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Creates a trail effect behind the ball
  static ParticleSystemComponent ballTrail({
    required Vector2 position,
    Color color = const Color(0xFFFFE082),
  }) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 3,
        lifespan: 0.4,
        generator: (i) {
          final offset = Vector2(
            (_random.nextDouble() - 0.5) * 10,
            (_random.nextDouble() - 0.5) * 10,
          );
          
          return MovingParticle(
            from: position + offset,
            to: position + offset,
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final alpha = (1.0 - particle.progress).clamp(0.0, 1.0) * 0.6;
                final trailColor = color.withOpacity(alpha);
                final size = (1.0 - particle.progress) * 2.5;
                
                canvas.drawCircle(
                  Offset.zero,
                  size,
                  Paint()..color = trailColor,
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Creates a celebration effect when player wins
  static ParticleSystemComponent celebration({
    required Vector2 position,
    required Vector2 gameSize,
  }) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 100, // More particles for bigger explosion
        lifespan: 2.5,
        generator: (i) {
          final colors = [
            const Color(0xFFFFD700), // Gold
            const Color(0xFFFF6B35), // Orange-red
            const Color(0xFFFF1744), // Bright red
            const Color(0xFFE91E63), // Pink
            const Color(0xFF9C27B0), // Purple
            const Color(0xFF673AB7), // Deep purple
            const Color(0xFF2196F3), // Blue
            const Color(0xFF00BCD4), // Cyan
            const Color(0xFF4CAF50), // Green
            const Color(0xFFFFEB3B), // Yellow
          ];
          
          final color = colors[_random.nextInt(colors.length)];
          
          // Explode outward from center
          final angle = _random.nextDouble() * 2 * math.pi;
          final speed = 100 + _random.nextDouble() * 300; // Faster, more dramatic
          final direction = Vector2(math.cos(angle), math.sin(angle));
          
          return MovingParticle(
            from: position.clone(),
            to: position + direction * speed,
            child: ComputedParticle(
              renderer: (canvas, particle) {
                // Bright at start, fade out
                final alpha = (1.0 - particle.progress).clamp(0.0, 1.0);
                final particleColor = color.withOpacity(alpha);
                
                // Start large, shrink over time
                final baseSize = 6.0 + _random.nextDouble() * 8.0;
                final size = baseSize * (1.0 - particle.progress * 0.7);
                
                // Add glow effect
                canvas.drawCircle(
                  Offset.zero,
                  size * 1.5,
                  Paint()..color = particleColor.withOpacity(alpha * 0.3),
                );
                
                canvas.drawCircle(
                  Offset.zero,
                  size,
                  Paint()..color = particleColor,
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Creates power-up collection effect (for future use)
  static ParticleSystemComponent powerUpCollection({
    required Vector2 position,
    Color color = Colors.cyan,
  }) {
    return ParticleSystemComponent(
      particle: Particle.generate(
        count: 12,
        lifespan: 1.0,
        generator: (i) {
          final angle = (i / 12) * 2 * math.pi;
          final radius = 30.0;
          final targetPos = position + Vector2(
            math.cos(angle) * radius,
            math.sin(angle) * radius,
          );
          
          return MovingParticle(
            from: targetPos,
            to: position.clone(),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final alpha = (1.0 - particle.progress).clamp(0.0, 1.0);
                final glowColor = color.withOpacity(alpha);
                final size = 4.0 * (1.0 - particle.progress * 0.5);
                
                canvas.drawCircle(
                  Offset.zero,
                  size,
                  Paint()..color = glowColor,
                );
              },
            ),
          );
        },
      ),
    );
  }
}