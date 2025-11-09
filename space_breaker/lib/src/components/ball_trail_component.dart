import 'dart:async';
import 'package:flame/components.dart';
import '../space_breaker.dart';
import 'ball.dart';
import 'particle_effects.dart';

class BallTrailComponent extends Component 
    with HasGameReference<BrickBreaker> {
  
  Timer? _trailTimer;
  late final Ball _ball;
  
  BallTrailComponent(this._ball);

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    
    // Create trail particles every 0.1 seconds when ball is moving
    _trailTimer = Timer(
      0.08, // Trail frequency
      repeat: true,
      onTick: _createTrailParticle,
    );
  }

  void _createTrailParticle() {
    // Only create trail particles if ball is moving at reasonable speed
    if (_ball.velocity.length > 50) {
      game.world.add(
        ParticleEffects.ballTrail(
          position: _ball.position.clone(),
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _trailTimer?.update(dt);
  }

  @override
  void onRemove() {
    _trailTimer?.stop();
    super.onRemove();
  }
}