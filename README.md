# 🎮 Space Breaker

https://space-breaker.netlify.app/

A modern Flutter implementation of the classic Breakout game, inspired by Steve Wozniak's original design. Built with the Flame game engine for cross-platform gaming excitement.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Flame](https://img.shields.io/badge/Flame-FF6B35?style=for-the-badge&logo=flame&logoColor=white)

## 🚀 Features

### 🎯 Core Gameplay
- **Classic Breakout Mechanics**: Paddle, ball, and colorful bricks
- **10 Challenging Levels**: Progressive difficulty with unique configurations
- **Power-ups System**: Extra balls, larger paddle, bonus lives, and more
- **Lives System**: Start with 3 lives, earn more through gameplay
- **High Score Persistence**: Your best scores are saved locally

### 🎨 Visual Design
- **Animated Gradient Background**: Dynamic, colorful backdrop
- **10 Beautiful Brick Colors**: Hand-picked hex color palette
- **Smooth Animations**: Flutter Animate integration for polish
- **Responsive Design**: Scales beautifully across devices

### 🎵 Audio Experience
- **Background Music**: Atmospheric soundtrack
- **Sound Effects**: Authentic arcade-style audio feedback
- **Audio Controls**: Toggle music and effects independently

### 🎮 Controls
- **Desktop**: Arrow keys or A/D keys for paddle movement
- **Mobile**: Touch and drag the paddle
- **Universal**: Tap to start, pause, and resume

### 🔧 Power-ups
- **🏓 Larger Paddle**: Easier ball catching
- **⚡ Extra Balls**: Multi-ball chaos mode  
- **❤️ Extra Life**: Bonus chances to continue
- **💰 Bonus Points**: Score multipliers

## 🛠️ Technical Stack

- **Framework**: Flutter 3.8.0+
- **Game Engine**: Flame 1.28.1
- **Audio**: Audioplayers & Flame Audio
- **Fonts**: Google Fonts (Press Start 2P)
- **Storage**: SharedPreferences for high scores
- **Animation**: Flutter Animate

## 🏗️ Architecture

```
lib/
├── main.dart                    # App entry point
├── src/
│   ├── space_breaker.dart      # Main game class
│   ├── config.dart             # Game configuration & constants
│   ├── components/             # Game objects (Ball, Paddle, Brick)
│   ├── config/                 # Power-up configurations
│   ├── services/               # Audio & high score services
│   └── widgets/                # UI overlays & HUD
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.0 or higher
- Dart SDK
- iOS Simulator / Android Emulator (for mobile)
- macOS (for desktop builds)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/benfortenberry/flutter-breakout.git
   cd flutter-breakout/space_breaker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run on your preferred platform**
   
   **Mobile (iOS/Android):**
   ```bash
   flutter run
   ```
   
   **Desktop (macOS):**
   ```bash
   flutter run -d macos
   ```
   
   **Web:**
   ```bash
   flutter run -d chrome
   ```

## 🎮 How to Play

1. **Start**: Tap anywhere to begin
2. **Move Paddle**: Use arrow keys, A/D keys, or touch controls
3. **Break Bricks**: Bounce the ball to destroy all bricks
4. **Collect Power-ups**: Catch falling power-ups for bonuses
5. **Survive**: Don't let the ball fall off the bottom
6. **Progress**: Complete all 10 levels to win!

## 🎯 Game Mechanics

### Level Progression
- **Levels 1-10**: Increasing difficulty
- **More Bricks**: Each level adds more rows
- **Faster Ball**: Speed increases with each level  
- **Smaller Paddle**: Paddle shrinks on higher levels
- **Color Variety**: More brick colors unlock progressively

### Scoring System
- **Brick Destruction**: +1 point per brick
- **Power-up Collection**: +100 points
- **Level Completion**: Bonus points
- **High Score**: Automatically saved

### Power-up Types
- **🏓 Large Paddle**: Temporary paddle size increase
- **⚡ Multi-ball**: Spawns additional balls
- **❤️ Extra Life**: Adds one life (max 5)
- **💰 Coin Bonus**: Instant score boost

## 🔧 Development

### Debug Controls (Development Mode)
- **P / ESC**: Pause/Resume game
- **W**: Win current level
- **L**: Lose a life  
- **G**: Trigger game over
- **R**: Reset high score

### Building for Production

**iOS App Store:**
```bash
flutter build ios --release
```

**Android Play Store:**
```bash
flutter build appbundle --release
```

**macOS Desktop:**
```bash
flutter build macos --release
```

**Web Deployment:**
```bash
flutter build web --release
```

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| iOS | ✅ | iPhone & iPad optimized |
| Android | ✅ | Material Design integration |
| macOS | ✅ | Native desktop experience |
| Web | ✅ | Progressive Web App ready |
| Windows | 🔄 | Coming soon |
| Linux | 🔄 | Coming soon |

## 🎨 Assets & Design

### Color Palette
The game features a carefully curated 10-color brick palette:
- **#f94144** - Vibrant Red
- **#f3722c** - Orange-Red  
- **#f8961e** - Pure Orange
- **#f9844a** - Light Orange
- **#f9c74f** - Golden Yellow
- **#90be6d** - Fresh Green
- **#43aa8b** - Teal
- **#4d908e** - Blue-Green
- **#277da1** - Ocean Blue
- **#577590** - Slate Blue

### Custom App Icon
Automatically generated for all platforms using `flutter_launcher_icons`.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

### Development Setup
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Steve Wozniak**: Original Breakout creator
- **Flame Community**: Excellent Flutter game engine
- **Flutter Team**: Amazing cross-platform framework
- **Google Fonts**: Press Start 2P retro gaming font

## 🎯 Roadmap

- [ ] Windows & Linux desktop support
- [ ] Online leaderboards
- [ ] Custom level editor
- [ ] Tournament mode
- [ ] Achievement system
- [ ] Particle effects enhancement
- [ ] Controller support

---

**Built with ❤️ using Flutter & Flame**

*Relive the classic arcade experience on any device!*
