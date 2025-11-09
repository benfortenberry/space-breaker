import 'package:flutter/material.dart'; 

const gameWidth = 820.0;
const gameHeight = 1600.0;
const ballRadius = gameWidth * .02; 
const batWidth = gameWidth * 0.2;                              
const batHeight = ballRadius * 2;
const batStep = gameWidth * 0.02;  // Increased from 0.05 for faster bat movement
  
                       

const brickColors = [                                           
  Color(0xfff94144),
  Color(0xfff3722c),
  Color(0xfff8961e),
  Color(0xfff9844a),
  Color(0xfff9c74f),
  Color(0xff90be6d),
  Color(0xff43aa8b),
  Color(0xff4d908e),
  Color(0xff277da1),
  Color(0xff577590),
];

const brickGutter = gameWidth * 0.015;                         
final brickWidth =
    (gameWidth - (brickGutter * (brickColors.length + 1))) / brickColors.length;
const brickHeight = gameHeight * 0.03;
const difficultyModifier = 1.33;
const initialLives = 3;

// Level progression constants
const int maxLevel = 10;
const double levelSpeedMultiplier = 0.1; // Speed increase per level
const double baseBallSpeed = 200.0;

// Level configurations
const Map<int, LevelConfig> levelConfigs = {
  1: LevelConfig(rows: 3, startColor: 0, endColor: 2, ballSpeedFactor: 1.5, batSizeFactor: 1.0),
  2: LevelConfig(rows: 4, startColor: 0, endColor: 3, ballSpeedFactor: 1.6, batSizeFactor: 1.0),
  3: LevelConfig(rows: 5, startColor: 0, endColor: 4, ballSpeedFactor: 1.7, batSizeFactor: 0.9),
  4: LevelConfig(rows: 6, startColor: 0, endColor: 5, ballSpeedFactor: 1.8, batSizeFactor: 0.9),
  5: LevelConfig(rows: 7, startColor: 0, endColor: 6, ballSpeedFactor: 1.9, batSizeFactor: 0.8),
  6: LevelConfig(rows: 8, startColor: 0, endColor: 7, ballSpeedFactor: 2.0, batSizeFactor: 0.8),
  7: LevelConfig(rows: 9, startColor: 0, endColor: 8, ballSpeedFactor: 2.1, batSizeFactor: 0.7),
  8: LevelConfig(rows: 10, startColor: 0, endColor: 9, ballSpeedFactor: 2.2, batSizeFactor: 0.7),
  9: LevelConfig(rows: 11, startColor: 0, endColor: 9, ballSpeedFactor: 2.3, batSizeFactor: 0.6),
  10: LevelConfig(rows: 12, startColor: 0, endColor: 9, ballSpeedFactor: 2.4, batSizeFactor: 0.6),
};

class LevelConfig {
  const LevelConfig({
    required this.rows,
    required this.startColor,
    required this.endColor,
    required this.ballSpeedFactor,
    required this.batSizeFactor,
  });

  final int rows;
  final int startColor;
  final int endColor;
  final double ballSpeedFactor;
  final double batSizeFactor;
}   