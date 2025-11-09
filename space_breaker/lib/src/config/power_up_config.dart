import 'package:flutter/material.dart';

enum PowerUpType {
  widerBat,
  multiBall,
  // slowerBall,
  extraLife,
}

class PowerUpConfig {
  final PowerUpType type;
  final String name;
  final IconData icon;
  final Color iconColor;
  final double duration; // Duration in seconds (0 for instant effects)
  
  const PowerUpConfig({
    required this.type,
    required this.name,
    required this.icon,
    required this.iconColor,
    this.duration = 10.0,
  });
}

const Map<PowerUpType, PowerUpConfig> powerUpConfigs = {
  PowerUpType.widerBat: PowerUpConfig(
    type: PowerUpType.widerBat,
    name: 'Wide Bat',
    icon: Icons.bolt,
    iconColor: Colors.cyanAccent,
    duration: 10.0,
  ),
  PowerUpType.multiBall: PowerUpConfig(
    type: PowerUpType.multiBall,
    name: 'Multi Ball',
    icon: Icons.star,
    iconColor: Colors.yellow,
    duration: 0, // Instant effect
  ),
  // PowerUpType.slowerBall: PowerUpConfig(
  //   type: PowerUpType.slowerBall,
  //   name: 'Slow Motion',
  //   icon: Icons.speed,
  //   iconColor: Colors.green,
  //   duration: 8.0,
  // ),
  PowerUpType.extraLife: PowerUpConfig(
    type: PowerUpType.extraLife,
    name: 'Extra Life',
    icon: Icons.favorite,
    iconColor: Colors.red,
    duration: 0, // Instant effect
  ),
};
